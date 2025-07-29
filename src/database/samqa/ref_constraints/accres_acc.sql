alter table samqa.accres
    add constraint accres_acc
        foreign key ( acc_id )
            references samqa.account ( acc_id )
        enable;


-- sqlcl_snapshot {"hash":"ae59aefbeb1bbe266c2efa6c24f7f743ea54c1d9","type":"REF_CONSTRAINT","name":"ACCRES_ACC","schemaName":"SAMQA","sxml":""}