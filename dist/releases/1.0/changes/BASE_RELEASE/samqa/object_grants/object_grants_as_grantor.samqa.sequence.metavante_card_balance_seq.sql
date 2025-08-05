-- liquibase formatted sql
-- changeset SAMQA:1754373937978 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.metavante_card_balance_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.metavante_card_balance_seq.sql:null:93f4527ef6e1428ac157e5627f6048cd30c4219a:create

grant select on samqa.metavante_card_balance_seq to rl_sam_rw;

