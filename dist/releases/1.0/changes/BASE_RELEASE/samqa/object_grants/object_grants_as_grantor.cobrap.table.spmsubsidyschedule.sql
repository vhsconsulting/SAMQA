-- liquibase formatted sql
-- changeset SAMQA:1754373926054 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.spmsubsidyschedule.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.spmsubsidyschedule.sql:null:b5cbee73151e661526b54613f50d3cb28ce4fcfc:create

grant select on cobrap.spmsubsidyschedule to samqa;

