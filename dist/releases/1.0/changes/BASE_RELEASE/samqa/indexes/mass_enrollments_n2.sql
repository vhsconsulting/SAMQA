-- liquibase formatted sql
-- changeset SAMQA:1754373931969 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\mass_enrollments_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/mass_enrollments_n2.sql:null:affc78ae54dd7ed96583cc9376478c864fe3f8bb:create

create index samqa.mass_enrollments_n2 on
    samqa.mass_enrollments (
        ssn
    );

