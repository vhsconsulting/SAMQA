-- liquibase formatted sql
-- changeset SAMQA:1754373942254 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.system_parameters.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.system_parameters.sql:null:56737e81d68bccf547db4ac639cab58bf4a45ac4:create

grant delete on samqa.system_parameters to rl_sam_rw;

grant insert on samqa.system_parameters to rl_sam_rw;

grant select on samqa.system_parameters to rl_sam1_ro;

grant select on samqa.system_parameters to rl_sam_rw;

grant select on samqa.system_parameters to rl_sam_ro;

grant update on samqa.system_parameters to rl_sam_rw;

