-- liquibase formatted sql
-- changeset SAMQA:1754374147450 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\activity_statement_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/activity_statement_seq.sql:null:f75d9c9cd02d068acb3d8c1d25a2ad184e8e9eb1:create

create sequence samqa.activity_statement_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 146331345 cache
20 noorder nocycle nokeep noscale global;

