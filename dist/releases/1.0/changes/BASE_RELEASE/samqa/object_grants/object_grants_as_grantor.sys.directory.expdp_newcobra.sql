-- liquibase formatted sql
-- changeset SAMQA:1754374180342 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.expdp_newcobra.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.expdp_newcobra.sql:null:95f270e58323433b52ac759eda680af62ee6755a:create

grant execute on directory sys.expdp_newcobra to samqa;

grant read on directory sys.expdp_newcobra to samqa;

grant write on directory sys.expdp_newcobra to samqa;

