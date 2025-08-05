-- liquibase formatted sql
-- changeset SAMQA:1754373944204 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.gender.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.gender.sql:null:0a29856b26311f1c15cefa203c8aea7fa9e65b13:create

grant select on samqa.gender to rl_sam1_ro;

grant select on samqa.gender to rl_sam_rw;

grant select on samqa.gender to rl_sam_ro;

grant select on samqa.gender to sgali;

