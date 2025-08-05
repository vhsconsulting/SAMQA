-- liquibase formatted sql
-- changeset SAMQA:1754374150991 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\account_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/account_history.sql:null:2bbb7a840874d7e5cac4a338942eda47a079ff65:create

create table samqa.account_history (
    acc_id          number,
    acc_num         varchar2(30 byte),
    old_plan_code   number,
    new_plan_code   number,
    old_start_date  date,
    new_start_date  date,
    creation_date   date,
    old_salesrep_id number,
    new_salesrep_id number,
    last_updated_by number,
    old_entrp_id    number,
    new_entrp_id    number,
    old_am_id       number,
    new_am_id       number
);

