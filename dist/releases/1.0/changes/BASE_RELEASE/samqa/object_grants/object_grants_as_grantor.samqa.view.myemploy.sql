-- liquibase formatted sql
-- changeset SAMQA:1754373944609 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.myemploy.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.myemploy.sql:null:2bedc003c22604be37505a4490e511b0054f0715:create

grant select on samqa.myemploy to rl_sam1_ro;

grant select on samqa.myemploy to rl_sam_rw;

grant select on samqa.myemploy to rl_sam_ro;

grant select on samqa.myemploy to sgali;

