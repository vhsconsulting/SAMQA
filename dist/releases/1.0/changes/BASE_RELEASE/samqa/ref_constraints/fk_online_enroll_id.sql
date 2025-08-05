-- liquibase formatted sql
-- changeset SAMQA:1754374147021 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\fk_online_enroll_id.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/fk_online_enroll_id.sql:null:bc2b1c8fc311a4adc96d8967f24cd5e6c9eec8ab:create

alter table samqa.online_enroll_plans
    add constraint fk_online_enroll_id
        foreign key ( enrollment_id )
            references samqa.online_enrollment ( enrollment_id )
        enable;

