-- liquibase formatted sql
-- changeset SAMQA:1754374148467 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\employer_divisions_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/employer_divisions_seq.sql:null:74763a6bd90d3c653a3272131acbb444b9f66ea5:create

create sequence samqa.employer_divisions_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 47073 cache 20
noorder nocycle nokeep noscale global;

