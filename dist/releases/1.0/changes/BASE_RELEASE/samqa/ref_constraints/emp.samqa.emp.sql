-- liquibase formatted sql
-- changeset SAMQA:1754374146948 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\emp.samqa.emp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/emp.samqa.emp.sql:null:84e78c9b2a387dd15547900c1836f3e0852d6cd4:create

alter table samqa.emp
    add
        foreign key ( mgr )
            references samqa.emp ( empno )
        enable;

