-- liquibase formatted sql
-- changeset SAMQA:1754373938277 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.site_navigation_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.site_navigation_seq.sql:null:65f8338fc787dac1d195a31a717bcf25888ab5e7:create

grant select on samqa.site_navigation_seq to rl_sam_rw;

