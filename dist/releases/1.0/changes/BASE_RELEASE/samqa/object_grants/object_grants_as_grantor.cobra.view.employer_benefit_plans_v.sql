-- liquibase formatted sql
-- changeset SAMQA:1754373925585 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobra.view.employer_benefit_plans_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobra/object_grants/object_grants_as_grantor.cobra.view.employer_benefit_plans_v.sql:null:5f8db9efbc1732eaa362e93d86b3b85fb5801466:create

grant select on cobra.employer_benefit_plans_v to samqa;

