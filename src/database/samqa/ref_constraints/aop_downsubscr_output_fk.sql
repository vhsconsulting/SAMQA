alter table samqa.aop_downsubscr_output
    add constraint aop_downsubscr_output_fk
        foreign key ( downsubscr_id )
            references samqa.aop_downsubscr ( id )
        enable;


-- sqlcl_snapshot {"hash":"4593f03cbfc2b09681b8161d94fcc7097a5dead3","type":"REF_CONSTRAINT","name":"AOP_DOWNSUBSCR_OUTPUT_FK","schemaName":"SAMQA","sxml":""}