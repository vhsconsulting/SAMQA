-- liquibase formatted sql
-- changeset SAMQA:1754373926049 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.spmscheduledpayment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.spmscheduledpayment.sql:null:3cfa86b8e223c05241bb1bc88f224fc550d0d857:create

grant select on cobrap.spmscheduledpayment to samqa;

