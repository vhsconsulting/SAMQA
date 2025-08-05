-- liquibase formatted sql
-- changeset SAMQA:1754374163040 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\scheduler_details_stg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/scheduler_details_stg.sql:null:0af7d18d3b16cf13b7fe533bd1f19446eaffe862:create

create table samqa.scheduler_details_stg (
    sch_det_stg_id      number,
    acc_num             varchar2(20 byte),
    ssn                 varchar2(20 byte),
    acc_id              number,
    er_amount           number default 0,
    ee_amount           number default 0,
    er_fee_amount       number default 0,
    ee_fee_amount       number default 0,
    batch_number        number,
    scheduler_detail_id number,
    scheduler_id        number,
    created_by          number,
    creation_date       date default sysdate,
    last_updated_by     number,
    last_updated_date   date default sysdate,
    status              varchar2(30 byte) default 'U',
    error_message       varchar2(3200 byte),
    note                varchar2(3200 byte),
    first_name          varchar2(255 byte),
    last_name           varchar2(50 byte),
    scheduler_stage_id  number
);

alter table samqa.scheduler_details_stg add primary key ( sch_det_stg_id )
    using index enable;

