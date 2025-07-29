alter table samqa.person
    add constraint pers_pers
        foreign key ( pers_main )
            references samqa.person ( pers_id )
                on delete cascade
        enable;


-- sqlcl_snapshot {"hash":"ee610379d42fd671d42d89d4349a73871264c425","type":"REF_CONSTRAINT","name":"PERS_PERS","schemaName":"SAMQA","sxml":""}