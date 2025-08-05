-- liquibase formatted sql
-- changeset SAMQA:1754373937558 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.coverage_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.coverage_seq.sql:null:3141212b50393dd221667ad8a12975c2a76bc7a8:create

grant select on samqa.coverage_seq to rl_sam_rw;

