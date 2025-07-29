alter table samqa.item_master
    add constraint item_master_r2
        foreign key ( item_class_id )
            references samqa.item_class ( item_class_id )
        enable;


-- sqlcl_snapshot {"hash":"4221b7db4a1b7e2e945070f95a3dd836614554bb","type":"REF_CONSTRAINT","name":"ITEM_MASTER_R2","schemaName":"SAMQA","sxml":""}