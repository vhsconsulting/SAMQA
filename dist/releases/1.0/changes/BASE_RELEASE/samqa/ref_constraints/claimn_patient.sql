-- liquibase formatted sql
-- changeset SAMQA:1754374146904 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\claimn_patient.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/claimn_patient.sql:null:f3f38c33945b55e79812a87980e83620ccea86cc:create

alter table samqa.claimn
    add constraint claimn_patient
        foreign key ( pers_patient )
            references samqa.person ( pers_id )
        enable;

