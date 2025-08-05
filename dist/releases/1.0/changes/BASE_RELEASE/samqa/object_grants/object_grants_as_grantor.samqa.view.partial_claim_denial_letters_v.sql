-- liquibase formatted sql
-- changeset SAMQA:1754373944794 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.partial_claim_denial_letters_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.partial_claim_denial_letters_v.sql:null:4104ccb665489531fbd9ab3261cdb172b01da679:create

grant select on samqa.partial_claim_denial_letters_v to rl_sam1_ro;

grant select on samqa.partial_claim_denial_letters_v to rl_sam_rw;

grant select on samqa.partial_claim_denial_letters_v to rl_sam_ro;

grant select on samqa.partial_claim_denial_letters_v to sgali;

