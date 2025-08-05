-- liquibase formatted sql
-- changeset SAMQA:1754374150235 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\trc_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/trc_seq.sql:null:d306cfdeaf9f60314b3af30c57550ff93c0206c5:create

create sequence samqa.trc_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 7281 cache 20 noorder nocycle
nokeep noscale global;

