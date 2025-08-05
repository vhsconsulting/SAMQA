-- liquibase formatted sql
-- changeset SAMQA:1754373943373 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.cobra_disbursement_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.cobra_disbursement_v.sql:null:7eaaf61e111b9305ac98ccc52ef2461c7f9268ad:create

grant select on samqa.cobra_disbursement_v to rl_sam1_ro;

grant select on samqa.cobra_disbursement_v to rl_sam_rw;

grant select on samqa.cobra_disbursement_v to rl_sam_ro;

