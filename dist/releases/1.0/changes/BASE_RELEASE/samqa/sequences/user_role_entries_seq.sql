-- liquibase formatted sql
-- changeset SAMQA:1753779763331 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\user_role_entries_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/user_role_entries_seq.sql:null:95ec9526dd57357325b8713d587254c2da661d62:create

create sequence samqa.user_role_entries_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 778185 cache 20
noorder nocycle nokeep noscale global;

