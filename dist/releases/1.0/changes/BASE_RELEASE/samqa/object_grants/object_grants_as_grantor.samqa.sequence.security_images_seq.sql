-- liquibase formatted sql
-- changeset SAMQA:1754373938262 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.security_images_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.security_images_seq.sql:null:fc86eb85b9d3befdf2964e8441d6a200bd17a2a7:create

grant select on samqa.security_images_seq to rl_sam_rw;

