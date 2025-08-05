-- liquibase formatted sql
-- changeset SAMQA:1754373937607 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.demo_images_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.demo_images_seq.sql:null:60b2b360305876ba64fd621f5e5e94fe3d40ce7b:create

grant select on samqa.demo_images_seq to rl_sam_rw;

