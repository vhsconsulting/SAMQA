-- liquibase formatted sql
-- changeset SAMQA:1754373932869 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\person_mass_enrollments_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/person_mass_enrollments_n1.sql:null:d042b487531c5662c4047ad665c414ad090f857c:create

create index samqa.person_mass_enrollments_n1 on
    samqa.person (
        mass_enrollment_id
    );

