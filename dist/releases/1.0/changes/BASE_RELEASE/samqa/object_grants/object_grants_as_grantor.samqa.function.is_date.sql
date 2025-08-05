-- liquibase formatted sql
-- changeset SAMQA:1754373935483 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.is_date.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.is_date.sql:null:00636aedca91aa4b6ec6680782f947ed02c76b6e:create

grant execute on samqa.is_date to rl_sam_ro;

