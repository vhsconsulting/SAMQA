-- liquibase formatted sql
-- changeset SAMQA:1754373940013 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_payment_del.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_payment_del.sql:null:66f3c053b525c5b05e227bf973fce4f15f83fb94:create

grant delete on samqa.employer_payment_del to rl_sam_rw;

grant insert on samqa.employer_payment_del to rl_sam_rw;

grant select on samqa.employer_payment_del to rl_sam1_ro;

grant select on samqa.employer_payment_del to rl_sam_ro;

grant select on samqa.employer_payment_del to rl_sam_rw;

grant update on samqa.employer_payment_del to rl_sam_rw;

