-- liquibase formatted sql
-- changeset SAMQA:1754373926363 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.table.qualifying_event.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.table.qualifying_event.sql:null:e289c435b3f5c92f9bf1ec9cd73b5ebe24b58cbf:create

grant alter on newcobra.qualifying_event to samqa;

grant delete on newcobra.qualifying_event to samqa;

grant index on newcobra.qualifying_event to samqa;

grant insert on newcobra.qualifying_event to samqa;

grant select on newcobra.qualifying_event to samqa;

grant update on newcobra.qualifying_event to samqa;

grant references on newcobra.qualifying_event to samqa;

grant read on newcobra.qualifying_event to samqa;

grant on commit refresh on newcobra.qualifying_event to samqa;

grant query rewrite on newcobra.qualifying_event to samqa;

grant debug on newcobra.qualifying_event to samqa;

grant flashback on newcobra.qualifying_event to samqa;

