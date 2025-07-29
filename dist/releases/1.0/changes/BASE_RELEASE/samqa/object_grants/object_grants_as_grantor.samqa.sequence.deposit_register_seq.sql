-- liquibase formatted sql
-- changeset SAMQA:1753779560823 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.deposit_register_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.deposit_register_seq.sql:null:d2c4399086ae5c0a62db274d5f1fba39638de340:create

grant select on samqa.deposit_register_seq to rl_sam_rw;

