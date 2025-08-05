-- liquibase formatted sql
-- changeset SAMQA:1754373938214 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.sales_team_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.sales_team_seq.sql:null:f379e3ac449cd43ede6e00baab77be2764d583c3:create

grant select on samqa.sales_team_seq to rl_sam_rw;

