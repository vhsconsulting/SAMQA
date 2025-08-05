-- liquibase formatted sql
-- changeset SAMQA:1754374180264 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.cobra_data.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.cobra_data.sql:null:aeca09075d77ab39e420bd06ff6ae67c958fee94:create

grant execute on directory sys.cobra_data to samqa;

grant read on directory sys.cobra_data to samqa;

grant write on directory sys.cobra_data to samqa;

