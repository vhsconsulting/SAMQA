-- liquibase formatted sql
-- changeset SAMQA:1754373938343 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.website_log_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.website_log_seq.sql:null:6093974a131b8a580ac698ae42e39dc56e0151b1:create

grant select on samqa.website_log_seq to rl_sam_rw;

