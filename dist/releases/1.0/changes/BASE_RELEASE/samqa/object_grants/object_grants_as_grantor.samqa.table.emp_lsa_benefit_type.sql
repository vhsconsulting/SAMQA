-- liquibase formatted sql
-- changeset SAMQA:1754373939865 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.emp_lsa_benefit_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.emp_lsa_benefit_type.sql:null:c16426e289f87091bfb5827566513dbe908c6d7c:create

grant delete on samqa.emp_lsa_benefit_type to rl_sam_rw;

grant insert on samqa.emp_lsa_benefit_type to rl_sam_rw;

grant select on samqa.emp_lsa_benefit_type to rl_sam1_ro;

grant select on samqa.emp_lsa_benefit_type to rl_sam_ro;

grant select on samqa.emp_lsa_benefit_type to rl_sam_rw;

grant update on samqa.emp_lsa_benefit_type to rl_sam_rw;

