-- liquibase formatted sql
-- changeset SAMQA:1754373938246 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.scheduler_details_stg_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.scheduler_details_stg_seq.sql:null:6a42ee6957a37eca7bd46a230ad2abaff882747d:create

grant select on samqa.scheduler_details_stg_seq to rl_sam_rw;

