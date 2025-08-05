alter table samqa.insure
    add constraint insure_insur_id
        foreign key ( insur_id )
            references samqa.enterprise ( entrp_id )
        enable;


-- sqlcl_snapshot {"hash":"876737d58320f4cbff395ed58a641fe9f193210c","type":"REF_CONSTRAINT","name":"INSURE_INSUR_ID","schemaName":"SAMQA","sxml":""}