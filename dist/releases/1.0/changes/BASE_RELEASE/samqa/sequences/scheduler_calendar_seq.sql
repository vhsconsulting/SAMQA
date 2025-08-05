-- liquibase formatted sql
-- changeset SAMQA:1754374150036 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\scheduler_calendar_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/scheduler_calendar_seq.sql:null:703ba5f353ada14a9c497c66e4b34d43458c85e1:create

create sequence samqa.scheduler_calendar_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 1388649 cache 20
noorder nocycle nokeep noscale global;

