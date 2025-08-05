-- liquibase formatted sql
-- changeset SAMQA:1754374180349 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.gp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.gp.sql:null:239d2fd7282aa889a91acc831d991c6736c43576:create

grant execute on directory sys.gp to samqa;

grant read on directory sys.gp to samqa;

grant write on directory sys.gp to samqa;

