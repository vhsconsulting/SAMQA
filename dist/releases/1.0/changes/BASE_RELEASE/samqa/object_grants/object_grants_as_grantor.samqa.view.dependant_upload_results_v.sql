-- liquibase formatted sql
-- changeset SAMQA:1754373943519 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.dependant_upload_results_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.dependant_upload_results_v.sql:null:0a287f6f6278c24885dc8c69704214bbc26486f0:create

grant select on samqa.dependant_upload_results_v to rl_sam1_ro;

grant select on samqa.dependant_upload_results_v to rl_sam_ro;

grant select on samqa.dependant_upload_results_v to rl_sam_rw;

