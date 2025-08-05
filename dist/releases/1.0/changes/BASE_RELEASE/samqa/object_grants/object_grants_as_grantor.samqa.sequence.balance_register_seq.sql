-- liquibase formatted sql
-- changeset SAMQA:1754373937352 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.balance_register_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.balance_register_seq.sql:null:7b566d927144db6b3ac3eecf3ae9b1df0d9e492f:create

grant select on samqa.balance_register_seq to rl_sam_rw;

