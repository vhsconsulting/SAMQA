-- liquibase formatted sql
-- changeset SAMQA:1753779763046 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\sales_team_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/sales_team_seq.sql:null:ef2cfa710a1ca5c3f2b23ec407ce046e95ed92d6:create

create sequence samqa.sales_team_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 805411 cache 20 noorder
nocycle nokeep noscale global;

