-- liquibase formatted sql
-- changeset SAMQA:1754373926001 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.spm.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.spm.sql:null:f8a6bc1ef519b1e9820a9ffe5d8e5e84cbc86b88:create

grant select on cobrap.spm to samqa;

