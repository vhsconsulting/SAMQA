-- liquibase formatted sql
-- changeset SAMQA:1754373926390 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.view.plan_creation_view.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.view.plan_creation_view.sql:null:670fc0e2807f29222aa94c217122df4eecea777d:create

grant delete on newcobra.plan_creation_view to samqa;

grant insert on newcobra.plan_creation_view to samqa;

grant select on newcobra.plan_creation_view to samqa;

grant update on newcobra.plan_creation_view to samqa;

grant references on newcobra.plan_creation_view to samqa;

grant read on newcobra.plan_creation_view to samqa;

grant on commit refresh on newcobra.plan_creation_view to samqa;

grant query rewrite on newcobra.plan_creation_view to samqa;

grant debug on newcobra.plan_creation_view to samqa;

grant flashback on newcobra.plan_creation_view to samqa;

grant merge view on newcobra.plan_creation_view to samqa;

