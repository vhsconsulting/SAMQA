-- liquibase formatted sql
-- changeset SAMQA:1754374180545 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.package_spec.utl_tcp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.package_spec.utl_tcp.sql:null:7c497ba4ddb212b84426676217f237658cc63556:create

grant execute on sys.utl_tcp to samqa;

