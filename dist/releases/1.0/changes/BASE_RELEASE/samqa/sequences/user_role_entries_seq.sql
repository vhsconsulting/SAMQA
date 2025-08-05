-- liquibase formatted sql
-- changeset SAMQA:1754374150273 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\user_role_entries_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/user_role_entries_seq.sql:null:8951936b29029321761c127702ba0520c7283d3e:create

create sequence samqa.user_role_entries_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 778725 cache 20
noorder nocycle nokeep noscale global;

