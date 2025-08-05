-- liquibase formatted sql
-- changeset SAMQA:1754373940833 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.insure_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.insure_history.sql:null:42556570cfeead61c60d4ae2a836d952721542f0:create

grant delete on samqa.insure_history to rl_sam_rw;

grant insert on samqa.insure_history to rl_sam_rw;

grant select on samqa.insure_history to rl_sam1_ro;

grant select on samqa.insure_history to rl_sam_rw;

grant select on samqa.insure_history to rl_sam_ro;

grant update on samqa.insure_history to rl_sam_rw;

