-- liquibase formatted sql
-- changeset SAMQA:1754373939547 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.contact_role.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.contact_role.sql:null:75558ba6596658b8f160d10832b8b8b70ca040bb:create

grant delete on samqa.contact_role to rl_sam_rw;

grant insert on samqa.contact_role to rl_sam_rw;

grant select on samqa.contact_role to rl_sam1_ro;

grant select on samqa.contact_role to rl_sam_rw;

grant select on samqa.contact_role to rl_sam_ro;

grant update on samqa.contact_role to rl_sam_rw;

