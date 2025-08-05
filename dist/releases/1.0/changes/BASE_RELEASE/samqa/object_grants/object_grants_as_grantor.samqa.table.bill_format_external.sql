-- liquibase formatted sql
-- changeset SAMQA:1754373938995 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.bill_format_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.bill_format_external.sql:null:13807a773cb3e4d1b240efe658a8431fea106135:create

grant select on samqa.bill_format_external to rl_sam1_ro;

grant select on samqa.bill_format_external to rl_sam_ro;

