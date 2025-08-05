-- liquibase formatted sql
-- changeset SAMQA:1754373925818 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientspmbillingfreqoption.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientspmbillingfreqoption.sql:null:2bd33d6472f6fa5ccc27ddec2baae8fc20131f02:create

grant select on cobrap.clientspmbillingfreqoption to samqa;

