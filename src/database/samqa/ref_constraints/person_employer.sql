alter table samqa.person
    add constraint person_employer
        foreign key ( entrp_id )
            references samqa.enterprise ( entrp_id )
        enable;


-- sqlcl_snapshot {"hash":"7ca009ea5f4e8841b673324429af790f59b76427","type":"REF_CONSTRAINT","name":"PERSON_EMPLOYER","schemaName":"SAMQA","sxml":""}