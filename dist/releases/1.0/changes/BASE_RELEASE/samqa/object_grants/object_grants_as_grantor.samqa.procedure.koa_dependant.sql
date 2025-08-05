-- liquibase formatted sql
-- changeset SAMQA:1754373936915 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.koa_dependant.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.koa_dependant.sql:null:84cbc5dbea16f293b4a7cdce4263822fa4f786a3:create

grant execute on samqa.koa_dependant to rl_sam_ro;

