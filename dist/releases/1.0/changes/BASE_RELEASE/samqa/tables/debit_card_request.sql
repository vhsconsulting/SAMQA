-- liquibase formatted sql
-- changeset SAMQA:1754374154521 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\debit_card_request.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/debit_card_request.sql:null:33e1933cd5bd1cade6c7a5c8b575831a3552b230:create

create table samqa.debit_card_request (
    debit_card_request_id number,
    card_id               number,
    acc_num               varchar2(3200 byte),
    status                number,
    error_message         varchar2(3200 byte),
    processed_flag        varchar2(1 byte),
    dependant_card        varchar2(1 byte),
    creation_date         date default sysdate,
    created_by            number default 0,
    last_update_date      date default sysdate,
    last_updated_by       number default 0
);

