-- liquibase formatted sql
-- changeset SAMQA:1754374148371 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\doc_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/doc_seq.sql:null:485bf2baeff48fd49e3ab20f58bd54e0eca938ea:create

create sequence samqa.doc_seq minvalue 1 maxvalue 1000000000000000000000000000 increment by 1 start with 8406072 nocache noorder nocycle
nokeep noscale global;

