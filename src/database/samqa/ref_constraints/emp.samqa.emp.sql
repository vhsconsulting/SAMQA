alter table samqa.emp
    add
        foreign key ( mgr )
            references samqa.emp ( empno )
        enable;


-- sqlcl_snapshot {"hash":"84e78c9b2a387dd15547900c1836f3e0852d6cd4","type":"REF_CONSTRAINT","name":"EMP.SAMQA.EMP","schemaName":"SAMQA","sxml":""}