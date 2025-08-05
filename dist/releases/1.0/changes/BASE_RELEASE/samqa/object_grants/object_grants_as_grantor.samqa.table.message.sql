-- liquibase formatted sql
-- changeset SAMQA:1754373941118 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.message.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.message.sql:null:3ccc8007dfa54effbfaed8b9938e210b126eb9eb:create

grant delete on samqa.message to rl_sam_rw;

grant insert on samqa.message to rl_sam_rw;

grant select on samqa.message to rl_sam1_ro;

grant select on samqa.message to rl_sam_rw;

grant select on samqa.message to rl_sam_ro;

grant update on samqa.message to rl_sam_rw;

