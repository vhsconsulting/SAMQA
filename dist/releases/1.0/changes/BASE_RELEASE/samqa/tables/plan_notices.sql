-- liquibase formatted sql
-- changeset SAMQA:1754374162361 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\plan_notices.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/plan_notices.sql:null:2533bd30f098decfea2915742990e7cd1e9fa4ab:create

create table samqa.plan_notices (
    plan_notice_id      number,
    entity_id           number,
    entity_type         varchar2(255 byte),
    notice_type         varchar2(255 byte),
    notice_sent_on      date,
    notice_reminder_on  date,
    notice_due_on       date,
    notice_review_sent  date,
    notice_received_on  date,
    description         varchar2(1000 byte),
    test_result         varchar2(30 byte),
    creation_date       date default sysdate,
    created_by          number,
    last_update_date    date default sysdate,
    last_updated_by     number,
    result_sent_on      date,
    entrp_id            number(9, 0),
    ben_plan_id_pending number
);

alter table samqa.plan_notices add primary key ( plan_notice_id )
    using index enable;

