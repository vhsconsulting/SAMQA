-- liquibase formatted sql
-- changeset SAMQA:1754374178554 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\run_out_term.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/run_out_term.sql:null:68cd9a7bfd9e73b53e2ff6b1b28238afd9cfb5b5:create

create or replace force editionable view samqa.run_out_term (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'RUN_OUT_TERM';

