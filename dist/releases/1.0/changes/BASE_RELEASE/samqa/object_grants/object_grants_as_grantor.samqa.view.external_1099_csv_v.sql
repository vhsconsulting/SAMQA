-- liquibase formatted sql
-- changeset SAMQA:1754373943888 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.external_1099_csv_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.external_1099_csv_v.sql:null:d88b7602cc6216e659cba8987317003096a1c8b9:create

grant select on samqa.external_1099_csv_v to rl_sam1_ro;

grant select on samqa.external_1099_csv_v to rl_sam_ro;

grant select on samqa.external_1099_csv_v to rl_sam_rw;

