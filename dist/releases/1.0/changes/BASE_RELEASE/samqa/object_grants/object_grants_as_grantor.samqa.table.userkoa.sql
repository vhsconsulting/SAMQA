-- liquibase formatted sql
-- changeset SAMQA:1754373942450 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.userkoa.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.userkoa.sql:null:950bc2da0d512d5e8c1a942b58b4f6fcf562d2da:create

grant delete on samqa.userkoa to rl_sam_rw;

grant insert on samqa.userkoa to rl_sam_rw;

grant select on samqa.userkoa to rl_sam1_ro;

grant select on samqa.userkoa to rl_sam_rw;

grant select on samqa.userkoa to rl_sam_ro;

grant update on samqa.userkoa to rl_sam_rw;

