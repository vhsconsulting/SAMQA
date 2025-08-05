-- liquibase formatted sql
-- changeset SAMQA:1754373943039 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.blocked_users.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.blocked_users.sql:null:a2edbef72e8d6aba5d579a5352ae9fa80b5d38c1:create

grant select on samqa.blocked_users to rl_sam1_ro;

grant select on samqa.blocked_users to rl_sam_rw;

grant select on samqa.blocked_users to rl_sam_ro;

grant select on samqa.blocked_users to sgali;

