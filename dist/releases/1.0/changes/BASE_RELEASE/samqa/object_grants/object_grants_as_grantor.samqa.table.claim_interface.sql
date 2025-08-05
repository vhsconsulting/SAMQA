-- liquibase formatted sql
-- changeset SAMQA:1754373939337 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claim_interface.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claim_interface.sql:null:3022a98981b190af273091ddd07f36bf52b5a4bc:create

grant delete on samqa.claim_interface to rl_sam_rw;

grant insert on samqa.claim_interface to rl_sam_rw;

grant select on samqa.claim_interface to rl_sam1_ro;

grant select on samqa.claim_interface to rl_sam_rw;

grant select on samqa.claim_interface to rl_sam_ro;

grant update on samqa.claim_interface to rl_sam_rw;

