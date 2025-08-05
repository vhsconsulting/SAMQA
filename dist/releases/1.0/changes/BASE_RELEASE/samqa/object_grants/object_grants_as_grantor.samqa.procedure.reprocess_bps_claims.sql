-- liquibase formatted sql
-- changeset SAMQA:1754373937092 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.reprocess_bps_claims.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.reprocess_bps_claims.sql:null:f8fb129d81b68932aa89f52feda0b076bb2749ff:create

grant execute on samqa.reprocess_bps_claims to rl_sam_ro;

grant execute on samqa.reprocess_bps_claims to rl_sam_rw;

grant execute on samqa.reprocess_bps_claims to rl_sam1_ro;

grant debug on samqa.reprocess_bps_claims to sgali;

grant debug on samqa.reprocess_bps_claims to rl_sam_rw;

grant debug on samqa.reprocess_bps_claims to rl_sam1_ro;

