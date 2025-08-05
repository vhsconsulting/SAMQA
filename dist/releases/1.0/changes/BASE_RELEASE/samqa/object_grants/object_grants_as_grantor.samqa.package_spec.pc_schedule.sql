-- liquibase formatted sql
-- changeset SAMQA:1754373936478 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_schedule.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_schedule.sql:null:5198639d298bccac996d7a494c5bbcd09c56b330:create

grant execute on samqa.pc_schedule to rl_sam_ro;

grant execute on samqa.pc_schedule to rl_sam_rw;

grant execute on samqa.pc_schedule to rl_sam1_ro;

grant debug on samqa.pc_schedule to sgali;

grant debug on samqa.pc_schedule to rl_sam_rw;

grant debug on samqa.pc_schedule to rl_sam1_ro;

grant debug on samqa.pc_schedule to rl_sam_ro;

