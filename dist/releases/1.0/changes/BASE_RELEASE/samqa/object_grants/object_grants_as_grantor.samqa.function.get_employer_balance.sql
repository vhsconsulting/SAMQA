-- liquibase formatted sql
-- changeset SAMQA:1754373935269 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_employer_balance.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_employer_balance.sql:null:51382c35ab078b27a8c54771b88cd75c31a77a70:create

grant execute on samqa.get_employer_balance to rl_sam_ro;

