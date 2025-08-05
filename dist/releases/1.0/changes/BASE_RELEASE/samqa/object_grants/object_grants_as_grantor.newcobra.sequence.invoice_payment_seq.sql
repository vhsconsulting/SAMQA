-- liquibase formatted sql
-- changeset SAMQA:1754373926117 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.sequence.invoice_payment_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.sequence.invoice_payment_seq.sql:null:37b173918ea86804be93c0564206edfee1f0cf52:create

grant alter on newcobra.invoice_payment_seq to samqa;

grant select on newcobra.invoice_payment_seq to samqa;

