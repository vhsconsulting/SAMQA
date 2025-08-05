-- liquibase formatted sql
-- changeset SAMQA:1754374148787 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\file_attachments_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/file_attachments_seq.sql:null:3c8295ad84f16d3336e5c1d5982e1b1748a346af:create

create sequence samqa.file_attachments_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 2395186 cache 20
noorder nocycle nokeep noscale global;

