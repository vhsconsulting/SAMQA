-- liquibase formatted sql
-- changeset SAMQA:1754374156622 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\enroll_depnd.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/enroll_depnd.sql:null:5b878c1353ebc394630ddbeee2f43b88f1b981cd:create

create table samqa.enroll_depnd (
    acct_id     varchar2(100 byte),
    dep_num     number,
    first_name  varchar2(200 byte),
    middle_name varchar2(100 byte),
    last_name   varchar2(200 byte),
    gender      varchar2(100 byte),
    ssn         varchar2(200 byte),
    birth_date  varchar2(120 byte),
    relat_code  varchar2(100 byte)
)
organization external ( type oracle_loader
    default directory online_enroll_dir access parameters (
        records delimited by newline
        fields terminated by '~' optionally enclosed by '"' missing field values are null
    ) location ( 'Online_Enroll_Dep.csv' )
) reject limit 0;

