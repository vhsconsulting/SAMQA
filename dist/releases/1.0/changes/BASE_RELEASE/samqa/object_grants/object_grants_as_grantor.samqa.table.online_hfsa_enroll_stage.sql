-- liquibase formatted sql
-- changeset SAMQA:1754373941453 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.online_hfsa_enroll_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.online_hfsa_enroll_stage.sql:null:cdcd4ef40a7d28c16fa663fe54f9c624146be25a:create

grant delete on samqa.online_hfsa_enroll_stage to rl_sam_rw;

grant insert on samqa.online_hfsa_enroll_stage to rl_sam_rw;

grant select on samqa.online_hfsa_enroll_stage to rl_sam1_ro;

grant select on samqa.online_hfsa_enroll_stage to rl_sam_rw;

grant select on samqa.online_hfsa_enroll_stage to rl_sam_ro;

grant update on samqa.online_hfsa_enroll_stage to rl_sam_rw;

