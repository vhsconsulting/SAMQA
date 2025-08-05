-- liquibase formatted sql
-- changeset SAMQA:1754373935098 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.add_weeks.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.add_weeks.sql:null:fe84ac1c05d9e15908acb32d7d5b214332127069:create

grant execute on samqa.add_weeks to rl_sam_ro;

