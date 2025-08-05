-- liquibase formatted sql
-- changeset SAMQA:1754374148698 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\erisa_file_upload_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/erisa_file_upload_seq.sql:null:698e05e54f757725fecaa3d6a628c633292e4f69:create

create sequence samqa.erisa_file_upload_seq minvalue 1 maxvalue 9999999999999999 increment by 1 start with 1 nocache noorder nocycle nokeep
noscale global;

