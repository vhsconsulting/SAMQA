alter table samqa.userip
    add constraint userip_uname
        foreign key ( uname )
            references samqa.userkoa ( uname )
        enable;


-- sqlcl_snapshot {"hash":"af552831043328e68de0c1e4028d6fad37f8fa53","type":"REF_CONSTRAINT","name":"USERIP_UNAME","schemaName":"SAMQA","sxml":""}