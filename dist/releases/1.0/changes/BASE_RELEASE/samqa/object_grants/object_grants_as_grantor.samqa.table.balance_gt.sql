-- liquibase formatted sql
-- changeset SAMQA:1754373938783 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.balance_gt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.balance_gt.sql:null:7b5488a8734db7ff41e77285e97a7b7c88064d06:create

grant delete on samqa.balance_gt to rl_sam_rw;

grant insert on samqa.balance_gt to rl_sam_rw;

grant select on samqa.balance_gt to rl_sam1_ro;

grant select on samqa.balance_gt to rl_sam_rw;

grant select on samqa.balance_gt to rl_sam_ro;

grant update on samqa.balance_gt to rl_sam_rw;

