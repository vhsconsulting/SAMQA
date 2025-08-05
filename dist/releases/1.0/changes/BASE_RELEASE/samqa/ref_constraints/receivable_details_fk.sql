-- liquibase formatted sql
-- changeset SAMQA:1754374147255 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\receivable_details_fk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/receivable_details_fk.sql:null:568fa5f1fba81fc7455bac9e810f8280ce164357:create

alter table samqa.receivable_details
    add constraint receivable_details_fk
        foreign key ( receivable_id )
            references samqa.receivable ( receivable_id )
        enable;

