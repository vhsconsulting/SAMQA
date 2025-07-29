alter table samqa.receivable_details
    add constraint receivable_details_fk
        foreign key ( receivable_id )
            references samqa.receivable ( receivable_id )
        enable;


-- sqlcl_snapshot {"hash":"568fa5f1fba81fc7455bac9e810f8280ce164357","type":"REF_CONSTRAINT","name":"RECEIVABLE_DETAILS_FK","schemaName":"SAMQA","sxml":""}