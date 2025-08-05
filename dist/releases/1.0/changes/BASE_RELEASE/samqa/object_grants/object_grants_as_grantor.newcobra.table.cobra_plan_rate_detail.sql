-- liquibase formatted sql
-- changeset SAMQA:1754373926175 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.table.cobra_plan_rate_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.table.cobra_plan_rate_detail.sql:null:d2c835559eaee87d69d8f629e062ebc90c5d2a77:create

grant alter on newcobra.cobra_plan_rate_detail to samqa;

grant delete on newcobra.cobra_plan_rate_detail to samqa;

grant index on newcobra.cobra_plan_rate_detail to samqa;

grant insert on newcobra.cobra_plan_rate_detail to samqa;

grant select on newcobra.cobra_plan_rate_detail to samqa;

grant update on newcobra.cobra_plan_rate_detail to samqa;

grant references on newcobra.cobra_plan_rate_detail to samqa;

grant read on newcobra.cobra_plan_rate_detail to samqa;

grant on commit refresh on newcobra.cobra_plan_rate_detail to samqa;

grant query rewrite on newcobra.cobra_plan_rate_detail to samqa;

grant debug on newcobra.cobra_plan_rate_detail to samqa;

grant flashback on newcobra.cobra_plan_rate_detail to samqa;

