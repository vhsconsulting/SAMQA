-- liquibase formatted sql
-- changeset SAMQA:1754373931494 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\external_sales_team_leads_idx.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/external_sales_team_leads_idx.sql:null:f4ffc6b546b38a0672aba8300e28af8d749f7506:create

create index samqa.external_sales_team_leads_idx on
    samqa.external_sales_team_leads (
        ref_entity_id
    );

