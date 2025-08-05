-- liquibase formatted sql
-- changeset SAMQA:1754373935179 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.date_or_null.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.date_or_null.sql:null:6755ca269a584e94e43a045d6a76b04eb96f3975:create

grant execute on samqa.date_or_null to rl_sam_ro;

