-- liquibase formatted sql
-- changeset SAMQA:1754373933626 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\website_logs_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/website_logs_n2.sql:null:909349051c475ae0d33933e102abdab9f271a5e0:create

create index samqa.website_logs_n2 on
    samqa.website_logs (
        creation_date
    );

