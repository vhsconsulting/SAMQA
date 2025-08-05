-- liquibase formatted sql
-- changeset SAMQA:1754373937666 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.employee_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.employee_seq.sql:null:438ecee98912e7d14f87fbc4c34ccde023c4fc7a:create

grant select on samqa.employee_seq to rl_sam_rw;

