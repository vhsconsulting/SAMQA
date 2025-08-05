-- liquibase formatted sql
-- changeset SAMQA:1754373925930 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qbaccess.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qbaccess.sql:null:2add3dd2cb772349d89afbc941daa65615857dad:create

grant select on cobrap.qbaccess to samqa;

