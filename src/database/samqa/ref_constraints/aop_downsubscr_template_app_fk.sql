alter table samqa.aop_downsubscr_template_app
    add constraint aop_downsubscr_template_app_fk
        foreign key ( downsubscr_template_id )
            references samqa.aop_downsubscr_template ( id )
        enable;


-- sqlcl_snapshot {"hash":"3dcf52c0f326072a386f7d69737147cebc57d2cc","type":"REF_CONSTRAINT","name":"AOP_DOWNSUBSCR_TEMPLATE_APP_FK","schemaName":"SAMQA","sxml":""}