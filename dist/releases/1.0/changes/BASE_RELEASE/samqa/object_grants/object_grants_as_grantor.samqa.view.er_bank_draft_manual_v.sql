-- liquibase formatted sql
-- changeset SAMQA:1754373943803 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.er_bank_draft_manual_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.er_bank_draft_manual_v.sql:null:a00e70e9befa6623f82c2ee58b742f8c833808ac:create

grant delete on samqa.er_bank_draft_manual_v to public;

grant insert on samqa.er_bank_draft_manual_v to public;

grant select on samqa.er_bank_draft_manual_v to rl_sam1_ro;

grant select on samqa.er_bank_draft_manual_v to public;

grant select on samqa.er_bank_draft_manual_v to rl_sam_ro;

grant select on samqa.er_bank_draft_manual_v to rl_sam_rw;

grant update on samqa.er_bank_draft_manual_v to public;

grant references on samqa.er_bank_draft_manual_v to public;

grant read on samqa.er_bank_draft_manual_v to public;

grant on commit refresh on samqa.er_bank_draft_manual_v to public;

grant query rewrite on samqa.er_bank_draft_manual_v to public;

grant debug on samqa.er_bank_draft_manual_v to public;

grant flashback on samqa.er_bank_draft_manual_v to public;

grant merge view on samqa.er_bank_draft_manual_v to public;

