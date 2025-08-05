-- liquibase formatted sql
-- changeset SAMQA:1754374152890 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\cards_status_gt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/cards_status_gt.sql:null:f5c378d1340cde60ea3ac969522f2b2d787511e1:create

create global temporary table samqa.cards_status_gt (
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
    creation_date            varchar2(30 byte)
) on commit preserve rows;

