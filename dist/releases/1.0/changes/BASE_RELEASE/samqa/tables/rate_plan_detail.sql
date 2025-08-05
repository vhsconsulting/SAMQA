-- liquibase formatted sql
-- changeset SAMQA:1754374162480 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\rate_plan_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/rate_plan_detail.sql:null:9e1637bea8fa4cefeabf0cd29f41075699866b2b:create

create table samqa.rate_plan_detail (
    rate_plan_detail_id number not null enable,
    rate_plan_id        number,
    coverage_type       varchar2(30 byte),
    calculation_type    varchar2(30 byte),
    minimum_range       number,
    maximum_range       number,
    description         varchar2(3200 byte),
    rate_code           varchar2(30 byte),
    rate_plan_cost      number,
    creation_date       date default sysdate,
    created_by          number,
    last_update_date    date default null,
    last_updated_by     number,
    rate_basis          varchar2(255 byte),
    effective_date      date default sysdate,
    effective_end_date  date,
    one_time_flag       varchar2(1 byte) default 'N',
    charged_to          varchar2(100 byte) default 'EMPLOYER',
    invoice_param_id    number,
    orig_sys_ref        varchar2(100 byte),
    plan_id             number,
    do_invoice          varchar2(1 byte) default 'Y'
);

alter table samqa.rate_plan_detail add primary key ( rate_plan_detail_id )
    using index enable;

