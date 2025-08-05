-- liquibase formatted sql
-- changeset SAMQA:1754373925766 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientplanqbnote.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientplanqbnote.sql:null:ff773f66ee4618be2309063c85a4990d7bd0768c:create

grant select on cobrap.clientplanqbnote to samqa;

