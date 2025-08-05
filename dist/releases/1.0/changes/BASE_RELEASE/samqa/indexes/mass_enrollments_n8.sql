-- liquibase formatted sql
-- changeset SAMQA:1754373931985 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\mass_enrollments_n8.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/mass_enrollments_n8.sql:null:9619001e2f5524a237acffe778f93e203ea7ff63:create

create index samqa.mass_enrollments_n8 on
    samqa.mass_enrollments (
        employer_name
    );

