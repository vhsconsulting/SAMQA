-- liquibase formatted sql
-- changeset SAMQA:1754373940117 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.enrollment_edi_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.enrollment_edi_external.sql:null:fda2f9daf0415debb6579f46a29e92c80d28550a:create

grant select on samqa.enrollment_edi_external to rl_sam1_ro;

grant select on samqa.enrollment_edi_external to rl_sam_ro;

