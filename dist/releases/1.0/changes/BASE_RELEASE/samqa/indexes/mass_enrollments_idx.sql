-- liquibase formatted sql
-- changeset SAMQA:1754373931953 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\mass_enrollments_idx.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/mass_enrollments_idx.sql:null:1555f2a3b61dd778e3e04cdb7217f8dc0d97e72e:create

create index samqa.mass_enrollments_idx on
    samqa.mass_enrollments (
        batch_number
    );

