alter table samqa.account
    add constraint account_pers
        foreign key ( pers_id )
            references samqa.person ( pers_id )
        enable;


-- sqlcl_snapshot {"hash":"934f4d6c61a2ddac096d78b4e0b9b6b7429f513b","type":"REF_CONSTRAINT","name":"ACCOUNT_PERS","schemaName":"SAMQA","sxml":""}