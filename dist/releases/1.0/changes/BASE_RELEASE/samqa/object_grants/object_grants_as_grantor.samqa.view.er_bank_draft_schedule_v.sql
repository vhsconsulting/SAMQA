-- liquibase formatted sql
-- changeset SAMQA:1754373943810 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.er_bank_draft_schedule_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.er_bank_draft_schedule_v.sql:null:f7a2e7ededd2a7e221417f843ab05271b82c2ecb:create

grant select on samqa.er_bank_draft_schedule_v to rl_sam1_ro;

grant select on samqa.er_bank_draft_schedule_v to rl_sam_rw;

grant select on samqa.er_bank_draft_schedule_v to rl_sam_ro;

grant select on samqa.er_bank_draft_schedule_v to sgali;

