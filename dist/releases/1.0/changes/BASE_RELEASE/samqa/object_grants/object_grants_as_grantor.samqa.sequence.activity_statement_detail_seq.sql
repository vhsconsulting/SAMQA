-- liquibase formatted sql
-- changeset SAMQA:1754373937311 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.activity_statement_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.activity_statement_detail_seq.sql:null:9f13deee950f0ac26c9f3016c2684dd05e4b11b5:create

grant select on samqa.activity_statement_detail_seq to rl_sam_rw;

