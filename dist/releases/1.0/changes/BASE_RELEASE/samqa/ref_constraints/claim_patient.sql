-- liquibase formatted sql
-- changeset SAMQA:1754374146883 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\claim_patient.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/claim_patient.sql:null:0356f4c8298f5d36f7dae82332ec16a1904dc165:create

alter table samqa.claim
    add constraint claim_patient
        foreign key ( pers_patient )
            references samqa.person ( pers_id )
        enable;

