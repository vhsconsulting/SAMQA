-- liquibase formatted sql
-- changeset SAMQA:1754373941341 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.notes_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.notes_bkp.sql:null:5e16c71f4551b35ea6e158ba49ce8d7bbf3c8227:create

grant delete on samqa.notes_bkp to rl_sam_rw;

grant insert on samqa.notes_bkp to rl_sam_rw;

grant select on samqa.notes_bkp to rl_sam1_ro;

grant select on samqa.notes_bkp to rl_sam_rw;

grant select on samqa.notes_bkp to rl_sam_ro;

grant update on samqa.notes_bkp to rl_sam_rw;

