-- liquibase formatted sql
-- changeset SAMQA:1754373938008 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.mike_settle_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.mike_settle_seq.sql:null:e6b2bd7f29811d424b0e5fae86f1b215c7a7c017:create

grant select on samqa.mike_settle_seq to rl_sam_rw;

