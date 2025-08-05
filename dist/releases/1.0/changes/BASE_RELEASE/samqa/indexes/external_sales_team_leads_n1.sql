-- liquibase formatted sql
-- changeset SAMQA:1754373931502 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\external_sales_team_leads_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/external_sales_team_leads_n1.sql:null:5385cbf89f99f9a2c3db0a3b4a6b007452af7353:create

create index samqa.external_sales_team_leads_n1 on
    samqa.external_sales_team_leads (
        entrp_id
    );

