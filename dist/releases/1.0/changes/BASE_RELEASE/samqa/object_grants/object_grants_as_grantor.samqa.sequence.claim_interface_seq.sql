-- liquibase formatted sql
-- changeset SAMQA:1754373937480 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.claim_interface_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.claim_interface_seq.sql:null:efdc1a1a37fb5c8c2a7b6530a9bcc025fba5fc3f:create

grant select on samqa.claim_interface_seq to rl_sam_rw;

