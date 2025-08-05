-- liquibase formatted sql
-- changeset SAMQA:1754373939129 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.broker_salesrep_assignment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.broker_salesrep_assignment.sql:null:d1482437e95ec96386e1b8e00229e4f30d91b8ad:create

grant select on samqa.broker_salesrep_assignment to rl_sam_ro;

