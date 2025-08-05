-- liquibase formatted sql
-- changeset SAMQA:1754373940976 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.list_format_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.list_format_external.sql:null:1b23d60bc0cb064ab30d9ef5f79f147ad0451511:create

grant select on samqa.list_format_external to rl_sam1_ro;

grant select on samqa.list_format_external to rl_sam_ro;

