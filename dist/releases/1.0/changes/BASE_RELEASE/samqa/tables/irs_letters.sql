-- liquibase formatted sql
-- changeset SAMQA:1754374159850 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\irs_letters.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/irs_letters.sql:null:d7717fd3e03a420a9dddc70b384a523a57e84de7:create

create table samqa.irs_letters (
    acc_num  varchar2(20 byte),
    name     varchar2(255 byte),
    address  varchar2(255 byte),
    city     varchar2(30 byte),
    state    varchar2(30 byte),
    zip      varchar2(30 byte),
    ssn      varchar2(30 byte),
    box1     number,
    box2     number,
    box3     number,
    box4     number,
    box5     number,
    hsa_flag varchar2(1 byte)
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'irsletter.bad'
            logfile 'irsletter.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( 'IRSLETTERS.csv' )
) reject limit unlimited;

