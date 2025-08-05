-- liquibase formatted sql
-- changeset SAMQA:1754373945444 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.yes_no.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.yes_no.sql:null:5332a4de8582980e11cbdcbc3a072f4a1dfc8376:create

grant select on samqa.yes_no to rl_sam_rw;

grant select on samqa.yes_no to rl_sam_ro;

grant select on samqa.yes_no to sgali;

grant select on samqa.yes_no to rl_sam1_ro;

