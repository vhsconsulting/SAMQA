-- liquibase formatted sql
-- changeset SAMQA:1754374148532 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\entrp_relationship_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/entrp_relationship_seq.sql:null:52af23048b4231c3810017a29054fcf9f2e83032:create

create sequence samqa.entrp_relationship_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 26524 cache 20
noorder nocycle nokeep noscale global;

