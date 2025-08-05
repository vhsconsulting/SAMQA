-- liquibase formatted sql
-- changeset SAMQA:1754373941309 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.new_hsa_commission_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.new_hsa_commission_report.sql:null:8efa195f9b6305f806dcf85754848f790a9f59be:create

grant delete on samqa.new_hsa_commission_report to rl_sam_rw;

grant insert on samqa.new_hsa_commission_report to rl_sam_rw;

grant select on samqa.new_hsa_commission_report to rl_sam1_ro;

grant select on samqa.new_hsa_commission_report to rl_sam_ro;

grant select on samqa.new_hsa_commission_report to rl_sam_rw;

grant update on samqa.new_hsa_commission_report to rl_sam_rw;

