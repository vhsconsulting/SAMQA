-- liquibase formatted sql
-- changeset SAMQA:1754373942002 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sam_roles.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sam_roles.sql:null:083354c7c6d5dd6175d8a6db89b472cbc3789cc4:create

grant delete on samqa.sam_roles to rl_sam_rw;

grant insert on samqa.sam_roles to rl_sam_rw;

grant select on samqa.sam_roles to rl_sam1_ro;

grant select on samqa.sam_roles to rl_sam_rw;

grant select on samqa.sam_roles to rl_sam_ro;

grant update on samqa.sam_roles to rl_sam_rw;

