-- liquibase formatted sql
-- changeset SAMQA:1754373945435 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.website_forms_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.website_forms_v.sql:null:34f59d24ddb997ca1aa619253ec1129f94622c65:create

grant select on samqa.website_forms_v to rl_sam_rw;

grant select on samqa.website_forms_v to rl_sam_ro;

grant select on samqa.website_forms_v to sgali;

grant select on samqa.website_forms_v to rl_sam1_ro;

