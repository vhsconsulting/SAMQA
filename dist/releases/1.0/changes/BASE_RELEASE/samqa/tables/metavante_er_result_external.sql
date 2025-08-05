-- liquibase formatted sql
-- changeset SAMQA:1754374160672 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\metavante_er_result_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/metavante_er_result_external.sql:null:f62feb8a8d309b19bb8bef2e6e56c7803e9b4512:create

create table samqa.metavante_er_result_external (
    record_id          varchar2(255 byte),
    tpa_id             varchar2(255 byte),
    employer_id        varchar2(255 byte),
    detail_resp_code   varchar2(255 byte),
    record_tracking_no varchar2(255 byte),
    plan_id            varchar2(30 byte)
)
organization external ( type oracle_loader
    default directory debit_card_dir access parameters (
        records delimited by newline
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( debit_card_dir : 'MB_6800025_ER_PLAN_UPDATE.res' )
) reject limit unlimited;

