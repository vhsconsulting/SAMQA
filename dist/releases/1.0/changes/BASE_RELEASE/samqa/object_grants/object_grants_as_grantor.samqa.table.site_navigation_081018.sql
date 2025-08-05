-- liquibase formatted sql
-- changeset SAMQA:1754373942168 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.site_navigation_081018.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.site_navigation_081018.sql:null:317438561a0dc72d9658a77d896b37bd4208beda:create

grant delete on samqa.site_navigation_081018 to rl_sam_rw;

grant insert on samqa.site_navigation_081018 to rl_sam_rw;

grant select on samqa.site_navigation_081018 to rl_sam1_ro;

grant select on samqa.site_navigation_081018 to rl_sam_ro;

grant select on samqa.site_navigation_081018 to rl_sam_rw;

grant update on samqa.site_navigation_081018 to rl_sam_rw;

