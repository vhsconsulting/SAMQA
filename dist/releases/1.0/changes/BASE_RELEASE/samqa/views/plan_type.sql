-- liquibase formatted sql
-- changeset SAMQA:1754374178250 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\plan_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/plan_type.sql:null:0672b5e9bae30755ee32fd80410abfc46ed99074:create

create or replace force editionable view samqa.plan_type (
    plan_type_code,
    plan_name,
    plan_type
) as
    select
        lookup_code plan_type_code,
        meaning     plan_name,
        description plan_type
    from
        lookups
    where
        lookup_name = 'PLAN_TYPE';

