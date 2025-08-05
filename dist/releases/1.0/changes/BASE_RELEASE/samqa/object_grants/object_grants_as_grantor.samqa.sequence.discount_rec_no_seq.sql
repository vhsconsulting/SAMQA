-- liquibase formatted sql
-- changeset SAMQA:1754373937642 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.discount_rec_no_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.discount_rec_no_seq.sql:null:a8b4f3ec4dd29487d318605cbf50fcf6f9f9f484:create

grant select on samqa.discount_rec_no_seq to rl_sam_rw;

