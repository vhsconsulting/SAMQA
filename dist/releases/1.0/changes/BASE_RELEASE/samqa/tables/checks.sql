-- liquibase formatted sql
-- changeset SAMQA:1754374153017 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\checks.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/checks.sql:null:d3b98442514ca6d5e505763f677a6e24c19f899c:create

create table samqa.checks (
    check_id          number,
    acc_id            number,
    check_number      varchar2(30 byte),
    check_amount      number,
    check_date        date,
    mailed_date       date,
    issued_date       date,
    returned          varchar2(1 byte),
    entity_type       varchar2(30 byte),
    entity_id         number,
    source_system     varchar2(30 byte),
    creation_date     date,
    created_by        number,
    last_update_date  date default sysdate,
    last_updated_by   number,
    status            varchar2(30 byte) default 'SENT',
    vendor_id         number,
    memo              varchar2(3200 byte),
    check_source      varchar2(50 byte),
    check_reason      number,
    entity_name       varchar2(1 byte),
    approved_by       number,
    release_level1_by number,
    release_level2_by number,
    product_type      varchar2(30 byte),
    provider_flag     varchar2(1 byte) default 'N'
);

alter table samqa.checks add primary key ( check_id )
    using index enable;

