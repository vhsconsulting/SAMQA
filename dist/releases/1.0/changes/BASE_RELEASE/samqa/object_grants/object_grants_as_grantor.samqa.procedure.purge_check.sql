-- liquibase formatted sql
-- changeset SAMQA:1754373937056 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.purge_check.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.purge_check.sql:null:5c464e274d43f099e08ed047476086455a46c866:create

grant execute on samqa.purge_check to rl_sam_ro;

grant execute on samqa.purge_check to rl_sam_rw;

grant execute on samqa.purge_check to rl_sam1_ro;

grant debug on samqa.purge_check to sgali;

grant debug on samqa.purge_check to rl_sam_rw;

grant debug on samqa.purge_check to rl_sam1_ro;

