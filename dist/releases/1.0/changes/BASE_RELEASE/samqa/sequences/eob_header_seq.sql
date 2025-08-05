-- liquibase formatted sql
-- changeset SAMQA:1754374148611 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\eob_header_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/eob_header_seq.sql:null:0162e800e7427e86f1f6d5955c246d743114930d:create

create sequence samqa.eob_header_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1382 nocache noorder nocycle
nokeep noscale global;

