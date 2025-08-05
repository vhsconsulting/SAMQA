alter table samqa.opportunity_notes
    add constraint opportunity_notes_fk1
        foreign key ( opp_id )
            references samqa.opportunity ( opp_id )
        enable;


-- sqlcl_snapshot {"hash":"6f96797588acbf119c12461ed60b62acf3e68f81","type":"REF_CONSTRAINT","name":"OPPORTUNITY_NOTES_FK1","schemaName":"SAMQA","sxml":""}