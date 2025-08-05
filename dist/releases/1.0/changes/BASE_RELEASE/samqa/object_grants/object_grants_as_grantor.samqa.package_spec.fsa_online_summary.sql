-- liquibase formatted sql
-- changeset SAMQA:1754373935748 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.fsa_online_summary.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.fsa_online_summary.sql:null:f89652ad600139c2f8a39d3b5e7d7d8ce3a9c998:create

grant execute on samqa.fsa_online_summary to rl_sam_ro;

grant execute on samqa.fsa_online_summary to rl_sam_rw;

grant execute on samqa.fsa_online_summary to rl_sam1_ro;

grant debug on samqa.fsa_online_summary to rl_sam_ro;

grant debug on samqa.fsa_online_summary to sgali;

grant debug on samqa.fsa_online_summary to rl_sam_rw;

grant debug on samqa.fsa_online_summary to rl_sam1_ro;

