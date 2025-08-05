-- liquibase formatted sql
-- changeset SAMQA:1754374147120 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\item_master_r2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/item_master_r2.sql:null:4221b7db4a1b7e2e945070f95a3dd836614554bb:create

alter table samqa.item_master
    add constraint item_master_r2
        foreign key ( item_class_id )
            references samqa.item_class ( item_class_id )
        enable;

