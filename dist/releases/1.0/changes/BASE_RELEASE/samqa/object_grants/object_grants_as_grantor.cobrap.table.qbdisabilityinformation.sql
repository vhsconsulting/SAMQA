-- liquibase formatted sql
-- changeset SAMQA:1754373925960 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qbdisabilityinformation.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qbdisabilityinformation.sql:null:c64708e7c3c4909cbb455dbdeacd024758b96291:create

grant select on cobrap.qbdisabilityinformation to samqa;

