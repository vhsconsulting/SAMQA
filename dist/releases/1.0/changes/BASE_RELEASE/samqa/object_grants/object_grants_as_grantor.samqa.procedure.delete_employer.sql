-- liquibase formatted sql
-- changeset SAMQA:1754373936811 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.delete_employer.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.delete_employer.sql:null:d464d4f50b3132f3dd8a0209d33396e16154b9aa:create

grant execute on samqa.delete_employer to rl_sam_ro;

grant execute on samqa.delete_employer to rl_sam_rw;

grant execute on samqa.delete_employer to rl_sam1_ro;

grant debug on samqa.delete_employer to rl_sam_rw;

grant debug on samqa.delete_employer to rl_sam1_ro;

