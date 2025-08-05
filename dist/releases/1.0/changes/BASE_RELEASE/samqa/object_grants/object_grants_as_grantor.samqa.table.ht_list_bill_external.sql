-- liquibase formatted sql
-- changeset SAMQA:1754373940753 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ht_list_bill_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ht_list_bill_external.sql:null:19311dddcb4e6be9866289b542c4c2570df8bcfb:create

grant select on samqa.ht_list_bill_external to rl_sam1_ro;

grant select on samqa.ht_list_bill_external to rl_sam_ro;

