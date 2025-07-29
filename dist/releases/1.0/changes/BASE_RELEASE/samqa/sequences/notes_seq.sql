-- liquibase formatted sql
-- changeset SAMQA:1753779762516 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\notes_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/notes_seq.sql:null:8bc1482c280ab1ef8a16deec88c9fbd99f9b93ff:create

create sequence samqa.notes_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 11903499 cache 20 noorder nocycle
nokeep noscale global;

