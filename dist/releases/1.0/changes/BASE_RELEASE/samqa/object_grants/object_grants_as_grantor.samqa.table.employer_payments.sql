-- liquibase formatted sql
-- changeset SAMQA:1754373940068 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_payments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_payments.sql:null:294f02a43d74bf0b87b48ce7c684f7ed16f69f6b:create

grant alter on samqa.employer_payments to newcobra;

grant alter on samqa.employer_payments to public;

grant delete on samqa.employer_payments to newcobra;

grant delete on samqa.employer_payments to public;

grant delete on samqa.employer_payments to rl_sam_rw;

grant index on samqa.employer_payments to newcobra;

grant index on samqa.employer_payments to public;

grant insert on samqa.employer_payments to newcobra;

grant insert on samqa.employer_payments to public;

grant insert on samqa.employer_payments to rl_sam_rw;

grant select on samqa.employer_payments to rl_sam1_ro;

grant select on samqa.employer_payments to newcobra;

grant select on samqa.employer_payments to public;

grant select on samqa.employer_payments to rl_sam_rw;

grant select on samqa.employer_payments to rl_sam_ro;

grant select on samqa.employer_payments to reportdb_ro;

grant update on samqa.employer_payments to newcobra;

grant update on samqa.employer_payments to public;

grant update on samqa.employer_payments to rl_sam_rw;

grant references on samqa.employer_payments to public;

grant references on samqa.employer_payments to newcobra;

grant read on samqa.employer_payments to public;

grant read on samqa.employer_payments to newcobra;

grant on commit refresh on samqa.employer_payments to public;

grant on commit refresh on samqa.employer_payments to newcobra;

grant query rewrite on samqa.employer_payments to public;

grant query rewrite on samqa.employer_payments to newcobra;

grant debug on samqa.employer_payments to public;

grant debug on samqa.employer_payments to newcobra;

grant flashback on samqa.employer_payments to public;

grant flashback on samqa.employer_payments to newcobra;

