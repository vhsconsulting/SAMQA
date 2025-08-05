-- liquibase formatted sql
-- changeset SAMQA:1754374155959 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employer.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employer.sql:null:d42e23519c3c7c24bce540ca67c517e3a9a96b88:create

create table samqa.employer (
    entrp_id   number(9, 0) not null enable,
    month_pay  number(15, 2),
    pay_code   number(3, 0),
    pay_period number(3, 0),
    cnt        number(9, 0),
    note       varchar2(4000 byte)
);

create unique index samqa.employer_pk on
    samqa.employer (
        entrp_id
    );

alter table samqa.employer
    add constraint employer_pk
        primary key ( entrp_id )
            using index samqa.employer_pk enable;

