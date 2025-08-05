-- liquibase formatted sql
-- changeset SAMQA:1754373937593 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.ded_rule_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.ded_rule_seq.sql:null:a23a5f0da3031ce21e5eb96815ac1262ed294ed0:create

grant select on samqa.ded_rule_seq to rl_sam_rw;

