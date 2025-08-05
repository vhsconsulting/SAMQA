-- liquibase formatted sql
-- changeset SAMQA:1754373925976 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qbpayment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qbpayment.sql:null:9bd9de70d7490e5ff623945c688ed4ca2109762b:create

grant select on cobrap.qbpayment to samqa;

