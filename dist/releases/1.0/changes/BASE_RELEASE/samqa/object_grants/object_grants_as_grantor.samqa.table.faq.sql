-- liquibase formatted sql
-- changeset SAMQA:1754373940422 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.faq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.faq.sql:null:7da86d334cc7f509d27c711e405af39b3a158eff:create

grant delete on samqa.faq to rl_sam_rw;

grant insert on samqa.faq to rl_sam_rw;

grant select on samqa.faq to rl_sam1_ro;

grant select on samqa.faq to rl_sam_rw;

grant select on samqa.faq to rl_sam_ro;

grant update on samqa.faq to rl_sam_rw;

