-- liquibase formatted sql
-- changeset SAMQA:1754373925885 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.npmaccess.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.npmaccess.sql:null:e8173b013412f4eb3bf8837ad52e92d5fa07e60c:create

grant select on cobrap.npmaccess to samqa;

