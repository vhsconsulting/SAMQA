alter table samqa.income
    add constraint income_fee_code
        foreign key ( fee_code )
            references samqa.fee_names ( fee_code )
        enable;


-- sqlcl_snapshot {"hash":"02d1df76a2b421b6dee04a2ddf18d19e47c04ee9","type":"REF_CONSTRAINT","name":"INCOME_FEE_CODE","schemaName":"SAMQA","sxml":""}