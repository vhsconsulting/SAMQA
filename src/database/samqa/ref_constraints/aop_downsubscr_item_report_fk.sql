alter table samqa.aop_downsubscr_item
    add constraint aop_downsubscr_item_report_fk
        foreign key ( downsubscr_id )
            references samqa.aop_downsubscr ( id )
        enable;


-- sqlcl_snapshot {"hash":"4c9fd526289fb1837c7974147ca872acd67feb35","type":"REF_CONSTRAINT","name":"AOP_DOWNSUBSCR_ITEM_REPORT_FK","schemaName":"SAMQA","sxml":""}