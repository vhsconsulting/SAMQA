-- liquibase formatted sql
-- changeset SAMQA:1754374148745 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\external_sales_team_lead_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/external_sales_team_lead_seq.sql:null:1e8936e31d3b2ba1f415625966a3ae8abb1a4791:create

create sequence samqa.external_sales_team_lead_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 38708 cache
20 noorder nocycle nokeep noscale global;

