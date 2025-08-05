-- liquibase formatted sql
-- changeset SAMQA:1754373940817 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.insure.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.insure.sql:null:509f99db09cd796ecece24cc42f34342aab52696:create

grant delete on samqa.insure to rl_sam_rw;

grant insert on samqa.insure to rl_sam_rw;

grant select on samqa.insure to rl_sam1_ro;

grant select on samqa.insure to rl_sam_rw;

grant select on samqa.insure to rl_sam_ro;

grant update on samqa.insure to rl_sam_rw;

