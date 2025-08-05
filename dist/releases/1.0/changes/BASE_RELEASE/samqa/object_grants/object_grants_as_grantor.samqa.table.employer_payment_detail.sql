-- liquibase formatted sql
-- changeset SAMQA:1754373940022 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_payment_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_payment_detail.sql:null:d606f6c5ea5a02a9e836afdb3169034a6f1ccd67:create

grant delete on samqa.employer_payment_detail to rl_sam_rw;

grant insert on samqa.employer_payment_detail to rl_sam_rw;

grant select on samqa.employer_payment_detail to rl_sam1_ro;

grant select on samqa.employer_payment_detail to rl_sam_rw;

grant select on samqa.employer_payment_detail to rl_sam_ro;

grant update on samqa.employer_payment_detail to rl_sam_rw;

