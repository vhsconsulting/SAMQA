alter table samqa.income
    add constraint income_acc
        foreign key ( acc_id )
            references samqa.account ( acc_id )
        enable;


-- sqlcl_snapshot {"hash":"362fac48f80af1c90f956c449429ce2e8ec5de14","type":"REF_CONSTRAINT","name":"INCOME_ACC","schemaName":"SAMQA","sxml":""}