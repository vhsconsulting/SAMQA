-- liquibase formatted sql
-- changeset SAMQA:1754374148082 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\contact_role_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/contact_role_seq.sql:null:2ad27be120d910770e56cc93a311ee5957370787:create

create sequence samqa.contact_role_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 900034 cache 20 noorder
nocycle nokeep noscale global;

