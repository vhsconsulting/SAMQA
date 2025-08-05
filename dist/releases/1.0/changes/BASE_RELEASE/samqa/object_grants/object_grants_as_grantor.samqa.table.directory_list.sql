-- liquibase formatted sql
-- changeset SAMQA:1754373939798 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.directory_list.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.directory_list.sql:null:60e9fd0bb1e23e1778e98373d0817516e80ae160:create

grant delete on samqa.directory_list to rl_sam_rw;

grant insert on samqa.directory_list to rl_sam_rw;

grant select on samqa.directory_list to rl_sam1_ro;

grant select on samqa.directory_list to rl_sam_rw;

grant select on samqa.directory_list to rl_sam_ro;

grant update on samqa.directory_list to rl_sam_rw;

