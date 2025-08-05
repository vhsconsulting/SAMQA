-- liquibase formatted sql
-- changeset SAMQA:1754373935246 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_biweekly.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_biweekly.sql:null:71af9a0c868cd8465c093b7dd05d695a4beb87f0:create

grant execute on samqa.get_biweekly to rl_sam_ro;

