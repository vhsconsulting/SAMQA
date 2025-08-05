-- liquibase formatted sql
-- changeset SAMQA:1754373944339 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hrafsa_file_upload_results_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hrafsa_file_upload_results_v.sql:null:6597738ec19567557cd58a1d007d47d2e4795b3b:create

grant select on samqa.hrafsa_file_upload_results_v to rl_sam1_ro;

grant select on samqa.hrafsa_file_upload_results_v to rl_sam_rw;

grant select on samqa.hrafsa_file_upload_results_v to rl_sam_ro;

grant select on samqa.hrafsa_file_upload_results_v to sgali;

