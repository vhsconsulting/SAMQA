-- liquibase formatted sql
-- changeset SAMQA:1754373940040 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_payment_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_payment_log.sql:null:e78d1a5f8504815f762ef3d6cf2476df5ae33ae3:create

grant delete on samqa.employer_payment_log to rl_sam_rw;

grant insert on samqa.employer_payment_log to rl_sam_rw;

grant select on samqa.employer_payment_log to rl_sam1_ro;

grant select on samqa.employer_payment_log to rl_sam_rw;

grant select on samqa.employer_payment_log to rl_sam_ro;

grant update on samqa.employer_payment_log to rl_sam_rw;

