-- liquibase formatted sql
-- changeset SAMQA:1754373926267 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.table.notice_events.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.table.notice_events.sql:null:b05937cb4f5d1d9aae616e5db5777e36142f6a80:create

grant alter on newcobra.notice_events to samqa;

grant delete on newcobra.notice_events to samqa;

grant index on newcobra.notice_events to samqa;

grant insert on newcobra.notice_events to samqa;

grant select on newcobra.notice_events to samqa;

grant update on newcobra.notice_events to samqa;

grant references on newcobra.notice_events to samqa;

grant read on newcobra.notice_events to samqa;

grant on commit refresh on newcobra.notice_events to samqa;

grant query rewrite on newcobra.notice_events to samqa;

grant debug on newcobra.notice_events to samqa;

grant flashback on newcobra.notice_events to samqa;

