-- liquibase formatted sql
-- changeset SAMQA:1754373939401 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cnb_check_sent_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cnb_check_sent_details.sql:null:0c03e3ff5885d1f578ecb43c5c546c2deebf17c7:create

grant select on samqa.cnb_check_sent_details to rl_sam_ro;

