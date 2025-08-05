-- liquibase formatted sql
-- changeset SAMQA:1754373940590 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.giact_api_errors.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.giact_api_errors.sql:null:a78798c43673aca978753e76edbaad2f561b0707:create

grant alter on samqa.giact_api_errors to public;

grant delete on samqa.giact_api_errors to public;

grant index on samqa.giact_api_errors to public;

grant insert on samqa.giact_api_errors to public;

grant select on samqa.giact_api_errors to public;

grant select on samqa.giact_api_errors to rl_sam_ro;

grant update on samqa.giact_api_errors to public;

grant references on samqa.giact_api_errors to public;

grant read on samqa.giact_api_errors to public;

grant on commit refresh on samqa.giact_api_errors to public;

grant query rewrite on samqa.giact_api_errors to public;

grant debug on samqa.giact_api_errors to public;

grant flashback on samqa.giact_api_errors to public;

