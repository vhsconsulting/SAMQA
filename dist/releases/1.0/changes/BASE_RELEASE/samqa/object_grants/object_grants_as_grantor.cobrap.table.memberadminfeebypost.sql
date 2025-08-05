-- liquibase formatted sql
-- changeset SAMQA:1754373925848 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.memberadminfeebypost.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.memberadminfeebypost.sql:null:860e99b63195622d3a24b40bdc919cb6a87c7293:create

grant select on cobrap.memberadminfeebypost to samqa;

