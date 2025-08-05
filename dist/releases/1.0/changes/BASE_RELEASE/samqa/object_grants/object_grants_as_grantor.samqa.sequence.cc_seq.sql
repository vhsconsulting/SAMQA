-- liquibase formatted sql
-- changeset SAMQA:1754373937430 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.cc_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.cc_seq.sql:null:d88154198a1910edf103d8bd8a7fb4489a2d08db:create

grant select on samqa.cc_seq to rl_sam_rw;

