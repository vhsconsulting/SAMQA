-- liquibase formatted sql
-- changeset SAMQA:1754373939291 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claim_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claim_detail.sql:null:2b814f05870643f9c62bad38c5218f8108fb1de2:create

grant delete on samqa.claim_detail to rl_sam_rw;

grant insert on samqa.claim_detail to rl_sam_rw;

grant select on samqa.claim_detail to rl_sam1_ro;

grant select on samqa.claim_detail to rl_sam_rw;

grant select on samqa.claim_detail to rl_sam_ro;

grant update on samqa.claim_detail to rl_sam_rw;

