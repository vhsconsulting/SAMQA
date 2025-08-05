-- liquibase formatted sql
-- changeset SAMQA:1754373945363 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.unsubstantiated_debit_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.unsubstantiated_debit_claims_v.sql:null:660fef555eaa03996657dc49529774c413c8e371:create

grant select on samqa.unsubstantiated_debit_claims_v to rl_sam_rw;

grant select on samqa.unsubstantiated_debit_claims_v to rl_sam_ro;

grant select on samqa.unsubstantiated_debit_claims_v to sgali;

grant select on samqa.unsubstantiated_debit_claims_v to rl_sam1_ro;

