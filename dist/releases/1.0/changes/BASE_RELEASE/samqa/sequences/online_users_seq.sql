-- liquibase formatted sql
-- changeset SAMQA:1754374149537 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\online_users_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/online_users_seq.sql:null:fd97605ebfe619a7ada7809dbc6f6e970041b19a:create

create sequence samqa.online_users_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 624118 cache 20 noorder
nocycle nokeep noscale global;

