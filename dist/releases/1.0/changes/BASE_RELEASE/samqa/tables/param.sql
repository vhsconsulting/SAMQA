-- liquibase formatted sql
-- changeset SAMQA:1754374161783 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\param.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/param.sql:null:073f17a80acff7b3382be7ee21db0131131d9fbb:create

create table samqa.param (
    param_code  varchar2(30 byte) not null enable,
    param_value varchar2(4000 byte) not null enable,
    note        varchar2(4000 byte)
);

create unique index samqa.param_pk on
    samqa.param (
        param_code
    );

alter table samqa.param
    add constraint param_pk
        primary key ( param_code )
            using index samqa.param_pk enable;

