alter table samqa.plan_fee
    add constraint plan_fee_code
        foreign key ( plan_code )
            references samqa.plans ( plan_code )
        enable;


-- sqlcl_snapshot {"hash":"3c9819a70f2831f02233f400251198ed4c826e65","type":"REF_CONSTRAINT","name":"PLAN_FEE_CODE","schemaName":"SAMQA","sxml":""}