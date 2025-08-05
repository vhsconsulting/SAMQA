-- liquibase formatted sql
-- changeset SAMQA:1754374172851 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\er_acc_analytics_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/er_acc_analytics_v.sql:null:887fb48d31f23cb5d58c03f2238678ce00afb77a:create

create or replace force editionable view samqa.er_acc_analytics_v (
    entrp_id,
    acc_num,
    acc_id,
    name,
    address,
    city,
    state,
    zip,
    salesrep_name,
    broker_name,
    reg_date,
    start_date,
    end_date,
    account_status,
    account_type
) as
    select
        p.entrp_id,
        ac.acc_num,
        ac.acc_id,
        p.name,
        p.address,
        p.city,
        p.state,
        p.zip,
        pc_account.get_salesrep_name(ac.salesrep_id)     salesrep_name,
        pc_broker.get_broker_name(ac.broker_id)          broker_name,
        to_char(ac.reg_date, 'MM/DD/YYYY')               reg_date,
        to_char(ac.start_date, 'MM/DD/YYYY')             start_date,
        to_char(ac.end_date, 'MM/DD/YYYY')               end_date,
        pc_lookups.get_account_status(ac.account_status) account_status,
        ac.account_type
    from
        enterprise p,
        account    ac
    where
        p.entrp_id = ac.entrp_id;

