-- liquibase formatted sql
-- changeset SAMQA:1754373942975 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.batch_upload_results_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.batch_upload_results_v.sql:null:9f1b1014505b90d517a4b5580841f2df4c8c4b61:create

grant select on samqa.batch_upload_results_v to rl_sam1_ro;

grant select on samqa.batch_upload_results_v to rl_sam_rw;

grant select on samqa.batch_upload_results_v to rl_sam_ro;

grant select on samqa.batch_upload_results_v to sgali;

