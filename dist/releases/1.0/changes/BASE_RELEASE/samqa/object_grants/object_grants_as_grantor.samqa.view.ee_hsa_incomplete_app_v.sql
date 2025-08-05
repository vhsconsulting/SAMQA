-- liquibase formatted sql
-- changeset SAMQA:1754373943558 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ee_hsa_incomplete_app_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ee_hsa_incomplete_app_v.sql:null:8a611bad1ba89c04ae4e2d60e199596c89d28182:create

grant select on samqa.ee_hsa_incomplete_app_v to rl_sam1_ro;

grant select on samqa.ee_hsa_incomplete_app_v to rl_sam_rw;

grant select on samqa.ee_hsa_incomplete_app_v to rl_sam_ro;

grant select on samqa.ee_hsa_incomplete_app_v to sgali;

