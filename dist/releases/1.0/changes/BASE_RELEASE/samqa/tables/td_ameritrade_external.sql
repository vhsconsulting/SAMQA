-- liquibase formatted sql
-- changeset SAMQA:1754374163651 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\td_ameritrade_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/td_ameritrade_external.sql:null:25575815303cfa5ddb7d8430e972552e552fa36c:create

create table samqa.td_ameritrade_external (
    plan_id      varchar2(50 byte),
    account_num  varchar2(10 byte),
    last_name    varchar2(250 byte),
    first_name   varchar2(250 byte),
    full_name    varchar2(250 byte),
    market_date  varchar2(30 byte),
    ticker_sy    varchar2(30 byte),
    cusip        varchar2(10 byte),
    security_id  varchar2(255 byte),
    secu         varchar2(20 byte),
    unse         varchar2(20 byte),
    unsettle     varchar2(20 byte),
    quantity     varchar2(20 byte),
    market_value varchar2(20 byte)
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
            badfile '03_31_2025_Schwab_file_upload.csv.bad'
            logfile '03_31_2025_Schwab_file_upload.csv.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( enroll_dir : '03_31_2025_Schwab_file_upload.csv' )
) reject limit unlimited;

