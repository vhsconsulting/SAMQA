-- liquibase formatted sql
-- changeset SAMQA:1754373945179 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.subscriber_hra_welcome_letter.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.subscriber_hra_welcome_letter.sql:null:acd42d655f1f67167aeb16ec4f100bbfc6735121:create

grant select on samqa.subscriber_hra_welcome_letter to rl_sam_rw;

grant select on samqa.subscriber_hra_welcome_letter to rl_sam_ro;

grant select on samqa.subscriber_hra_welcome_letter to sgali;

grant select on samqa.subscriber_hra_welcome_letter to rl_sam1_ro;

