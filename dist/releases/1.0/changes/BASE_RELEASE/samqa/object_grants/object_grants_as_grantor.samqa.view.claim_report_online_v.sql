-- liquibase formatted sql
-- changeset SAMQA:1754373943326 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.claim_report_online_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.claim_report_online_v.sql:null:e0381bdab38b733955e3d5fcd90e8382c8b4b1e3:create

grant select on samqa.claim_report_online_v to rl_sam1_ro;

grant select on samqa.claim_report_online_v to rl_sam_rw;

grant select on samqa.claim_report_online_v to rl_sam_ro;

grant select on samqa.claim_report_online_v to sgali;

