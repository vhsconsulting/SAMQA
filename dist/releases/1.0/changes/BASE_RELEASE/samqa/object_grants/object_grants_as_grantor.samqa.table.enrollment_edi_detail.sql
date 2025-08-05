-- liquibase formatted sql
-- changeset SAMQA:1754373940104 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.enrollment_edi_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.enrollment_edi_detail.sql:null:eeadc2c1db4fb5905c702828f006e553ef70ec99:create

grant delete on samqa.enrollment_edi_detail to rl_sam_rw;

grant insert on samqa.enrollment_edi_detail to rl_sam_rw;

grant select on samqa.enrollment_edi_detail to rl_sam1_ro;

grant select on samqa.enrollment_edi_detail to rl_sam_rw;

grant select on samqa.enrollment_edi_detail to rl_sam_ro;

grant update on samqa.enrollment_edi_detail to rl_sam_rw;

