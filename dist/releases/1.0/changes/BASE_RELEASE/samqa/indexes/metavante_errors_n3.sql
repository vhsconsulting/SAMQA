-- liquibase formatted sql
-- changeset SAMQA:1754373932163 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_errors_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_errors_n3.sql:null:0054e3b11cc4ccf1c7ca77c7bee21f76a27bba24:create

create index samqa.metavante_errors_n3 on
    samqa.metavante_errors (
        employee_id
    );

