-- liquibase formatted sql
-- changeset SAMQA:1754373940279 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eob_provider.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eob_provider.sql:null:688a05a38ae649ca72f9c7df204f2678f37d729e:create

grant delete on samqa.eob_provider to rl_sam_rw;

grant insert on samqa.eob_provider to rl_sam_rw;

grant select on samqa.eob_provider to rl_sam1_ro;

grant select on samqa.eob_provider to rl_sam_rw;

grant select on samqa.eob_provider to rl_sam_ro;

grant update on samqa.eob_provider to rl_sam_rw;

