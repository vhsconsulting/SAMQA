-- liquibase formatted sql
-- changeset SAMQA:1754374144264 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\insert_rate_plan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/insert_rate_plan.sql:null:b0d9f2f2953dd65b2e38b19e760c20ec700ce272:create

create or replace procedure samqa.insert_rate_plan as
    l_rate_plan_id number;
    l_trn_combo    number := 0;
    l_fsa_combo    number := 0;
begin
    for x in (
        select
            b.acc_id,
            a.entrp_id,
            a.name,
            b.start_date,
            b.account_type,
            (
                select
                    sum(pc_person.count_debit_card(pers_id))
                from
                    person
                where
                    entrp_id = a.entrp_id
            ) no_of_cards
        from
            enterprise a,
            account    b
        where
                a.entrp_id = b.entrp_id
            and b.account_type in ( 'HRA', 'FSA' )
            and not exists (
                select
                    *
                from
                    rate_plans
                where
                    entity_id = a.entrp_id
            )
    ) loop
        l_rate_plan_id := rate_plans_seq.nextval;
        insert into rate_plans (
            rate_plan_id,
            rate_plan_name,
            entity_type,
            entity_id,
            status,
            note,
            effective_date,
            effective_end_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            rate_plan_type,
            sales_team_member_id
        ) values ( l_rate_plan_id,
                   x.name,
                   'EMPLOYER',
                   x.entrp_id,
                   'A',
                   null,
                   x.start_date,
                   null,
                   sysdate,
                   4,
                   sysdate,
                   4,
                   'INVOICE',
                   null );

        l_trn_combo := 0;
        l_fsa_combo := 0;
        if
            x.no_of_cards > 0
            and x.account_type = 'FSA'
        then
        -- card issuance
            insert into rate_plan_detail (
                rate_plan_detail_id,
                rate_plan_id,
                calculation_type,
                rate_code,
                rate_plan_cost,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                rate_basis,
                effective_date,
                effective_end_date,
                one_time_flag
            ) values ( rate_plan_detail_seq.nextval,
                       l_rate_plan_id,
                       'AMOUNT',
                       '16',
                       5,
                       sysdate,
                       0,
                       sysdate,
                       0,
                       'ACTIVE',
                       x.start_date,
                       null,
                       'N' );
        -- card txn fee
            insert into rate_plan_detail (
                rate_plan_detail_id,
                rate_plan_id,
                calculation_type,
                rate_code,
                rate_plan_cost,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                rate_basis,
                effective_date,
                effective_end_date,
                one_time_flag
            ) values ( rate_plan_detail_seq.nextval,
                       l_rate_plan_id,
                       'AMOUNT',
                       '17',
                       1,
                       sysdate,
                       0,
                       sysdate,
                       0,
                       'ACTIVE',
                       x.start_date,
                       null,
                       'N' );
        -- Lost Card -Replacement
            insert into rate_plan_detail (
                rate_plan_detail_id,
                rate_plan_id,
                calculation_type,
                rate_code,
                rate_plan_cost,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                rate_basis,
                effective_date,
                effective_end_date,
                one_time_flag
            ) values ( rate_plan_detail_seq.nextval,
                       l_rate_plan_id,
                       'AMOUNT',
                       '4',
                       10,
                       sysdate,
                       0,
                       sysdate,
                       0,
                       'ACTIVE',
                       x.start_date,
                       null,
                       'N' );

        end if;

        for xx in (
            select
                a.plan_type,
                reason_code,
                runout_period_days,
                case
                    when a.plan_type in ( 'TRN', 'PKG' ) then
                        3.25
                    else
                        5
                end rate_plan_cost
            from
                ben_plan_enrollment_setup a,
                pay_reason
            where
                    acc_id = x.acc_id
                and pay_reason.plan_type = case
                                               when a.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' ) then
                                                   'HRA'
                                               else
                                                   a.plan_type
                                           end
                and pay_reason.plan_type is not null
                and plan_end_date > sysdate
                and plan_start_date < sysdate
        ) loop
            insert into rate_plan_detail (
                rate_plan_detail_id,
                rate_plan_id,
                calculation_type,
                rate_code,
                rate_plan_cost,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                rate_basis,
                effective_date,
                effective_end_date,
                one_time_flag
            ) values ( rate_plan_detail_seq.nextval,
                       l_rate_plan_id,
                       'AMOUNT',
                       xx.reason_code,
                       xx.rate_plan_cost,
                       sysdate,
                       0,
                       sysdate,
                       0,
                       'ACTIVE',
                       x.start_date,
                       null,
                       'N' );

            if xx.runout_period_days > 0 then
                l_fsa_combo := l_fsa_combo + 1;
                insert into rate_plan_detail (
                    rate_plan_detail_id,
                    rate_plan_id,
                    calculation_type,
                    rate_code,
                    rate_plan_cost,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    rate_basis,
                    effective_date,
                    effective_end_date,
                    one_time_flag
                ) values ( rate_plan_detail_seq.nextval,
                           l_rate_plan_id,
                           'AMOUNT',
                           xx.reason_code,
                           xx.rate_plan_cost,
                           sysdate,
                           0,
                           sysdate,
                           0,
                           'RUNOUT',
                           x.start_date,
                           null,
                           'N' );

            end if;

            if x.account_type = 'FSA' then
                if xx.plan_type not in ( 'TRN', 'PKG' ) then
                    l_fsa_combo := l_fsa_combo + 1;
                else
                    l_trn_combo := l_trn_combo + 1;
                    l_fsa_combo := l_fsa_combo + 1;
                end if;
            end if;

        end loop;

        select
            count(*)
        into l_fsa_combo
        from
            ben_plan_enrollment_setup
        where
                acc_id = x.acc_id
            and plan_type in ( 'FSA', 'LPF', 'IIR' );

        if l_fsa_combo > 0 then
            insert into rate_plan_detail (
                rate_plan_detail_id,
                rate_plan_id,
                calculation_type,
                rate_code,
                rate_plan_cost,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                rate_basis,
                effective_date,
                effective_end_date,
                one_time_flag
            ) values ( rate_plan_detail_seq.nextval,
                       l_rate_plan_id,
                       'AMOUNT',
                       31,
                       5,
                       sysdate,
                       0,
                       sysdate,
                       0,
                       'ACTIVE',
                       x.start_date,
                       null,
                       'N' );

            insert into rate_plan_detail (
                rate_plan_detail_id,
                rate_plan_id,
                calculation_type,
                rate_code,
                rate_plan_cost,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                rate_basis,
                effective_date,
                effective_end_date,
                one_time_flag
            ) values ( rate_plan_detail_seq.nextval,
                       l_rate_plan_id,
                       'AMOUNT',
                       31,
                       5,
                       sysdate,
                       0,
                       sysdate,
                       0,
                       'RUNOUT',
                       x.start_date,
                       null,
                       'N' );

        end if;

        if l_trn_combo > 0 then
            insert into rate_plan_detail (
                rate_plan_detail_id,
                rate_plan_id,
                calculation_type,
                rate_code,
                rate_plan_cost,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                rate_basis,
                effective_date,
                effective_end_date,
                one_time_flag
            ) values ( rate_plan_detail_seq.nextval,
                       l_rate_plan_id,
                       'AMOUNT',
                       32,
                       5,
                       sysdate,
                       0,
                       sysdate,
                       0,
                       'ACTIVE',
                       x.start_date,
                       null,
                       'N' );

        end if;

    end loop;

    for x in (
        select
            rate_plan_id,
            effective_date,
            count(*) cnt
        from
            rate_plan_detail
        where
                rate_code = '34'
            and rate_basis = 'ACTIVE'
        group by
            rate_plan_id,
            effective_date
    ) loop
        if x.cnt > 0 then
            insert into rate_plan_detail (
                rate_plan_detail_id,
                rate_plan_id,
                calculation_type,
                rate_code,
                rate_plan_cost,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                rate_basis,
                effective_date,
                effective_end_date,
                one_time_flag
            ) values ( rate_plan_detail_seq.nextval,
                       x.rate_plan_id,
                       'AMOUNT',
                       '43',
                       350,
                       sysdate,
                       0,
                       sysdate,
                       0,
                       'FLAT_FEE',
                       x.effective_date,
                       null,
                       'Y' );

            insert into rate_plan_detail (
                rate_plan_detail_id,
                rate_plan_id,
                calculation_type,
                rate_code,
                rate_plan_cost,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                rate_basis,
                effective_date,
                effective_end_date,
                one_time_flag
            ) values ( rate_plan_detail_seq.nextval,
                       x.rate_plan_id,
                       'AMOUNT',
                       '45',
                       350,
                       sysdate,
                       0,
                       sysdate,
                       0,
                       'FLAT_FEE',
                       x.effective_date,
                       null,
                       'Y' );

        end if;
    end loop;

    for x in (
        select
            rate_plan_id,
            effective_date,
            count(*) cnt
        from
            rate_plan_detail
        where
            rate_code in ( '31', '31', '33', '35', '36',
                           '37', '38', '39', '40' )
            and rate_basis = 'ACTIVE'
        group by
            rate_plan_id,
            effective_date
    ) loop
        if x.cnt > 0 then
            insert into rate_plan_detail (
                rate_plan_detail_id,
                rate_plan_id,
                calculation_type,
                rate_code,
                rate_plan_cost,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                rate_basis,
                effective_date,
                effective_end_date,
                one_time_flag
            ) values ( rate_plan_detail_seq.nextval,
                       x.rate_plan_id,
                       'AMOUNT',
                       '44',
                       350,
                       sysdate,
                       0,
                       sysdate,
                       0,
                       'FLAT_FEE',
                       x.effective_date,
                       null,
                       'Y' );

            insert into rate_plan_detail (
                rate_plan_detail_id,
                rate_plan_id,
                calculation_type,
                rate_code,
                rate_plan_cost,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                rate_basis,
                effective_date,
                effective_end_date,
                one_time_flag
            ) values ( rate_plan_detail_seq.nextval,
                       x.rate_plan_id,
                       'AMOUNT',
                       '46',
                       350,
                       sysdate,
                       0,
                       sysdate,
                       0,
                       'FLAT_FEE',
                       x.effective_date,
                       null,
                       'Y' );

        end if;
    end loop;

end;
/

