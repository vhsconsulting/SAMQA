-- liquibase formatted sql
-- changeset SAMQA:1754373935322 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_list_bill.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_list_bill.sql:null:7a81bde1e28978a4f865226b5e8348fae8e808c6:create

grant execute on samqa.get_list_bill to rl_sam_ro;

