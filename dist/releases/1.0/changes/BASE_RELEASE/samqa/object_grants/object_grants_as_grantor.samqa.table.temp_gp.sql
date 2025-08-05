-- liquibase formatted sql
-- changeset SAMQA:1754373942292 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.temp_gp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.temp_gp.sql:null:84c2bd839f41ef702d0eb8a930d132e3eee572b1:create

grant delete on samqa.temp_gp to rl_sam_rw;

grant insert on samqa.temp_gp to rl_sam_rw;

grant select on samqa.temp_gp to rl_sam1_ro;

grant select on samqa.temp_gp to rl_sam_rw;

grant select on samqa.temp_gp to rl_sam_ro;

grant update on samqa.temp_gp to rl_sam_rw;

