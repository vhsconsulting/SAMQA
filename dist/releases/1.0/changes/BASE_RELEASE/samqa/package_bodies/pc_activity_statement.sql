-- liquibase formatted sql
-- changeset SAMQA:1754373958363 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_activity_statement.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_activity_statement.sql:null:52dd2f6a37bee2f1fda0bd004eef6a2112367e8a:create

create or replace package body samqa.pc_activity_statement as

    procedure process_yearly_activity (
        p_acc_id_from in number,
        p_acc_id_to   in number
    ) is
        l_batch_number number;
    begin
        l_batch_number := batch_num_seq.nextval;
        for x in (
            select
                acc_num
            from
                acc_yearly_paper_stmt_v
            where
                    acc_id >= p_acc_id_from
                and acc_id <= p_acc_id_to
        ) loop
            generate_activity_statement('YEARLY', '01-JAN-2013', '31-DEC-2013', x.acc_num, null,
                                        l_batch_number);
        end loop;

    end;

    procedure generate_activity_statement (
        p_statement_method in varchar2,
        p_start_date       in date default sysdate,
        p_end_date         in date default sysdate,
        p_acc_num          in varchar2 default null,
        p_entrp_id         in number default null,
        x_batch_number     in out number
    ) is
        l_statement_id number;
        l_batch_number number;
        l_generation_error exception;
    begin
        if
            p_start_date is null
            and p_end_date is null
        then
            raise l_generation_error;
        end if;
        if x_batch_number is null
           or x_batch_number = 0 then
            l_batch_number := batch_num_seq.nextval;
        else
            l_batch_number := x_batch_number;
        end if;
     --  x_statement_id := null;
        pc_log.log_error('GENERATE_ACTIVITY_STATEMENT', 'Batch Number ' || l_batch_number);
        pc_log.log_error('GENERATE_ACTIVITY_STATEMENT', 'p_acc_num ' || p_acc_num);
        if p_statement_method = 'YEARLY' then
            insert into activity_statement (
                statement_id,
                acc_num,
                acc_id,
                pers_id,
                start_date,
                begin_date,
                end_date,
                name,
                address,
                city,
                state,
                zip,
                coverage_level,
                contribution_limit,
                beginning_balance,
                ending_balance,
                disbursable_balance,
                beg_fee_balance,
                end_fee_balance,
                interest,
                outside_inv_bal,
                previous_yr_contrib,
                current_yr_contrib,
                total_contribution,
                qual_disb_amount,
                nqual_disb_amount,
                total_disbursement,
                total_er_amount,
                total_ee_amount,
                txn_fee_paid,
                admin_fee_paid,
                creation_date,
                plan_sign,
                batch_number,
                statement_method
            )
                select
                    activity_statement_seq.nextval,
                    acc_num,
                    acc_id,
                    pers_id,
                    effective_date,
                    p_start_date,
                    p_end_date,
                    person_name,
                    address,
                    city,
                    state,
                    zip,
                    plan_type,
                    to_number(pc_param.get_system_value(
                        decode(
                            nvl(plan_type_code, 0),
                            0,
                            'INDIVIDUAL_CONTRIBUTION',
                            1,
                            'FAMILY_CONTRIBUTION'
                        ),
                        trunc(p_start_date, 'YYYY')
                    )) +
                    case
                        when round(months_between(sysdate, birth_date) / 12) >= 55 then
                                nvl(to_number(pc_param.get_system_value('CATCHUP_CONTRIBUTION',
                                                                        trunc(p_start_date, 'YYYY'))),
                                    0)
                        else
                            0
                    end
                    contribution_limit,
                    case
                        when trunc(effective_date) >= p_start_date then
                            0
                        else
                            nvl(
                                pc_account.current_balance(acc_id, '01-JAN-2004', p_start_date - 1),
                                0
                            )
                    end     beginning_balance,
                    nvl(
                        pc_account.current_balance(acc_id, '01-JAN-2004', p_end_date),
                        0
                    )       ending_balance,
                    nvl(
                        pc_account.new_acc_balance(acc_id, '01-JAN-2004', p_end_date),
                        0.00
                    )       disbursable_balance,
                    case
                        when trunc(effective_date) >= p_start_date then
                            0
                        else
                            nvl(
                                pc_account.fee_bucket_balance(acc_id, '01-JAN-2004', p_start_date - 1),
                                0.00
                            )
                    end     b_fee_bucket,
                    nvl(
                        pc_account.fee_bucket_balance(acc_id, '01-JAN-2004', p_end_date),
                        0.00
                    )       e_fee_bucket,
                    nvl(
                        pc_account_details.get_interest_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       interest,
                    nvl(
                        pc_account.outside_inv_balance(acc_id, p_end_date),
                        0.00
                    )       outside_inv_balance,
                    nvl(
                        pc_account_details.get_prior_year_total(acc_id, p_start_date, p_end_date, effective_date),
                        0.00
                    )       prior_yr_contrib,
                    nvl(
                        pc_account_details.get_current_year_total(acc_id, p_start_date, p_end_date, effective_date),
                        0.00
                    )       current_yr_contrib,
                    nvl(
                        pc_account_details.get_receipts_total(acc_id, p_start_date, p_end_date, effective_date),
                        0.00
                    )       total_contribution
                    /* , NVL(pc_account_details.get_qdisb_total (acc_id,p_start_date,p_end_date),0.00)
                     + NVL(pc_account_details.get_nqdisb_total (acc_id,p_start_date,p_end_date),0.00)*/,
                    nvl(
                        pc_account_details.get_disbursement_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       qual_disb_amount,
                    0
                    -- , NVL(pc_account_details.get_nqdisb_total (acc_id,p_start_date,p_end_date),0.00) nqual_disb_amount
                    ,
                    nvl(
                        pc_account_details.get_disbursement_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       total_disb_amount,
                    nvl(
                        pc_account_details.get_er_receipts_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       er_contribution,
                    nvl(
                        pc_account_details.get_ee_receipts_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       ee_contribution,
                    nvl(
                        pc_account_details.get_disb_fee_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       txn_fee_paid,
                    nvl(
                        pc_account_details.get_fee_paid_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       admin_fee_paid,
                    sysdate,
                    plan_sign,
                    l_batch_number,
                    p_statement_method
                from
                    (
                        select distinct
                            a.acc_num,
                            a.acc_id,
                            a.pers_id,
                            a.effective_date,
                            a.person_name,
                            a.address,
                            a.city,
                            a.state,
                            a.zip,
                            a.plan_type,
                            a.plan_type_code,
                            a.plan_sign,
                            a.birth_date
                        from
                            acc_user_profile_v      a,
                            acc_yearly_paper_stmt_v b
                        where
                                a.acc_id = b.acc_id
                            and account_status <> 3
                            and a.entrp_id = nvl(p_entrp_id, a.entrp_id)
                            and a.acc_num = nvl(p_acc_num, a.acc_num)
                            and plan_sign = 'SHA'
                    );

            for x in (
                select
                    statement_id,
                    city,
                    beginning_balance + ending_balance + disbursable_balance + beg_fee_balance + end_fee_balance + interest + outside_inv_bal
                    + previous_yr_contrib + current_yr_contrib + total_contribution + qual_disb_amount + nqual_disb_amount + total_disbursement
                    + txn_fee_paid + admin_fee_paid bal
                from
                    activity_statement
                where
                    batch_number = l_batch_number
            ) loop
                l_statement_id := x.statement_id;
                if
                    l_statement_id is null
                    and p_statement_method = 'YEARLY'
                then
                    if x.bal = 0 then
                        l_statement_id := null;
                    end if;
           -- will not send statements to the incorrect address with all 00000
                    if x.city like '00%'
                       or x.city like ',' then
                        l_statement_id := null;
                    end if;

                    delete from activity_statement
                    where
                        statement_id = x.statement_id;

                end if;

            end loop;

        elsif p_statement_method = 'QUARTERLY' then
            insert into activity_statement (
                statement_id,
                acc_num,
                acc_id,
                pers_id,
                start_date,
                begin_date,
                end_date,
                name,
                address,
                city,
                state,
                zip,
                coverage_level,
                contribution_limit,
                beginning_balance,
                ending_balance,
                disbursable_balance,
                beg_fee_balance,
                end_fee_balance,
                interest,
                outside_inv_bal,
                previous_yr_contrib,
                current_yr_contrib,
                total_contribution,
                qual_disb_amount,
                nqual_disb_amount,
                total_disbursement,
                txn_fee_paid,
                admin_fee_paid,
                total_er_amount,
                total_ee_amount,
                creation_date,
                plan_sign,
                batch_number,
                statement_method
            )
                select
                    activity_statement_seq.nextval,
                    acc_num,
                    acc_id,
                    pers_id,
                    effective_date,
                    p_start_date,
                    p_end_date,
                    person_name,
                    address,
                    city,
                    state,
                    zip,
                    plan_type,
                    to_number(pc_param.get_system_value(
                        decode(
                            nvl(plan_type_code, 0),
                            0,
                            'INDIVIDUAL_CONTRIBUTION',
                            1,
                            'FAMILY_CONTRIBUTION'
                        ),
                        trunc(p_start_date, 'YYYY')
                    )) +
                    case
                        when round(months_between(sysdate, birth_date) / 12) >= 55 then
                                nvl(to_number(pc_param.get_system_value('CATCHUP_CONTRIBUTION',
                                                                        trunc(p_start_date, 'YYYY'))),
                                    0)
                        else
                            0
                    end
                    contribution_limit,
                    case
                        when trunc(effective_date) >= p_start_date then
                            0
                        else
                            nvl(
                                pc_account.current_balance(acc_id, '01-JAN-2004', p_start_date - 1),
                                0
                            )
                    end     beginning_balance,
                    nvl(
                        pc_account.current_balance(acc_id, '01-JAN-2004', p_end_date),
                        0
                    )       ending_balance,
                    nvl(
                        pc_account.new_acc_balance(acc_id, '01-JAN-2004', p_end_date),
                        0.00
                    )       disbursable_balance,
                    case
                        when trunc(effective_date) >= p_start_date then
                            0
                        else
                            nvl(
                                pc_account.fee_bucket_balance(acc_id, '01-JAN-2004', p_start_date - 1),
                                0.00
                            )
                    end     b_fee_bucket,
                    nvl(
                        pc_account.fee_bucket_balance(acc_id, '01-JAN-2004', p_end_date),
                        0.00
                    )       e_fee_bucket,
                    nvl(
                        pc_account_details.get_interest_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       interest,
                    nvl(
                        pc_account.outside_inv_balance(acc_id, p_end_date),
                        0.00
                    )       outside_inv_balance,
                    nvl(
                        pc_account_details.get_prior_year_total(acc_id,
                                                                trunc(p_start_date, 'YYYY'),
                                                                (add_months(
                                                 trunc(p_start_date, 'YYYY'),
                                                 12
                                             ) - 1),
                                                                effective_date),
                        0.00
                    )       prior_yr_contrib,
                    nvl(
                        pc_account_details.get_current_year_total(acc_id,
                                                                  trunc(p_start_date, 'YYYY'),
                                                                  (add_months(
                                                   trunc(p_start_date, 'YYYY'),
                                                   12
                                               ) - 1),
                                                                  effective_date),
                        0.00
                    )       current_yr_contrib, /*NVL(pc_account_details.get_receipts_total (acc_id,TRUNC(P_START_DATE,'YYYY')
                                                                           ,(ADD_MONTHS(TRUNC(P_START_DATE,'YYYY'),12)-1),effective_date),0.00) total_contribution*/
                    nvl(
                        pc_account_details.get_receipts_total(acc_id, p_start_date, p_end_date, effective_date),
                        0.00
                    )       total_contribution,/* NVL(pc_account_details.get_disbursement_total (acc_id,TRUNC(P_START_DATE,'YYYY')
                                                                           ,(ADD_MONTHS(TRUNC(P_START_DATE,'YYYY'),12)-1)),0.00)
                     qual_disb_amount*/
                    nvl(
                        pc_account_details.get_disbursement_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       qual_disb_amount,
                    0
                    -- , NVL(pc_account_details.get_nqdisb_total (acc_id,p_start_date,p_end_date),0.00) nqual_disb_amount
                    , /*NVL(pc_account_details.get_disbursement_total (acc_id,TRUNC(P_START_DATE,'YYYY')
                                                                           ,(ADD_MONTHS(TRUNC(P_START_DATE,'YYYY'),12)-1)),0.00) total_disb_amount*/
                    nvl(
                        pc_account_details.get_disbursement_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       total_disb_amount,
                    nvl(
                        pc_account_details.get_disb_fee_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       txn_fee_paid,
                    nvl(
                        pc_account_details.get_fee_paid_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       admin_fee_paid
                     /*, NVL(pc_account_details.GET_Er_RECEIPTS_TOTAL (acc_id,TRUNC(P_START_DATE,'YYYY')
                                                                           ,(ADD_MONTHS(TRUNC(P_START_DATE,'YYYY'),12)-1),effective_date),0.00) er_contribution
                     , NVL(pc_account_details.GET_EE_RECEIPTS_TOTAL (acc_id,TRUNC(P_START_DATE,'YYYY')
                                                                           ,(ADD_MONTHS(TRUNC(P_START_DATE,'YYYY'),12)-1),effective_date),0.00) ee_contribution*/
                    ,
                    nvl(
                        pc_account_details.get_er_receipts_total(acc_id, p_start_date, p_end_date, effective_date),
                        0.00
                    )       er_contribution,
                    nvl(
                        pc_account_details.get_ee_receipts_total(acc_id, p_start_date, p_end_date, effective_date),
                        0.00
                    )       ee_contribution,
                    sysdate,
                    plan_sign,
                    l_batch_number,
                    p_statement_method
                from
                    (
                        select distinct
                            a.acc_num,
                            a.acc_id,
                            a.pers_id,
                            a.effective_date,
                            a.person_name,
                            a.address,
                            a.city,
                            a.state,
                            a.zip,
                            a.plan_type,
                            a.plan_type_code,
                            a.plan_sign,
                            a.birth_date
                        from
                            acc_user_profile_v         a,
                            acc_quarterly_paper_stmt_v b
                        where
                                a.acc_id = b.acc_id
                            and account_status <> 3
                            and plan_sign = 'SHA'
                    );

            for x in (
                select
                    statement_id,
                    city,
                    beginning_balance + ending_balance + disbursable_balance + beg_fee_balance + end_fee_balance + interest + outside_inv_bal
                    + previous_yr_contrib + current_yr_contrib + total_contribution + qual_disb_amount + nqual_disb_amount + total_disbursement
                    + txn_fee_paid + admin_fee_paid bal
                from
                    activity_statement
                where
                    batch_number = l_batch_number
            ) loop
                l_statement_id := x.statement_id;
                if
                    l_statement_id is null
                    and p_statement_method = 'QUARTERLY'
                then
                    if x.bal = 0 then
                        l_statement_id := null;
                    end if;
           -- will not send statements to the incorrect address with all 00000
                    if x.city like '00%'
                       or x.city like ',' then
                        l_statement_id := null;
                    end if;

                    delete from activity_statement
                    where
                        statement_id = x.statement_id;

                end if;

            end loop;

        else
            insert into activity_statement (
                statement_id,
                acc_num,
                acc_id,
                pers_id,
                start_date,
                begin_date,
                end_date,
                name,
                address,
                city,
                state,
                zip,
                coverage_level,
                contribution_limit,
                beginning_balance,
                ending_balance,
                disbursable_balance,
                beg_fee_balance,
                end_fee_balance,
                interest,
                outside_inv_bal,
                previous_yr_contrib,
                current_yr_contrib,
                total_contribution,
                qual_disb_amount,
                nqual_disb_amount,
                total_disbursement,
                txn_fee_paid,
                admin_fee_paid,
                total_er_amount,
                total_ee_amount,
                creation_date,
                plan_sign,
                batch_number,
                statement_method
            )
                select
                    activity_statement_seq.nextval,
                    acc_num,
                    acc_id,
                    pers_id,
                    effective_date,
                    p_start_date,
                    p_end_date,
                    person_name,
                    address,
                    city,
                    state,
                    zip,
                    plan_type,
                    to_number(pc_param.get_system_value(
                        decode(
                            nvl(plan_type_code, 0),
                            0,
                            'INDIVIDUAL_CONTRIBUTION',
                            1,
                            'FAMILY_CONTRIBUTION'
                        ),
                        trunc(p_start_date, 'YYYY')
                    )) +
                    case
                        when round(months_between(sysdate, birth_date) / 12) >= 55 then
                                nvl(to_number(pc_param.get_system_value('CATCHUP_CONTRIBUTION',
                                                                        trunc(p_start_date, 'YYYY'))),
                                    0)
                        else
                            0
                    end
                    contribution_limit,
                    case
                        when trunc(effective_date) >= p_start_date then
                            0
                        else
                            nvl(
                                pc_account.current_balance(acc_id, '01-JAN-2004', p_start_date - 1),
                                0
                            )
                    end     beginning_balance,
                    nvl(
                        pc_account.current_balance(acc_id, '01-JAN-2004', p_end_date),
                        0
                    )       ending_balance,
                    nvl(
                        pc_account.new_acc_balance(acc_id, '01-JAN-2004', p_end_date),
                        0.00
                    )       disbursable_balance,
                    case
                        when trunc(effective_date) >= p_start_date then
                            0
                        else
                            nvl(
                                pc_account.fee_bucket_balance(acc_id, '01-JAN-2004', p_start_date - 1),
                                0.00
                            )
                    end     b_fee_bucket,
                    nvl(
                        pc_account.fee_bucket_balance(acc_id, '01-JAN-2004', p_end_date),
                        0.00
                    )       e_fee_bucket,
                    nvl(
                        pc_account_details.get_interest_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       interest,
                    nvl(
                        pc_account.outside_inv_balance(acc_id, p_end_date),
                        0.00
                    )       outside_inv_balance,
                    nvl(
                        pc_account_details.get_prior_year_total(acc_id,
                                                                trunc(p_start_date, 'YYYY'),
                                                                (add_months(
                                                 trunc(p_start_date, 'YYYY'),
                                                 12
                                             ) - 1),
                                                                effective_date),
                        0.00
                    )       prior_yr_contrib,
                    nvl(
                        pc_account_details.get_current_year_total(acc_id,
                                                                  trunc(p_start_date, 'YYYY'),
                                                                  (add_months(
                                                   trunc(p_start_date, 'YYYY'),
                                                   12
                                               ) - 1),
                                                                  effective_date),
                        0.00
                    )       current_yr_contrib, /*NVL(pc_account_details.get_receipts_total (acc_id,TRUNC(P_START_DATE,'YYYY')
                                                                           ,(ADD_MONTHS(TRUNC(P_START_DATE,'YYYY'),12)-1),effective_date),0.00) total_contribution*/
                    nvl(
                        pc_account_details.get_receipts_total(acc_id, p_start_date, p_end_date, effective_date),
                        0.00
                    )       total_contribution,/* NVL(pc_account_details.get_disbursement_total (acc_id,TRUNC(P_START_DATE,'YYYY')
                                                                           ,(ADD_MONTHS(TRUNC(P_START_DATE,'YYYY'),12)-1)),0.00)
                      qual_disb_amount*/
                    nvl(
                        pc_account_details.get_disbursement_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       qual_disb_amount,
                    0
                    -- , NVL(pc_account_details.get_nqdisb_total (acc_id,p_start_date,p_end_date),0.00) nqual_disb_amount
                    , /*NVL(pc_account_details.get_disbursement_total (acc_id,TRUNC(P_START_DATE,'YYYY')
                                                                           ,(ADD_MONTHS(TRUNC(P_START_DATE,'YYYY'),12)-1)),0.00) total_disb_amount*/
                    nvl(
                        pc_account_details.get_disbursement_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       total_disb_amount,
                    nvl(
                        pc_account_details.get_disb_fee_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       txn_fee_paid,
                    nvl(
                        pc_account_details.get_fee_paid_total(acc_id, p_start_date, p_end_date),
                        0.00
                    )       admin_fee_paid
                    /* , NVL(pc_account_details.GET_Er_RECEIPTS_TOTAL (acc_id,TRUNC(P_START_DATE,'YYYY')
                                                                           ,(ADD_MONTHS(TRUNC(P_START_DATE,'YYYY'),12)-1),effective_date),0.00) er_contribution
                     , NVL(pc_account_details.GET_EE_RECEIPTS_TOTAL (acc_id,TRUNC(P_START_DATE,'YYYY')
                                                                           ,(ADD_MONTHS(TRUNC(P_START_DATE,'YYYY'),12)-1),effective_date),0.00) ee_contribution */
                    ,
                    nvl(
                        pc_account_details.get_er_receipts_total(acc_id, p_start_date, p_end_date, effective_date),
                        0.00
                    )       er_contribution,
                    nvl(
                        pc_account_details.get_ee_receipts_total(acc_id, p_start_date, p_end_date, effective_date),
                        0.00
                    )       ee_contribution,
                    sysdate,
                    plan_sign,
                    l_batch_number,
                    p_statement_method
                from
                    (
                        select distinct
                            a.acc_num,
                            a.acc_id,
                            a.pers_id,
                            a.effective_date,
                            a.person_name,
                            a.address,
                            a.city,
                            a.state,
                            a.zip,
                            a.plan_type,
                            a.plan_type_code,
                            a.plan_sign,
                            a.birth_date
                        from
                            acc_user_profile_v a
                        where
                            a.acc_num = p_acc_num
                    ); -- fixed by vanitha on 2/25 for SAM slowness

            for x in (
                select
                    statement_id,
                    city,
                    beginning_balance + ending_balance + disbursable_balance + beg_fee_balance + end_fee_balance + interest + outside_inv_bal
                    + previous_yr_contrib + current_yr_contrib + total_contribution + qual_disb_amount + nqual_disb_amount + total_disbursement
                    + txn_fee_paid + admin_fee_paid bal
                from
                    activity_statement
                where
                    batch_number = l_batch_number
            ) loop
                l_statement_id := x.statement_id;
                if x.bal = 0 then
                    l_statement_id := null;
                end if;
           -- will not send statements to the incorrect address with all 00000
                if x.city like '00%'
                   or x.city like ',' then
                    l_statement_id := null;
                end if;

            end loop;

        end if;

        for x in (
            select
                count(*) cnt
            from
                activity_statement
            where
                batch_number = l_batch_number
        ) loop
            if x.cnt > 0 then
                x_batch_number := l_batch_number;
            end if;
        end loop;

        if x_batch_number is not null then
            insert into activity_statement_detail (
                stmt_detail_id,
                statement_id,
                acc_id,
                transaction_date,
                expense_code,
                description,
                total_receipt_amount,
                total_disb_amount,
                receipt_amount,
                disb_amount,
                fee_receipt,
                fee_disb,
                creation_date
            )
                select
                    activity_statement_detail_seq.nextval,
                    statement_id,
                    acc_id,
                    fee_date,
                    fee_code,
                    fee_name,
                    total_received,
                    disb_amount,
                    receipt,
                    disbursed,
                    fee_amount,
                    fee_disb,
                    sysdate
                from
                    (
                        select
                            a.acc_id,
                            a.fee_date,
                            fee_code,
                            case
                                when a.fee_date < p_start_date
                                     and trunc(b.start_date) >= p_start_date then
                                    fee_name
                                    || ' (For '
                                    || to_char(
                                        trunc(b.start_date),
                                        'MM/DD/YYYY'
                                    )
                                    || ' Effective )'
                                when trunc(b.start_date) > p_end_date then
                                    fee_name
                                    || ' (For '
                                    || to_char(
                                        trunc(b.start_date),
                                        'MM/DD/YYYY'
                                    )
                                    || ' Effective )'
                                else
                                    fee_name
                            end                                           fee_name,
                            total_received,
                            0                                             disb_amount,
                            nvl(amount, 0) + nvl(amount_add, 0)           receipt,
                            0                                             disbursed,
                            nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0) fee_amount,
                            0                                             fee_disb,
                            b.statement_id
                        from
                            income_statement_v a,
                            activity_statement b
                        where
                                b.batch_number = l_batch_number
                            and a.acc_id = b.acc_id
                            and b.acc_num = nvl(p_acc_num, b.acc_num)
                            and trunc(fee_date) >= case
                                                       when trunc(fee_date) < b.start_date
                                                            and trunc(b.start_date) >= trunc(b.begin_date) then
                                                           least(
                                                               trunc(fee_date),
                                                               trunc(b.begin_date)
                                                           )
                                                       else
                                                           trunc(b.begin_date)
                                                   end
                            and trunc(fee_date) <= trunc(b.end_date)
                        union all
                        select
                            a.acc_id,
                            pay_date,
                            decode(expense_code, 'NQ', 'Q', expense_code),
                            description,
                            0,
                            nvl(amount, 0),
                            0,
                            nvl(amount, 0) - nvl(fee_amount, 0),
                            0                  fee_amount,
                            nvl(fee_amount, 0) fee_disb,
                            b.statement_id
                        from
                            payment_statement_v a,
                            activity_statement  b
                        where
                                b.batch_number = l_batch_number
                            and a.acc_id = b.acc_id
                            and b.acc_num = nvl(p_acc_num, b.acc_num)
               --  AND    a.reason_mode <> 'FP'
                            and trunc(pay_date) >= trunc(b.begin_date)
                            and trunc(pay_date) <= trunc(b.end_date)
                        order by
                            2
                    );

        end if;

        commit;
    exception
        when l_generation_error then
            null;
        when others then
            pc_log.log_error('Error in activity statement generation for ', sqlerrm);
    end generate_activity_statement;

    function get_er_statement_detail (
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) return er_statement_tbl
        pipelined
        deterministic
    is
        l_record er_statement_rec;
    begin
        for x in (
            select
                a.contributor                          entrp_id,
                pc_entrp.get_acc_num(a.contributor)    group_acc_num,
                c.first_name,
                c.middle_name,
                c.last_name,
                acc_num,
                a.fee_date,
                pc_person.get_division_name(c.pers_id) division_code,
                nvl(amount, 0)                         emp_deposit,
                nvl(amount_add, 0)                     subscr_deposit,
                nvl(ee_fee_amount, 0)                  ee_fee_deposit,
                nvl(er_fee_amount, 0)                  er_fee_deposit
            from
                income  a,
                account b,
                person  c
            where
                    a.acc_id = b.acc_id
                and c.pers_id = b.pers_id
                and nvl(a.fee_code, -1) <> 130
                and trunc(fee_date) >= p_start_date
                and trunc(fee_date) <= p_end_date
                and a.contributor = p_entrp_id
            union
            select
                a.contributor                          entrp_id,
                pc_entrp.get_acc_num(a.contributor)    group_acc_num,
                c.first_name,
                c.middle_name,
                c.last_name,
                acc_num,
                a.fee_date,
                pc_person.get_division_name(c.pers_id) division_code,
                nvl(amount, 0)                         emp_deposit,
                nvl(amount_add, 0)                     subscr_deposit,
                nvl(ee_fee_amount, 0)                  ee_fee_deposit,
                nvl(er_fee_amount, 0)                  er_fee_deposit
            from
                income  a,
                account b,
                person  c
            where
                    a.acc_id = b.acc_id
                and c.pers_id = b.pers_id
                and a.fee_code = 130
                and trunc(fee_date) >= trunc(
                    add_months(to_date(p_start_date), 12),
                    'YYYY'
                )
                and trunc(fee_date) <= add_months(to_date(p_end_date), 12)
                and a.contributor = p_entrp_id
        ) loop
            l_record.entrp_id := x.entrp_id;
            l_record.er_acc_num := x.group_acc_num;
            l_record.acc_num := x.acc_num;
            l_record.first_name := x.first_name;
            l_record.middle_name := x.middle_name;
            l_record.last_name := x.last_name;
            l_record.division_code := x.division_code;
            l_record.fee_date := x.fee_date;
            l_record.emp_deposit := x.emp_deposit;
            l_record.subscr_deposit := x.subscr_deposit;
            l_record.er_fee_deposit := x.er_fee_deposit;
            l_record.total := x.emp_deposit + x.subscr_deposit + x.er_fee_deposit;
            pipe row ( l_record );
        end loop;
    end get_er_statement_detail;

    function get_er_statement (
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) return er_statement_tbl
        pipelined
        deterministic
    is
        l_record er_statement_rec;
    begin
        for x in (
            select
                acc_num,
                first_name,
                middle_name,
                last_name,
                division_code,
                sum(emp_deposit)                                   emp_deposit,
                sum(subscr_deposit)                                subscr_deposit,
                sum(er_fee_deposit)                                er_fee_deposit,
                sum(emp_deposit + subscr_deposit + er_fee_deposit) total
            from
                (
                    select
                        *
                    from
                        table ( get_er_statement_detail(p_entrp_id, p_start_date, p_end_date) )
                )
            group by
                first_name,
                middle_name,
                last_name,
                acc_num,
                division_code
        ) loop
            l_record.entrp_id := p_entrp_id;
            l_record.acc_num := x.acc_num;
            l_record.first_name := x.first_name;
            l_record.middle_name := x.middle_name;
            l_record.last_name := x.last_name;
            l_record.division_code := x.division_code;
            l_record.emp_deposit := x.emp_deposit;
            l_record.subscr_deposit := x.subscr_deposit;
            l_record.er_fee_deposit := x.er_fee_deposit;
            l_record.total := x.total;
            pipe row ( l_record );
        end loop;
    end get_er_statement;

 -- Below Function added by Swamy for Ticket#8984(Related to SQL Injection)
    function get_emp_contrib_detail (
        p_group_acc_num in varchar2,
        p_entrp_id      in varchar2,
        p_start_date    in varchar2,
        p_end_date      in varchar2,
        p_sort          in varchar2
    ) return tbl_emp_contrib_detail
        pipelined
    is

        rec           rec_emp_contrib_detail;
        v_start_date  varchar2(10);
        v_end_date    varchar2(10);
        v_sort        varchar2(100);
        v_entrp_id    number;
        cursor cur_contrib is
        select
            acc_num,
            first_name,
            middle_name,
            last_name,
            sum(emp_deposit)                                   emp_deposit,
            sum(subscr_deposit)                                subscr_deposit,
            sum(er_fee_deposit)                                er_fee_deposit,
            sum(emp_deposit + subscr_deposit + er_fee_deposit) total
        from
            (
                select
                    name,
                    first_name,
                    middle_name,
                    last_name,
                    acc_num,
                    emp_deposit                         emp_deposit,
                    ( er_fee_deposit + ee_fee_deposit ) er_fee_deposit,
                    subscr_deposit                      subscr_deposit
                from
                    emp_contrib_detail_v
                where
                        entrp_id = v_entrp_id
                    and trunc(fee_date) >= v_start_date
                    and trunc(fee_date) <= v_end_date
                union all
                select
                    name,
                    first_name,
                    middle_name,
                    last_name,
                    acc_num,
                    emp_deposit                         emp_deposit,
                    ( er_fee_deposit + ee_fee_deposit ) er_fee_deposit,
                    subscr_deposit                      subscr_deposit
                from
                    emp_prev_adj_v
                where
                        entrp_id = v_entrp_id
                    and trunc(fee_date) >= trunc(
                        add_months(v_start_date, 12),
                        'YYYY'
                    )
                    and trunc(fee_date) <= add_months(v_end_date, 12)
            )
        group by
            first_name,
            middle_name,
            last_name,
            acc_num
        order by
            v_sort;

        v_process_flg varchar2(1) := 'N';
        v_message     varchar2(500);
        erreur exception;
    begin
        if is_number(nvl(p_entrp_id, '@')) = 'N' then
            v_message := 'Invalid Entrp_Id :=' || p_entrp_id;
            raise erreur;
        else
            v_entrp_id := p_entrp_id;
        end if;

        if is_date(
            nvl(p_end_date, '@'),
            'DD-MON-YYYY'
        ) = 'N' then
            v_message := 'Invalid end_date :=' || p_end_date;
            raise erreur;
        else
            v_end_date := to_date ( p_end_date, 'DD-MON-YYYY' );
        end if;

        if is_date(
            nvl(p_start_date, '@'),
            'DD-MON-YYYY'
        ) = 'N' then
            v_message := 'Invalid start_date :=' || p_start_date;
            raise erreur;
        else
            v_start_date := to_date ( p_start_date, 'DD-MON-YYYY' );
        end if;

        if p_sort in ( 'FIRST_NAME', 'LAST_NAME', 'ACC_NUM' ) then
            v_sort := p_sort;
        else
            v_sort := 'FIRST_NAME';
        end if;

        for k in cur_contrib loop
            rec.first_name := k.first_name;
            rec.middle_name := k.middle_name;
            rec.last_name := k.last_name;
            rec.acc_num := k.acc_num;
            rec.emp_deposit := k.emp_deposit;
            rec.subscr_deposit := k.subscr_deposit;
            rec.er_fee_deposit := k.er_fee_deposit;
            rec.total := k.total;
            pipe row ( rec );
        end loop;

    exception
        when erreur then
            pc_log.log_error('Error in GET_EMP_CONTRIB_DETAIL for ', v_message);
        when others then
            pc_log.log_error('Error OTHERS in GET_EMP_CONTRIB_DETAIL for ',
                             sqlerrm(sqlcode));
    end get_emp_contrib_detail;

end pc_activity_statement;
/

