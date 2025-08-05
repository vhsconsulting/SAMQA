-- liquibase formatted sql
-- changeset SAMQA:1754373937517 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.compliance_plan_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.compliance_plan_seq.sql:null:5210117dc4ac08fea77be8be27860d9e6b366ff6:create

grant select on samqa.compliance_plan_seq to rl_sam_rw;

