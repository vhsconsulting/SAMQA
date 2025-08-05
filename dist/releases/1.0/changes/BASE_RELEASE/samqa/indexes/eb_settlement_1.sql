-- liquibase formatted sql
-- changeset SAMQA:1754373930843 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\eb_settlement_1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/eb_settlement_1.sql:null:9e3b36a5b722563f8fa4913e5d5b9f6bfb39740d:create

create index samqa.eb_settlement_1 on
    samqa.eb_settlement (
        file_date,
        file_time,
        line,
        processed_date
    );

