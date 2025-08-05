-- liquibase formatted sql
-- changeset SAMQA:1754373939298 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claim_edi_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claim_edi_detail.sql:null:997533903a059d5661ef822fcb1789a525a1ff53:create

grant delete on samqa.claim_edi_detail to rl_sam_rw;

grant insert on samqa.claim_edi_detail to rl_sam_rw;

grant select on samqa.claim_edi_detail to rl_sam1_ro;

grant select on samqa.claim_edi_detail to rl_sam_rw;

grant select on samqa.claim_edi_detail to rl_sam_ro;

grant update on samqa.claim_edi_detail to rl_sam_rw;

