create or replace force editionable view samqa.close_pay_type (
    reason_name,
    reason_code
) as
    select
        reason_name,
        reason_code
    from
        pay_reason
    where
        ( reason_code in ( 12, 120, 80 ) );


-- sqlcl_snapshot {"hash":"a7c9ba363c2148fbb1d0ac524ac89fa7a2ead06c","type":"VIEW","name":"CLOSE_PAY_TYPE","schemaName":"SAMQA","sxml":""}