alter table samqa.plan_fee
    add constraint plan_fee_reason
        foreign key ( fee_code )
            references samqa.pay_reason ( reason_code )
        enable;


-- sqlcl_snapshot {"hash":"43fedec79412977a3697af1d2755aef37ddfde9e","type":"REF_CONSTRAINT","name":"PLAN_FEE_REASON","schemaName":"SAMQA","sxml":""}