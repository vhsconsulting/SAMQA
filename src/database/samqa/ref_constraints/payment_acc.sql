alter table samqa.payment
    add constraint payment_acc
        foreign key ( acc_id )
            references samqa.account ( acc_id )
        enable;


-- sqlcl_snapshot {"hash":"be0aad9d6276f027647cecd2abe9f263427ab50c","type":"REF_CONSTRAINT","name":"PAYMENT_ACC","schemaName":"SAMQA","sxml":""}