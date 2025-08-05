-- liquibase formatted sql
-- changeset SAMQA:1754373935289 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_er_interest.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_er_interest.sql:null:00e2a497a86a726fe52bf7dfa0146dd5f71ded47:create

grant execute on samqa.get_er_interest to rl_sam_ro;

