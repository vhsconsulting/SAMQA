alter table samqa.card_debit
    add constraint card_debit_pers
        foreign key ( card_id )
            references samqa.person ( pers_id )
        enable;


-- sqlcl_snapshot {"hash":"56b785b70e8a0e88449969ff544029ab65c62cdd","type":"REF_CONSTRAINT","name":"CARD_DEBIT_PERS","schemaName":"SAMQA","sxml":""}