-- liquibase formatted sql
-- changeset SAMQA:1754373935230 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.format_to_date.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.format_to_date.sql:null:ae7b8cd2ba6f97a15cdd116ba762184185d21a9e:create

grant execute on samqa.format_to_date to rl_sam_ro;

