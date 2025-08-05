-- liquibase formatted sql
-- changeset SAMQA:1754373945245 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.subscriber_welcome_letter.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.subscriber_welcome_letter.sql:null:8ce9a568969186f1e8007a10fc2a1b52c2c8172d:create

grant select on samqa.subscriber_welcome_letter to rl_sam_rw;

grant select on samqa.subscriber_welcome_letter to rl_sam_ro;

grant select on samqa.subscriber_welcome_letter to sgali;

grant select on samqa.subscriber_welcome_letter to rl_sam1_ro;

