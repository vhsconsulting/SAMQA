-- liquibase formatted sql
-- changeset SAMQA:1754373944690 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.myperson_pl.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.myperson_pl.sql:null:8f297ece02bbdb49d90ec50af502c6e795411b96:create

grant select on samqa.myperson_pl to rl_sam1_ro;

grant select on samqa.myperson_pl to rl_sam_rw;

grant select on samqa.myperson_pl to rl_sam_ro;

grant select on samqa.myperson_pl to sgali;

