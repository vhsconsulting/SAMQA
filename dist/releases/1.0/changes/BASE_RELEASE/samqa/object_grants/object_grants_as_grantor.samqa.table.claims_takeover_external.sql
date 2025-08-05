-- liquibase formatted sql
-- changeset SAMQA:1754373939382 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claims_takeover_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claims_takeover_external.sql:null:16c749504823564d0eaa070d96d99eaff52d9e3a:create

grant select on samqa.claims_takeover_external to rl_sam1_ro;

grant select on samqa.claims_takeover_external to rl_sam_ro;

