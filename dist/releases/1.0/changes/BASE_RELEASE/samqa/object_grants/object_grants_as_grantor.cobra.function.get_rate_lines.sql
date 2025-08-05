-- liquibase formatted sql
-- changeset SAMQA:1754373925565 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobra.function.get_rate_lines.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobra/object_grants/object_grants_as_grantor.cobra.function.get_rate_lines.sql:null:4e6ed08948136c5276f337f98bdd940a0f5c8d30:create

grant execute on cobra.get_rate_lines to samqa;

grant debug on cobra.get_rate_lines to samqa;

