alter table samqa.rate_structure
    add constraint rate_pay_reason_fk
        foreign key ( rate_id )
            references samqa.pay_reason ( reason_code )
        enable;


-- sqlcl_snapshot {"hash":"8359cabb76c9931d4f91c036cc9cd04ef85673e8","type":"REF_CONSTRAINT","name":"RATE_PAY_REASON_FK","schemaName":"SAMQA","sxml":""}