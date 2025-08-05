-- liquibase formatted sql
-- changeset SAMQA:1754373944459 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.insureg_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.insureg_v.sql:null:f72353352e77d9104ecb6166bb13ba5130bc184c:create

grant select on samqa.insureg_v to rl_sam1_ro;

grant select on samqa.insureg_v to rl_sam_rw;

grant select on samqa.insureg_v to rl_sam_ro;

grant select on samqa.insureg_v to sgali;

