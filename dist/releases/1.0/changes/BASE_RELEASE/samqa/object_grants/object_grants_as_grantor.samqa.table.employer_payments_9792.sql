-- liquibase formatted sql
-- changeset SAMQA:1754373940076 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_payments_9792.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_payments_9792.sql:null:c27d6580228b81bb40e02e256c1cbae1cf993710:create

grant delete on samqa.employer_payments_9792 to rl_sam_rw;

grant insert on samqa.employer_payments_9792 to rl_sam_rw;

grant select on samqa.employer_payments_9792 to rl_sam1_ro;

grant select on samqa.employer_payments_9792 to rl_sam_rw;

grant select on samqa.employer_payments_9792 to rl_sam_ro;

grant update on samqa.employer_payments_9792 to rl_sam_rw;

