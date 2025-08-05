-- liquibase formatted sql
-- changeset SAMQA:1754373938608 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.all_audit.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.all_audit.sql:null:7b8f420f8156c5330e47a7be31bba218243cd761:create

grant delete on samqa.all_audit to rl_sam_rw;

grant insert on samqa.all_audit to rl_sam_rw;

grant select on samqa.all_audit to rl_sam1_ro;

grant select on samqa.all_audit to rl_sam_rw;

grant select on samqa.all_audit to rl_sam_ro;

grant update on samqa.all_audit to rl_sam_rw;

