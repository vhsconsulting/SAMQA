-- liquibase formatted sql
-- changeset SAMQA:1754373941504 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.opportunity_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.opportunity_history.sql:null:0c8b690699c0233f3b35417dc64e0408992d59e3:create

grant select on samqa.opportunity_history to rl_sam_ro;

