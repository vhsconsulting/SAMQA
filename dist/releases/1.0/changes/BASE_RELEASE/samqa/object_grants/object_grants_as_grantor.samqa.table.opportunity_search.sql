-- liquibase formatted sql
-- changeset SAMQA:1754373941517 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.opportunity_search.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.opportunity_search.sql:null:fae18c4974a816aeedc233ca390640866142d5db:create

grant select on samqa.opportunity_search to rl_sam_ro;

