-- liquibase formatted sql
-- changeset SAMQA:1754374178453 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\provider_payment_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/provider_payment_v.sql:null:de06eff2ec3322af26d839e5f46782ee2910219a:create

create or replace force editionable view samqa.provider_payment_v (
    amount,
    pay_month,
    pay_mm,
    check_number,
    prov_name,
    acc_id
) as
    select
        sum(amount)                   amount,
        to_char(pay_date, 'MON-YYYY') pay_month,
        to_char(pay_date, 'MM')       pay_mm,
        pay_num                       check_number,
        b.prov_name,
        acc_id
    from
        payment a,
        claimn  b
    where
            a.claimn_id = b.claim_id
        and pay_date > trunc(sysdate, 'YYYY')
        and reason_code = 11
    group by
        pay_date,
        pay_num,
        b.prov_name,
        acc_id;

