-- liquibase formatted sql
-- changeset SAMQA:1754373926406 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.view.plan_rate_detail_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.view.plan_rate_detail_v.sql:null:69e770544e9b39b02cee3441fac10649f450a81d:create

grant delete on newcobra.plan_rate_detail_v to samqa;

grant insert on newcobra.plan_rate_detail_v to samqa;

grant select on newcobra.plan_rate_detail_v to samqa;

grant update on newcobra.plan_rate_detail_v to samqa;

grant references on newcobra.plan_rate_detail_v to samqa;

grant read on newcobra.plan_rate_detail_v to samqa;

grant on commit refresh on newcobra.plan_rate_detail_v to samqa;

grant query rewrite on newcobra.plan_rate_detail_v to samqa;

grant debug on newcobra.plan_rate_detail_v to samqa;

grant flashback on newcobra.plan_rate_detail_v to samqa;

grant merge view on newcobra.plan_rate_detail_v to samqa;

