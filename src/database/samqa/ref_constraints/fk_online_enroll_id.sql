alter table samqa.online_enroll_plans
    add constraint fk_online_enroll_id
        foreign key ( enrollment_id )
            references samqa.online_enrollment ( enrollment_id )
        enable;


-- sqlcl_snapshot {"hash":"bc2b1c8fc311a4adc96d8967f24cd5e6c9eec8ab","type":"REF_CONSTRAINT","name":"FK_ONLINE_ENROLL_ID","schemaName":"SAMQA","sxml":""}