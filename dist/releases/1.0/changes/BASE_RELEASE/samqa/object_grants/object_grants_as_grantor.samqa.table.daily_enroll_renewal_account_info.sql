-- liquibase formatted sql
-- changeset SAMQA:1754373939616 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.daily_enroll_renewal_account_info.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.daily_enroll_renewal_account_info.sql:null:443fb74f7cb5f70b0fafbd233d759f9b47c0f15a:create

grant delete on samqa.daily_enroll_renewal_account_info to rl_sam_rw;

grant insert on samqa.daily_enroll_renewal_account_info to rl_sam_rw;

grant select on samqa.daily_enroll_renewal_account_info to rl_sam1_ro;

grant select on samqa.daily_enroll_renewal_account_info to rl_sam_ro;

grant select on samqa.daily_enroll_renewal_account_info to rl_sam_rw;

grant update on samqa.daily_enroll_renewal_account_info to rl_sam_rw;

