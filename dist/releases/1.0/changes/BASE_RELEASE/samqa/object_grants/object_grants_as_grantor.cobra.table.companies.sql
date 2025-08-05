-- liquibase formatted sql
-- changeset SAMQA:1754373925580 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobra.table.companies.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobra/object_grants/object_grants_as_grantor.cobra.table.companies.sql:null:32873d4b12c7418fb02c60a165ad043bbced267f:create

grant select on cobra.companies to samqa;

