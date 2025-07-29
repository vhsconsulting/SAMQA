alter table samqa.payment
    add constraint payment_reason
        foreign key ( reason_code )
            references samqa.pay_reason ( reason_code )
        enable;


-- sqlcl_snapshot {"hash":"3e0d927b8b548797c898a676c145eef9590c014b","type":"REF_CONSTRAINT","name":"PAYMENT_REASON","schemaName":"SAMQA","sxml":""}