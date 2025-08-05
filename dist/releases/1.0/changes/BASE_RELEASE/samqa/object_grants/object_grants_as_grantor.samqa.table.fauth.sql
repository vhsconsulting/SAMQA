-- liquibase formatted sql
-- changeset SAMQA:1754373940447 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.fauth.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.fauth.sql:null:d2afc8bbcdf1cbf91d2d71aa695ee3a590627262:create

grant delete on samqa.fauth to rl_sam_rw;

grant insert on samqa.fauth to rl_sam_rw;

grant select on samqa.fauth to rl_sam1_ro;

grant select on samqa.fauth to rl_sam_rw;

grant select on samqa.fauth to rl_sam_ro;

grant update on samqa.fauth to rl_sam_rw;

