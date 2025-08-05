-- liquibase formatted sql
-- changeset SAMQA:1754374147200 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\person_employer.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/person_employer.sql:null:7ca009ea5f4e8841b673324429af790f59b76427:create

alter table samqa.person
    add constraint person_employer
        foreign key ( entrp_id )
            references samqa.enterprise ( entrp_id )
        enable;

