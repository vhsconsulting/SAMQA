-- liquibase formatted sql
-- changeset SAMQA:1754374148879 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\fsa_relationship_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/fsa_relationship_seq.sql:null:d8012df9c1b8b25c6e6bebea67cff265632f28e8:create

create sequence samqa.fsa_relationship_seq minvalue 1001 maxvalue 999999999 increment by 1 start with 337427 nocache noorder nocycle nokeep
noscale global;

