-- liquibase formatted sql
-- changeset SAMQA:1754374153881 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\cobra_er_terminated_accounts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/cobra_er_terminated_accounts.sql:null:2c6d8c210aeeed9ce3edcace82c5a6bbbf8d1006:create

create table samqa.cobra_er_terminated_accounts (
    client_id        number,
    ein              varchar2(30 byte),
    termination_date date,
    entrp_id         number,
    acc_id           number,
    creation_date    date default sysdate,
    last_update_date date default sysdate,
    last_updated_by  number
);

