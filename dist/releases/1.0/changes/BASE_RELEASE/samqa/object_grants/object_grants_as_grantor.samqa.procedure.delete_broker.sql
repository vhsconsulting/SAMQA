-- liquibase formatted sql
-- changeset SAMQA:1754373936789 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.delete_broker.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.delete_broker.sql:null:ccd4b57e30afbaaa4918f08535d183daf20923c5:create

grant execute on samqa.delete_broker to rl_sam_ro;

grant execute on samqa.delete_broker to rl_sam_rw;

grant execute on samqa.delete_broker to rl_sam1_ro;

grant debug on samqa.delete_broker to rl_sam_rw;

grant debug on samqa.delete_broker to rl_sam1_ro;

