alter table samqa.claim
    add constraint claim_patient
        foreign key ( pers_patient )
            references samqa.person ( pers_id )
        enable;


-- sqlcl_snapshot {"hash":"0356f4c8298f5d36f7dae82332ec16a1904dc165","type":"REF_CONSTRAINT","name":"CLAIM_PATIENT","schemaName":"SAMQA","sxml":""}