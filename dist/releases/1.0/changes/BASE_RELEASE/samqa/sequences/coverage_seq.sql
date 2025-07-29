-- liquibase formatted sql
-- changeset SAMQA:1753779761204 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\coverage_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/coverage_seq.sql:null:31ce91853c8465830d4e1573465ef211cd3fd374:create

create sequence samqa.coverage_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 539597 cache 20 noorder nocycle
nokeep noscale global;

