-- liquibase formatted sql
-- changeset SAMQA:1754373943933 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.file_upload_results_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.file_upload_results_v.sql:null:d4acf1d5ff2494581c43369970a996e4e25645ae:create

grant select on samqa.file_upload_results_v to rl_sam1_ro;

grant select on samqa.file_upload_results_v to rl_sam_rw;

grant select on samqa.file_upload_results_v to rl_sam_ro;

grant select on samqa.file_upload_results_v to sgali;

