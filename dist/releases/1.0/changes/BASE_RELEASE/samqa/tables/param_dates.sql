-- liquibase formatted sql
-- changeset SAMQA:1754374161807 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\param_dates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/param_dates.sql:null:cc7039f32736ff7e1cefb18716509407941de79f:create

create table samqa.param_dates (
    param_code  varchar2(30 byte),
    param_date  date,
    param_value varchar2(4000 byte)
);

create unique index samqa.param_dates_pk on
    samqa.param_dates (
        param_code,
        param_date
    );

alter table samqa.param_dates
    add constraint param_dates_pk
        primary key ( param_code,
                      param_date )
            using index samqa.param_dates_pk enable;

