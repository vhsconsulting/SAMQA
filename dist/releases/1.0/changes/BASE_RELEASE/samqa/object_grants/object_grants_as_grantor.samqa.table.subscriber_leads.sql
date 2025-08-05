-- liquibase formatted sql
-- changeset SAMQA:1754373942227 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.subscriber_leads.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.subscriber_leads.sql:null:a56266617a1de9f7e739f1fdc340c83ac5311273:create

grant delete on samqa.subscriber_leads to rl_sam_rw;

grant insert on samqa.subscriber_leads to rl_sam_rw;

grant select on samqa.subscriber_leads to rl_sam1_ro;

grant select on samqa.subscriber_leads to rl_sam_rw;

grant select on samqa.subscriber_leads to rl_sam_ro;

grant update on samqa.subscriber_leads to rl_sam_rw;

