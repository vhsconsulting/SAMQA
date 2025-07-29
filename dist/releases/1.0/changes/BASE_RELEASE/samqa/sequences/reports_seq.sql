-- liquibase formatted sql
-- changeset SAMQA:1753779762962 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\reports_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/reports_seq.sql:null:b9520b05993750bffe5d415c53f5964e40dd3686:create

create sequence samqa.reports_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 424827 cache 20 noorder nocycle
nokeep noscale global;

