create or replace type samqa.annual_elec_rec as object (
        batch_number  number,
        entrp_id      number,
        check_amount  number,
        plan_type     varchar2(255),
        plan_end_date date
);
/


-- sqlcl_snapshot {"hash":"32ff78f1247ce39ba585fd4d288c0cb487eeffe5","type":"TYPE_SPEC","name":"ANNUAL_ELEC_REC","schemaName":"SAMQA","sxml":""}