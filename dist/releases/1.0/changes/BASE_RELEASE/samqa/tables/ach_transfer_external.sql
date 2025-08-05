-- liquibase formatted sql
-- changeset SAMQA:1754374151172 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ach_transfer_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ach_transfer_external.sql:null:b92551b908defc06f509830cd4499bc6708e9242:create

create table samqa.ach_transfer_external (
    transaction_id   number,
    acct_id          varchar2(10 byte),
    display_name     varchar2(25 byte),
    bank_name        varchar2(50 byte),
    bank_routing_num varchar2(9 byte),
    bank_acct_num    varchar2(20 byte),
    bank_acct_type   varchar2(20 byte),
    transaction_type varchar2(20 byte),
    amount           number,
    transaction_date varchar2(20 byte),
    status           varchar2(1 byte),
    comments         varchar2(1 byte),
    error_msg        varchar2(80 byte),
    date_updated     varchar2(20 byte),
    date_created     varchar2(20 byte),
    date_processed   varchar2(20 byte)
)
organization external ( type oracle_loader
    default directory online_enroll_dir access parameters (
        records delimited by newline
        fields terminated by '~' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( online_enroll_dir : 'ach_transfer.csv' )
) reject limit unlimited;

