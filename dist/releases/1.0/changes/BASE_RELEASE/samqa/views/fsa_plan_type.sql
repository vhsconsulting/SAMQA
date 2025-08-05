-- liquibase formatted sql
-- changeset SAMQA:1754374174830 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\fsa_plan_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/fsa_plan_type.sql:null:856df9d15b4c6ffe11f12b0b39e858b7b20b8c77:create

create or replace force editionable view samqa.fsa_plan_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'FSA_PLAN_TYPE';

