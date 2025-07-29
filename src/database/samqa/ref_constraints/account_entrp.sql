alter table samqa.account
    add constraint account_entrp
        foreign key ( entrp_id )
            references samqa.enterprise ( entrp_id )
        enable;


-- sqlcl_snapshot {"hash":"d4b2dea519b33b17c81dee3515d8c7ef6c0d889f","type":"REF_CONSTRAINT","name":"ACCOUNT_ENTRP","schemaName":"SAMQA","sxml":""}