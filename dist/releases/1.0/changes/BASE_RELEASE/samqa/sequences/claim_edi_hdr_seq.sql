-- liquibase formatted sql
-- changeset SAMQA:1754374147902 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\claim_edi_hdr_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/claim_edi_hdr_seq.sql:null:a035ce5f983b51a0c93591240b94befee3f6b445:create

create sequence samqa.claim_edi_hdr_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 21 cache 20 noorder
nocycle nokeep noscale global;

