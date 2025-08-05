-- liquibase formatted sql
-- changeset SAMQA:1754373925662 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.client.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.client.sql:null:8f81949604171fa2b2241c7a28065d66f0cfec61:create

grant select on cobrap.client to samqa;

