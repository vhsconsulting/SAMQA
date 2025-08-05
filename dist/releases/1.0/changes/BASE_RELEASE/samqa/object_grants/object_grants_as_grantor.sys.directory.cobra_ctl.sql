-- liquibase formatted sql
-- changeset SAMQA:1754374180259 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.cobra_ctl.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.cobra_ctl.sql:null:fab0446c71fd105869a3f0a87bf16775d473e769:create

grant execute on directory sys.cobra_ctl to samqa;

grant read on directory sys.cobra_ctl to samqa;

grant write on directory sys.cobra_ctl to samqa;

