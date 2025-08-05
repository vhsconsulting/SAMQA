-- liquibase formatted sql
-- changeset SAMQA:1754374146957 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\employee.samqa.department.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/employee.samqa.department.sql:null:6dc2d0e2e146462bab2ef591ecb5f192162f772f:create

alter table samqa.employee
    add
        foreign key ( dept_no )
            references samqa.department ( dept_no )
        enable;

