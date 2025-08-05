-- liquibase formatted sql
-- changeset SAMQA:1754374149444 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\notif_template_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/notif_template_seq.sql:null:7612b8cfb5607a2f66fe699c94f6016ca65b4168:create

create sequence samqa.notif_template_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 1582 cache 20 noorder
nocycle nokeep noscale global;

