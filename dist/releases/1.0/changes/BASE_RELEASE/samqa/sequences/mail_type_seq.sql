-- liquibase formatted sql
-- changeset SAMQA:1754374149218 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\mail_type_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/mail_type_seq.sql:null:373c453d489a11b26aa8cf9831964ba055dd716f:create

create sequence samqa.mail_type_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 65 cache 20 noorder nocycle
nokeep noscale global;

