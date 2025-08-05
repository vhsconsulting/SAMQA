-- liquibase formatted sql
-- changeset SAMQA:1754373936660 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.aop_outputto_collection.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.aop_outputto_collection.sql:null:366c3a3b61e87e10a3f13a0930c79a8b5f95b66c:create

grant execute on samqa.aop_outputto_collection to rl_sam_ro;

grant execute on samqa.aop_outputto_collection to rl_sam1_ro;

grant execute on samqa.aop_outputto_collection to rl_sam_rw;

grant debug on samqa.aop_outputto_collection to rl_sam1_ro;

grant debug on samqa.aop_outputto_collection to rl_sam_rw;

