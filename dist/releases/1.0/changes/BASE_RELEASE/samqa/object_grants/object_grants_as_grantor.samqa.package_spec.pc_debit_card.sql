-- liquibase formatted sql
-- changeset SAMQA:1754373936051 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_debit_card.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_debit_card.sql:null:3c48d276c0c73208aa504f52e418d7d897260716:create

grant execute on samqa.pc_debit_card to rl_sam_ro;

grant execute on samqa.pc_debit_card to rl_sam_rw;

grant execute on samqa.pc_debit_card to rl_sam1_ro;

grant debug on samqa.pc_debit_card to rl_sam_ro;

grant debug on samqa.pc_debit_card to sgali;

grant debug on samqa.pc_debit_card to rl_sam_rw;

grant debug on samqa.pc_debit_card to rl_sam1_ro;

