alter table samqa.claimn
    add constraint claimn_pers
        foreign key ( pers_id )
            references samqa.person ( pers_id )
        enable;


-- sqlcl_snapshot {"hash":"47b4f3867678f533e57c7053aa98f4af0f55cb3c","type":"REF_CONSTRAINT","name":"CLAIMN_PERS","schemaName":"SAMQA","sxml":""}