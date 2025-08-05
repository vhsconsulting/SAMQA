-- liquibase formatted sql
-- changeset SAMQA:1754373938989 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.benefit_codes_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.benefit_codes_stage.sql:null:4474d1573e93fa723a9a576a650c8eed8b3d01f6:create

grant delete on samqa.benefit_codes_stage to rl_sam_rw;

grant insert on samqa.benefit_codes_stage to rl_sam_rw;

grant select on samqa.benefit_codes_stage to rl_sam1_ro;

grant select on samqa.benefit_codes_stage to rl_sam_rw;

grant select on samqa.benefit_codes_stage to rl_sam_ro;

grant update on samqa.benefit_codes_stage to rl_sam_rw;

