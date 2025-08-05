-- liquibase formatted sql
-- changeset SAMQA:1754374159297 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\hra_deductible_options.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/hra_deductible_options.sql:null:42a1420429b942907e262b0f3921f56e04d1cd67:create

create table samqa.hra_deductible_options (
    option_id             number,
    enrollment_detail_id  number,
    entrp_id              number,
    single_ee_contrib_amt number,
    ee_spouse_ee_amt      number,
    ee_spouse_amt         number,
    ee_children_amt       number,
    ee_childen_depend_amt number,
    family_ee_amt         number,
    family_spouse_amt     number,
    family_children_amt   number,
    coverage_tier         varchar2(1000 byte),
    created_by            number,
    creation_date         date,
    last_update_date      date,
    last_updated_by       number,
    batch_number          number
);

