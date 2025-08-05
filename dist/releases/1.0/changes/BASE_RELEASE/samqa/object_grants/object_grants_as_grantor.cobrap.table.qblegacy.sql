-- liquibase formatted sql
-- changeset SAMQA:1754373925968 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qblegacy.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qblegacy.sql:null:1f3a3dd3b1d54a41cb123472a502901f5ece0c01:create

grant select on cobrap.qblegacy to samqa;

