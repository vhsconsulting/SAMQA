-- liquibase formatted sql
-- changeset SAMQA:1754374147011 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\fk_enroll_id.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/fk_enroll_id.sql:null:ec23a961644cbb362a8dd0044031a4528ddde25a:create

alter table samqa.mass_enroll_plans
    add constraint fk_enroll_id
        foreign key ( mass_enrollment_id )
            references samqa.mass_enrollments ( mass_enrollment_id )
        enable;

