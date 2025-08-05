-- liquibase formatted sql
-- changeset SAMQA:1754374148518 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\enrollment_edi_header_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/enrollment_edi_header_seq.sql:null:bc40ed952d1e7438a540bbed0cd98ebe777e440f:create

create sequence samqa.enrollment_edi_header_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 3881 cache 20
noorder nocycle nokeep noscale global;

