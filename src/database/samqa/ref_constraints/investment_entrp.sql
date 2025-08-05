alter table samqa.investment
    add constraint investment_entrp
        foreign key ( invest_id )
            references samqa.enterprise ( entrp_id )
        enable;


-- sqlcl_snapshot {"hash":"4b79de47197d18d841b375fe7861a1f9e18b2782","type":"REF_CONSTRAINT","name":"INVESTMENT_ENTRP","schemaName":"SAMQA","sxml":""}