-- liquibase formatted sql
-- changeset SAMQA:1754373942516 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.website_api_requests.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.website_api_requests.sql:null:582f8004ab6a05ab76d631cbd18e35e106faf6ed:create

grant alter on samqa.website_api_requests to public;

grant delete on samqa.website_api_requests to public;

grant index on samqa.website_api_requests to public;

grant insert on samqa.website_api_requests to public;

grant select on samqa.website_api_requests to public;

grant select on samqa.website_api_requests to rl_sam_ro;

grant update on samqa.website_api_requests to public;

grant references on samqa.website_api_requests to public;

grant read on samqa.website_api_requests to public;

grant on commit refresh on samqa.website_api_requests to public;

grant query rewrite on samqa.website_api_requests to public;

grant debug on samqa.website_api_requests to public;

grant flashback on samqa.website_api_requests to public;

