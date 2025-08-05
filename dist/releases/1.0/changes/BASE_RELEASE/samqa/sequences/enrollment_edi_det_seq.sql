-- liquibase formatted sql
-- changeset SAMQA:1754374148511 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\enrollment_edi_det_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/enrollment_edi_det_seq.sql:null:70f750a986cb26d8938bb304bcf612d89c6afe37:create

create sequence samqa.enrollment_edi_det_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 702541 cache 20
noorder nocycle nokeep noscale global;

