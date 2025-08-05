-- liquibase formatted sql
-- changeset SAMQA:1754374179123 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\subscriber_sfo_qtrly_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/subscriber_sfo_qtrly_v.sql:null:7abf896564a6bf328438fffa988a77db0d29538f:create

create or replace force editionable view samqa.subscriber_sfo_qtrly_v (
    name,
    acc_id,
    acc_num,
    plan_type,
    email,
    pers_id,
    letter_type,
    ben_plan_id,
    plan_start_date,
    plan_end_date,
    start_date,
    end_date
) as
    select
        a.first_name
        || ' '
        || a.middle_name
        || ' '
        || a.last_name           name,
        b.acc_id,
        b.acc_num,
        e.plan_type,
        a.email,
        a.pers_id,
        'QUARTERLY'              letter_type,
        e.ben_plan_id,
        trunc(e.plan_start_date) plan_start_date,
        trunc(e.plan_end_date)   plan_end_date,
        nvl((
            select
                max(fee_date)
            from
                income
            where
                    acc_id = b.acc_id
                and fee_date < i.fee_date
        ),
            i.fee_date)          start_date,
        i.fee_date               end_date
    from
        person                    a,
        account                   b,
        ben_plan_enrollment_setup e,
        income                    i
    where
            a.pers_id = b.pers_id
        and b.acc_id = e.acc_id
        and e.plan_end_date + 30 > sysdate
    --  AND E.PLAN_START_DATE   < sysdate-30
        and e.status = 'A'
        and e.sf_ordinance_flag = 'Y'
        and i.acc_id = b.acc_id
        and i.plan_type = e.plan_type
        and i.fee_code in ( 17, 11 )
        and trunc(i.fee_date) >= nvl(e.qtly_rprt_start_date, e.plan_start_date)
        and b.account_type in ( 'HRA', 'FSA' )
        and e.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' );

