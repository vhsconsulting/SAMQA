-- liquibase formatted sql
-- changeset SAMQA:1754374163008 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\scheduler_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/scheduler_details.sql:null:2a40e46d056e2791deb9a0f732fad04063ad781e:create

create table samqa.scheduler_details (
    scheduler_detail_id number,
    scheduler_id        number,
    acc_id              number,
    er_amount           number default 0,
    ee_amount           number default 0,
    er_fee_amount       number default 0,
    ee_fee_amount       number default 0,
    created_by          number,
    creation_date       date default sysdate,
    last_updated_by     number,
    last_updated_date   date default sysdate,
    status              varchar2(30 byte) default 'A',
    note                varchar2(3200 byte),
    effective_date      date,
    effective_end_date  date
);

alter table samqa.scheduler_details add primary key ( scheduler_detail_id )
    using index enable;

