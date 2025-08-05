-- liquibase formatted sql
-- changeset SAMQA:1754373937512 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.cobra_plan_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.cobra_plan_seq.sql:null:6079a9188e0dd716b6334183849eaaf37543be23:create

grant select on samqa.cobra_plan_seq to rl_sam_rw;

