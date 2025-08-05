-- liquibase formatted sql
-- changeset SAMQA:1754373940125 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.enrollment_edi_header.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.enrollment_edi_header.sql:null:fbec088b19a95ac7d62ff998f2f2d45b92904d9e:create

grant delete on samqa.enrollment_edi_header to rl_sam_rw;

grant insert on samqa.enrollment_edi_header to rl_sam_rw;

grant select on samqa.enrollment_edi_header to rl_sam1_ro;

grant select on samqa.enrollment_edi_header to rl_sam_rw;

grant select on samqa.enrollment_edi_header to rl_sam_ro;

grant update on samqa.enrollment_edi_header to rl_sam_rw;

