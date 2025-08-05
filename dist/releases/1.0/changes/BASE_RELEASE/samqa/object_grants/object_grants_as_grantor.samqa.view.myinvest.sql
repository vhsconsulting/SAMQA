-- liquibase formatted sql
-- changeset SAMQA:1754373944651 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.myinvest.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.myinvest.sql:null:adec3d84da407ebb6e25566153dacd504e34ad91:create

grant select on samqa.myinvest to rl_sam1_ro;

grant select on samqa.myinvest to rl_sam_rw;

grant select on samqa.myinvest to rl_sam_ro;

grant select on samqa.myinvest to sgali;

