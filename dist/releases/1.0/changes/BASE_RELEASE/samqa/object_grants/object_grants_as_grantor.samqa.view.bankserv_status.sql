-- liquibase formatted sql
-- changeset SAMQA:1754373942959 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.bankserv_status.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.bankserv_status.sql:null:b71af45c170d739bcca45ec0dfff662be101d38f:create

grant select on samqa.bankserv_status to rl_sam1_ro;

grant select on samqa.bankserv_status to rl_sam_rw;

grant select on samqa.bankserv_status to rl_sam_ro;

grant select on samqa.bankserv_status to sgali;

