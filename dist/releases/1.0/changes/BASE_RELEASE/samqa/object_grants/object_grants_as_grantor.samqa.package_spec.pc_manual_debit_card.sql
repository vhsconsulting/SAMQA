-- liquibase formatted sql
-- changeset SAMQA:1754373936301 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_manual_debit_card.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_manual_debit_card.sql:null:50c6669d3791f93bbc930c98f853a6b8e259a92a:create

grant execute on samqa.pc_manual_debit_card to rl_sam_ro;

grant execute on samqa.pc_manual_debit_card to rl_sam_rw;

grant execute on samqa.pc_manual_debit_card to rl_sam1_ro;

grant debug on samqa.pc_manual_debit_card to sgali;

grant debug on samqa.pc_manual_debit_card to rl_sam_rw;

grant debug on samqa.pc_manual_debit_card to rl_sam_ro;

grant debug on samqa.pc_manual_debit_card to rl_sam1_ro;

