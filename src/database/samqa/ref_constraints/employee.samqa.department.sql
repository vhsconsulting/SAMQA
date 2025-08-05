alter table samqa.employee
    add
        foreign key ( dept_no )
            references samqa.department ( dept_no )
        enable;


-- sqlcl_snapshot {"hash":"6dc2d0e2e146462bab2ef591ecb5f192162f772f","type":"REF_CONSTRAINT","name":"EMPLOYEE.SAMQA.DEPARTMENT","schemaName":"SAMQA","sxml":""}