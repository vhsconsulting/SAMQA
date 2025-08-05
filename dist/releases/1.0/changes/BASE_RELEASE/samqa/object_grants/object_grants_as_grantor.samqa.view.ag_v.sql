-- liquibase formatted sql
-- changeset SAMQA:1754373942880 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ag_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ag_v.sql:null:417ca5b3a5ecf124b534b81817ac40d1ba63d1b0:create

grant select on samqa.ag_v to rl_sam1_ro;

grant select on samqa.ag_v to rl_sam_rw;

grant select on samqa.ag_v to rl_sam_ro;

grant select on samqa.ag_v to sgali;

