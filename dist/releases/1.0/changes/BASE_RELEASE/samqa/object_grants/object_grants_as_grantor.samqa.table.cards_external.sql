-- liquibase formatted sql
-- changeset SAMQA:1754373939188 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cards_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cards_external.sql:null:bf246a67cb418e2906845eac1a0c261e412df48a:create

grant select on samqa.cards_external to rl_sam1_ro;

grant select on samqa.cards_external to rl_sam_ro;

