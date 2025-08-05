-- liquibase formatted sql
-- changeset SAMQA:1754373941828 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.receivable.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.receivable.sql:null:b9c595bea4f07a6de3c064d2f1ad58008070c8df:create

grant delete on samqa.receivable to rl_sam_rw;

grant insert on samqa.receivable to rl_sam_rw;

grant select on samqa.receivable to rl_sam1_ro;

grant select on samqa.receivable to rl_sam_rw;

grant select on samqa.receivable to rl_sam_ro;

grant update on samqa.receivable to rl_sam_rw;

