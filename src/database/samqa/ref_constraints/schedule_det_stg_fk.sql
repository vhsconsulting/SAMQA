alter table samqa.scheduler_details_stg
    add constraint schedule_det_stg_fk
        foreign key ( scheduler_id )
            references samqa.scheduler_master ( scheduler_id )
        enable;


-- sqlcl_snapshot {"hash":"60241f7a4c699eed977e04ea8b3f0eb46e47c3d6","type":"REF_CONSTRAINT","name":"SCHEDULE_DET_STG_FK","schemaName":"SAMQA","sxml":""}