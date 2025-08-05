-- liquibase formatted sql
-- changeset SAMQA:1754374163263 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\site_navigation.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/site_navigation.sql:null:42934423a6d9445d308320b84b45a26d223c58a6:create

create table samqa.site_navigation (
    site_nav_id         number,
    account_type        varchar2(255 byte),
    nav_code            varchar2(255 byte),
    nav_description     varchar2(255 byte),
    start_date          date,
    end_date            date,
    status              varchar2(1 byte),
    entrp_id            number,
    creation_date       date default sysdate,
    created_by          number,
    last_update_date    date default sysdate,
    last_updated_by     number,
    web_nav_code        varchar2(255 byte),
    web_nav_url         varchar2(255 byte),
    seq_no              number,
    portal_type         varchar2(30 byte) default 'EMPLOYER',
    show_in_view_portal varchar2(3 byte) default 'N',
    conditional_flag    varchar2(1 byte) default 'N'
);

alter table samqa.site_navigation add primary key ( site_nav_id )
    using index enable;

