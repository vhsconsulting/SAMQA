alter table samqa.enterprise
    add constraint enterprise_main
        foreign key ( entrp_main )
            references samqa.enterprise ( entrp_id )
        enable;


-- sqlcl_snapshot {"hash":"edb5778b2bc57692517a00d0f8186f6d1b2ad464","type":"REF_CONSTRAINT","name":"ENTERPRISE_MAIN","schemaName":"SAMQA","sxml":""}