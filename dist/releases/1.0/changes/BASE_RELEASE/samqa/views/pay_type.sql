-- liquibase formatted sql
-- changeset SAMQA:1754374177851 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\pay_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/pay_type.sql:null:b946ef1904710c505af2db274b472058e7d10329:create

create or replace force editionable view samqa.pay_type (
    lookup_name,
    pay_code,
    pay_name
) as
    select
        lookup_name,
        lookup_code pay_code,
        meaning     pay_name
    from
        lookups
    where
        lookup_name = 'PAY_TYPE';

