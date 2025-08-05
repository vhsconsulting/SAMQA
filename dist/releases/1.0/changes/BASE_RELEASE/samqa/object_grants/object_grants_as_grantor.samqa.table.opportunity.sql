-- liquibase formatted sql
-- changeset SAMQA:1754373941496 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.opportunity.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.opportunity.sql:null:0980dd593a482496d8bc213b4f279d29c22fdda3:create

grant select on samqa.opportunity to rl_sam_ro;

