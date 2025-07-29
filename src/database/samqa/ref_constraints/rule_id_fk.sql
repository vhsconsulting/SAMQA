alter table samqa.deductible_rule_detail
    add constraint rule_id_fk
        foreign key ( rule_id )
            references samqa.deductible_rule ( rule_id )
        enable;


-- sqlcl_snapshot {"hash":"63b618b58c85961bdcd668a63ba0818cf113c78b","type":"REF_CONSTRAINT","name":"RULE_ID_FK","schemaName":"SAMQA","sxml":""}