-- liquibase formatted sql
-- changeset SAMQA:1754374146929 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\customer_class_gp_r.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/customer_class_gp_r.sql:null:5e84ff526ea05b58c155b9cd9be800a42a482078:create

alter table samqa.customer_class_gp
    add constraint customer_class_gp_r
        foreign key ( checkbook_id )
            references samqa.checkbook_gp ( checkbook_id )
        enable;

