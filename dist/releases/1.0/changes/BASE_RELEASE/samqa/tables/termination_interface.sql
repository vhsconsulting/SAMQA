-- liquibase formatted sql
-- changeset SAMQA:1754374163740 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\termination_interface.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/termination_interface.sql:null:620839538b77e32a0290bca1e7a43ff476bfca11:create

create table samqa.termination_interface (
    termination_intf_id number,
    batch_number        varchar2(30 byte),
    entrp_id            number,
    er_acc_num          varchar2(30 byte),
    ssn                 varchar2(30 byte),
    last_name           varchar2(255 byte),
    first_name          varchar2(255 byte),
    termination_date    date,
    plan_type           varchar2(255 byte),
    acc_id              number,
    pers_id             number,
    processed           varchar2(255 byte),
    creation_date       date default sysdate,
    created_by          number default 0,
    last_update_date    date default sysdate,
    last_updated_by     number default 0,
    ben_plan_id         number,
    ein                 varchar2(30 byte),
    tpa_id              varchar2(30 byte),
    error_message       varchar2(3200 byte),
    ee_acc_num          varchar2(30 byte)
);

alter table samqa.termination_interface add primary key ( termination_intf_id )
    using index enable;

