-- liquibase formatted sql
-- changeset SAMQA:1754374147211 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\person_person.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/person_person.sql:null:2fc7a39d4001993c19a9c8f19832469613291c8f:create

alter table samqa.debit_card_updates
    add constraint person_person
        foreign key ( pers_id )
            references samqa.person ( pers_id )
        enable;

