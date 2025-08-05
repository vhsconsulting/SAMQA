-- liquibase formatted sql
-- changeset SAMQA:1754373943118 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.broker_renewal_rev_hsa_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.broker_renewal_rev_hsa_v.sql:null:98e454e52bc3394b3cf0a26dd4efe2f481388438:create

grant select on samqa.broker_renewal_rev_hsa_v to rl_sam_ro;

grant read on samqa.broker_renewal_rev_hsa_v to rl_sam_ro;

grant on commit refresh on samqa.broker_renewal_rev_hsa_v to rl_sam_ro;

grant query rewrite on samqa.broker_renewal_rev_hsa_v to rl_sam_ro;

grant debug on samqa.broker_renewal_rev_hsa_v to rl_sam_ro;

grant flashback on samqa.broker_renewal_rev_hsa_v to rl_sam_ro;

grant merge view on samqa.broker_renewal_rev_hsa_v to rl_sam_ro;

