-- liquibase formatted sql
-- changeset SAMQA:1754373936875 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.generate_matrix_rates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.generate_matrix_rates.sql:null:bd22678c3f2b95166f88d8df69c6e9e8d90ee003:create

grant execute on samqa.generate_matrix_rates to rl_sam_ro;

