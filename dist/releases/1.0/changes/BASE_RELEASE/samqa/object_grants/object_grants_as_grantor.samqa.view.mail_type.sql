-- liquibase formatted sql
-- changeset SAMQA:1754373944529 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.mail_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.mail_type.sql:null:3eafc0a85a96851e522dd97d9a57b96f6de741dd:create

grant select on samqa.mail_type to rl_sam1_ro;

grant select on samqa.mail_type to rl_sam_rw;

grant select on samqa.mail_type to rl_sam_ro;

grant select on samqa.mail_type to sgali;

