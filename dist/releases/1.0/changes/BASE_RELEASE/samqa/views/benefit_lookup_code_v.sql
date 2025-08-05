-- liquibase formatted sql
-- changeset SAMQA:1754374168726 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\benefit_lookup_code_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/benefit_lookup_code_v.sql:null:f173c42ebeb57268b8aa43376c6f99a4f3ac17ad:create

create or replace force editionable view samqa.benefit_lookup_code_v (
    lookup_code,
    description
) as
    (
        select
            lookup_code,
            decode(lookup_code, '5A', 'EMPLOYER_HEALTH', '5B', 'EMPLOYER_DENTAL',
                   '5C', 'EMPLOYER_VISION', '5D', 'EMPLOYER_GROUP_TERM_LIFE', '5E',
                   'HEALTH_SAVING_ACCOUNT', '5F', 'EMPLOYER_LONG_TERM_DISABILITY', '5H', 'COBRA',
                   '5I', 'EMPLOYER_SHORT_TERM_DISABILITY', '5J', 'ACCIDENTAL_DEATH_AND_DISMEMBERMENT', '5K',
                   'OTHERS', '6A', 'GROUP_MEDICAL_INSURANCE', '6B', 'GROUP_DENTAL_INSURANCE',
                   '6C', 'GROUP_VISION_INSURANCE', '6D', 'HSA_CONTRIBUTIONS', '6E',
                   'GROUP_TERM_LIFE', '6F', 'CANCER_INSURANCE', '6G', 'VOLUNTARY_BENEFITS',
                   '6H', 'PERSONAL_SICKNESS_INDEMINITY', '6I', 'LONG_TERM_DISABILITY_INSURANCE', '6J',
                   'SHORT_TERM_ISABILITY_INSURANCE', '6K', 'ACCIDENTAL_DEATH_AND_DISMEMBERMENT_INSURANCE', '6L', 'CRITICAL_ILLNESS_INSURANCE'
                   ,
                   '6M', 'HOSPITAL_INDEMNITY_INSURANCE', '6N', 'CASH_IN_LIEU_OF_BENEFITS', '6O',
                   'INTENSIVE_CARE_INSURANCE', '6P', 'SPECIFIED_HEALTH_EVENT') description
        from
            lookups
        where
            lookup_name in ( 'POP_ELIGIBILITY', 'POP_PLAN_BENEFITS' )
    );

