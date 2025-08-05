-- liquibase formatted sql
-- changeset SAMQA:1754373935567 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.session_sentry.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.session_sentry.sql:null:10e365beb96ec86c108ea0015e07524d92d7e3a4:create

grant execute on samqa.session_sentry to rl_sam_ro;

