-- liquibase formatted sql
-- changeset SAMQA:1754373936667 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.aop_outputto_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.aop_outputto_email.sql:null:50507a9e0324b11db561571768b8812bdb1d0526:create

grant execute on samqa.aop_outputto_email to rl_sam_ro;

grant execute on samqa.aop_outputto_email to rl_sam1_ro;

grant execute on samqa.aop_outputto_email to rl_sam_rw;

grant debug on samqa.aop_outputto_email to rl_sam1_ro;

grant debug on samqa.aop_outputto_email to rl_sam_rw;

