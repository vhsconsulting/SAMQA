-- liquibase formatted sql
-- changeset SAMQA:1754374159581 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\insure_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/insure_history.sql:null:9c2b1ad5f85e8cf3285f27bd159ff80df238172f:create

create table samqa.insure_history (
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
    eob_connection_status varchar2(30 byte),
    allow_eob             varchar2(30 byte),
    carrier_supported     varchar2(30 byte),
    carrier_user_name     varchar2(255 byte),
    carrier_password      varchar2(255 byte),
    last_update_date      date,
    revoked_date          date,
    last_updated_by       number,
    creation_date         date,
    created_by            number
);

