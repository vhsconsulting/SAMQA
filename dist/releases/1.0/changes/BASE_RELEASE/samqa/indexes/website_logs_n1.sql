-- liquibase formatted sql
-- changeset SAMQA:1754373933626 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\website_logs_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/website_logs_n1.sql:null:43e57b9ebee11c16b9f1b60b4b16924f21c5180f:create

create index samqa.website_logs_n1 on
    samqa.website_logs (
        component
    );

