-- liquibase formatted sql
-- changeset SAMQA:1754373945163 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.subscriber_hra_welcome_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.subscriber_hra_welcome_email.sql:null:c2802e92df4f9a84d95176ec381006d379d59ad7:create

grant select on samqa.subscriber_hra_welcome_email to rl_sam_rw;

grant select on samqa.subscriber_hra_welcome_email to rl_sam_ro;

grant select on samqa.subscriber_hra_welcome_email to sgali;

grant select on samqa.subscriber_hra_welcome_email to rl_sam1_ro;

