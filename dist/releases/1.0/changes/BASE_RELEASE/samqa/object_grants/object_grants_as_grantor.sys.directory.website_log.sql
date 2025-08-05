-- liquibase formatted sql
-- changeset SAMQA:1754374180519 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.website_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.website_log.sql:null:9d94aefc5359c3f48ea5871894a53aa53f75e421:create

grant execute on directory sys.website_log to samqa;

grant read on directory sys.website_log to samqa;

grant write on directory sys.website_log to samqa;

