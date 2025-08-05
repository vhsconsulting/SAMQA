-- liquibase formatted sql
-- changeset SAMQA:1754374150107 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\security_images_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/security_images_seq.sql:null:68045b6bdc76e49889d8ecf99746891abe794352:create

create sequence samqa.security_images_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 41 cache 20 noorder
nocycle nokeep noscale global;

