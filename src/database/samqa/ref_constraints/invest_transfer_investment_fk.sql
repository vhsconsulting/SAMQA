alter table samqa.invest_transfer
    add constraint invest_transfer_investment_fk
        foreign key ( investment_id )
            references samqa.investment ( investment_id )
        enable;


-- sqlcl_snapshot {"hash":"316e043cf7034d4897e7ba6ac99273d55eebe3fb","type":"REF_CONSTRAINT","name":"INVEST_TRANSFER_INVESTMENT_FK","schemaName":"SAMQA","sxml":""}