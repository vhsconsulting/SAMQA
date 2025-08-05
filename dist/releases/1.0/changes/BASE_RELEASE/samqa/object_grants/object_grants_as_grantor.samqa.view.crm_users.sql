-- liquibase formatted sql
-- changeset SAMQA:1754373943468 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.crm_users.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.crm_users.sql:null:c88082e3abe9610a211b0aa0fe65d2e2591d5036:create

grant select on samqa.crm_users to rl_sam1_ro;

grant select on samqa.crm_users to rl_sam_ro;

grant select on samqa.crm_users to rl_sam_rw;

