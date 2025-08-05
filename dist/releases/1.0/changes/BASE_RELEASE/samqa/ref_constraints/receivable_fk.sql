-- liquibase formatted sql
-- changeset SAMQA:1754374147267 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\receivable_fk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/receivable_fk.sql:null:c591f89ecee121c71ec455b88e4e38eaa6f1f77f:create

alter table samqa.receivable
    add constraint receivable_fk
        foreign key ( invoice_id )
            references samqa.ar_invoice ( invoice_id )
        enable;

