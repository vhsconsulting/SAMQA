-- liquibase formatted sql
-- changeset SAMQA:1754373925855 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.memberletterattachment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.memberletterattachment.sql:null:89648a3945f9a07b8e03e0a3556b82fd2faedd8b:create

grant select on cobrap.memberletterattachment to samqa;

