alter table samqa.income
    add constraint income_contributor
        foreign key ( contributor )
            references samqa.enterprise ( entrp_id )
        enable;


-- sqlcl_snapshot {"hash":"696c594e08950255cbb6452d23a116fa1dac5035","type":"REF_CONSTRAINT","name":"INCOME_CONTRIBUTOR","schemaName":"SAMQA","sxml":""}