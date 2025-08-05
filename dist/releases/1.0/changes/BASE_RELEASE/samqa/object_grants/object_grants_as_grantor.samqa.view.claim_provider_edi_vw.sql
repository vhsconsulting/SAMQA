-- liquibase formatted sql
-- changeset SAMQA:1754373943326 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.claim_provider_edi_vw.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.claim_provider_edi_vw.sql:null:9f3ea144975e8c35cd49e2d3673a570b95cd0170:create

grant select on samqa.claim_provider_edi_vw to rl_sam1_ro;

grant select on samqa.claim_provider_edi_vw to rl_sam_rw;

grant select on samqa.claim_provider_edi_vw to rl_sam_ro;

grant select on samqa.claim_provider_edi_vw to sgali;

