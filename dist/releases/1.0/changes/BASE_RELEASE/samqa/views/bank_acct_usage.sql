-- liquibase formatted sql
-- changeset SAMQA:1754374168356 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\bank_acct_usage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/bank_acct_usage.sql:null:7e38bbb8132882636242b43af2e79f65f2262a40:create

create or replace force editionable view samqa.bank_acct_usage (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'BANK_ACCT_USAGE';

