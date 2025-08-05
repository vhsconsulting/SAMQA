-- liquibase formatted sql
-- changeset SAMQA:1754374163310 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\site_navigation_bkup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/site_navigation_bkup.sql:null:2fccca6548571f54b11b20cc5389c506e9a3920d:create

create table samqa.site_navigation_bkup (
    site_nav_id      number,
    account_type     varchar2(255 byte),
    nav_code         varchar2(255 byte),
    nav_description  varchar2(255 byte),
    start_date       date,
    end_date         date,
    status           varchar2(1 byte),
    entrp_id         number,
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number,
    web_nav_code     varchar2(255 byte),
    web_nav_url      varchar2(255 byte),
    seq_no           number
);

