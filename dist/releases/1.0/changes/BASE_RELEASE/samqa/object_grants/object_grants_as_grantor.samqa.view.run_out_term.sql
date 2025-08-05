-- liquibase formatted sql
-- changeset SAMQA:1754373945060 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.run_out_term.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.run_out_term.sql:null:5329fbd8f4afdfc9e867ff52a95d06b806281bba:create

grant select on samqa.run_out_term to rl_sam1_ro;

grant select on samqa.run_out_term to rl_sam_rw;

grant select on samqa.run_out_term to rl_sam_ro;

grant select on samqa.run_out_term to sgali;

