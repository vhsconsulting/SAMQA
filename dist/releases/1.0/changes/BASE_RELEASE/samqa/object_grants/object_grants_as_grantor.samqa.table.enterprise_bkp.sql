-- liquibase formatted sql
-- changeset SAMQA:1754373940177 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.enterprise_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.enterprise_bkp.sql:null:cac70685959db07f31f93ec6ee5246c8cf024a56:create

grant delete on samqa.enterprise_bkp to rl_sam_rw;

grant insert on samqa.enterprise_bkp to rl_sam_rw;

grant select on samqa.enterprise_bkp to rl_sam1_ro;

grant select on samqa.enterprise_bkp to rl_sam_rw;

grant select on samqa.enterprise_bkp to rl_sam_ro;

grant update on samqa.enterprise_bkp to rl_sam_rw;

