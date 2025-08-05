-- liquibase formatted sql
-- changeset SAMQA:1754374162442 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\portfolio_accounts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/portfolio_accounts.sql:null:f9077410f699bcb6c4edc032c6b0e88c536fb50a:create

create table samqa.portfolio_accounts (
    portfolio_id  number,
    acc_num       varchar2(30 byte),
    tax_id        varchar2(30 byte),
    entity_type   varchar2(30 byte),
    entity_id     number,
    user_id       number,
    account_type  varchar2(30 byte),
    salesrep_id   number,
    start_date    date,
    end_date      date,
    creation_date date,
    created_by    number
);

alter table samqa.portfolio_accounts add primary key ( portfolio_id )
    using index enable;

