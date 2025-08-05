-- liquibase formatted sql
-- changeset SAMQA:1754374157362 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\eob_detail_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/eob_detail_external.sql:null:32cf9aadd4d807916666f26a5412facefb2784a6:create

create table samqa.eob_detail_external (
    eob_id               varchar2(255 byte),
    eob_detail_id        varchar2(255 byte),
    action               varchar2(20 byte),
    error_flag           varchar2(10 byte),
    service_date_from    varchar2(255 byte),
    procedure_code       varchar2(255 byte),
    description          varchar2(3200 byte),
    amount_charged       number,
    amount_withdiscount  number,
    amount_notcovered    number,
    amount_paidbyins     number,
    amount_planpayment   number,
    amount_deductible    number,
    amount_coinsurance   number,
    amount_copay         number,
    final_patient_amount number,
    creation_date        varchar2(255 byte),
    last_update_date     varchar2(255 byte)
)
organization external ( type oracle_loader
    default directory eob_dir access parameters (
        records delimited by newline
            badfile 'eob_detail.bad'
            logfile 'eob_detail.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( eob_dir : 'HEx_item_9180_108822113.csv' )
) reject limit unlimited;

