alter table samqa.customer_class_gp
    add constraint customer_class_gp_r
        foreign key ( checkbook_id )
            references samqa.checkbook_gp ( checkbook_id )
        enable;


-- sqlcl_snapshot {"hash":"5e84ff526ea05b58c155b9cd9be800a42a482078","type":"REF_CONSTRAINT","name":"CUSTOMER_CLASS_GP_R","schemaName":"SAMQA","sxml":""}