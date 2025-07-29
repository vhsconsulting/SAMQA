create or replace editionable trigger samqa.income_bal after
    insert or update or delete on samqa.income
    for each row
declare
    l_posted_balance     number := 0;
    l_old_posted_balance number := 0;
    l_remaining_balance  number := 0;
    l_reason_mode        varchar2(1);
    l_fee_code           number;
    l_reg_id             number;
    l_exists_flag        varchar2(1) := 'N';
    l_deposit_exist      varchar2(1) := 'N';
    l_account_type       varchar2(10);
begin
/* Mark account changed, for calc balance
  08.01.2006 mal  creation
 */
    l_account_type := pc_account.get_account_type(:new.acc_id);
    if ( nvl(:new.fee_code,
             -1) <> 12
    or (
        l_account_type = 'COBRA'
        and nvl(:new.fee_code,
                -1) <> 4
    ) ) then -- dont insert into balance register for annual election

        if inserting then
            if :new.transaction_type = 'P' then
                l_reason_mode := 'E';
                l_fee_code := 110;
            else
                l_reason_mode := 'I';
                l_fee_code := :new.fee_code;
            end if;

            insert into balance_register (
                register_id,
                acc_id,
                fee_date,
                reason_code,
                note,
                amount,
                reason_mode,
                change_id,
                plan_type
            ) values ( balance_register_seq.nextval,
                       :new.acc_id,
                       :new.fee_date,
                       l_fee_code,
                       :new.note,
                       nvl(:new.amount,
                           0) + nvl(:new.amount_add,
                                    0),
                       l_reason_mode,
                       :new.change_num,
                       case
                           when l_account_type <> 'COBRA' then
                               :new.plan_type
                           else
                               null
                       end
            );

            if nvl(:new.ee_fee_amount,
                   0) + nvl(:new.er_fee_amount,
                            0) <> 0 then
                insert into balance_register (
                    register_id,
                    acc_id,
                    fee_date,
                    reason_code,
                    note,
                    amount,
                    reason_mode,
                    change_id,
                    plan_type
                ) values ( balance_register_seq.nextval,
                           :new.acc_id,
                           :new.fee_date,
                           l_fee_code,
                           :new.note,
                           nvl(:new.ee_fee_amount,
                               0) + nvl(:new.er_fee_amount,
                                        0),
                           'F',
                           :new.change_num,
                           case
                               when l_account_type <> 'COBRA' then
                                   :new.plan_type
                               else
                                   null
                           end
                );

            end if;

        elsif updating then
            if :new.transaction_type = 'P' then
                l_reason_mode := 'E';
                l_fee_code := 110;
            else
                l_reason_mode := 'I';
                l_fee_code := :new.fee_code;
            end if;

            update balance_register
            set
                amount = nvl(:new.amount,
                             0) + nvl(:new.amount_add,
                                      0),
                reason_code = l_fee_code,
                reason_mode = l_reason_mode,
                note = :new.note,
                fee_date = :new.fee_date,
                plan_type =
                    case
                        when l_account_type <> 'COBRA' then
                            :new.plan_type
                        else
                            null
                    end
            where
                    change_id = :new.change_num
                and acc_id = :new.acc_id
                and reason_mode <> 'F';

            for x in (
                select
                    1
                from
                    balance_register
                where
                        change_id = :new.change_num
                    and reason_mode = 'F'
            ) loop
                l_exists_flag := 'Y';
            end loop;

            if l_exists_flag = 'Y' then
                update balance_register
                set
                    amount = nvl(:new.er_fee_amount,
                                 0) + nvl(:new.ee_fee_amount,
                                          0),
                    reason_code = :new.fee_code,
                    note = :new.note,
                    fee_date = :new.fee_date,
                    plan_type =
                        case
                            when l_account_type <> 'COBRA' then
                                :new.plan_type
                            else
                                null
                        end
                where
                        change_id = :new.change_num
                    and reason_mode = 'F';

            end if;

            if
                l_exists_flag = 'N'
                and nvl(:new.ee_fee_amount,
                        0) + nvl(:new.er_fee_amount,
                                 0) <> 0
            then
                insert into balance_register (
                    register_id,
                    acc_id,
                    fee_date,
                    reason_code,
                    note,
                    amount,
                    reason_mode,
                    change_id,
                    plan_type
                ) values ( balance_register_seq.nextval,
                           :new.acc_id,
                           :new.fee_date,
                           :new.fee_code,
                           :new.note,
                           nvl(:new.ee_fee_amount,
                               0) + nvl(:new.er_fee_amount,
                                        0),
                           'F',
                           :new.change_num,
                           case
                               when l_account_type <> 'COBRA' then
                                   :new.plan_type
                               else
                                   null
                           end
                );

            end if;

        elsif deleting then
            delete from balance_register
            where
                    change_id = :old.change_num
                and acc_id = :old.acc_id;

        end if;

        if l_account_type = 'HSA' then
            if
                :new.fee_code <> 8
                and :new.contributor is null
                and :new.list_bill is null
            then
                if inserting
                or updating then
                    for x in (
                        select
                            deposit_register_id
                        from
                            deposit_register b
                        where
                            b.orig_sys_ref = :new.change_num
                    ) loop
                        update deposit_register
                        set
                            posted_flag = 'Y',
                            reconciled_flag = decode(check_amount,
                                                     nvl(:new.amount,
                                                         0) + nvl(:new.amount_add,
                                                                  0) + nvl(:new.ee_fee_amount,
                                                                           0) + nvl(:new.er_fee_amount,
                                                                                    0),
                                                     'Y',
                                                     'N'),
                            last_updated_by = get_user_id(v('APP_USER')),
                            last_update_date = sysdate
                        where
                            deposit_register_id = x.deposit_register_id;

                        l_deposit_exist := 'Y';
                    end loop;

                    if l_deposit_exist = 'N' then
                        insert into deposit_register (
                            deposit_register_id,
                            first_name,
                            last_name,
                            acc_num,
                            acc_id,
                            check_number,
                            check_amount,
                            trans_date,
                            posted_flag,
                            reconciled_flag,
                            list_bill,
                            orig_sys_ref,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date
                        )
                            select
                                deposit_register_seq.nextval,
                                x.first_name       -- FIRST_NAME
                                ,
                                x.last_name        -- LAST_NAME
                                ,
                                a.acc_num          -- ACC_NUM
                                ,
                                a.acc_id           -- ACC_ID
                                ,
                                :new.cc_number     -- CHECK_NUMBER
                                ,
                                nvl(:new.amount,
                                    0) + nvl(:new.amount_add,
                                             0) + nvl(:new.ee_fee_amount,
                                                      0) + nvl(:new.er_fee_amount,
                                                               0)     -- CHECK_AMOUNT
                                                               ,
                                to_char(:new.fee_date,
                                        'MM/DD/YYYY')       -- TRANS_DATE
                                        ,
                                'Y',
                                'Y',
                                :new.list_bill,
                                :new.change_num,
                                get_user_id(v('APP_USER'))         -- CREATED_BY
                                ,
                                sysdate           -- CREATION_DATE
                                ,
                                get_user_id(v('APP_USER'))         -- LAST_UPDATED_BY
                                ,
                                sysdate        -- LAST_UPDATE_DATE); 
                            from
                                account a,
                                person  x
                            where
                                    a.acc_id = :new.acc_id
                                and a.pers_id = x.pers_id;

                    end if;

                end if;

                if deleting then
                    update deposit_register
                    set
                        reconciled_flag = decode(check_amount,
                                                 nvl(:old.amount,
                                                     0) + nvl(:old.amount_add,
                                                              0) + nvl(:old.ee_fee_amount,
                                                                       0) + nvl(:old.er_fee_amount,
                                                                                0),
                                                 'Y',
                                                 'N'),
                        last_updated_by = get_user_id(v('APP_USER')),
                        last_update_date = sysdate
                    where
                        orig_sys_ref = :new.change_num;

                end if;

            end if;

        end if;

    end if;

exception
    when others then
        raise;
end income_bal;
/

alter trigger samqa.income_bal enable;


-- sqlcl_snapshot {"hash":"cf136845bde12ad7da6bfcffc66461f236d5b0da","type":"TRIGGER","name":"INCOME_BAL","schemaName":"SAMQA","sxml":""}