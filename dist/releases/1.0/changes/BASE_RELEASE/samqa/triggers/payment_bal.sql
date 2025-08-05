-- liquibase formatted sql
-- changeset SAMQA:1754374166012 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\payment_bal.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/payment_bal.sql:null:769b2e816aa7555a562f8c247807deb64119eed4:create

create or replace editionable trigger samqa.payment_bal after
    insert or update or delete on samqa.payment
    for each row
declare
    l_reason_mode    varchar2(30);
    l_fee_bucket_bal number;
begin
/* Mark account changed, for calc balance
  08.01.2006 mal  creation
 */
  
/* L_reason_mode := null;
 IF :NEW.REASON_CODE IN (1,2) 
 AND pc_account.fee_bucket_balance(:NEW.ACC_ID) >= :NEW.AMOUNT THEN
     L_reason_mode := 'FP';
 ELSE
     L_reason_mode := 'P';
 END IF;*/

    if :new.reason_mode = 'FP' then
        for x in (
            select
                a.employer_deposit_id,
                fee_bucket_balance
            from
                employer_deposits a,
                person            b,
                account           c
            where
                    c.acc_id = :new.acc_id
                and a.entrp_id = b.entrp_id
                and b.pers_id = c.pers_id
                and fee_bucket_balance > 0
            order by
                fee_bucket_balance asc
        ) loop
            l_fee_bucket_bal := x.fee_bucket_balance - ( :new.amount - nvl(l_fee_bucket_bal, 0) );

            if l_fee_bucket_bal >= 0 then
                update employer_deposits
                set
                    fee_bucket_balance = fee_bucket_balance - :new.amount
                where
                    employer_deposit_id = x.employer_deposit_id;

            else
                update employer_deposits
                set
                    fee_bucket_balance = 0
                where
                    employer_deposit_id = x.employer_deposit_id;

            end if;

        end loop;
    end if;

    if inserting then
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
                   :new.pay_date,
                   :new.reason_code,
                   :new.note,
                   - :new.amount,
                   :new.reason_mode,
                   :new.change_num,
                   :new.plan_type );

    elsif updating then
        update balance_register
        set
            amount = - :new.amount,
            reason_code = :new.reason_code,
            note = :new.note,
            plan_type = :new.plan_type
        where
                change_id = :new.change_num
            and acc_id = :new.acc_id;

        update broker_commission_register
        set
            amount = :new.amount,
            reason_code = :new.reason_code
        where
                change_num = :new.change_num
            and acc_id = :new.acc_id;

        if :new.pay_date <> :old.pay_date then
            update balance_register
            set
                fee_date = :new.pay_date,
                plan_type = :new.plan_type
            where
                    change_id = :new.change_num
                and acc_id = :new.acc_id;

        end if;

    elsif deleting then
        delete from balance_register
        where
                change_id = :old.change_num
            and acc_id = :old.acc_id;
  -- DELETE FROM BROKER_COMMISSION_REGISTER
  --  WHERE  change_num  = :OLD.CHANGE_NUM
  --  AND   acc_id       = :OLD.acc_id;

    end if;

end payment_bal;
/

alter trigger samqa.payment_bal enable;

