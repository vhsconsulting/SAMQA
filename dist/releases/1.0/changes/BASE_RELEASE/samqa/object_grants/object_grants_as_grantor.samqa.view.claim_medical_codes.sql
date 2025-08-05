-- liquibase formatted sql
-- changeset SAMQA:1754373943310 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.claim_medical_codes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.claim_medical_codes.sql:null:557726e8d8b18ad095d792db82230c0776e65ae5:create

grant select on samqa.claim_medical_codes to rl_sam1_ro;

grant select on samqa.claim_medical_codes to rl_sam_rw;

grant select on samqa.claim_medical_codes to rl_sam_ro;

grant select on samqa.claim_medical_codes to sgali;

