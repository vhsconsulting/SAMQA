alter table samqa.insure
    add constraint insure_pers
        foreign key ( pers_id )
            references samqa.person ( pers_id )
        enable;


-- sqlcl_snapshot {"hash":"223f2b14d86d93363f65bba30f78c6f791125b87","type":"REF_CONSTRAINT","name":"INSURE_PERS","schemaName":"SAMQA","sxml":""}