-- liquibase formatted sql
-- changeset SAMQA:1754373939196 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cards_status_gt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cards_status_gt.sql:null:a51361a5559d8c15a83e29bb54e4da52d773f1d9:create

grant delete on samqa.cards_status_gt to rl_sam_rw;

grant insert on samqa.cards_status_gt to rl_sam_rw;

grant select on samqa.cards_status_gt to rl_sam1_ro;

grant select on samqa.cards_status_gt to rl_sam_rw;

grant select on samqa.cards_status_gt to rl_sam_ro;

grant update on samqa.cards_status_gt to rl_sam_rw;

