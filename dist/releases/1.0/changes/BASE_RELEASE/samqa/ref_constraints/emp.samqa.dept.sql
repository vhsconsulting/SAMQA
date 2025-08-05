-- liquibase formatted sql
-- changeset SAMQA:1754374146939 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\emp.samqa.dept.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/emp.samqa.dept.sql:null:c8b50cb159a1dfae7425e07f6ed36f8f7933bc9c:create

alter table samqa.emp
    add
        foreign key ( deptno )
            references samqa.dept ( deptno )
        enable;

