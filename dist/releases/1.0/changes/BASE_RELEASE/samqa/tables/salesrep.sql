-- liquibase formatted sql
-- changeset SAMQA:1754374162896 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\salesrep.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/salesrep.sql:null:a12e79cc1ef0405ac53651fca0f62983c7c3f58d:create

create table samqa.salesrep (
    salesrep_id          number,
    start_date           date,
    status               varchar2(1 byte),
    creation_date        date,
    created_by           number,
    last_update_date     date,
    last_updated_by      number,
    name                 varchar2(255 byte),
    emp_id               number,
    role_type            varchar2(30 byte),
    end_date             date,
    inside_salesrep_flag varchar2(1 byte)
);

