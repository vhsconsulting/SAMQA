-- liquibase formatted sql
-- changeset SAMQA:1754373937849 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.health_plan_upload_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.health_plan_upload_seq.sql:null:9bf1110b8516930de5cf62ede75dbe303ab78b22:create

grant select on samqa.health_plan_upload_seq to rl_sam_rw;

