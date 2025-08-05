-- liquibase formatted sql
-- changeset SAMQA:1754374174449 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\fsa_hra_plan_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/fsa_hra_plan_type.sql:null:060d2863b54865c08eefbf71bba3cc296a35b300:create

create or replace force editionable view samqa.fsa_hra_plan_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'FSA_HRA_PLAN_TYPE'
    union
    select
        lookup_code,
        meaning
    from
        lookups
    where
            lookup_name = 'FSA_PLAN_TYPE'
        and lookup_code <> 'HRA';

