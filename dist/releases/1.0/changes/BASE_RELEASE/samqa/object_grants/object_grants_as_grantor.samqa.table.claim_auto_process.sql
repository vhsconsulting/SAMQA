-- liquibase formatted sql
-- changeset SAMQA:1754373939271 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claim_auto_process.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claim_auto_process.sql:null:b7cd4509850cc3b9558efc3fda4f8666265dcbc2:create

grant delete on samqa.claim_auto_process to rl_sam_rw;

grant insert on samqa.claim_auto_process to rl_sam_rw;

grant select on samqa.claim_auto_process to rl_sam1_ro;

grant select on samqa.claim_auto_process to rl_sam_rw;

grant select on samqa.claim_auto_process to rl_sam_ro;

grant update on samqa.claim_auto_process to rl_sam_rw;

