-- liquibase formatted sql
-- changeset SAMQA:1754374150024 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\sam_users_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/sam_users_seq.sql:null:a3c75a9c51595539c5deac714ea99aec9b3d0326:create

create sequence samqa.sam_users_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 10583 cache 20 noorder nocycle
nokeep noscale global;

