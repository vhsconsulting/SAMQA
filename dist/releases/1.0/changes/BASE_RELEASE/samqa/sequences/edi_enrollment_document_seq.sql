-- liquibase formatted sql
-- changeset SAMQA:1754374148387 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\edi_enrollment_document_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/edi_enrollment_document_seq.sql:null:4fc77257e973a8cc066d3537c5e9270520b95d72:create

create sequence samqa.edi_enrollment_document_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1 cache 20
noorder nocycle nokeep noscale global;

