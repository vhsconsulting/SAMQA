-- liquibase formatted sql
-- changeset SAMQA:1754374149970 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\sales_team_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/sales_team_seq.sql:null:7348b9eb9f8c966c29a95a55c8d4dcf5f852f975:create

create sequence samqa.sales_team_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 805471 cache 20 noorder
nocycle nokeep noscale global;

