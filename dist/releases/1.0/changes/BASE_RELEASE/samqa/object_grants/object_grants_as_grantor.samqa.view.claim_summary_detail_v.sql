-- liquibase formatted sql
-- changeset SAMQA:1754373943341 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.claim_summary_detail_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.claim_summary_detail_v.sql:null:d33b8f2ce32e73bdba120775e326251dadde46e1:create

grant select on samqa.claim_summary_detail_v to rl_sam1_ro;

grant select on samqa.claim_summary_detail_v to rl_sam_rw;

grant select on samqa.claim_summary_detail_v to rl_sam_ro;

grant select on samqa.claim_summary_detail_v to sgali;

