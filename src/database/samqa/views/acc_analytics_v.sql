create or replace force editionable view samqa.acc_analytics_v (
    acc_num,
    acc_id,
    first_name,
    last_name,
    address,
    city,
    state,
    zip,
    age,
    employer_name,
    salesrep_name,
    broker_name,
    reg_date,
    start_date,
    end_date,
    account_status,
    account_type
) as
    select
        ac.acc_num,
        ac.acc_id,
        p.first_name,
        p.last_name,
        p.address,
        p.city,
        p.state,
        p.zip,
        getage(p.birth_date)                             age,
        pc_entrp.get_entrp_name(p.entrp_id)              employer_name,
        pc_account.get_salesrep_name(ac.salesrep_id)     salesrep_name,
        pc_broker.get_broker_name(ac.broker_id)          broker_name,
        to_char(ac.reg_date, 'MM/DD/YYYY')               reg_date,
        to_char(ac.start_date, 'MM/DD/YYYY')             start_date,
        to_char(ac.end_date, 'MM/DD/YYYY')               end_date,
        pc_lookups.get_account_status(ac.account_status) account_status,
        ac.account_type
    from
        person  p,
        account ac
    where
        p.pers_id = ac.pers_id;


-- sqlcl_snapshot {"hash":"06494d4b5a173f7562835d1ec2aaa65bf20ef758","type":"VIEW","name":"ACC_ANALYTICS_V","schemaName":"SAMQA","sxml":""}