-- liquibase formatted sql
-- changeset SAMQA:1754374180524 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.package_spec.dbms_crypto.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.package_spec.dbms_crypto.sql:null:3843150dfbc6dac8ceed8df006e1ea75f82073d3:create

grant execute on sys.dbms_crypto to samqa;

