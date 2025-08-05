-- liquibase formatted sql
-- changeset SAMQA:1754373942959 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.bank_transfer_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.bank_transfer_v.sql:null:12eb2a89d94646c0c63bfc09738ec53c7b16d69b:create

grant select on samqa.bank_transfer_v to rl_sam1_ro;

grant select on samqa.bank_transfer_v to rl_sam_rw;

grant select on samqa.bank_transfer_v to rl_sam_ro;

grant select on samqa.bank_transfer_v to sgali;

