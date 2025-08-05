-- liquibase formatted sql
-- changeset SAMQA:1754373937578 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.debit_card_request_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.debit_card_request_seq.sql:null:3f7d78cf390fd689e11deb7232e4c4d5eddf7360:create

grant select on samqa.debit_card_request_seq to rl_sam_rw;

