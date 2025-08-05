-- liquibase formatted sql
-- changeset SAMQA:1754374161137 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\online_disb_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/online_disb_external.sql:null:5b6330cfbd0bfa3a2785fdee7ad16949d999c77e:create

create table samqa.online_disb_external (
    first_name varchar2(2000 byte),
    last_name  varchar2(2000 byte),
    acc_num    varchar2(30 byte),
    claim_type varchar2(255 byte),
    amount     number
)
organization external ( type oracle_loader
    default directory claim_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'online_disb.bad'
            logfile 'online_disb.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( 'Online Disbursements.csv' )
) reject limit 5;

