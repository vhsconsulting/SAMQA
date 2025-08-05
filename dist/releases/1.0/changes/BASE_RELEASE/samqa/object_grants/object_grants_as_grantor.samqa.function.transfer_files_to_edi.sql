-- liquibase formatted sql
-- changeset SAMQA:1754373935605 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.transfer_files_to_edi.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.transfer_files_to_edi.sql:null:5b83dfb17ff2c43bfe9e4a2983b23b79c7579fe0:create

grant execute on samqa.transfer_files_to_edi to rl_sam1_ro;

grant execute on samqa.transfer_files_to_edi to rl_sam_rw;

grant execute on samqa.transfer_files_to_edi to rl_sam_ro;

grant debug on samqa.transfer_files_to_edi to rl_sam1_ro;

grant debug on samqa.transfer_files_to_edi to rl_sam_rw;

