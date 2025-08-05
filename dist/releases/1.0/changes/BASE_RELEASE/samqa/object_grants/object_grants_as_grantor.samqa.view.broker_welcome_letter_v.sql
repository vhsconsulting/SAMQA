-- liquibase formatted sql
-- changeset SAMQA:1754373943155 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.broker_welcome_letter_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.broker_welcome_letter_v.sql:null:b0aa8b1241a94ea085c855d7069ac47030b024f5:create

grant select on samqa.broker_welcome_letter_v to rl_sam1_ro;

grant select on samqa.broker_welcome_letter_v to rl_sam_rw;

grant select on samqa.broker_welcome_letter_v to rl_sam_ro;

grant select on samqa.broker_welcome_letter_v to sgali;

