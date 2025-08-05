-- liquibase formatted sql
-- changeset SAMQA:1754374180507 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.website_forms_dev.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.website_forms_dev.sql:null:52d9b15e99dbf2f3d87e6fa6c2f9b5f91b506fb7:create

grant execute on directory sys.website_forms_dev to samqa;

grant read on directory sys.website_forms_dev to samqa;

grant write on directory sys.website_forms_dev to samqa;

