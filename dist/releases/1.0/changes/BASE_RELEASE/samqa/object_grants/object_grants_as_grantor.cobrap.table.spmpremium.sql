-- liquibase formatted sql
-- changeset SAMQA:1754373926040 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.spmpremium.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.spmpremium.sql:null:f55a0851d82e15fdad897b17b4a0314f317d0e75:create

grant select on cobrap.spmpremium to samqa;

