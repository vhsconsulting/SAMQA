-- liquibase formatted sql
-- changeset SAMQA:1754373941856 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.rto_api_plan_doc_request.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.rto_api_plan_doc_request.sql:null:c94450a8dfa44ed07fc6cd1d77fe2cb9d9a7f5c3:create

grant alter on samqa.rto_api_plan_doc_request to public;

grant delete on samqa.rto_api_plan_doc_request to public;

grant index on samqa.rto_api_plan_doc_request to public;

grant insert on samqa.rto_api_plan_doc_request to public;

grant select on samqa.rto_api_plan_doc_request to public;

grant select on samqa.rto_api_plan_doc_request to rl_sam_ro;

grant update on samqa.rto_api_plan_doc_request to public;

grant references on samqa.rto_api_plan_doc_request to public;

grant read on samqa.rto_api_plan_doc_request to public;

grant on commit refresh on samqa.rto_api_plan_doc_request to public;

grant query rewrite on samqa.rto_api_plan_doc_request to public;

grant debug on samqa.rto_api_plan_doc_request to public;

grant flashback on samqa.rto_api_plan_doc_request to public;

