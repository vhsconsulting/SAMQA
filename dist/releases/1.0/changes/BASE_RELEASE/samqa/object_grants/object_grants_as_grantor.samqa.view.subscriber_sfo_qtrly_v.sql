-- liquibase formatted sql
-- changeset SAMQA:1754373945233 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.subscriber_sfo_qtrly_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.subscriber_sfo_qtrly_v.sql:null:e4397eb2ab36d914e23dfa544e5b814a0d7df06d:create

grant select on samqa.subscriber_sfo_qtrly_v to rl_sam_rw;

grant select on samqa.subscriber_sfo_qtrly_v to rl_sam_ro;

grant select on samqa.subscriber_sfo_qtrly_v to sgali;

grant select on samqa.subscriber_sfo_qtrly_v to rl_sam1_ro;

