-- liquibase formatted sql
-- changeset SAMQA:1754373943246 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.carriers_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.carriers_v.sql:null:ff047c445b40da9e41b6af646a09c7018e81fe6e:create

grant select on samqa.carriers_v to rl_sam1_ro;

grant select on samqa.carriers_v to rl_sam_rw;

grant select on samqa.carriers_v to rl_sam_ro;

grant select on samqa.carriers_v to sgali;

