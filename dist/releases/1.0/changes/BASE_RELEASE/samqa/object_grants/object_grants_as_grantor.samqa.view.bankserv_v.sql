-- liquibase formatted sql
-- changeset SAMQA:1754373942975 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.bankserv_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.bankserv_v.sql:null:7a81661efdf77e4f225c70d7bd9e23a129ccf56b:create

grant select on samqa.bankserv_v to rl_sam1_ro;

grant select on samqa.bankserv_v to rl_sam_rw;

grant select on samqa.bankserv_v to rl_sam_ro;

grant select on samqa.bankserv_v to sgali;

