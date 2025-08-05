-- liquibase formatted sql
-- changeset SAMQA:1754374155798 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\eb_ssn_updates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/eb_ssn_updates.sql:null:d5bf179941d9fbcc3ced43e3c73ff093d4d90c9a:create

create table samqa.eb_ssn_updates (
    pers_id      varchar2(30 byte) not null enable,
    oldssn       varchar2(12 byte),
    newssn       varchar2(12 byte),
    when_changed date not null enable
);

