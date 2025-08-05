-- liquibase formatted sql
-- changeset SAMQA:1754373942785 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.accreg_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.accreg_v.sql:null:d5aa31d9cf445cd3d84ade7468eb2d59a03cb1eb:create

grant select on samqa.accreg_v to rl_sam1_ro;

grant select on samqa.accreg_v to rl_sam_rw;

grant select on samqa.accreg_v to rl_sam_ro;

grant select on samqa.accreg_v to sgali;

