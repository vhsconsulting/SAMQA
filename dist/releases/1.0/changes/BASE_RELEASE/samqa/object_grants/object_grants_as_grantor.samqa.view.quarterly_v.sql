-- liquibase formatted sql
-- changeset SAMQA:1754373945017 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.quarterly_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.quarterly_v.sql:null:ef36a4b7c649d3127a206dac22f1032ce3dd173a:create

grant select on samqa.quarterly_v to rl_sam1_ro;

grant select on samqa.quarterly_v to rl_sam_rw;

grant select on samqa.quarterly_v to rl_sam_ro;

grant select on samqa.quarterly_v to sgali;

