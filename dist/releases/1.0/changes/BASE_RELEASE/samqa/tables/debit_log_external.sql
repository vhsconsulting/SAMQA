-- liquibase formatted sql
-- changeset SAMQA:1754374154654 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\debit_log_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/debit_log_external.sql:null:2f19af7f36e6576124728124fe3ae3426e02fb1b:create

create table samqa.debit_log_external (
    line varchar2(3200 byte)
)
organization external ( type oracle_loader
    default directory bank_serv_dir access parameters (
        records delimited by newline
            badfile 'debit.bad'
            logfile 'debit.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( 'DebitLog.csv' )
) reject limit unlimited;

