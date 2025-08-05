-- liquibase formatted sql
-- changeset SAMQA:1754373926095 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.sequence.cobra_notification_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.sequence.cobra_notification_seq.sql:null:6c0f6dff245566f800e3dc1bb7119f8634636be0:create

grant alter on newcobra.cobra_notification_seq to samqa;

grant select on newcobra.cobra_notification_seq to samqa;

