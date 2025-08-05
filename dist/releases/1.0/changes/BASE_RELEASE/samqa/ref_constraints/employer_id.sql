-- liquibase formatted sql
-- changeset SAMQA:1754374146968 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\employer_id.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/employer_id.sql:null:29f4260a42db520a4eb49014c940341dc844b088:create

alter table samqa.employer
    add constraint employer_id
        foreign key ( entrp_id )
            references samqa.enterprise ( entrp_id )
        enable;

