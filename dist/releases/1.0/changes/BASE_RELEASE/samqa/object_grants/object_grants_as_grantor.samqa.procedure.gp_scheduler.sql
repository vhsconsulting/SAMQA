-- liquibase formatted sql
-- changeset SAMQA:1754373936888 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.gp_scheduler.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.gp_scheduler.sql:null:c79769f76a85d248825067d9fc9f5493828084b3:create

grant execute on samqa.gp_scheduler to rl_sam_ro;

