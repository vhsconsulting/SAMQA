-- liquibase formatted sql
-- changeset SAMQA:1754373936601 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.process_bill_format.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.process_bill_format.sql:null:7e04d733e8bbf71c056710e6bb5ceb318fe5a598:create

grant execute on samqa.process_bill_format to rl_sam_ro;

grant execute on samqa.process_bill_format to rl_sam_rw;

grant execute on samqa.process_bill_format to rl_sam1_ro;

grant debug on samqa.process_bill_format to sgali;

grant debug on samqa.process_bill_format to rl_sam_rw;

grant debug on samqa.process_bill_format to rl_sam1_ro;

grant debug on samqa.process_bill_format to rl_sam_ro;

