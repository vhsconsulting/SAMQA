-- liquibase formatted sql
-- changeset SAMQA:1754373945111 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.spiff_details_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.spiff_details_v.sql:null:9b6934c4b79fdcec79faad9c91680bca61118d6c:create

grant select on samqa.spiff_details_v to rl_sam1_ro;

grant select on samqa.spiff_details_v to rl_sam_rw;

grant select on samqa.spiff_details_v to rl_sam_ro;

grant select on samqa.spiff_details_v to sgali;

