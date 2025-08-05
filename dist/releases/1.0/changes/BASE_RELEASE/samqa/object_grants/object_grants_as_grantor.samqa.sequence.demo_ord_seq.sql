-- liquibase formatted sql
-- changeset SAMQA:1754373937612 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.demo_ord_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.demo_ord_seq.sql:null:78ce33fdb0ad3ef828f793b7c3e77e2cb33c8683:create

grant select on samqa.demo_ord_seq to rl_sam_rw;

