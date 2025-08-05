-- liquibase formatted sql
-- changeset SAMQA:1754373939669 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.debit_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.debit_external.sql:null:73eedab8985e28ad1cd92d734a603d6f196f6725:create

grant select on samqa.debit_external to rl_sam1_ro;

grant select on samqa.debit_external to rl_sam_ro;

