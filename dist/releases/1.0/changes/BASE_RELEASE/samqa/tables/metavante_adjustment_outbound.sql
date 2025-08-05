-- liquibase formatted sql
-- changeset SAMQA:1754374160560 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\metavante_adjustment_outbound.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/metavante_adjustment_outbound.sql:null:e63be20acb5523d48babc2d073c88def938c37b2:create

create table samqa.metavante_adjustment_outbound (
    acc_num           varchar2(20 byte) not null enable,
    acc_id            number(9, 0) not null enable,
    record_type       varchar2(8 byte),
    change_num        number,
    amount            number,
    debit_card_posted varchar2(1 byte),
    creation_date     date
);

