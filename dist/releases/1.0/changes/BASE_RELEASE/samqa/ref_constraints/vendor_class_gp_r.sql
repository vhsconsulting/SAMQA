-- liquibase formatted sql
-- changeset SAMQA:1754374147336 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\vendor_class_gp_r.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/vendor_class_gp_r.sql:null:e3e25423bcd88d9b271d40ec5ad541fa66fcda84:create

alter table samqa.vendor_class_gp
    add constraint vendor_class_gp_r
        foreign key ( checkbook_id )
            references samqa.checkbook_gp ( checkbook_id )
        enable;

