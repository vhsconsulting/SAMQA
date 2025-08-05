-- liquibase formatted sql
-- changeset SAMQA:1754374146818 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\aop_downsubscr_log_fk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/aop_downsubscr_log_fk.sql:null:48a4e1e560594201696f5331f4e43da22954ea48:create

alter table samqa.aop_downsubscr_log
    add constraint aop_downsubscr_log_fk
        foreign key ( downsubscr_id )
            references samqa.aop_downsubscr ( id )
        enable;

