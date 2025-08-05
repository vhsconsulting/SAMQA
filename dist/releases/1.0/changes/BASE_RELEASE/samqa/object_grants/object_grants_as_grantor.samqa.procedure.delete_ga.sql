-- liquibase formatted sql
-- changeset SAMQA:1754373936818 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.delete_ga.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.delete_ga.sql:null:929047f40f45182b8c42219e76a4cdae126ae203:create

grant execute on samqa.delete_ga to rl_sam_ro;

grant execute on samqa.delete_ga to rl_sam_rw;

grant execute on samqa.delete_ga to rl_sam1_ro;

grant debug on samqa.delete_ga to rl_sam_rw;

grant debug on samqa.delete_ga to rl_sam1_ro;

