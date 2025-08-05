-- liquibase formatted sql
-- changeset SAMQA:1754373937154 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.sam_bps_refresh.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.sam_bps_refresh.sql:null:a325d0fc073aa33363eb3edd45ec4138048b1169:create

grant execute on samqa.sam_bps_refresh to rl_sam_rw;

grant execute on samqa.sam_bps_refresh to rl_sam1_ro;

grant execute on samqa.sam_bps_refresh to rl_sam_ro;

grant debug on samqa.sam_bps_refresh to rl_sam_rw;

grant debug on samqa.sam_bps_refresh to rl_sam1_ro;

