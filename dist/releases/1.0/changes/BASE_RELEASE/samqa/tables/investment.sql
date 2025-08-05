-- liquibase formatted sql
-- changeset SAMQA:1754374159632 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\investment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/investment.sql:null:df63a4cb99b632ef5825bed43027627162924f50:create

create table samqa.investment (
    investment_id number(9, 0) not null enable,
    acc_id        number(9, 0) not null enable,
    invest_id     number(9, 0) not null enable,
    invest_acc    varchar2(20 byte) not null enable,
    start_date    date,
    end_date      date,
    note          varchar2(4000 byte)
);

create unique index samqa.investment_pk on
    samqa.investment (
        investment_id
    );

alter table samqa.investment
    add constraint investment_pk
        primary key ( investment_id )
            using index samqa.investment_pk enable;

