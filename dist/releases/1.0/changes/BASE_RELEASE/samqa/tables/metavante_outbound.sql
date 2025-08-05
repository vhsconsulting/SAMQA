-- liquibase formatted sql
-- changeset SAMQA:1754374160726 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\metavante_outbound.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/metavante_outbound.sql:null:52bb2a81fe2f902046a928fef69b5a0cdd7d8787:create

create table samqa.metavante_outbound (
    request_id       number,
    action           varchar2(255 byte),
    pers_id          number,
    acc_id           number,
    acc_num          varchar2(255 byte),
    bps_acc_num      varchar2(255 byte),
    processed_flag   varchar2(255 byte),
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number
);

