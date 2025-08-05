-- liquibase formatted sql
-- changeset SAMQA:1754373936804 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.delete_employee.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.delete_employee.sql:null:b97ca1bc49b3bc47123b1a4475c3b4965274f066:create

grant execute on samqa.delete_employee to rl_sam_ro;

grant execute on samqa.delete_employee to rl_sam_rw;

grant execute on samqa.delete_employee to rl_sam1_ro;

grant debug on samqa.delete_employee to rl_sam_rw;

grant debug on samqa.delete_employee to rl_sam1_ro;

