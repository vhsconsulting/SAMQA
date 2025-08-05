-- liquibase formatted sql
-- changeset SAMQA:1754373939904 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_discount.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_discount.sql:null:ad4ac5060dc2f2329a2b91cd350fd578f2f2a864:create

grant delete on samqa.employer_discount to rl_sam_rw;

grant insert on samqa.employer_discount to rl_sam_rw;

grant select on samqa.employer_discount to rl_sam1_ro;

grant select on samqa.employer_discount to rl_sam_ro;

grant select on samqa.employer_discount to rl_sam_rw;

grant update on samqa.employer_discount to rl_sam_rw;

