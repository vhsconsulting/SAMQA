alter table samqa.userkoa
    add constraint userkoa_pers
        foreign key ( pers_id )
            references samqa.person ( pers_id )
        enable;


-- sqlcl_snapshot {"hash":"86b2c26bb5437b3d3744fa46cbda7fe511404ede","type":"REF_CONSTRAINT","name":"USERKOA_PERS","schemaName":"SAMQA","sxml":""}