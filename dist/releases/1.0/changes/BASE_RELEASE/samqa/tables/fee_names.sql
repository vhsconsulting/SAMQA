-- liquibase formatted sql
-- changeset SAMQA:1754374158452 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\fee_names.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/fee_names.sql:null:a6961974fd86af798d9ec1e2aa59725ae599a6e9:create

create table samqa.fee_names (
    fee_code number(3, 0) not null enable,
    fee_name varchar2(100 byte) not null enable,
    fee_type number(1, 0) default 0
);

create unique index samqa.fee_names_pk on
    samqa.fee_names (
        fee_code
    );

alter table samqa.fee_names
    add constraint fee_names_pk
        primary key ( fee_code )
            using index samqa.fee_names_pk enable;

