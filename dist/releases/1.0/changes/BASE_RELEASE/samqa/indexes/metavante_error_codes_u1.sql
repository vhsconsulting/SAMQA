-- liquibase formatted sql
-- changeset SAMQA:1754373932126 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_error_codes_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_error_codes_u1.sql:null:c381e1c53bcbde9886a5069285bcb8a3a074f3f9:create

create unique index samqa.metavante_error_codes_u1 on
    samqa.metavante_error_codes (
        error_id
    );

