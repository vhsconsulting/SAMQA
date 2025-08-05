-- liquibase formatted sql
-- changeset SAMQA:1754373932153 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_errors_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_errors_n2.sql:null:e0bafacca42fbadbd3cdf0b7fa242203f0121c4f:create

create index samqa.metavante_errors_n2 on
    samqa.metavante_errors (
        error_id,
        employee_id,
        dependant_id
    );

