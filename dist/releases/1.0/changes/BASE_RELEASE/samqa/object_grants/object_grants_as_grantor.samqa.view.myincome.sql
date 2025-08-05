-- liquibase formatted sql
-- changeset SAMQA:1754373944634 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.myincome.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.myincome.sql:null:8d3e885dd1ed347de5fef43eca4b56e1455ff4ce:create

grant select on samqa.myincome to rl_sam_ro;

grant select on samqa.myincome to sgali;

grant select on samqa.myincome to rl_sam1_ro;

grant select on samqa.myincome to rl_sam_rw;

