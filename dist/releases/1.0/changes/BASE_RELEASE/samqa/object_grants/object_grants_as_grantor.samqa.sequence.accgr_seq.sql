-- liquibase formatted sql
-- changeset SAMQA:1754373937284 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.accgr_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.accgr_seq.sql:null:b23148354465672f2dbe665b90262e0a526fd49e:create

grant select on samqa.accgr_seq to rl_sam_rw;

grant select on samqa.accgr_seq to cobra;

