-- liquibase formatted sql
-- changeset SAMQA:1754373936718 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.cleanup_duplicate.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.cleanup_duplicate.sql:null:2fb6017dc012071a44e1ee6de346eed30c81c237:create

grant execute on samqa.cleanup_duplicate to rl_sam_ro;

