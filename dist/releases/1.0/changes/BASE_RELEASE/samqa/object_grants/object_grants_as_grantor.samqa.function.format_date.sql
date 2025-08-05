-- liquibase formatted sql
-- changeset SAMQA:1754373935217 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.format_date.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.format_date.sql:null:24b40bfe5cd025e1fff560ef6d39293190f93250:create

grant execute on samqa.format_date to rl_sam_ro;

grant execute on samqa.format_date to rl_sam_rw;

grant execute on samqa.format_date to cobra;

grant execute on samqa.format_date to rl_sam1_ro;

grant debug on samqa.format_date to sgali;

grant debug on samqa.format_date to rl_sam_rw;

grant debug on samqa.format_date to rl_sam1_ro;

