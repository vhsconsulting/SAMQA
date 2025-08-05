-- liquibase formatted sql
-- changeset SAMQA:1754374168959 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\broker_assign_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/broker_assign_v.sql:null:f756cbda746a339031eeb56f3e36d55fee86fb8f:create

create or replace force editionable view samqa.broker_assign_v (
    broker_assignment_id,
    broker_name,
    broker_lic,
    effective_date,
    effective_end_date,
    entrp_id,
    pers_id,
    broker_id,
    salesrep_id
) as
    select
        broker_assignment_id,
        e.first_name
        || ' '
        || e.last_name                                    broker_name,
        d.broker_lic,
        a.effective_date,
        a.effective_end_date,
        a.entrp_id,
        a.pers_id,
        a.broker_id,
        pc_account.get_salesrep_id(a.pers_id, a.entrp_id) salesrep_id
    from
        broker_assignments a,
        broker             d,
        person             e
    where
            d.broker_id = a.broker_id
        and e.pers_id = d.broker_id;

