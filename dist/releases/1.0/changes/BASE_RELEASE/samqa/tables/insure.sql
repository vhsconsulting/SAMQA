-- liquibase formatted sql
-- changeset SAMQA:1754374159549 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\insure.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/insure.sql:null:08adbbdcc94602127aae30bb3ac596c8ab9b1d24:create

create table samqa.insure (
    pers_id               number(9, 0) not null enable,
    insur_id              number(9, 0) not null enable,
    policy_num            varchar2(20 byte),
    start_date            date not null enable,
    end_date              date,
    group_no              varchar2(20 byte),
    deductible            number(15, 2) not null enable,
    op_max                number(15, 2),
    note                  varchar2(4000 byte),
    plan_type             number,
    eob_connection_status varchar2(30 byte) default 'NOT_CONNECTED',
    allow_eob             varchar2(30 byte) default 'N' -- this is applicable only for HRA&FSA
    ,
    carrier_supported     varchar2(30 byte) default 'N',
    carrier_user_name     varchar2(255 byte),
    carrier_password      varchar2(255 byte),
    last_update_date      date default sysdate,
    revoked_date          date,
    last_updated_by       number,
    creation_date         date default sysdate,
    created_by            number,
    insurance_member_id   varchar2(100 byte)
);

create unique index samqa.insure_pk on
    samqa.insure (
        pers_id
    );

alter table samqa.insure
    add constraint insure_pk
        primary key ( pers_id )
            using index samqa.insure_pk enable;

