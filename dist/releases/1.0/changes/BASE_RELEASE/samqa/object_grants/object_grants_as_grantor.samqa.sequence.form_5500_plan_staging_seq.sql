-- liquibase formatted sql
-- changeset SAMQA:1754373937801 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.form_5500_plan_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.form_5500_plan_staging_seq.sql:null:788a5dbbfe55e430feda023d4d8a479ee7b5b654:create

grant select on samqa.form_5500_plan_staging_seq to rl_sam_rw;

