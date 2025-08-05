-- liquibase formatted sql
-- changeset SAMQA:1754373931511 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\external_sales_team_leads_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/external_sales_team_leads_n2.sql:null:8b12b793ae99269ac33323fb5435f873e65e7350:create

create index samqa.external_sales_team_leads_n2 on
    samqa.external_sales_team_leads (
        ref_entity_id,
        ref_entity_type
    );

