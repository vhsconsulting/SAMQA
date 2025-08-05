-- liquibase formatted sql
-- changeset SAMQA:1754373942996 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ben_plan_status.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ben_plan_status.sql:null:e975b1de5b643de0069e60ab07be45875ff20b81:create

grant select on samqa.ben_plan_status to rl_sam1_ro;

grant select on samqa.ben_plan_status to rl_sam_rw;

grant select on samqa.ben_plan_status to rl_sam_ro;

grant select on samqa.ben_plan_status to sgali;

