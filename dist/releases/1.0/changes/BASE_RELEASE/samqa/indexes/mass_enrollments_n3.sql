-- liquibase formatted sql
-- changeset SAMQA:1754373931976 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\mass_enrollments_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/mass_enrollments_n3.sql:null:f9c463802cb40f3d88c45f3f0efc783030d209dc:create

create index samqa.mass_enrollments_n3 on
    samqa.mass_enrollments (
        entrp_id
    );

