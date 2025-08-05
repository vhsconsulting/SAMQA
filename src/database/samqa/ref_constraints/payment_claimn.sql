alter table samqa.payment
    add constraint payment_claimn
        foreign key ( claimn_id )
            references samqa.claimn ( claim_id )
        disable;


-- sqlcl_snapshot {"hash":"1ae08f5fd31f43386e5b563ae045e5ddd207dd25","type":"REF_CONSTRAINT","name":"PAYMENT_CLAIMN","schemaName":"SAMQA","sxml":""}