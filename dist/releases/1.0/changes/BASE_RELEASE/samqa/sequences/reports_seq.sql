-- liquibase formatted sql
-- changeset SAMQA:1754374149884 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\reports_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/reports_seq.sql:null:f8ee85505cb7ee796d10d52e13a46957024349de:create

create sequence samqa.reports_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 424867 cache 20 noorder nocycle
nokeep noscale global;

