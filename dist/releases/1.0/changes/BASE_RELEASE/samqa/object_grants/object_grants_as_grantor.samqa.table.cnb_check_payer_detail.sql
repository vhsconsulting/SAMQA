-- liquibase formatted sql
-- changeset SAMQA:1754373939396 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cnb_check_payer_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cnb_check_payer_detail.sql:null:d62406cbf65e65d5bb50726eb56f7b770bd20a6e:create

grant select on samqa.cnb_check_payer_detail to rl_sam_ro;

