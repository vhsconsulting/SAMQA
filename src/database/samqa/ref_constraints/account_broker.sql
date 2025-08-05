alter table samqa.account
    add constraint account_broker
        foreign key ( broker_id )
            references samqa.broker ( broker_id )
        enable;


-- sqlcl_snapshot {"hash":"85d99a33f243f618c566924bc141186940723f8c","type":"REF_CONSTRAINT","name":"ACCOUNT_BROKER","schemaName":"SAMQA","sxml":""}