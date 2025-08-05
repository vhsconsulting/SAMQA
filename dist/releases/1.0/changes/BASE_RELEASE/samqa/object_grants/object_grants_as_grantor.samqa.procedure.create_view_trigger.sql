-- liquibase formatted sql
-- changeset SAMQA:1754373936782 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.create_view_trigger.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.create_view_trigger.sql:null:afedc3d5b7cb433ff265efb5a19adaf833bee804:create

grant execute on samqa.create_view_trigger to rl_sam_ro;

grant execute on samqa.create_view_trigger to rl_sam_rw;

grant execute on samqa.create_view_trigger to rl_sam1_ro;

grant debug on samqa.create_view_trigger to sgali;

grant debug on samqa.create_view_trigger to rl_sam_rw;

grant debug on samqa.create_view_trigger to rl_sam1_ro;

