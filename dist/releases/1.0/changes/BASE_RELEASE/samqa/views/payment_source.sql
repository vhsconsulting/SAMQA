-- liquibase formatted sql
-- changeset SAMQA:1754374177933 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\payment_source.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/payment_source.sql:null:4b0d85aea30889589e0ad83f2125ffa688d5c57e:create

create or replace force editionable view samqa.payment_source (
    pay_source,
    description
) as
    select
        lookup_code pay_source,
        description
    from
        lookups
    where
        lookup_name = 'PAYMENT_SOURCE';

