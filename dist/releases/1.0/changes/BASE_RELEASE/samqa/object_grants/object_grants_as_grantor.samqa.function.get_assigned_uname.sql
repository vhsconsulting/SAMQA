-- liquibase formatted sql
-- changeset SAMQA:1754373935234 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_assigned_uname.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_assigned_uname.sql:null:593d1261bcbbd7c3a1bd0c0c7c9cd8e179bb69ea:create

grant execute on samqa.get_assigned_uname to rl_sam_ro;

