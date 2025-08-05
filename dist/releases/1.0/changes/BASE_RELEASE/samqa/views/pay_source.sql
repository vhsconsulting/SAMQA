-- liquibase formatted sql
-- changeset SAMQA:1754374177842 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\pay_source.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/pay_source.sql:null:66eaae24e738f69acc0ec2b4a3f6e0e5a485718e:create

create or replace force editionable view samqa.pay_source (
    pay_source_code,
    pay_source_name
) as
    select
        lookup_code pay_source_code,
        meaning     pay_source_name
    from
        lookups
    where
        lookup_name = 'PAY_SOURCE';

