-- liquibase formatted sql
-- changeset SAMQA:1754373933264 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sales_team_member_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sales_team_member_n1.sql:null:e281e362d523bd0dc967e379c4951cad27fa5a53:create

create index samqa.sales_team_member_n1 on
    samqa.sales_team_member (
        emplr_id
    );

