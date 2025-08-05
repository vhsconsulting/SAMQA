-- liquibase formatted sql
-- changeset SAMQA:1754373945444 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.weekly_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.weekly_v.sql:null:1f9fb5d6c926dcb0c8c02783377a0e933b008815:create

grant select on samqa.weekly_v to rl_sam1_ro;

grant select on samqa.weekly_v to rl_sam_rw;

grant select on samqa.weekly_v to rl_sam_ro;

grant select on samqa.weekly_v to sgali;

