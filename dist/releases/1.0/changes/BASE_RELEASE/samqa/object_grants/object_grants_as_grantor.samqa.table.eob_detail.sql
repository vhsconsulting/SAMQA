-- liquibase formatted sql
-- changeset SAMQA:1754373940230 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eob_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eob_detail.sql:null:05cfea69adac5453fcf9f16067a4d0db895b4afd:create

grant delete on samqa.eob_detail to rl_sam_rw;

grant insert on samqa.eob_detail to rl_sam_rw;

grant select on samqa.eob_detail to rl_sam1_ro;

grant select on samqa.eob_detail to rl_sam_rw;

grant select on samqa.eob_detail to rl_sam_ro;

grant update on samqa.eob_detail to rl_sam_rw;

