-- liquibase formatted sql
-- changeset SAMQA:1754373943007 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.beneficiary_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.beneficiary_type.sql:null:15415d5dc6434ae491d008ad785aa89c7fe27dcf:create

grant select on samqa.beneficiary_type to rl_sam1_ro;

grant select on samqa.beneficiary_type to rl_sam_rw;

grant select on samqa.beneficiary_type to rl_sam_ro;

grant select on samqa.beneficiary_type to sgali;

