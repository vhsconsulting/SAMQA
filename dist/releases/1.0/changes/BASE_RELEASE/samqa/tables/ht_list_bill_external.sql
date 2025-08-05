-- liquibase formatted sql
-- changeset SAMQA:1754374159356 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ht_list_bill_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ht_list_bill_external.sql:null:9011ebc89b44ad5ab7c65c5191e3c9efc65ae198:create

create table samqa.ht_list_bill_external (
    line_number varchar2(3200 byte)
)
organization external ( type oracle_loader
    default directory listbill_dir access parameters (
        records delimited by newline
            badfile '2019-01-23zpyio040.txt.bad'
            logfile '2019-01-23zpyio040.txt.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( '2019-01-23zpyio040.txt' )
) reject limit 1;

