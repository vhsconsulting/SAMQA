create or replace package samqa.pc_cobra_utility_pkg as
    type cobra_sso_row_t is record (
            client_id      varchar2(30),
            sso_identifier varchar2(255)
    );
    type cobra_sso_t is
        table of cobra_sso_row_t;
    function is_cobra_sso_allowed (
        p_tax_id in varchar2
    ) return varchar2;

    function get_client_sso_info (
        p_ein in varchar2
    ) return cobra_sso_t
        pipelined
        deterministic;

    function get_qb_sso_info (
        p_ssn in varchar2
    ) return cobra_sso_t
        pipelined
        deterministic;



   ------rprabu 02/07/2021
    ------rprabu 02/07/2021
    type plan_record_t is record (
            entrp_id                   number,
            plan_id                    number,
            member_type                varchar2(100),
            rate_type                  varchar2(100),
            plan_name                  varchar2(300),
            plan_type                  varchar2(300),
            plan_start_date            varchar2(300),
            carrier_name               varchar2(300),
            carrier_phone_no           varchar2(100),
            carrier_contact_name       varchar2(100),
            carrier_enrollment_contact varchar2(100),
            ben_term_type              varchar2(100),
            waiting_period             varchar2(100),
            insured_type               varchar2(100),
            division_name              varchar2(300)
    );
    type plan_t is
        table of plan_record_t;

  ------ rprabu 17/05/2021
    function get_plans (
        p_entrp_id        in number,
        p_division_id     in number,
        p_plan_bundle_id  in number,
        p_division_option varchar2
    ) return plan_t
        pipelined
        deterministic;



   ---- 14/10/2021  CP project  start rprabu
    function get_plans_ui (
        p_entrp_id        in number,
        p_division_id     in number,
        p_plan_bundle_id  in number,
        p_division_option varchar2
    ) return sys_refcursor;

   ------rprabu 14/05/2021
    ------ rprabu 17/05/2021
    type employee_record_t is record (
            rn             number,
            entrp_id       number,
            first_name     varchar2(255),
            last_name      varchar2(255),
            ssn            varchar2(255),
            division_code  varchar2(255),
            division_name  varchar2(255),
            hire_date      varchar2(30),
            pers_id        number,
            er_acc_id      number,
            er_acc_num     varchar2(255),
            ee_acc_num     varchar2(255),
            employer_name  varchar2(255),
            person_type    varchar2(255),
            account_status varchar2(255),
            birth_date     varchar2(255),
            event_date     varchar2(255)
    );
    type employee_t is
        table of employee_record_t;

  ------ rprabu 17/05/2021
    function get_cobra_employees (
        p_er_accnum    in varchar2,
        p_search_by    in varchar2,
        p_search_value in varchar2,
        p_member_type  in varchar2,
        p_sort_by      in varchar2,
        p_sort_order   in varchar2
    ) return employee_t
        pipelined
        deterministic;

  ------ rprabu 17/05/2021
    type npm_record_t is record (
            entrp_id                  number,
            employer_name             varchar2(255),
            division_code             varchar2(255),
            division_name             varchar2(255),
            ssn                       varchar2(255),
            masked_ssn                varchar2(255),
            first_name                varchar2(255),
            last_name                 varchar2(255),
            address                   varchar2(255),
            phone_day                 varchar2(255),
            email                     varchar2(255),
            hire_date                 varchar2(30),
            use_family                varchar2(100),
            send_general_right_letter varchar2(100),
            waive_covr                varchar2(100),
            valid_qb                  varchar2(1),
            pers_id                   number,
            er_acc_id                 number,
            er_acc_num                varchar2(255),
            person_type               varchar2(255)
    );
    type employee_npm_t is
        table of npm_record_t;

  ------ rprabu 17/05/2021
    function get_npm_employee (
        p_ssn in varchar2
    ) return employee_npm_t
        pipelined
        deterministic;

    function get_qb_npm (
        p_entrp_id in number
    ) return employee_t
        pipelined
        deterministic;
   ------ rprabu 18/05/2021
    procedure update_division (
        p_entrp_id      number,
        p_pers_id       number,
        p_division_code varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

end pc_cobra_utility_pkg;
/


-- sqlcl_snapshot {"hash":"b804a78f7813a982c7a6aae73aff42539e8aea81","type":"PACKAGE_SPEC","name":"PC_COBRA_UTILITY_PKG","schemaName":"SAMQA","sxml":""}