-- liquibase formatted sql
-- changeset SAMQA:1754374153328 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claim_interface.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claim_interface.sql:null:6292cefe64446b2b1be011306927e691ae5c4a57:create

create table samqa.claim_interface (
    claim_interface_id   number,
    er_acc_num           varchar2(15 byte),
    claim_number         varchar2(25 byte),
    member_id            varchar2(15 byte),
    service_plan_type    varchar2(5 byte),
    claim_amount         varchar2(15 byte),
    provider_name        varchar2(50 byte),
    patient_name         varchar2(50 byte),
    service_start_dt     varchar2(15 byte),
    service_end_dt       varchar2(15 byte),
    note                 varchar2(50 byte),
    provider_flag        varchar2(1 byte),
    check_ach_flag       varchar2(5 byte),
    eob_required_ind     varchar2(1 byte),
    insurance_category   varchar2(50 byte),
    expense_category     varchar2(50 byte),
    address              varchar2(50 byte),
    city                 varchar2(25 byte),
    state                varchar2(2 byte),
    zip                  varchar2(10 byte),
    provider_acct_number varchar2(25 byte),
    bank_name            varchar2(25 byte),
    bank_acct_number     varchar2(20 byte),
    routing_number       varchar2(20 byte),
    acc_id               number,
    pers_id              number,
    entrp_id             number,
    acc_num              varchar2(20 byte),
    interface_status     varchar2(20 byte),
    error_message        varchar2(3200 byte),
    last_updated_by      number,
    last_update_date     date,
    created_by           number,
    creation_date        date,
    batch_number         varchar2(20 byte),
    claim_id             number,
    other_insurance      varchar2(1 byte) default 'N',
    takeover             varchar2(1 byte),
    error_code           varchar2(255 byte)
);

alter table samqa.claim_interface add primary key ( claim_interface_id )
    using index enable;

