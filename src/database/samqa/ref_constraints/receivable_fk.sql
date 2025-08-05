alter table samqa.receivable
    add constraint receivable_fk
        foreign key ( invoice_id )
            references samqa.ar_invoice ( invoice_id )
        enable;


-- sqlcl_snapshot {"hash":"c591f89ecee121c71ec455b88e4e38eaa6f1f77f","type":"REF_CONSTRAINT","name":"RECEIVABLE_FK","schemaName":"SAMQA","sxml":""}