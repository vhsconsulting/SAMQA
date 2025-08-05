alter table samqa.claimn
    add constraint claimn_patient
        foreign key ( pers_patient )
            references samqa.person ( pers_id )
        enable;


-- sqlcl_snapshot {"hash":"f3f38c33945b55e79812a87980e83620ccea86cc","type":"REF_CONSTRAINT","name":"CLAIMN_PATIENT","schemaName":"SAMQA","sxml":""}