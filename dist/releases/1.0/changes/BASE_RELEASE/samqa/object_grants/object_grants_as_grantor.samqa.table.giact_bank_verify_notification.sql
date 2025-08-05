-- liquibase formatted sql
-- changeset SAMQA:1754373940618 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.giact_bank_verify_notification.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.giact_bank_verify_notification.sql:null:d5c90e41cacd267c5ed37d276dd6ab234e2d3924:create

grant alter on samqa.giact_bank_verify_notification to public;

grant delete on samqa.giact_bank_verify_notification to public;

grant index on samqa.giact_bank_verify_notification to public;

grant insert on samqa.giact_bank_verify_notification to public;

grant select on samqa.giact_bank_verify_notification to public;

grant select on samqa.giact_bank_verify_notification to rl_sam_ro;

grant update on samqa.giact_bank_verify_notification to public;

grant references on samqa.giact_bank_verify_notification to public;

grant read on samqa.giact_bank_verify_notification to public;

grant on commit refresh on samqa.giact_bank_verify_notification to public;

grant query rewrite on samqa.giact_bank_verify_notification to public;

grant debug on samqa.giact_bank_verify_notification to public;

grant flashback on samqa.giact_bank_verify_notification to public;

