-- liquibase formatted sql
-- changeset SAMQA:1754374155935 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employee.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employee.sql:null:d809f81c53c3f5a496fad410428aba9c58976b37:create

create table samqa.employee (
    emp_id           number,
    first_name       varchar2(255 byte),
    middle_name      varchar2(30 byte),
    last_name        varchar2(255 byte),
    ssn              varchar2(20 byte),
    birth_date       varchar2(255 byte),
    address          varchar2(1000 byte),
    city             varchar2(100 byte),
    state            varchar2(10 byte),
    zip              varchar2(15 byte),
    job_title        varchar2(100 byte),
    email            varchar2(100 byte),
    hire_date        date,
    term_date        date,
    dept_no          number,
    day_phone        varchar2(20 byte),
    evening_phone    varchar2(20 byte),
    extn             varchar2(10 byte),
    user_id          number,
    location         varchar2(100 byte),
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number,
    manager_id       number,
    supervisor_flag  varchar2(1 byte) default 'N',
    team_url         varchar2(2000 byte)
);

alter table samqa.employee add primary key ( emp_id )
    using index enable;

