-- liquibase formatted sql
-- changeset SAMQA:1754374137525 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_enroll_utility_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_enroll_utility_pkg.sql:null:5883b7200916d7baa0c9c2fcfdd0120725300c46:create

create or replace package samqa.pc_enroll_utility_pkg is
    type person_row_t is record (
            first_name  varchar2(255),
            last_name   varchar2(255),
            middle_name varchar2(255),
            birth_date  varchar2(30),
            title       varchar2(255),
            gender      varchar2(10),
            address     varchar2(255),
            city        varchar2(255),
            state       varchar2(30),
            zip         varchar2(30),
            day_phone   varchar2(30),
            passport    varchar2(255),
            driv_lic    varchar2(255),
            email       varchar2(255),
            id_type     varchar2(30),
            id_number   varchar2(30)
    );
    type person_user_row_t is record (
            entrp_id        number,
            ein             varchar2(255),
            ssn             varchar2(255),
            birth_date      varchar2(255),
            stacked_account varchar2(1),
            er_acc_id       number,
            acc_id          number
    );
    type product_lookup_row is record (
            product_code        varchar2(30),
            product_description varchar2(255),
            entrp_id            number,
            action              varchar2(30),
            plan_code           number
    );
    type carrier_row_t is record (
            carrier_name     varchar2(2000),
            carrier_id       number,
            insure_plan_type varchar2(255),
            effective_date   varchar2(30)
    );
    type benefit_plan_row_t is record (
            plan_name              varchar2(2000),
            plan_type              varchar2(2000),
            effective_date         varchar2(30),
            minimum_election       number,
            maximum_election       number,
            plan_id                varchar2(255),
            plan_year              varchar2(255),
            plan_start_date        varchar2(255),
            plan_end_date          varchar2(255),
            coverage_tier          varchar2(255),
            runout_period_days     number,
            grace_period           number,
            status                 varchar2(30),
            status_code            varchar2(30),
            pay_cycle              varchar2(255),
            first_payroll_date     varchar2(30),
            pay_contrb             varchar2(255),
            annual_election        number,
            life_event_code        varchar2(255),
            product_type           varchar2(30),
            entrp_id               number,
            acc_id                 number,
            acc_num                varchar2(30),
            batch_number           number,
            open_enroll_start_date varchar2(255),
            open_enroll_end_date   varchar2(255),
            ben_plan_id_main       number,
            current_year           varchar2(1)
    );
    type pending_plans_row_t is record (
            name               varchar2(2000),
            plan_type          varchar2(2000),
            plan_type_meaning  varchar2(2000),
            effective_date     varchar2(30),
            annual_election    number,
            life_event_code    varchar2(255),
            pay_cycle          varchar2(255),
            first_payroll_date varchar2(30),
            pay_contrb         varchar2(255),
            plan_start_date    varchar2(30),
            plan_end_date      varchar2(255),
            ben_plan_id        number,
            acc_id             number,
            pers_id            number,
            cov_tier_name      varchar2(255),
            acc_num            varchar2(30)
    );
    type dependent_row_t is record (
            first_name     varchar2(2000),
            middle_name    varchar2(2000),
            last_name      varchar2(2000),
            relat_code     varchar2(30),
            relat_name     varchar2(30),
            ssn            varchar2(30),
            gender         varchar2(10),
            birth_date     varchar2(30),
            subscriber_ssn varchar2(30)
    );
    type enrollment_status_row_t is record (
            enrollment_id     varchar2(30),
            acc_num           varchar2(30),
            account_type      varchar2(300),
            acct_type         varchar2(300),
            plan_type         varchar2(300),
            plan_type_meaning varchar2(300),
            plan_start_date   varchar2(30),
            plan_end_date     varchar2(30),
            fraud_flag        varchar2(10),
            enrollment_status varchar2(30),
            error_message     varchar2(2000)
    );
    type lookup_row_t is record (
            lookup_code varchar2(255),
            description varchar2(2000)
    );
    type yes_no_row_t is record (
        debit_card_flag varchar2(30)
    );
    type coverage_tier_row_t is record (
            cov_tier_id        number,
            cov_tier_name      varchar2(255),
            annual_election    number,
            calculation_method varchar2(255),
            ben_plan_id        number
    );
    type user_info_row_t is record (
            user_name         varchar2(255),
            password_rem_ques varchar2(255),
            password_rem_ans  varchar2(255)
    );
    type hex_conn_row_t is record (
            first_name    varchar2(255),
            middle_name   varchar2(255),
            last_name     varchar2(255),
            email         varchar2(255),
            user_id       varchar2(255),
            account_list  varchar2(255),
            employer_name varchar2(255)
    );
    type welcome_email_row_t is record (
            enrollment_id number,
            first_name    varchar2(255),
            last_name     varchar2(255),
            email         varchar2(255),
            user_name     varchar2(255),
            registered    varchar2(1),
            acc_num       varchar2(255),
            confirmed     varchar2(1),
            account_type  varchar2(255),
            employer_id   varchar2(255)
    );
    type enrollment_rec is record (
            enrollment_id              number,
            first_name                 varchar2(255),
            last_name                  varchar2(255),
            middle_name                varchar2(255),
            title                      varchar2(10),
            gender                     varchar2(10),
            birth_date                 varchar2(30),
            ssn                        varchar2(10),
            id_type                    varchar2(10),
            id_number                  varchar2(30),
            address                    varchar2(100),
            city                       varchar2(100),
            state                      varchar2(10),
            zip                        varchar2(100),
            phone                      varchar2(100),
            email                      varchar2(100),
            carrier_id                 number,
            health_plan_eff_date       varchar2(100),
            entrp_id                   number,
            plan_type                  varchar2(100),
            deductible                 number,
            ip_address                 varchar2(100),
            account_type               varchar2(100),
            batch_number               number,
            user_name                  varchar2(100),
            password_reminder_question varchar2(100),
            password_reminder_answer   varchar2(100),
            plan_code                  varchar2(100),
            debit_card_flag            varchar2(10)
    );
    type enroll_plan_rec is record (
            enroll_stage_id    number,
            plan_type          varchar2(255),
            effective_date     varchar2(255),
            annual_election    number,
            pay_contrb         number,
            pay_cycle          varchar2(255),
            covg_tier_name     varchar2(255),
            deductible         number,
            qual_event_code    varchar2(255),
            first_payroll_date varchar2(255)
    );
    type beneficiary_rec is record (
            mass_enrollment_id   number,
            first_name           varchar2(255),
            middle_name          varchar2(30),
            last_name            varchar2(255),
            gender               varchar2(30),
            beneficiary_type     varchar2(30),
            beneficiary_relation varchar2(30),
            effective_date       varchar2(30),
            distiribution        number
    );
    type dependent_rec is record (
            mass_enrollment_id number,
            first_name         varchar2(255),
            middle_name        varchar2(30),
            last_name          varchar2(255),
            gender             varchar2(30),
            birth_date         varchar2(30),
            ssn                varchar2(30),
            dep_flag           varchar2(30),
            debit_card_flag    varchar2(10),
            account_type       varchar2(10)
    );
    type pay_freq_rec is record (
            name         varchar2(255),
            scheduler_id number,
            frequency    varchar2(255),
            start_date   varchar2(30),
            end_date     varchar2(30),
            entrp_id     number
    );

   --added by Joshi for webform enrollment
    type validate_ssn_rec is record (
            ssn_exists         varchar2(1),
            all_plans_enrolled varchar2(1),
            error_message      varchar2(2000),
            error_status       varchar2(1),
            active_plan_exist  varchar2(1),
            debitcard_exist    varchar2(1)
    );
    type person_t is
        table of person_row_t;
    type product_lookup_t is
        table of product_lookup_row;
    type carrier_t is
        table of carrier_row_t;
    type benefit_plan_t is
        table of benefit_plan_row_t;
    type dependents_t is
        table of dependent_row_t;
    type enrollment_status_t is
        table of enrollment_status_row_t;
    type lookup_t is
        table of lookup_row_t;
    type pending_plans_t is
        table of pending_plans_row_t;
    type yes_no_t is
        table of yes_no_row_t;
    type coverage_tier_t is
        table of coverage_tier_row_t;
    type hex_conn_t is
        table of hex_conn_row_t;
    type welcome_email_t is
        table of welcome_email_row_t;
    type enrollment_t is
        table of enrollment_rec;
    type enroll_plan_t is
        table of enroll_plan_rec;
    type beneficiary_t is
        table of beneficiary_rec;
    type dependent_t is
        table of dependent_rec;
    type person_user_t is
        table of person_user_row_t;
    type pay_freq_t is
        table of pay_freq_rec;
    type validate_ssn_rec_t is
        table of validate_ssn_rec;
    function get_person_info (
        p_ssn in varchar2
    ) return person_t
        pipelined
        deterministic;
 -- Added following for function for Webform.
    function get_person_info (
        p_ssn in varchar2,
        p_ein in varchar2
    ) return person_t
        pipelined
        deterministic;

    function does_account_exist (
        p_ssn          in varchar2,
        p_account_type in varchar2
    ) return varchar2;

    function does_person_exist (
        p_ssn          in varchar2,
        p_dob          in date,
        p_account_type in varchar2
    ) return varchar2;

    function validate_dob_ssn (
        p_ssn in varchar2,
        p_dob in varchar2
    ) return varchar2;

    function get_product_lookup (
        p_ein in varchar2,
        p_ssn in varchar2,
        p_dob in varchar2
    ) return product_lookup_t
        pipelined
        deterministic;

    function get_er_product_lookup (
        p_ein in varchar2
    ) return product_lookup_t
        pipelined
        deterministic;

    function get_carrier_info (
        p_tax_id    in varchar2,
        p_prod_type in varchar2
    ) return carrier_t
        pipelined
        deterministic;

    function get_ee_carrier_info (
        p_tax_id in varchar2
    ) return carrier_t
        pipelined
        deterministic;

    function get_enrolled_products (
        p_ein in varchar2,
        p_ssn in varchar2
    ) return product_lookup_t
        pipelined
        deterministic;

    function get_annual_election (
        p_ein in varchar2
    ) return benefit_plan_t
        pipelined
        deterministic;

    function get_dependents (
        p_ssn in varchar2
    ) return dependents_t
        pipelined
        deterministic;

    function get_ee_benefit_plan (
        p_ein in varchar2,
        p_ssn in varchar2
    ) return benefit_plan_t
        pipelined
        deterministic;

    function get_enrollment_status (
        p_batch_number in varchar2
    ) return enrollment_status_t
        pipelined
        deterministic;

    function does_dependent_exist (
        p_ssn          in varchar2,
        p_account_type in varchar2
    ) return varchar2;

    function get_enrolled_benefit_plan (
        p_acc_id       in number,
        p_product_type in varchar2
    ) return benefit_plan_t
        pipelined
        deterministic;

    function get_qual_events (
        p_acc_id in number,
        p_source in varchar2 default 'EVENT_CHANGE'
    ) return lookup_t
        pipelined
        deterministic;

    function get_pending_employees (
        p_entrp_id  in varchar2,
        p_plan_type in varchar2
    ) return pending_plans_t
        pipelined
        deterministic;

    function debit_card_allowed (
        p_ein in varchar2,
        p_ssn in varchar2
    ) return yes_no_t
        pipelined
        deterministic;

    function get_coverage_tier (
        p_ein in varchar2
    ) return coverage_tier_t
        pipelined
        deterministic;

    function get_coverage_tier (
        p_ein         in varchar2,
        p_ben_plan_id in number
    ) return coverage_tier_t
        pipelined
        deterministic;
