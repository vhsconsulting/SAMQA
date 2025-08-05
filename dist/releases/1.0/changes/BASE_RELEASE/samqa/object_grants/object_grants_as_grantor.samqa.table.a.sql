-- liquibase formatted sql
-- changeset SAMQA:1754373938357 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.a.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.a.sql:null:7d5ef016e16c1b2386605b532efa2662177a54c8:create

grant delete on samqa.a to rl_sam_rw;

grant insert on samqa.a to rl_sam_rw;

grant select on samqa.a to rl_sam1_ro;

grant select on samqa.a to rl_sam_rw;

grant select on samqa.a to rl_sam_ro;

grant update on samqa.a to rl_sam_rw;

