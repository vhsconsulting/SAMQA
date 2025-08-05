-- liquibase formatted sql
-- changeset SAMQA:1754373937472 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.claim_edi_hdr_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.claim_edi_hdr_seq.sql:null:d9b790739d4f414246e03f55dfe75ca531c64fdf:create

grant select on samqa.claim_edi_hdr_seq to rl_sam_rw;

