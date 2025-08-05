-- liquibase formatted sql
-- changeset SAMQA:1754373936767 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.create_employer_payment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.create_employer_payment.sql:null:938fded738f0059898969ad45e30ae861776310c:create

grant execute on samqa.create_employer_payment to rl_sam_ro;

grant execute on samqa.create_employer_payment to rl_sam_rw;

grant execute on samqa.create_employer_payment to rl_sam1_ro;

grant debug on samqa.create_employer_payment to sgali;

grant debug on samqa.create_employer_payment to rl_sam_rw;

grant debug on samqa.create_employer_payment to rl_sam1_ro;

