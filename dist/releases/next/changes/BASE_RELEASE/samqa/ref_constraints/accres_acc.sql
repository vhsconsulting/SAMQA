-- liquibase formatted sql
-- changeset SAMQA:1753779759899 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\accres_acc.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/accres_acc.sql:null:ae59aefbeb1bbe266c2efa6c24f7f743ea54c1d9:create

alter table samqa.accres
    add constraint accres_acc
        foreign key ( acc_id )
            references samqa.account ( acc_id )
        enable;

