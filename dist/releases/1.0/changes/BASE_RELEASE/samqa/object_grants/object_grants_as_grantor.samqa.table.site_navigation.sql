-- liquibase formatted sql
-- changeset SAMQA:1754373942158 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.site_navigation.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.site_navigation.sql:null:2acf6f6c622504e4b5796e01ce1eb336d10c2acd:create

grant delete on samqa.site_navigation to rl_sam_rw;

grant insert on samqa.site_navigation to rl_sam_rw;

grant select on samqa.site_navigation to rl_sam1_ro;

grant select on samqa.site_navigation to rl_sam_rw;

grant select on samqa.site_navigation to rl_sam_ro;

grant update on samqa.site_navigation to rl_sam_rw;

