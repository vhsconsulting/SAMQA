-- liquibase formatted sql
-- changeset SAMQA:1754374146831 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\aop_downsubscr_output_fk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/aop_downsubscr_output_fk.sql:null:4593f03cbfc2b09681b8161d94fcc7097a5dead3:create

alter table samqa.aop_downsubscr_output
    add constraint aop_downsubscr_output_fk
        foreign key ( downsubscr_id )
            references samqa.aop_downsubscr ( id )
        enable;

