-- liquibase formatted sql
-- changeset SAMQA:1754373942176 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.site_navigation_bkup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.site_navigation_bkup.sql:null:b699cf2263c3e4d51d9172d8f7ecf677353ef80e:create

grant delete on samqa.site_navigation_bkup to rl_sam_rw;

grant insert on samqa.site_navigation_bkup to rl_sam_rw;

grant select on samqa.site_navigation_bkup to rl_sam1_ro;

grant select on samqa.site_navigation_bkup to rl_sam_ro;

grant select on samqa.site_navigation_bkup to rl_sam_rw;

grant update on samqa.site_navigation_bkup to rl_sam_rw;

