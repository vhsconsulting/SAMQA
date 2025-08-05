-- liquibase formatted sql
-- changeset SAMQA:1754373936771 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.create_prefunded_receipt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.create_prefunded_receipt.sql:null:7f20dfecbefa89c7fcac952acb274bb253f75a70:create

grant execute on samqa.create_prefunded_receipt to rl_sam_ro;

