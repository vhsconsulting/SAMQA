-- liquibase formatted sql
-- changeset SAMQA:1754373944347 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hrafsa_future_claim_letters_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hrafsa_future_claim_letters_v.sql:null:738f549df48f2eddc3ba174d80a09e9732fcaded:create

grant select on samqa.hrafsa_future_claim_letters_v to rl_sam1_ro;

grant select on samqa.hrafsa_future_claim_letters_v to rl_sam_rw;

grant select on samqa.hrafsa_future_claim_letters_v to rl_sam_ro;

grant select on samqa.hrafsa_future_claim_letters_v to sgali;

