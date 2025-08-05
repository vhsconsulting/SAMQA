-- liquibase formatted sql
-- changeset SAMQA:1754374162382 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\plan_notices_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/plan_notices_stage.sql:null:bafafe84f90a81bf1124d7c0ec31f0fa2ab095be:create

create table samqa.plan_notices_stage (
    plan_notice_id     number,
    entity_id          number,
    entity_type        varchar2(255 byte),
    notice_type        varchar2(255 byte),
    notice_sent_on     date,
    notice_reminder_on date,
    notice_due_on      date,
    notice_review_sent date,
    notice_received_on date,
    description        varchar2(1000 byte),
    test_result        varchar2(30 byte),
    creation_date      date,
    created_by         number,
    last_update_date   date,
    last_updated_by    number,
    result_sent_on     date,
    entrp_id           number(9, 0),
    batch_number       number,
    record_id          number,
    flg_no_notice      varchar2(1 byte),
    flg_addition       varchar2(1 byte)
);

