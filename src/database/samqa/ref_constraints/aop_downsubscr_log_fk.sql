alter table samqa.aop_downsubscr_log
    add constraint aop_downsubscr_log_fk
        foreign key ( downsubscr_id )
            references samqa.aop_downsubscr ( id )
        enable;


-- sqlcl_snapshot {"hash":"48a4e1e560594201696f5331f4e43da22954ea48","type":"REF_CONSTRAINT","name":"AOP_DOWNSUBSCR_LOG_FK","schemaName":"SAMQA","sxml":""}