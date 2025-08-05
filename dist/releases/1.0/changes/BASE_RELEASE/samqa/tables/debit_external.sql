-- liquibase formatted sql
-- changeset SAMQA:1754374154626 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\debit_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/debit_external.sql:null:b7a65d39ffc6d2ce5a2ae50892c6b6f18b882c78:create

create table samqa."debit_EXTERNAL" (
    ssn        varchar2(30 byte),
    debit_card varchar2(30 byte)
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'debit.bad'
            logfile 'debit.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( 'debit_card.csv' )
) reject limit unlimited;

