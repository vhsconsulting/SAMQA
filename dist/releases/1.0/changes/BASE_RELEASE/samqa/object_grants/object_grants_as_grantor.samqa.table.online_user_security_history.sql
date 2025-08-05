-- liquibase formatted sql
-- changeset SAMQA:1754373941476 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.online_user_security_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.online_user_security_history.sql:null:6ca90fda751b552924e6ad1318b114c6b6505839:create

grant alter on samqa.online_user_security_history to public;

grant delete on samqa.online_user_security_history to public;

grant delete on samqa.online_user_security_history to rl_sam_rw;

grant index on samqa.online_user_security_history to public;

grant insert on samqa.online_user_security_history to public;

grant insert on samqa.online_user_security_history to rl_sam_rw;

grant select on samqa.online_user_security_history to rl_sam1_ro;

grant select on samqa.online_user_security_history to public;

grant select on samqa.online_user_security_history to rl_sam_ro;

grant select on samqa.online_user_security_history to rl_sam_rw;

grant update on samqa.online_user_security_history to public;

grant update on samqa.online_user_security_history to rl_sam_rw;

grant references on samqa.online_user_security_history to public;

grant read on samqa.online_user_security_history to public;

grant on commit refresh on samqa.online_user_security_history to public;

grant query rewrite on samqa.online_user_security_history to public;

grant debug on samqa.online_user_security_history to public;

grant flashback on samqa.online_user_security_history to public;

