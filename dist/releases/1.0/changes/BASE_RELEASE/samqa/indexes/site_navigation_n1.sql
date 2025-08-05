-- liquibase formatted sql
-- changeset SAMQA:1754373933371 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\site_navigation_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/site_navigation_n1.sql:null:2d1b84652a6bc2ec1196ba9105bde6d4d6ad1926:create

create index samqa.site_navigation_n1 on
    samqa.site_navigation (
        nav_code
    );

