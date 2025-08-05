-- liquibase formatted sql
-- changeset SAMQA:1754373938601 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.alert_preferences.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.alert_preferences.sql:null:6b2f139bbef84cbe8ba1930815dcf7481a6c2b42:create

grant alter on samqa.alert_preferences to public;

grant delete on samqa.alert_preferences to public;

grant delete on samqa.alert_preferences to rl_sam_rw;

grant index on samqa.alert_preferences to public;

grant insert on samqa.alert_preferences to public;

grant insert on samqa.alert_preferences to rl_sam_rw;

grant select on samqa.alert_preferences to rl_sam1_ro;

grant select on samqa.alert_preferences to rl_sam_ro;

grant select on samqa.alert_preferences to public;

grant select on samqa.alert_preferences to rl_sam_rw;

grant update on samqa.alert_preferences to public;

grant update on samqa.alert_preferences to rl_sam_rw;

grant references on samqa.alert_preferences to public;

grant read on samqa.alert_preferences to public;

grant on commit refresh on samqa.alert_preferences to public;

grant query rewrite on samqa.alert_preferences to public;

grant debug on samqa.alert_preferences to public;

grant flashback on samqa.alert_preferences to public;

