-- liquibase formatted sql
-- changeset SAMQA:1754374163294 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\site_navigation_081018.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/site_navigation_081018.sql:null:abb58b03ccef7de67335d24105f435260ee3f167:create

create table samqa.site_navigation_081018 (
    site_nav_id      number,
    account_type     varchar2(255 byte),
    nav_code         varchar2(255 byte),
    nav_description  varchar2(255 byte),
    start_date       date,
    end_date         date,
    status           varchar2(1 byte),
    entrp_id         number,
    creation_date    date default sysdate,
    created_by       number,
    last_update_date date default sysdate,
    last_updated_by  number,
    web_nav_code     varchar2(255 byte),
    web_nav_url      varchar2(255 byte)
);

