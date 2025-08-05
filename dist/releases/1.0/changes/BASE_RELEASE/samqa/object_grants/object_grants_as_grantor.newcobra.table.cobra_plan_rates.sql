-- liquibase formatted sql
-- changeset SAMQA:1754373926213 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.table.cobra_plan_rates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.table.cobra_plan_rates.sql:null:d732baab270bea6c4ffbec0ee6add5b93fa26d22:create

grant alter on newcobra.cobra_plan_rates to samqa;

grant delete on newcobra.cobra_plan_rates to samqa;

grant index on newcobra.cobra_plan_rates to samqa;

grant insert on newcobra.cobra_plan_rates to samqa;

grant select on newcobra.cobra_plan_rates to samqa;

grant update on newcobra.cobra_plan_rates to samqa;

grant references on newcobra.cobra_plan_rates to samqa;

grant read on newcobra.cobra_plan_rates to samqa;

grant on commit refresh on newcobra.cobra_plan_rates to samqa;

grant query rewrite on newcobra.cobra_plan_rates to samqa;

grant debug on newcobra.cobra_plan_rates to samqa;

grant flashback on newcobra.cobra_plan_rates to samqa;

