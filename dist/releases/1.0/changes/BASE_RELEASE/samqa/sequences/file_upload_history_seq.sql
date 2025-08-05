-- liquibase formatted sql
-- changeset SAMQA:1754374148826 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\file_upload_history_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/file_upload_history_seq.sql:null:b22afd4b9433d5bd63cae8c3c1895c30600e3c5c:create

create sequence samqa.file_upload_history_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 221467 cache 20
noorder nocycle nokeep noscale global;

