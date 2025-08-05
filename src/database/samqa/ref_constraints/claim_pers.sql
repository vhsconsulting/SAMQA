alter table samqa.claim
    add constraint claim_pers
        foreign key ( pers_id )
            references samqa.person ( pers_id )
        enable;


-- sqlcl_snapshot {"hash":"2eea4aea5c0ea924d0dc4bd9c36eb63cff34d873","type":"REF_CONSTRAINT","name":"CLAIM_PERS","schemaName":"SAMQA","sxml":""}