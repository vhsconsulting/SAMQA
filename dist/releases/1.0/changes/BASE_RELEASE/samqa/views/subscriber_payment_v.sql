-- liquibase formatted sql
-- changeset SAMQA:1754374179079 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\subscriber_payment_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/subscriber_payment_v.sql:null:20fe7e783cd5b8fe49dae21dca1010e5b5d8821f:create

create or replace force editionable view samqa.subscriber_payment_v (
    amount,
    pay_month,
    pay_mm,
    check_number,
    acc_id
) as
    select
        sum(amount)                   amount,
        to_char(pay_date, 'MON-YYYY') pay_month,
        to_char(pay_date, 'MM')       pay_mm,
        pay_num                       check_number,
        acc_id
    from
        payment
    where
            pay_date > trunc(sysdate, 'YYYY')
        and reason_code in ( 12, 19 )
    group by
        acc_id,
        pay_num,
        pay_date;

