-- liquibase formatted sql
-- changeset SAMQA:1754373937273 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.vendor_cleanup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.vendor_cleanup.sql:null:7eaa77b9e05eedf3f49b0ae08d322002222928e7:create

grant execute on samqa.vendor_cleanup to rl_sam_ro;

grant execute on samqa.vendor_cleanup to rl_sam_rw;

grant execute on samqa.vendor_cleanup to rl_sam1_ro;

grant debug on samqa.vendor_cleanup to sgali;

grant debug on samqa.vendor_cleanup to rl_sam_rw;

grant debug on samqa.vendor_cleanup to rl_sam1_ro;

