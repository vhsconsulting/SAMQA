alter table samqa.card_debit
    add constraint card_debit_emitent
        foreign key ( emitent )
            references samqa.enterprise ( entrp_id )
        enable;


-- sqlcl_snapshot {"hash":"385f75a339a89c8ccca52d5707bffbe306b59a0d","type":"REF_CONSTRAINT","name":"CARD_DEBIT_EMITENT","schemaName":"SAMQA","sxml":""}