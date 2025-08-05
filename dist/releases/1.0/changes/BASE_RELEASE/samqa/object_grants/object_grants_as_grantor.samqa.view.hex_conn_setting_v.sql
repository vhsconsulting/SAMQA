-- liquibase formatted sql
-- changeset SAMQA:1754373944216 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hex_conn_setting_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hex_conn_setting_v.sql:null:fa059ccaa623aea7f17ca3098523b36bfa8fde23:create

grant select on samqa.hex_conn_setting_v to rl_sam1_ro;

grant select on samqa.hex_conn_setting_v to rl_sam_rw;

grant select on samqa.hex_conn_setting_v to rl_sam_ro;

grant select on samqa.hex_conn_setting_v to sgali;

