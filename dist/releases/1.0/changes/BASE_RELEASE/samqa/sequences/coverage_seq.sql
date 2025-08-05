-- liquibase formatted sql
-- changeset SAMQA:1754374148132 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\coverage_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/coverage_seq.sql:null:096aa26fd65532b5b76989f19de25a483f39f271:create

create sequence samqa.coverage_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 539617 cache 20 noorder nocycle
nokeep noscale global;

