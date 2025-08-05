-- liquibase formatted sql
-- changeset SAMQA:1754373939311 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claim_edi_header.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claim_edi_header.sql:null:dd816de1fd6fec98f83c17f9b758c25c90b31380:create

grant delete on samqa.claim_edi_header to rl_sam_rw;

grant insert on samqa.claim_edi_header to rl_sam_rw;

grant select on samqa.claim_edi_header to rl_sam1_ro;

grant select on samqa.claim_edi_header to rl_sam_rw;

grant select on samqa.claim_edi_header to rl_sam_ro;

grant update on samqa.claim_edi_header to rl_sam_rw;

