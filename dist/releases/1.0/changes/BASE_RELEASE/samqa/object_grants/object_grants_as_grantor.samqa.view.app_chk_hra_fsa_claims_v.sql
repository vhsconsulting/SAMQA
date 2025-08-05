-- liquibase formatted sql
-- changeset SAMQA:1754373942895 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.app_chk_hra_fsa_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.app_chk_hra_fsa_claims_v.sql:null:da0e2b2528b5e3e521b7f7d612262af1cc54f8ef:create

grant select on samqa.app_chk_hra_fsa_claims_v to rl_sam1_ro;

grant select on samqa.app_chk_hra_fsa_claims_v to rl_sam_rw;

grant select on samqa.app_chk_hra_fsa_claims_v to rl_sam_ro;

grant select on samqa.app_chk_hra_fsa_claims_v to sgali;