-- FUNCTION get_pay_frequency(p_acc_num IN VARCHAR2) RETURN  lookup_t PIPELINED DETERMINISTIC;
    function get_pay_frequency (
        p_acc_num in varchar2
    ) return pay_freq_t
        pipelined
        deterministic;

    function get_not_enrolled_deps (
        p_ssn          in varchar2,
        p_batch_number in number
    ) return dependents_t
        pipelined
        deterministic;

    function get_hex_conn_details (
        p_ssn          in varchar2,
        p_batch_number in varchar2
    ) return hex_conn_t
        pipelined
        deterministic;

    function get_welcome_email (
        p_batch_number in number
    ) return welcome_email_t
        pipelined
        deterministic;

    function get_not_enrolled_plans (
        p_batch_number in number
    ) return pending_plans_t
        pipelined
        deterministic;

    function is_stacked_account (
        p_ein in varchar2,
        p_ssn in varchar2
    ) return varchar2;

    function get_benefit_plan (
        p_ben_plan_id in number
    ) return benefit_plan_t
        pipelined
        deterministic;

    function get_hra_ppc (
        p_cov_tier_name in varchar2,
        p_hire_date     in varchar2,
        p_ben_plan_id   in number
    ) return number;

    function get_approved_plans (
        p_entrp_id     in number,
        p_batch_number in number
    ) return benefit_plan_t
        pipelined
        deterministic;

    function get_pending_plans (
        p_entrp_id in number
    ) return benefit_plan_t
        pipelined
        deterministic;

    function can_hra_submit_claim (
        p_acc_id in number
    ) return varchar2;

    function get_enroll_detail_from_user (
        p_user_id in number
    ) return person_user_t
        pipelined
        deterministic;

    function get_ee_plan_open_enroll (
        p_ein in varchar2,
        p_ssn in varchar2
    ) return benefit_plan_t
        pipelined
        deterministic;

    function show_enroll_plan (
        p_user_id in number
    ) return varchar2;

    function get_enrollment (
        p_ssn          in varchar2,
        p_batch_number in number
    ) return enrollment_t
        pipelined
        deterministic;

    function get_enroll_plan (
        p_ssn          in varchar2,
        p_batch_number in number
    ) return enroll_plan_t
        pipelined
        deterministic;

    function get_beneficiary (
        p_ssn          in varchar2,
        p_batch_number in number
    ) return beneficiary_t
        pipelined
        deterministic;

    function get_dependent (
        p_ssn          in varchar2,
        p_batch_number in number
    ) return dependent_t
        pipelined
        deterministic;

    function get_er_benefit_plan (
        p_entrp_id     in number,
        p_product_type in varchar2
    ) return benefit_plan_t
        pipelined
        deterministic;

    function get_acc_id_from_ssn (
        p_ssn          in varchar2,
        p_product_type in varchar2
    ) return number;

    function get_er_pay_frequency (
        p_ein in varchar2
    ) return pay_freq_t
        pipelined
        deterministic;
 -- Added below function by Joshi for Webform Enrollment
    function get_acc_id_from_ssn (
        p_ssn          in varchar2,
        p_ein          in varchar2,
        p_product_type in varchar2
    ) return number;

    function validate_ssn_plan (
        p_ein in varchar2,
        p_ssn in varchar2
    ) return validate_ssn_rec_t
        pipelined
        deterministic;

 -- GA----jaggi 30/07/2020 9141
    type employer_ein_row_t is record (
            ein           number,
            error_message varchar2(1000),
            error_flag    varchar2(2)
    );
    type employer_ein_record_t is
        table of employer_ein_row_t;
    function validate_ein (
        p_ein in varchar2
    ) return employer_ein_record_t
        pipelined
        deterministic;  ----jaggi 30/07/2020 9141

end pc_enroll_utility_pkg;
/

