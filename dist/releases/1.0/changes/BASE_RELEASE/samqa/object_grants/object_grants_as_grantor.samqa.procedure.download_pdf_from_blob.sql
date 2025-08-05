-- liquibase formatted sql
-- changeset SAMQA:1754373936854 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.download_pdf_from_blob.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.download_pdf_from_blob.sql:null:4e29aa50198a4c95029601f9cd791b1184671113:create

grant execute on samqa.download_pdf_from_blob to rl_sam_ro;

