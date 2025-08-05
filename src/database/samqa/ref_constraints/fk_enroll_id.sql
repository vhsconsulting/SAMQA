alter table samqa.mass_enroll_plans
    add constraint fk_enroll_id
        foreign key ( mass_enrollment_id )
            references samqa.mass_enrollments ( mass_enrollment_id )
        enable;


-- sqlcl_snapshot {"hash":"ec23a961644cbb362a8dd0044031a4528ddde25a","type":"REF_CONSTRAINT","name":"FK_ENROLL_ID","schemaName":"SAMQA","sxml":""}