-- liquibase formatted sql
-- changeset SAMQA:1754373938182 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.receivable_details_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.receivable_details_seq.sql:null:bcb8070f83e50fb9a90fa4424ed3eca95e7c111e:create

grant select on samqa.receivable_details_seq to rl_sam_rw;

