-- liquibase formatted sql
-- changeset SAMQA:1754373940636 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.gp_customer_account_gt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.gp_customer_account_gt.sql:null:f69034676d174c1a519eddc977cb7ab8b47ecadb:create

grant delete on samqa.gp_customer_account_gt to rl_sam_rw;

grant insert on samqa.gp_customer_account_gt to rl_sam_rw;

grant select on samqa.gp_customer_account_gt to rl_sam1_ro;

grant select on samqa.gp_customer_account_gt to rl_sam_rw;

grant select on samqa.gp_customer_account_gt to rl_sam_ro;

grant update on samqa.gp_customer_account_gt to rl_sam_rw;

