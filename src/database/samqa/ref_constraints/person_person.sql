alter table samqa.debit_card_updates
    add constraint person_person
        foreign key ( pers_id )
            references samqa.person ( pers_id )
        enable;


-- sqlcl_snapshot {"hash":"2fc7a39d4001993c19a9c8f19832469613291c8f","type":"REF_CONSTRAINT","name":"PERSON_PERSON","schemaName":"SAMQA","sxml":""}