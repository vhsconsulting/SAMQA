-- liquibase formatted sql
-- changeset SAMQA:1754374149698 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\pers_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/pers_seq.sql:null:5d148dfafd634056e3028481bceaab6570ad6aea:create

create sequence samqa.pers_seq minvalue 1 maxvalue 999999999 increment by 1 start with 3898323 nocache noorder nocycle nokeep noscale
global;

