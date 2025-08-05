-- liquibase formatted sql
-- changeset SAMQA:1754374153860 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\cobra_ee_terminated_accounts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/cobra_ee_terminated_accounts.sql:null:4f7004c479596325d19bc204c997162e9fb4c029:create

create table samqa.cobra_ee_terminated_accounts (
    client_id        number,
    ssn              varchar2(30 byte),
    termination_date date,
    pers_id          number,
    acc_id           number,
    qb_id            number,
    creation_date    date,
    last_update_date date,
    last_updated_by  number
);

