-- liquibase formatted sql
-- changeset SAMQA:1754373944029 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_hra_claim_payments_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_hra_claim_payments_v.sql:null:f4adeca9391511695032236afa8cd8e81e1a9778:create

grant select on samqa.fsa_hra_claim_payments_v to rl_sam1_ro;

grant select on samqa.fsa_hra_claim_payments_v to rl_sam_rw;

grant select on samqa.fsa_hra_claim_payments_v to rl_sam_ro;

grant select on samqa.fsa_hra_claim_payments_v to sgali;

