-- liquibase formatted sql
-- changeset SAMQA:1754373941526 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.page_validity.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.page_validity.sql:null:106a33e44de6c160e3814e5c6a467052ab2aded3:create

grant delete on samqa.page_validity to rl_sam_rw;

grant insert on samqa.page_validity to rl_sam_rw;

grant select on samqa.page_validity to rl_sam_ro;

grant select on samqa.page_validity to rl_sam_rw;

grant select on samqa.page_validity to rl_sam1_ro;

grant update on samqa.page_validity to rl_sam_rw;

