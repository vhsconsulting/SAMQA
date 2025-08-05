-- liquibase formatted sql
-- changeset SAMQA:1754373940111 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.enrollment_edi_detail_error.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.enrollment_edi_detail_error.sql:null:5f9f42cb120474b88b8d4f7881c3e1f935c466ed:create

grant delete on samqa.enrollment_edi_detail_error to rl_sam_rw;

grant insert on samqa.enrollment_edi_detail_error to rl_sam_rw;

grant select on samqa.enrollment_edi_detail_error to rl_sam1_ro;

grant select on samqa.enrollment_edi_detail_error to rl_sam_rw;

grant select on samqa.enrollment_edi_detail_error to rl_sam_ro;

grant update on samqa.enrollment_edi_detail_error to rl_sam_rw;

