-- liquibase formatted sql
-- changeset SAMQA:1754373942018 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sam_users.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sam_users.sql:null:f0b6381ddc07ef332caa09ef6c3d9f130525e0c1:create

grant alter on samqa.sam_users to asis;

grant delete on samqa.sam_users to rl_sam_rw;

grant delete on samqa.sam_users to asis;

grant index on samqa.sam_users to asis;

grant insert on samqa.sam_users to rl_sam_rw;

grant insert on samqa.sam_users to asis;

grant select on samqa.sam_users to rl_sam1_ro;

grant select on samqa.sam_users to rl_sam_rw;

grant select on samqa.sam_users to rl_sam_ro;

grant select on samqa.sam_users to asis;

grant update on samqa.sam_users to rl_sam_rw;

grant update on samqa.sam_users to asis;

grant references on samqa.sam_users to asis;

grant on commit refresh on samqa.sam_users to asis;

grant query rewrite on samqa.sam_users to asis;

grant debug on samqa.sam_users to asis;

grant flashback on samqa.sam_users to asis;

