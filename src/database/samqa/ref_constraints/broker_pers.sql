alter table samqa.broker
    add constraint broker_pers
        foreign key ( broker_id )
            references samqa.person ( pers_id )
        enable;


-- sqlcl_snapshot {"hash":"ad1cb42a91d48ece54fff0abf192bf9948a851ee","type":"REF_CONSTRAINT","name":"BROKER_PERS","schemaName":"SAMQA","sxml":""}