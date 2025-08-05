-- liquibase formatted sql
-- changeset SAMQA:1754374160656 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\metavante_dependants_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/metavante_dependants_external.sql:null:f3d3f09007428f42fac1b4a43c5329741ba87e98:create

create table samqa.metavante_dependants_external (
    record_id       varchar2(255 byte),
    tps_id          varchar2(255 byte),
    employer_id     varchar2(255 byte),
    employee_id     varchar2(255 byte),
    dep_id          varchar2(255 byte),
    prefix          varchar2(255 byte),
    dep_last_name   varchar2(255 byte),
    dep_first_name  varchar2(255 byte),
    dep_middle_name varchar2(255 byte),
    address         varchar2(255 byte),
    city            varchar2(255 byte),
    state           varchar2(255 byte),
    zip             varchar2(255 byte),
    country         varchar2(255 byte),
    status          varchar2(255 byte),
    gender          varchar2(255 byte),
    relationship    varchar2(255 byte),
    birth_date      varchar2(255 byte),
    dep_ssn         varchar2(255 byte),
    ee_ssn          varchar2(255 byte),
    card_number     varchar2(255 byte)
)
organization external ( type oracle_loader
    default directory debit_card_dir access parameters (
        records delimited by newline
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( debit_card_dir : 'dependant_migration.csv' )
) reject limit unlimited;

