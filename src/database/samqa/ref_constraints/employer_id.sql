alter table samqa.employer
    add constraint employer_id
        foreign key ( entrp_id )
            references samqa.enterprise ( entrp_id )
        enable;


-- sqlcl_snapshot {"hash":"29f4260a42db520a4eb49014c940341dc844b088","type":"REF_CONSTRAINT","name":"EMPLOYER_ID","schemaName":"SAMQA","sxml":""}