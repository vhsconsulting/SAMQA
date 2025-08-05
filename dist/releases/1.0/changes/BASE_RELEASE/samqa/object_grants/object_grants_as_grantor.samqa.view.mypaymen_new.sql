-- liquibase formatted sql
-- changeset SAMQA:1754373944670 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.mypaymen_new.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.mypaymen_new.sql:null:8e34f6d904f4d0cfa25d2c7fc8c512a500054f0e:create

grant select on samqa.mypaymen_new to rl_sam1_ro;

grant select on samqa.mypaymen_new to rl_sam_rw;

grant select on samqa.mypaymen_new to rl_sam_ro;

grant select on samqa.mypaymen_new to sgali;

