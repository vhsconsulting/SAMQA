-- liquibase formatted sql
-- changeset SAMQA:1754374151973 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\bank_serv_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/bank_serv_external.sql:null:67d06bfbf1044cb3a8b60bb9797dc7789c88a3c5:create

create table samqa.bank_serv_external (
    txnid                 number,
    accnum                varchar2(30 byte),
    name                  varchar2(100 byte),
    totalamount           number,
    deposittype           number,
    deposittypetranslated varchar2(30 byte),
    bankservstatus        varchar2(255 byte),
    date_yyyymmddhhmmss   varchar2(100 byte),
    employeecontrib       varchar2(30 byte),
    employercontrib       varchar2(30 byte),
    employeeid            varchar2(255 byte),
    employeenameperson    varchar2(255 byte),
    employeenameenroll    varchar2(255 byte)
)
organization external ( type oracle_loader
    default directory bank_serv_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( bank_serv_dir : '20100115-0600_oracle.csv' )
) reject limit 0;

