-- liquibase formatted sql
-- changeset SAMQA:1754373938548 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.agender.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.agender.sql:null:2e59da8e8ae2fa97b9efb8e914cfb25f9f1af284:create

grant delete on samqa.agender to rl_sam_rw;

grant insert on samqa.agender to rl_sam_rw;

grant select on samqa.agender to rl_sam1_ro;

grant select on samqa.agender to rl_sam_rw;

grant select on samqa.agender to rl_sam_ro;

grant update on samqa.agender to rl_sam_rw;

