-- liquibase formatted sql
-- changeset SAMQA:1754374163391 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\subscriber_lead_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/subscriber_lead_external.sql:null:132b1f87a1ebdd014f54815fe059677a5a328b54:create

create table samqa.subscriber_lead_external (
    group_name   varchar2(300 byte),
    first_name   varchar2(300 byte),
    last_name    varchar2(300 byte),
    broker_name  varchar2(300 byte),
    carrier_name varchar2(300 byte),
    setup        number,
    maint_fee    number
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'sales_report.bad'
            logfile 'sales_report.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( 'sales_report.csv' )
) reject limit unlimited;

