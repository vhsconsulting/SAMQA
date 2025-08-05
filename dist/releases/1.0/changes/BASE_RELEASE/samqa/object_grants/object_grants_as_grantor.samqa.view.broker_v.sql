-- liquibase formatted sql
-- changeset SAMQA:1754373943145 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.broker_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.broker_v.sql:null:09f76897dcd13068cbc6352797efb54a5d6e1ace:create

grant select on samqa.broker_v to rl_sam1_ro;

grant select on samqa.broker_v to rl_sam_rw;

grant select on samqa.broker_v to rl_sam_ro;

grant select on samqa.broker_v to sgali;

