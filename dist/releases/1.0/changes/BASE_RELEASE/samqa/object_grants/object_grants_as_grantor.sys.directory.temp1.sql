-- liquibase formatted sql
-- changeset SAMQA:1754374180447 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.temp1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.temp1.sql:null:ebc81ae9b2d7cab99df232720e29d1364ae5b083:create

grant execute on directory sys.temp1 to samqa;

grant read on directory sys.temp1 to samqa;

grant write on directory sys.temp1 to samqa;

