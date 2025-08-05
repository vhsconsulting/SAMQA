-- liquibase formatted sql
-- changeset SAMQA:1754373937849 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.health_plan_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.health_plan_seq.sql:null:571036f978cdb8ab2fcc789c0de10e0f2e3e01fd:create

grant select on samqa.health_plan_seq to rl_sam_rw;

