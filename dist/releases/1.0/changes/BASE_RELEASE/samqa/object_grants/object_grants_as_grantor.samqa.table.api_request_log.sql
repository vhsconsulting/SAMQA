-- liquibase formatted sql
-- changeset SAMQA:1754373938688 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.api_request_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.api_request_log.sql:null:0671ef9d21be1ee6aa420b68055cb3c3cecf61dc:create

grant alter on samqa.api_request_log to public;

grant delete on samqa.api_request_log to public;

grant index on samqa.api_request_log to public;

grant insert on samqa.api_request_log to public;

grant select on samqa.api_request_log to public;

grant select on samqa.api_request_log to rl_sam_ro;

grant update on samqa.api_request_log to public;

grant references on samqa.api_request_log to public;

grant read on samqa.api_request_log to public;

grant on commit refresh on samqa.api_request_log to public;

grant query rewrite on samqa.api_request_log to public;

grant debug on samqa.api_request_log to public;

grant flashback on samqa.api_request_log to public;

