alter table samqa.scheduler_details
    add constraint schedule_det_fk
        foreign key ( scheduler_id )
            references samqa.scheduler_master ( scheduler_id )
        enable;


-- sqlcl_snapshot {"hash":"326a5111e12dc392b26a66113c84a363241e6d4c","type":"REF_CONSTRAINT","name":"SCHEDULE_DET_FK","schemaName":"SAMQA","sxml":""}