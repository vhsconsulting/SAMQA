-- liquibase formatted sql
-- changeset SAMQA:1754374160972 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\news.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/news.sql:null:61a8aa532d4490d279d764e92a90be4879dcfcb8:create

create table samqa.news (
    news_id           number,
    news_title        varchar2(3200 byte),
    news_date         date,
    news_magazine     varchar2(3200 byte),
    file_name         varchar2(3200 byte),
    url               varchar2(3200 byte),
    note              varchar2(3200 byte),
    creation_date     date default sysdate,
    created_by        number default - 1,
    last_updated_date date default sysdate,
    last_updated_by   number default - 1
);

alter table samqa.news add primary key ( news_id )
    using index enable;

