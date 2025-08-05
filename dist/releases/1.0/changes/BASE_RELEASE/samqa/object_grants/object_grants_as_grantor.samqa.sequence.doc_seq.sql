-- liquibase formatted sql
-- changeset SAMQA:1754373937647 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.doc_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.doc_seq.sql:null:535aec9e19c529f86d18bcac35f3fedd9eca10aa:create

grant select on samqa.doc_seq to rl_sam_rw;

