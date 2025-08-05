-- liquibase formatted sql
-- changeset SAMQA:1754373943297 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.claim_edi_external_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.claim_edi_external_v.sql:null:83e876b88a5756309c9c2146e809f3a018bcf959:create

grant select on samqa.claim_edi_external_v to rl_sam1_ro;

grant select on samqa.claim_edi_external_v to rl_sam_rw;

grant select on samqa.claim_edi_external_v to rl_sam_ro;

grant select on samqa.claim_edi_external_v to sgali;

