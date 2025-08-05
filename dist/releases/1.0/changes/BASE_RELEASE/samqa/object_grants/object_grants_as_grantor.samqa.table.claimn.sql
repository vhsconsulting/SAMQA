-- liquibase formatted sql
-- changeset SAMQA:1754373939371 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claimn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claimn.sql:null:e554a59b2180bf13faa70226430bf5c87d9a8d02:create

grant delete on samqa.claimn to rl_sam_rw;

grant insert on samqa.claimn to rl_sam_rw;

grant select on samqa.claimn to rl_sam1_ro;

grant select on samqa.claimn to rl_sam_rw;

grant select on samqa.claimn to rl_sam_ro;

grant update on samqa.claimn to rl_sam_rw;

