-- liquibase formatted sql
-- changeset SAMQA:1754373932134 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_errors_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_errors_n1.sql:null:5cf4ec1d9d26cd16c82bd8ef9eb42446806cdcf9:create

create index samqa.metavante_errors_n1 on
    samqa.metavante_errors (
        error_id,
        employee_id
    );

