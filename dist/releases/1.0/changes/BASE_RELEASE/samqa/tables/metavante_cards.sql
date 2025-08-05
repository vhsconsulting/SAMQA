-- liquibase formatted sql
-- changeset SAMQA:1754374160620 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\metavante_cards.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/metavante_cards.sql:null:6df06a88c1de2ac38a71eb41b203165bc02e7fe2:create

create table samqa.metavante_cards (
    metavante_card_id        number,
    acc_num                  varchar2(30 byte),
    card_effective_date      varchar2(30 byte),
    card_expire_date         varchar2(30 byte),
    card_number              varchar2(30 byte),
    status_code              varchar2(30 byte),
    status_code_reason       varchar2(30 byte),
    shipment_tracking_number varchar2(30 byte),
    activation_date          varchar2(30 byte),
    mailed_date              varchar2(30 byte),
    issue_date               varchar2(30 byte),
    last_update_date         date,
    creation_date            date,
    dependant_id             number,
    card_proxy_number        varchar2(255 byte),
    pin_request_date         date,
    pin_mailed_date          date
);

