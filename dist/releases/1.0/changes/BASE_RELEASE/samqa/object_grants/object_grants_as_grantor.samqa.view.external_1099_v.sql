-- liquibase formatted sql
-- changeset SAMQA:1754373943894 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.external_1099_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.external_1099_v.sql:null:ad21dbe27275d3ef202dbd3079a450564d26e9fc:create

grant select on samqa.external_1099_v to rl_sam1_ro;

grant select on samqa.external_1099_v to rl_sam_rw;

grant select on samqa.external_1099_v to rl_sam_ro;

grant select on samqa.external_1099_v to sgali;

