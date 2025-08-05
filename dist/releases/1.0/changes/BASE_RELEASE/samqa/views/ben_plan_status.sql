-- liquibase formatted sql
-- changeset SAMQA:1754374168631 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\ben_plan_status.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/ben_plan_status.sql:null:efab44d657ffc3a477e2f5c293707e687e2dc6ea:create

create or replace force editionable view samqa.ben_plan_status (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'BEN_PLAN_STATUS';

