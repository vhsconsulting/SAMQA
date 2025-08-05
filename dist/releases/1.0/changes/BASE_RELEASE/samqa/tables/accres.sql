-- liquibase formatted sql
-- changeset SAMQA:1754374151055 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\accres.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/accres.sql:null:00d849548a6db8c8a252b7be8b52b3ca32483613:create

create table samqa.accres (
    change_num number,
    acc_id     number(9, 0),
    fee_date   date,
    fee_code   number(3, 0),
    amount     number(15, 2),
    pre_days   number,
    pre_amo    number(15, 2),
    cur_amo    number(15, 2)
);

create unique index samqa.accres_pk on
    samqa.accres (
        change_num
    );

alter table samqa.accres
    add constraint accres_pk
        primary key ( change_num )
            using index samqa.accres_pk enable;

