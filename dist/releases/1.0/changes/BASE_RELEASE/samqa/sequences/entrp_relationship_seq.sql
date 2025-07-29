-- liquibase formatted sql
-- changeset SAMQA:1753779761607 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\entrp_relationship_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/entrp_relationship_seq.sql:null:f31cb0671af38653d714e5a8af28431171f67446:create

create sequence samqa.entrp_relationship_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 26264 cache 20
noorder nocycle nokeep noscale global;

