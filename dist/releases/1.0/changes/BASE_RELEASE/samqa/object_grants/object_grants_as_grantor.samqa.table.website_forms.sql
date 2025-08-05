-- liquibase formatted sql
-- changeset SAMQA:1754373942524 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.website_forms.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.website_forms.sql:null:a0920957dd949602929dd87e285a7e556d7a5c18:create

grant delete on samqa.website_forms to rl_sam_rw;

grant insert on samqa.website_forms to rl_sam_rw;

grant select on samqa.website_forms to rl_sam1_ro;

grant select on samqa.website_forms to rl_sam_rw;

grant select on samqa.website_forms to rl_sam_ro;

grant update on samqa.website_forms to rl_sam_rw;

