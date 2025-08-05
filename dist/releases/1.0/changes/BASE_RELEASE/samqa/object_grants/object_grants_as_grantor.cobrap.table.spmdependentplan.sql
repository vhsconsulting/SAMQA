-- liquibase formatted sql
-- changeset SAMQA:1754373926023 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.spmdependentplan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.spmdependentplan.sql:null:d182cc4ae6c154a8cb592d6e6968ca4edb823076:create

grant select on cobrap.spmdependentplan to samqa;

