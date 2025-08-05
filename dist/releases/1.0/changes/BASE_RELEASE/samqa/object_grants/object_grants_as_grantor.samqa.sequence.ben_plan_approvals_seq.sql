-- liquibase formatted sql
-- changeset SAMQA:1754373937366 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.ben_plan_approvals_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.ben_plan_approvals_seq.sql:null:0b452c85f1de7280f2f5fb80a62e3f8eb91e583e:create

grant select on samqa.ben_plan_approvals_seq to rl_sam_rw;

