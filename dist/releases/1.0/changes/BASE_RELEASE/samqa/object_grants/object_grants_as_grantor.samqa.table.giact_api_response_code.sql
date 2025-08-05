-- liquibase formatted sql
-- changeset SAMQA:1754373940605 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.giact_api_response_code.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.giact_api_response_code.sql:null:0897afcebedabd01a2980d9157760ae23bfa2c2f:create

grant alter on samqa.giact_api_response_code to public;

grant delete on samqa.giact_api_response_code to public;

grant index on samqa.giact_api_response_code to public;

grant insert on samqa.giact_api_response_code to public;

grant select on samqa.giact_api_response_code to public;

grant select on samqa.giact_api_response_code to rl_sam_ro;

grant update on samqa.giact_api_response_code to public;

grant references on samqa.giact_api_response_code to public;

grant read on samqa.giact_api_response_code to public;

grant on commit refresh on samqa.giact_api_response_code to public;

grant query rewrite on samqa.giact_api_response_code to public;

grant debug on samqa.giact_api_response_code to public;

grant flashback on samqa.giact_api_response_code to public;

