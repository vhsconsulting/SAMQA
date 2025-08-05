-- liquibase formatted sql
-- changeset SAMQA:1754373935465 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.google_geocode.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.google_geocode.sql:null:bd0c1870c9343bce91f43afdb5ba9d8a099dc2fe:create

grant execute on samqa.google_geocode to rl_sam_ro;

