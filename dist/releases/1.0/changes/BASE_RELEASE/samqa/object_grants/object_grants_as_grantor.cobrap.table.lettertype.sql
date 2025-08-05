-- liquibase formatted sql
-- changeset SAMQA:1754373925840 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.lettertype.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.lettertype.sql:null:36526905544e94604eabff0a504813011f75947e:create

grant select on cobrap.lettertype to samqa;

