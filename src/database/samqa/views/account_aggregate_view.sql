create or replace force editionable view samqa.account_aggregate_view (
    acc_id,
    ind_depo_acc_id,
    emp_acc_id,
    emp_acc_entrp_id,
    emp_depo_entrp_id,
    ind_demo_entrp_id,
    emp_entrp_id,
    emp_name,
    ind_broker_id,
    emp_broker_id,
    broker_broker_id,
    broker_id_demo_pers_id,
    change_num,
    ind_demo_pers_id,
    ind_salesrep_id,
    emp_salesrep_id,
    ind_list_bill,
    emp_list_bill,
    hsa_effective_date,
    ind_start_date,
    ind_end_date,
    ind_plan_code,
    ind_month_pay,
    ind_fee_ini,
    ind_fee_setup,
    ind_fee_maint,
    ind_account_status,
    contributor,
    fee_date,
    amount,
    amount_add,
    contributor_amount,
    cur_bal,
    check_date,
    check_amount,
    posted_balance,
    remaining_balance,
    fee_bucket_balance,
    gender,
    state,
    ind_zip,
    emp_state,
    num_eligible_emp,
    emp_start_date,
    emp_end_date,
    emp_plan_code,
    emp_month_pay,
    emp_fee_ini,
    emp_fee_setup,
    emp_fee_maint,
    emp_account_status,
    reason_code,
    broker_rate,
    broker_start_date,
    broker_end_date,
    address_verified,
    agency_name,
    broker_lic,
    age,
    q1,
    q2,
    q3,
    q4,
    days_active,
    target
) as
    select
        f.acc_id                                 as acc_id,
        i.acc_id                                 as ind_depo_acc_id,
        c.acc_id                                 as emp_acc_id,
        c.entrp_id                               as emp_acc_entrp_id,
        e.entrp_id                               as emp_depo_entrp_id,
        h.entrp_id                               as ind_demo_entrp_id,
        d.entrp_id                               as emp_entrp_id,
        d.name                                   as emp_name,
        f.broker_id                              as ind_broker_id,
        c.broker_id                              as emp_broker_id,
        a.broker_id                              as broker_broker_id,
        b.pers_id                                as broker_id_demo_pers_id,
        h.pers_id                                as ind_demo_pers_id,
        i.change_num,
        f.salesrep_id                            as ind_salesrep_id,
        c.salesrep_id                            as emp_salesrep_id,
        i.list_bill                              as ind_list_bill,
        e.list_bill                              as emp_list_bill,
        f.hsa_effective_date                     as hsa_effective_date,
        f.start_date                             as ind_start_date,
        f.end_date                               as ind_end_date,
        f.plan_code                              as ind_plan_code,
        f.month_pay                              as ind_month_pay,
        f.fee_ini                                as ind_fee_ini,
        f.fee_setup                              as ind_fee_setup,
        f.fee_maint                              as ind_fee_maint,
        f.account_status                         as ind_account_status,
        i.contributor                            as contributor,
        i.fee_date                               as fee_date,
        i.amount                                 as amount,
        i.amount_add                             as amount_add,
        i.contributor_amount                     as contributor_amount,
        i.cur_bal                                as cur_bal,
        e.check_date                             as check_date,
        e.check_amount                           as check_amount,
        e.posted_balance                         as posted_balance,
        e.remaining_balance                      as remaining_balance,
        e.fee_bucket_balance                     as fee_bucket_balance,
        h.gender                                 as gender,
        h.state                                  as state,
        h.zip                                    as ind_zip,
        d.state                                  as emp_state,
        d.no_of_eligible                         as num_eligible_emp,
        c.start_date                             as emp_start_date,
        c.end_date                               as emp_end_date,
        c.plan_code                              as emp_plan_code,
        c.month_pay                              as emp_month_pay,
        c.fee_ini                                as emp_fee_ini,
        c.fee_setup                              as emp_fee_setup,
        c.fee_maint                              as emp_fee_maint,
        c.account_status                         as emp_account_status,
        e.reason_code                            as reason_code,
        a.broker_rate                            as broker_rate,
        a.start_date                             as broker_start_date,
        a.end_date                               as broker_end_date,
        case
            when h.address_verified is null then
                'N'
            else
                'Y'
        end                                      as address_verified,
        case
            when a.agency_name is null then
                'Independent'
            else
                a.agency_name
        end                                      as agency_name,
        case
            when a.broker_lic is null then
                'None'
            else
                a.broker_lic
        end                                      as broker_lic,
        round((sysdate - h.birth_date) / 365.25) age,
        case
            when to_char(f.hsa_effective_date, 'MM') in ( '01', '02', '03' ) then
                1
            else
                0
        end                                      q1,
        case
            when to_char(f.hsa_effective_date, 'MM') in ( '04', '05', '06' ) then
                1
            else
                0
        end                                      q2,
        case
            when to_char(f.hsa_effective_date, 'MM') in ( '07', '08', '09' ) then
                1
            else
                0
        end                                      q3,
        case
            when to_char(f.hsa_effective_date, 'MM') in ( '10', '11', '12' ) then
                1
            else
                0
        end                                      q4,
        case
            when f.end_date is not null then
                round(f.end_date - f.start_date)
            else
                round(sysdate - f.start_date)
        end                                      days_active,
        case
            when f.account_status = 1 then
                0
            when f.account_status = 4 then
                1
        end                                      target
    from
             account f
        inner join income            i on i.acc_id = f.acc_id
        inner join person            h on h.pers_id = f.pers_id
        right outer join enterprise        d on h.entrp_id = d.entrp_id
        inner join account           c on d.entrp_id = c.entrp_id
        left outer join employer_deposits e on i.contributor = e.entrp_id
                                               and i.list_bill = e.list_bill
        left outer join broker            a on c.broker_id = a.broker_id
                                    and f.broker_id = a.broker_id
        left outer join person            b on b.pers_id = a.broker_id;


-- sqlcl_snapshot {"hash":"5a64ccbde8fcb89dcf661e04af1c502593c0cb57","type":"VIEW","name":"ACCOUNT_AGGREGATE_VIEW","schemaName":"SAMQA","sxml":""}