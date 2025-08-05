-- liquibase formatted sql
-- changeset SAMQA:1754373926154 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.table.cobra_payments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.table.cobra_payments.sql:null:debde3c4e858c0db72980b59393eae9dcd14dc9c:create

grant alter on newcobra.cobra_payments to samqa;

grant delete on newcobra.cobra_payments to samqa;

grant index on newcobra.cobra_payments to samqa;

grant insert on newcobra.cobra_payments to samqa;

grant select on newcobra.cobra_payments to samqa;

grant update on newcobra.cobra_payments to samqa;

grant references on newcobra.cobra_payments to samqa;

grant read on newcobra.cobra_payments to samqa;

grant on commit refresh on newcobra.cobra_payments to samqa;

grant query rewrite on newcobra.cobra_payments to samqa;

grant debug on newcobra.cobra_payments to samqa;

grant flashback on newcobra.cobra_payments to samqa;

