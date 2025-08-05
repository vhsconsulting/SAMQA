-- liquibase formatted sql
-- changeset SAMQA:1754374146841 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\aop_downsubscr_template_app_fk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/aop_downsubscr_template_app_fk.sql:null:3dcf52c0f326072a386f7d69737147cebc57d2cc:create

alter table samqa.aop_downsubscr_template_app
    add constraint aop_downsubscr_template_app_fk
        foreign key ( downsubscr_template_id )
            references samqa.aop_downsubscr_template ( id )
        enable;

