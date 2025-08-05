-- liquibase formatted sql
-- changeset SAMQA:1754373935587 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.strip_bad.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.strip_bad.sql:null:c052800514a5e53ba18516c5d3e34d1d4487b76c:create

grant execute on samqa.strip_bad to rl_sam_ro;

