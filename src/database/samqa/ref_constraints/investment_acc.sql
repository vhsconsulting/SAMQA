alter table samqa.investment
    add constraint investment_acc
        foreign key ( acc_id )
            references samqa.account ( acc_id )
        enable;


-- sqlcl_snapshot {"hash":"6715511de5d875614674aa37c754cdfb7e9de702","type":"REF_CONSTRAINT","name":"INVESTMENT_ACC","schemaName":"SAMQA","sxml":""}