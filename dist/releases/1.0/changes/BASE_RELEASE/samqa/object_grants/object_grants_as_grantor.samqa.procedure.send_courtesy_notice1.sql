-- liquibase formatted sql
-- changeset SAMQA:1754373937193 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.send_courtesy_notice1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.send_courtesy_notice1.sql:null:99af520c84713e2d0ea6b833b5049a54dcfee071:create

grant execute on samqa.send_courtesy_notice1 to rl_sam_ro;

grant execute on samqa.send_courtesy_notice1 to rl_sam_rw;

grant execute on samqa.send_courtesy_notice1 to rl_sam1_ro;

grant debug on samqa.send_courtesy_notice1 to rl_sam_rw;

grant debug on samqa.send_courtesy_notice1 to rl_sam1_ro;

