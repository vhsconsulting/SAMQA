alter table samqa.vendor_class_gp
    add constraint vendor_class_gp_r
        foreign key ( checkbook_id )
            references samqa.checkbook_gp ( checkbook_id )
        enable;


-- sqlcl_snapshot {"hash":"e3e25423bcd88d9b271d40ec5ad541fa66fcda84","type":"REF_CONSTRAINT","name":"VENDOR_CLASS_GP_R","schemaName":"SAMQA","sxml":""}