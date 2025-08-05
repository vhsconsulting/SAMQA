-- liquibase formatted sql
-- changeset SAMQA:1754374153125 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claim_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claim_detail.sql:null:696d9caaf1b5b1795b307f96ca67e1fd97b93fb2:create

create table samqa.claim_detail (
    claim_id            number(9, 0) not null enable,
    service_code        varchar2(30 byte) not null disable,
    tax_code            varchar2(20 byte),
    service_price       number(15, 2) not null enable,
    service_count       number default 1,
    service_status      number(3, 0),
    service_name        varchar2(255 byte),
    sure_amount         number(15, 2),
    note                varchar2(4000 byte),
    claim_detail_id     number,
    service_date        date,
    service_provider    varchar2(3200 byte),
    creation_date       date,
    created_by          number,
    last_update_date    date,
    last_updated_by     number,
    service_end_date    date,
    patient_dep_name    varchar2(3200 byte),
    provider_tax_id     varchar2(30 byte),
    line_status         varchar2(30 byte),
    eob_detail_id       number,
    state_tax           number,
    eob_linked          varchar2(10 byte),
    claim_detail_status varchar2(30 byte)
);

create unique index samqa.claim_detail_pk on
    samqa.claim_detail (
        claim_detail_id
    );

alter table samqa.claim_detail
    add constraint claim_detail_pk
        primary key ( claim_detail_id )
            using index samqa.claim_detail_pk enable;

