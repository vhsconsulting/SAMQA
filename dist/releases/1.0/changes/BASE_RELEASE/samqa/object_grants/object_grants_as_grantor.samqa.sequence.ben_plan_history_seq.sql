-- liquibase formatted sql
-- changeset SAMQA:1754373937371 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.ben_plan_history_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.ben_plan_history_seq.sql:null:f71007510178f87fad79a8976a9902b79abffcc1:create

grant select on samqa.ben_plan_history_seq to rl_sam_rw;

