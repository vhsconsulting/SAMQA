-- liquibase formatted sql
-- changeset SAMQA:1753779761870 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\file_attachments_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/file_attachments_seq.sql:null:101e05442f0a1324557b9b92313414ff92647f38:create

create sequence samqa.file_attachments_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 2395026 cache 20
noorder nocycle nokeep noscale global;

