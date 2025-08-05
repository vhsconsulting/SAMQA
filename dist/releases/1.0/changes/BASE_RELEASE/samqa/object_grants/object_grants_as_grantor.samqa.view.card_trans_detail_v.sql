-- liquibase formatted sql
-- changeset SAMQA:1754373943214 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.card_trans_detail_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.card_trans_detail_v.sql:null:07b39226c8f8b8ff4a6d63bbe7e090fe368ebb63:create

grant select on samqa.card_trans_detail_v to rl_sam1_ro;

grant select on samqa.card_trans_detail_v to rl_sam_rw;

grant select on samqa.card_trans_detail_v to rl_sam_ro;

grant select on samqa.card_trans_detail_v to sgali;

