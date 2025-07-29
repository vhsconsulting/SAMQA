alter table samqa.emp
    add
        foreign key ( deptno )
            references samqa.dept ( deptno )
        enable;


-- sqlcl_snapshot {"hash":"c8b50cb159a1dfae7425e07f6ed36f8f7933bc9c","type":"REF_CONSTRAINT","name":"EMP.SAMQA.DEPT","schemaName":"SAMQA","sxml":""}