-- liquibase formatted sql
-- changeset SAMQA:1754373944682 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.myperson.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.myperson.sql:null:f8b3ba1f11f474506975f01562ef0a5a483e5bb1:create

grant select on samqa.myperson to rl_sam1_ro;

grant select on samqa.myperson to rl_sam_rw;

grant select on samqa.myperson to rl_sam_ro;

grant select on samqa.myperson to sgali;

