-- liquibase formatted sql
-- changeset SAMQA:1753779761817 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\external_sales_team_lead_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/external_sales_team_lead_seq.sql:null:75deba5aff6144f503adab1c286f618d0c3c9a31:create

create sequence samqa.external_sales_team_lead_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 38668 cache
20 noorder nocycle nokeep noscale global;

