-- liquibase formatted sql
-- changeset SAMQA:1754373941395 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.online_disb_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.online_disb_external.sql:null:641f565eb33ee93cbc8295423ffe855ae44a0c36:create

grant select on samqa.online_disb_external to rl_sam1_ro;

grant select on samqa.online_disb_external to rl_sam_ro;

