-- liquibase formatted sql
-- changeset SAMQA:1754373944364 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hsa_claim_report_online_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hsa_claim_report_online_v.sql:null:7fcaa81743dc4fac19f868523cfe5023a7513764:create

grant select on samqa.hsa_claim_report_online_v to rl_sam1_ro;

grant select on samqa.hsa_claim_report_online_v to rl_sam_rw;

grant select on samqa.hsa_claim_report_online_v to rl_sam_ro;

grant select on samqa.hsa_claim_report_online_v to sgali;

