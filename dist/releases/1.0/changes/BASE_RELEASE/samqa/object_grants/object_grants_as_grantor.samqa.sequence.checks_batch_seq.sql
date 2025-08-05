-- liquibase formatted sql
-- changeset SAMQA:1754373937454 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.checks_batch_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.checks_batch_seq.sql:null:7b0e6b0e59017c82f184fff23f3f4bf42f7ca5df:create

grant alter on samqa.checks_batch_seq to public;

grant select on samqa.checks_batch_seq to public;

