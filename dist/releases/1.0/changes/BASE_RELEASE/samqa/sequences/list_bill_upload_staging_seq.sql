-- liquibase formatted sql
-- changeset SAMQA:1754374149182 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\list_bill_upload_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/list_bill_upload_staging_seq.sql:null:d8dfe1fd092f852971e0e0660c9db94b079fd991:create

create sequence samqa.list_bill_upload_staging_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 816949 cache
20 noorder nocycle nokeep noscale global;

