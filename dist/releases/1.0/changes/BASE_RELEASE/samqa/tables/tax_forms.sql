-- liquibase formatted sql
-- changeset SAMQA:1754374163608 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\tax_forms.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/tax_forms.sql:null:3b12f46d91259c340c810bfb4b9bd618c5d5af3a:create

create table samqa.tax_forms (
    tax_form_id          number,
    batch_number         number,
    acc_id               number,
    pers_id              number,
    acc_num              varchar2(30 byte),
    start_date           date,
    start_fee_date       date,
    begin_date           date,
    end_date             date,
    prev_yr_deposit      number,
    curr_yr_deposit      number,
    rollover             number,
    current_bal          number,
    gross_dist           number,
    creation_date        date default sysdate,
    tax_doc_type         varchar2(30 byte),
    corrected_flag       varchar2(1 byte) default 'N',
    override_flag        varchar2(1 byte) default 'N',
    corrected_by         number,
    overridden_by        number,
    last_update_date     date default sysdate,
    entrp_id             number,
    notification_sent_on date,
    received_on          date,
    ben_plan_id          number
);

alter table samqa.tax_forms add primary key ( tax_form_id )
    using index enable;

