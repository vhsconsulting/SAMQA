-- liquibase formatted sql
-- changeset SAMQA:1754373926233 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.table.cobra_plans.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.table.cobra_plans.sql:null:84e8b1e05ab718b0ad4a476a693699f5b60d3af0:create

grant alter on newcobra.cobra_plans to samqa;

grant delete on newcobra.cobra_plans to samqa;

grant index on newcobra.cobra_plans to samqa;

grant insert on newcobra.cobra_plans to samqa;

grant select on newcobra.cobra_plans to samqa;

grant update on newcobra.cobra_plans to samqa;

grant references on newcobra.cobra_plans to samqa;

grant read on newcobra.cobra_plans to samqa;

grant on commit refresh on newcobra.cobra_plans to samqa;

grant query rewrite on newcobra.cobra_plans to samqa;

grant debug on newcobra.cobra_plans to samqa;

grant flashback on newcobra.cobra_plans to samqa;

