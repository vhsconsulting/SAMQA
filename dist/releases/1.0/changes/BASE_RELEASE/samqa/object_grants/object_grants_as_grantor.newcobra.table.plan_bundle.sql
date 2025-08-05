-- liquibase formatted sql
-- changeset SAMQA:1754373926297 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.table.plan_bundle.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.table.plan_bundle.sql:null:f62ebe2f99c6676bb94873471d2275dd76978af2:create

grant alter on newcobra.plan_bundle to samqa;

grant delete on newcobra.plan_bundle to samqa;

grant index on newcobra.plan_bundle to samqa;

grant insert on newcobra.plan_bundle to samqa;

grant select on newcobra.plan_bundle to samqa;

grant update on newcobra.plan_bundle to samqa;

grant references on newcobra.plan_bundle to samqa;

grant read on newcobra.plan_bundle to samqa;

grant on commit refresh on newcobra.plan_bundle to samqa;

grant query rewrite on newcobra.plan_bundle to samqa;

grant debug on newcobra.plan_bundle to samqa;

grant flashback on newcobra.plan_bundle to samqa;

