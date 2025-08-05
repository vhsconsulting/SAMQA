-- liquibase formatted sql
-- changeset SAMQA:1754373938290 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.subscriber_leads_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.subscriber_leads_seq.sql:null:53237e9a34389e53fc51aa762dfb68506de85043:create

grant select on samqa.subscriber_leads_seq to rl_sam_rw;

