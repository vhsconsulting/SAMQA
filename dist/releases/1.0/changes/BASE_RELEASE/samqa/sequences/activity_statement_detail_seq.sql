-- liquibase formatted sql
-- changeset SAMQA:1754374147438 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\activity_statement_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/activity_statement_detail_seq.sql:null:3c872774f9ea956ddf2b089c5ee9b4176c4846f2:create

create sequence samqa.activity_statement_detail_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 362729556
cache 20 noorder nocycle nokeep noscale global;

