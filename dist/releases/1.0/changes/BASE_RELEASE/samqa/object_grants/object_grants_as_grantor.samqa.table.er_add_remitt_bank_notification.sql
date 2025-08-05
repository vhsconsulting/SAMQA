-- liquibase formatted sql
-- changeset SAMQA:1754373940297 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.er_add_remitt_bank_notification.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.er_add_remitt_bank_notification.sql:null:9036e8c5febeca580ee8ed480abe99cc7ce9573b:create

grant select on samqa.er_add_remitt_bank_notification to rl_sam_ro;

