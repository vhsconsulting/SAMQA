-- liquibase formatted sql
-- changeset SAMQA:1754373939896 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_deposits.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_deposits.sql:null:42aa728cbf7cae2a4e187dbf4a72b441a98649ec:create

grant delete on samqa.employer_deposits to rl_sam_rw;

grant insert on samqa.employer_deposits to rl_sam_rw;

grant select on samqa.employer_deposits to rl_sam1_ro;

grant select on samqa.employer_deposits to reportdb_ro;

grant select on samqa.employer_deposits to rl_sam_rw;

grant select on samqa.employer_deposits to rl_sam_ro;

grant update on samqa.employer_deposits to rl_sam_rw;

