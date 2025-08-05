-- liquibase formatted sql
-- changeset SAMQA:1754373937076 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.release_invoiced_claims.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.release_invoiced_claims.sql:null:332ec513bff44dfec8589507931810b5d0c66f95:create

grant execute on samqa.release_invoiced_claims to rl_sam_ro;

