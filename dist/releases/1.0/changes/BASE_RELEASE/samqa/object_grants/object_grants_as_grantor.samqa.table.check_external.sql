-- liquibase formatted sql
-- changeset SAMQA:1754373939220 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.check_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.check_external.sql:null:046e98ac72dec5d25ab088093f3cd104ec7d05c6:create

grant select on samqa.check_external to rl_sam_ro;

