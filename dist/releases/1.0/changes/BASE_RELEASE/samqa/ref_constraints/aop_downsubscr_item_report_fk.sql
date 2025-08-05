-- liquibase formatted sql
-- changeset SAMQA:1754374146806 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\aop_downsubscr_item_report_fk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/aop_downsubscr_item_report_fk.sql:null:4c9fd526289fb1837c7974147ca872acd67feb35:create

alter table samqa.aop_downsubscr_item
    add constraint aop_downsubscr_item_report_fk
        foreign key ( downsubscr_id )
            references samqa.aop_downsubscr ( id )
        enable;

