-- liquibase formatted sql
-- changeset SAMQA:1754373939224 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.check_result_ack_ext_cnb.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.check_result_ack_ext_cnb.sql:null:c32b5922e9e05f95eecdd77fd7488492bf401044:create

grant select on samqa.check_result_ack_ext_cnb to rl_sam_ro;

