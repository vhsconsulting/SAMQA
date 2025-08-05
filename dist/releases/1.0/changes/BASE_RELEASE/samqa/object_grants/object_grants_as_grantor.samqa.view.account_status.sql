-- liquibase formatted sql
-- changeset SAMQA:1754373942753 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.account_status.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.account_status.sql:null:0d58fd94344fd5504f26743f47615348d069742b:create

grant select on samqa.account_status to rl_sam1_ro;

grant select on samqa.account_status to rl_sam_rw;

grant select on samqa.account_status to rl_sam_ro;

grant select on samqa.account_status to sgali;

