-- liquibase formatted sql
-- changeset SAMQA:1754373940817 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.income_last_year.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.income_last_year.sql:null:7a7959c0aeee4817c988f172d7cb91b24ba0a070:create

grant delete on samqa.income_last_year to rl_sam_rw;

grant insert on samqa.income_last_year to rl_sam_rw;

grant select on samqa.income_last_year to rl_sam1_ro;

grant select on samqa.income_last_year to rl_sam_rw;

grant select on samqa.income_last_year to rl_sam_ro;

grant update on samqa.income_last_year to rl_sam_rw;

