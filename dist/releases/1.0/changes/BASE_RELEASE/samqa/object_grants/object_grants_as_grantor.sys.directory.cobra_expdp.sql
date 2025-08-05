-- liquibase formatted sql
-- changeset SAMQA:1754374180271 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.cobra_expdp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.cobra_expdp.sql:null:5fc45d08af4bbeb63cea1ce502dd00032ef7b118:create

grant execute on directory sys.cobra_expdp to samqa;

grant read on directory sys.cobra_expdp to samqa;

grant write on directory sys.cobra_expdp to samqa;

