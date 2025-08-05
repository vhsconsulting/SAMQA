-- liquibase formatted sql
-- changeset SAMQA:1754373942742 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.account_opportunity1_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.account_opportunity1_v.sql:null:3aeb52fa22bf46e727fc3b185dd304b5dff52daf:create

grant select on samqa.account_opportunity1_v to rl_sam_ro;

