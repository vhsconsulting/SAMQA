-- liquibase formatted sql
-- changeset SAMQA:1754374152011 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\bankserv_txn_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/bankserv_txn_external.sql:null:1a00ae324fe84bbf8dbb077ab642fb3b511d6595:create

create table samqa.bankserv_txn_external (
    company_number   varchar2(100 byte),
    routing_num      varchar2(100 byte),
    acc_number       varchar2(100 byte),
    check_number     varchar2(100 byte),
    check_date       varchar2(100 byte),
    return_date      varchar2(100 byte),
    amount           varchar2(100 byte),
    reference_number varchar2(100 byte),
    origin           varchar2(100 byte),
    created_by       varchar2(100 byte),
    return_code      varchar2(255 byte),
    rtn              varchar2(255 byte),
    rtn_queue        varchar2(255 byte),
    status           varchar2(100 byte),
    cust_id          varchar2(100 byte),
    cust_ref_num     varchar2(100 byte),
    first_name       varchar2(100 byte),
    last_name        varchar2(100 byte),
    product_type     varchar2(100 byte)
)
organization external ( type oracle_loader
    default directory bank_serv_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'Bankserv Return0219.csv.bad'
            logfile 'Bankserv Return0219.csv.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( bank_serv_dir : 'Bankserv Return0219.csv' )
) reject limit 0;

