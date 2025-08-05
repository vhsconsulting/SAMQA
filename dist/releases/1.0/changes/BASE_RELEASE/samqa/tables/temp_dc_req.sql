-- liquibase formatted sql
-- changeset SAMQA:1754374163664 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\temp_dc_req.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/temp_dc_req.sql:null:822b0e178696d2e912fbc2a96e381a222c839a0e:create

create table samqa.temp_dc_req (
    debit_card_request_id number,
    card_id               number,
    acc_num               varchar2(3200 byte),
    status                number,
    error_message         varchar2(3200 byte),
    processed_flag        varchar2(1 byte),
    dependant_card        varchar2(1 byte),
    creation_date         date,
    created_by            number,
    last_update_date      date,
    last_updated_by       number
);

