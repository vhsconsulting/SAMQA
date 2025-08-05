-- liquibase formatted sql
-- changeset SAMQA:1754374177833 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\pay_period.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/pay_period.sql:null:762d008978c0ffbae311d2228fa238387e4e46bc:create

create or replace force editionable view samqa.pay_period (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'ACC_PAY_PERIOD';

