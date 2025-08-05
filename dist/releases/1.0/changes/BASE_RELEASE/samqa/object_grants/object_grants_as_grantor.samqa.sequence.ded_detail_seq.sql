-- liquibase formatted sql
-- changeset SAMQA:1754373937588 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.ded_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.ded_detail_seq.sql:null:9225902b7369a8079be299ebfa490fb22aa6b02f:create

grant select on samqa.ded_detail_seq to rl_sam_rw;

