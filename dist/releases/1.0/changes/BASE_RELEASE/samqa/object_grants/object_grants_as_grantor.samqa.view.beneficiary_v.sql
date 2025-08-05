-- liquibase formatted sql
-- changeset SAMQA:1754373943011 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.beneficiary_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.beneficiary_v.sql:null:460d5b7ae6940dea0acd70fddda6a385ae2163df:create

grant select on samqa.beneficiary_v to rl_sam1_ro;

grant select on samqa.beneficiary_v to rl_sam_rw;

grant select on samqa.beneficiary_v to rl_sam_ro;

grant select on samqa.beneficiary_v to sgali;

