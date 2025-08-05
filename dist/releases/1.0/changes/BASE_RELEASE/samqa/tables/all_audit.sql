-- liquibase formatted sql
-- changeset SAMQA:1754374151433 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\all_audit.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/all_audit.sql:null:2290245c2f535feb9898d2a966165fb2fcad9c1d:create

create table samqa.all_audit (
    when_changed date default sysdate not null enable,
    who          varchar2(30 byte) default user
                                  || ' '
                                  || userenv('TERMINAL') not null enable,
    table_name   varchar2(30 byte) not null enable,
    field_name   varchar2(30 byte) not null enable,
    old_value    varchar2(4000 byte),
    new_value    varchar2(4000 byte),
    cod1         varchar2(30 byte) not null enable,
    cod2         varchar2(30 byte),
    cod3         varchar2(30 byte)
);

