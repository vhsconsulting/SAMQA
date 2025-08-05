-- liquibase formatted sql
-- changeset SAMQA:1754374152873 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\cards_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/cards_external.sql:null:f6be3ee2758d2623925d40e6ce986111467a6194:create

create table samqa.cards_external (
    record_id                varchar2(30 byte),
    tpa_id                   varchar2(30 byte),
    employee_id              varchar2(30 byte),
    card_effective_date      varchar2(30 byte),
    card_expire_date         varchar2(30 byte),
    card_number              varchar2(30 byte),
    status_code              varchar2(30 byte),
    status_code_reason       varchar2(30 byte),
    shipment_tracking_number varchar2(255 byte),
    activation_date          varchar2(30 byte),
    mailed_date              varchar2(30 byte),
    issue_date               varchar2(30 byte),
    dependant_id             varchar2(30 byte),
    primary_flag             varchar2(1 byte),
    creation_date            varchar2(30 byte),
    card_proxy_number        varchar2(255 byte),
    pin_request_date         varchar2(255 byte),
    pin_mailed_date          varchar2(255 byte)
)
organization external ( type oracle_loader
    default directory debit_card_dir access parameters (
        records delimited by newline
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( debit_card_dir : 'MB_6800035_EM.exp' )
) reject limit unlimited;

