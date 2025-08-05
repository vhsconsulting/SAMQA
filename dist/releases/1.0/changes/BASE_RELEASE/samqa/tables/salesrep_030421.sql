-- liquibase formatted sql
-- changeset SAMQA:1754374162912 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\salesrep_030421.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/salesrep_030421.sql:null:22b0402b08c1da9d011e634e6023960490d71faf:create

create table samqa.salesrep_030421 (
    salesrep_id      number,
    start_date       date,
    status           varchar2(1 byte),
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number,
    name             varchar2(255 byte),
    emp_id           number,
    role_type        varchar2(30 byte),
    end_date         date
);

