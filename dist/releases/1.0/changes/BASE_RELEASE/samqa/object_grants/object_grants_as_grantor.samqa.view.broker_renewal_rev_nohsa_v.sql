-- liquibase formatted sql
-- changeset SAMQA:1754373943127 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.broker_renewal_rev_nohsa_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.broker_renewal_rev_nohsa_v.sql:null:9ecc05dd21f4ff8f4eb34647cffc3c203ac3a365:create

grant select on samqa.broker_renewal_rev_nohsa_v to rl_sam_ro;

grant read on samqa.broker_renewal_rev_nohsa_v to rl_sam_ro;

grant on commit refresh on samqa.broker_renewal_rev_nohsa_v to rl_sam_ro;

grant query rewrite on samqa.broker_renewal_rev_nohsa_v to rl_sam_ro;

grant debug on samqa.broker_renewal_rev_nohsa_v to rl_sam_ro;

grant flashback on samqa.broker_renewal_rev_nohsa_v to rl_sam_ro;

grant merge view on samqa.broker_renewal_rev_nohsa_v to rl_sam_ro;

