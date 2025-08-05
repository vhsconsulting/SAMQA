-- liquibase formatted sql
-- changeset SAMQA:1754373925630 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.brokernote.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.brokernote.sql:null:a27d0bbaec96983d09caf80fa7051f0b05af226f:create

grant select on cobrap.brokernote to samqa;

