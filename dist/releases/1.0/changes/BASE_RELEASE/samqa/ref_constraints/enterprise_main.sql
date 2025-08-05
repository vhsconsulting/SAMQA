-- liquibase formatted sql
-- changeset SAMQA:1754374146989 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\enterprise_main.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/enterprise_main.sql:null:edb5778b2bc57692517a00d0f8186f6d1b2ad464:create

alter table samqa.enterprise
    add constraint enterprise_main
        foreign key ( entrp_main )
            references samqa.enterprise ( entrp_id )
        enable;

