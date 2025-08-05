-- liquibase formatted sql
-- changeset SAMQA:1754373937671 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.employer_deposit_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.employer_deposit_seq.sql:null:a4f212ea71e1387b9cf1b75dccb9d1968d9c9820:create

grant select on samqa.employer_deposit_seq to rl_sam_rw;

