-- liquibase formatted sql
-- changeset SAMQA:1754374180513 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.website_forms_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.website_forms_dir.sql:null:14e8983dbc1c4fe71232c8960a26cd0f28fc9bb0:create

grant execute on directory sys.website_forms_dir to samqa;

grant read on directory sys.website_forms_dir to samqa;

grant write on directory sys.website_forms_dir to samqa;

