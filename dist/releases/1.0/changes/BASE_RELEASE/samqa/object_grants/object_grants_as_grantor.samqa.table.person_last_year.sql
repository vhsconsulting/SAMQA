-- liquibase formatted sql
-- changeset SAMQA:1754373941677 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.person_last_year.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.person_last_year.sql:null:eda183cad173eb428a8ef1a4dfad4c12975bd353:create

grant delete on samqa.person_last_year to rl_sam_rw;

grant insert on samqa.person_last_year to rl_sam_rw;

grant select on samqa.person_last_year to rl_sam1_ro;

grant select on samqa.person_last_year to rl_sam_rw;

grant select on samqa.person_last_year to rl_sam_ro;

grant update on samqa.person_last_year to rl_sam_rw;

