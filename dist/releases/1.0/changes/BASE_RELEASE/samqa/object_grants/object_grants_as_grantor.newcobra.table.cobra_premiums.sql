-- liquibase formatted sql
-- changeset SAMQA:1754373926249 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.table.cobra_premiums.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.table.cobra_premiums.sql:null:cf4a53ca4826d0cf8b273a7c2e3f7028f7bcaf85:create

grant alter on newcobra.cobra_premiums to samqa;

grant delete on newcobra.cobra_premiums to samqa;

grant index on newcobra.cobra_premiums to samqa;

grant insert on newcobra.cobra_premiums to samqa;

grant select on newcobra.cobra_premiums to samqa;

grant update on newcobra.cobra_premiums to samqa;

grant references on newcobra.cobra_premiums to samqa;

grant read on newcobra.cobra_premiums to samqa;

grant on commit refresh on newcobra.cobra_premiums to samqa;

grant query rewrite on newcobra.cobra_premiums to samqa;

grant debug on newcobra.cobra_premiums to samqa;

grant flashback on newcobra.cobra_premiums to samqa;

