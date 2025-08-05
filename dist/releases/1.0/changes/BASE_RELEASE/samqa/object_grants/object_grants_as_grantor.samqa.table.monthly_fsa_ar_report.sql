-- liquibase formatted sql
-- changeset SAMQA:1754373941229 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.monthly_fsa_ar_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.monthly_fsa_ar_report.sql:null:f62418ef3dbf9f63a1f145d7588a622c92e98be5:create

grant delete on samqa.monthly_fsa_ar_report to rl_sam_rw;

grant insert on samqa.monthly_fsa_ar_report to rl_sam_rw;

grant select on samqa.monthly_fsa_ar_report to rl_sam1_ro;

grant select on samqa.monthly_fsa_ar_report to rl_sam_ro;

grant select on samqa.monthly_fsa_ar_report to rl_sam_rw;

grant update on samqa.monthly_fsa_ar_report to rl_sam_rw;

