-- liquibase formatted sql
-- changeset SAMQA:1754373935366 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_quarter_balance.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_quarter_balance.sql:null:acdda0a16a24cbaa3cb95dbab91b2f9b6ecad2f0:create

grant execute on samqa.get_quarter_balance to rl_sam_ro;

