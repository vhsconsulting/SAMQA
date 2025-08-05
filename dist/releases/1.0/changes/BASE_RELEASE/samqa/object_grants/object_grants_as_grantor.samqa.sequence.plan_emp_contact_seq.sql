-- liquibase formatted sql
-- changeset SAMQA:1754373938134 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.plan_emp_contact_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.plan_emp_contact_seq.sql:null:d8f1748cc433fdb1af52f6c572ed73ebb0c88717:create

grant select on samqa.plan_emp_contact_seq to rl_sam_rw;

