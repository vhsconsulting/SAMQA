-- liquibase formatted sql
-- changeset SAMQA:1754373939262 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claim.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claim.sql:null:8cd533aeab1a07b79428a1afadd6a88ef4faaa38:create

grant delete on samqa.claim to rl_sam_rw;

grant insert on samqa.claim to rl_sam_rw;

grant select on samqa.claim to rl_sam1_ro;

grant select on samqa.claim to rl_sam_rw;

grant select on samqa.claim to rl_sam_ro;

grant update on samqa.claim to rl_sam_rw;

