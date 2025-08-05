-- liquibase formatted sql
-- changeset SAMQA:1754373939532 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.contact_import.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.contact_import.sql:null:5c592d1e06b2033b0f815c61f3c2a13ad32ed38a:create

grant delete on samqa.contact_import to rl_sam_rw;

grant insert on samqa.contact_import to rl_sam_rw;

grant select on samqa.contact_import to rl_sam1_ro;

grant select on samqa.contact_import to rl_sam_rw;

grant select on samqa.contact_import to rl_sam_ro;

grant update on samqa.contact_import to rl_sam_rw;

