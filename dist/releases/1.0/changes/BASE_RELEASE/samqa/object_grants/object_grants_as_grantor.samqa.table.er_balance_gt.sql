-- liquibase formatted sql
-- changeset SAMQA:1754373940305 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.er_balance_gt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.er_balance_gt.sql:null:8b73e6e46ffc35e7039e16da7ba95e7d41cc98e1:create

grant delete on samqa.er_balance_gt to rl_sam_rw;

grant insert on samqa.er_balance_gt to rl_sam_rw;

grant select on samqa.er_balance_gt to rl_sam1_ro;

grant select on samqa.er_balance_gt to rl_sam_rw;

grant select on samqa.er_balance_gt to rl_sam_ro;

grant update on samqa.er_balance_gt to rl_sam_rw;

