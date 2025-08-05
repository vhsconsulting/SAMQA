-- liquibase formatted sql
-- changeset SAMQA:1754373942622 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.type_spec.samclobs.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.type_spec.samclobs.sql:null:774768c0734e120d9d9f667cc6b388f4005dbed1:create

grant execute on samqa.samclobs to rl_sam1_ro;

grant execute on samqa.samclobs to rl_sam_ro;

grant execute on samqa.samclobs to rl_sam_rw;

