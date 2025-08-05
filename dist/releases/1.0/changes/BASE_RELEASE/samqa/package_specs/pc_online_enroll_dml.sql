-- liquibase formatted sql
-- changeset SAMQA:1754374139579 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_online_enroll_dml.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_online_enroll_dml.sql:null:4e8630a8ca8670df19e97a2cb8050255f07634bc:create

create or replace package samqa.pc_online_enroll_dml is
    type varchar2_tbl is
        table of varchar2(3200) index by binary_integer;
    function array_fill (
        p_array       varchar2_tbl,
        p_array_count number
    ) return varchar2_tbl;

    type notify_row_t is record (
            email       varchar2(255),
            email_body  varchar2(3200),
            subject     varchar2(255),
            pers_id     number,
            acc_id      number,
            person_name varchar2(255),
            user_name   varchar2(255),
            plan_types  varchar2(255),
            status      varchar2(255),
            acc_num     varchar2(255),
            contrib_amt number
    );/*Ticket#6588 */

    type notify_t is
        table of notify_row_t;
    procedure validate_demographics (
        p_enroll_source        in varchar2 -- Added by Joshi for webform Enrollment
        ,
        p_first_name           in varchar2,
        p_last_name            in varchar2,
        p_middle_name          in varchar2,
        p_title                in varchar2,
        p_gender               in varchar2,
        p_birth_date           in varchar2,
        p_ssn                  in varchar2,
        p_id_type              in varchar2,
        p_id_number            in varchar2,
        p_address              in varchar2,
        p_city                 in varchar2,
        p_state                in varchar2,
        p_zip                  in varchar2,
        p_phone                in varchar2,
        p_email                in varchar2,
        p_health_plan_eff_date in varchar2,
        p_plan_type            in varchar2,
        p_account_type         in varchar2_tbl,
        x_error_message        out varchar2
    );

    procedure validate_beneficiary (
        p_beneficiary_name     in varchar2_tbl,
        p_beneficiary_type     in varchar2_tbl,
        p_beneficiary_relation in varchar2_tbl,
        p_ben_distiribution    in varchar2_tbl,
        x_error_message        out varchar2
    );

    procedure validate_dependent (
        p_ssn                 in varchar2,
        p_dep_first_name      in varchar2_tbl,
        p_dep_middle_name     in varchar2_tbl,
        p_dep_last_name       in varchar2_tbl,
        p_dep_gender          in varchar2_tbl,
        p_dep_birth_date      in varchar2_tbl,
        p_dep_ssn             in varchar2_tbl,
        p_dep_relative        in varchar2_tbl,
        p_dep_debit_card_flag in varchar2_tbl,
        x_error_message       out varchar2
    );

    procedure pc_insert_demographics (
        p_enroll_source        in varchar2,
        p_first_name           in varchar2,
        p_last_name            in varchar2,
        p_middle_name          in varchar2,
        p_title                in varchar2,
        p_gender               in varchar2,
        p_birth_date           in varchar2,
        p_ssn                  in varchar2,
        p_id_type              in varchar2,
        p_id_number            in varchar2,
        p_address              in varchar2,
        p_city                 in varchar2,
        p_state                in varchar2,
        p_zip                  in varchar2,
        p_phone                in varchar2,
        p_email                in varchar2,
        p_carrier_id           in number,
        p_health_plan_eff_date in varchar2,
        p_entrp_id             in varchar2,
        p_account_type         in varchar2_tbl,
        p_user_id              in number,
        p_plan_type            in varchar2,
        p_deductible           in varchar2,
        p_lang_pref            in varchar2,
        p_ip_address           in varchar2,
        p_batch_number         in number,
        x_error_message        out varchar2,
        x_return_status        out varchar2
    );

    procedure insert_user (
        p_batch_number      in number,
        p_ssn               in varchar2,
        p_user_name         in varchar2,
        p_user_password     in varchar2,
        p_password_question in varchar2,
        p_password_answer   in varchar2,
        x_error_message     out varchar2,
        x_return_status     out varchar2
    );

    procedure pc_insert_plan (
        p_batch_number  in number,
        p_plan_code     in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure pc_insert_beneficiary (
        p_batch_number         in number,
        p_beneficiary_name     in varchar2_tbl,
        p_beneficiary_type     in varchar2_tbl,
        p_beneficiary_relation in varchar2_tbl,
        p_ben_distiribution    in varchar2_tbl,
        p_ssn                  in varchar2,
        p_user_id              in number,
        x_error_message        out varchar2,
        x_return_status        out varchar2
    );

    procedure pc_insert_dependent (
        p_batch_number    in number,
        p_ssn             in varchar2,
        p_dep_first_name  in varchar2_tbl,
        p_dep_middle_name in varchar2_tbl,
        p_dep_last_name   in varchar2_tbl,
        p_dep_gender      in varchar2_tbl,
        p_dep_birth_date  in varchar2_tbl,
        p_dep_ssn         in varchar2_tbl,
        p_dep_relative    in varchar2_tbl,
        p_account_type    in varchar2_tbl,
        p_user_id         in number,
        x_error_message   out varchar2,
        x_return_status   out varchar2
    );

    procedure pc_insert_hrafsa_plan (
        p_batch_number    in number,
        p_ssn             in varchar2,
        p_ben_plan_id     in varchar2_tbl,
        p_plan_type       in varchar2_tbl,
        p_effective_date  in varchar2_tbl,
        p_annual_election in varchar2_tbl,
        p_pay_contrib     in varchar2_tbl,
        p_pay_cycle       in varchar2_tbl,
        p_pay_date        in varchar2_tbl,
        p_cov_tier_name   in varchar2_tbl,
        p_deductible      in varchar2_tbl,
        p_event_code      in varchar2_tbl,
        x_error_message   out varchar2,
        x_return_status   out varchar2
    );

    procedure process_enrollment (
        p_batch_number           in number,
        p_enroll_source          in varchar2,
        p_entrp_id               in varchar2,
        p_account_type           in varchar2_tbl,
        p_id_verification_status in varchar2,
        p_transaction_id         in number,
        p_verification_date      in varchar2,
        p_user_id                in number,
        x_error_message          out varchar2,
        x_return_status          out varchar2
    );

    procedure insert_file_history (
        p_batch_number   in varchar2,
        p_entrp_id       in varchar2,
        p_file_name      in varchar2,
        p_lang_perf      in varchar2,
        p_user_id        in number,
        x_file_upload_id out number
    );

    procedure update_file_results (
        p_batch_number   in varchar2,
        p_entrp_id       in varchar2,
        p_file_name      in varchar2,
        p_lang_perf      in varchar2,
        p_user_id        in number,
        p_file_upload_id in number
    );

    procedure validate_hsa_enrollment (
        p_batch_number           in number,
        p_id_verification_status in number,
        x_error_message          out varchar2
    );

    procedure process_hsa_enrollment (
        p_batch_number           in varchar2,
        p_entrp_id               in varchar2,
        p_file_name              in varchar2,
        p_lang_perf              in varchar2,
        p_id_verification_status in varchar2,
        p_transaction_id         in number,
        p_verification_date      in varchar2,
        p_user_id                in number,
        x_error_message          out varchar2,
        x_return_status          out varchar2
    );

    procedure pc_hsa_batch_enrollment (
        p_batch_number           in varchar2,
        p_entrp_id               in varchar2,
        p_file_name              in varchar2,
        p_lang_perf              in varchar2,
        p_id_verification_status in varchar2,
        p_transaction_id         in number,
        p_verification_date      in varchar2,
        p_user_id                in number,
        x_error_message          out varchar2,
        x_return_status          out varchar2
    );

    procedure pc_insert_coverage (
        p_batch_number  in number,
        p_ssn           in varchar2,
        p_ben_plan_id   in varchar2_tbl,
        p_coverage_type in varchar2_tbl
    );

    procedure process_dependent (
        p_batch_number  in number,
        p_account_type  in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure approve_hrafsa_plan (
        p_name            in varchar2_tbl,
        p_ben_plan_id     in varchar2_tbl,
        p_effective_date  in varchar2_tbl,
        p_annual_election in varchar2_tbl,
        p_pay_contrib     in varchar2_tbl,
        p_pay_cycle       in varchar2_tbl,
        p_payroll_date    in varchar2_tbl,
        p_event_code      in varchar2_tbl,
        p_status          in varchar2_tbl,
        p_user_id         in number,
        p_batch_number    in number,
        p_entrp_id        in number,
        x_approval_status out varchar2_tbl
    );

    procedure update_debit_card (
        p_batch_number in number,
        p_ssn          in varchar2,
        p_dep_ssn      in varchar2_tbl,
        p_account_type in varchar2_tbl,
        p_debit_card   in varchar2_tbl,
        p_person_type  in varchar2_tbl
    );

    procedure delete_plan (
        p_ssn          in varchar2,
        p_batch_number in number,
        p_plan_type    in varchar2_tbl
    );

    procedure delete_receipts (
        p_ben_plan_id in number
    );

    procedure pc_add_hrafsa_plan (
        p_batch_number    in number,
        p_acc_id          in varchar2,
        p_ben_plan_id     in varchar2_tbl,
        p_plan_type       in varchar2_tbl,
        p_effective_date  in varchar2_tbl,
        p_annual_election in varchar2_tbl,
        p_pay_contrib     in varchar2_tbl,
        p_pay_cycle       in varchar2_tbl,
        p_pay_date        in varchar2_tbl,
        p_cov_tier_name   in varchar2_tbl,
        p_deductible      in varchar2_tbl,
        p_event_code      in varchar2_tbl,
        p_user_id         in number,
        x_error_message   out varchar2,
        x_return_status   out varchar2
    );

    procedure pc_delete_hrafsa_plan (
        p_ben_plan_id   in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure pc_update_hrafsa_plan (
        p_ben_plan_id     in number,
        p_effective_date  in varchar2,
        p_annual_election in number,
        p_pay_contrib     in number,
        p_pay_cycle       in varchar2,
        p_pay_date        in varchar2,
        p_cov_tier_name   in varchar2,
        p_deductible      in varchar2,
        p_event_code      in varchar2,
        p_user_id         in number,
        x_error_message   out varchar2,
        x_return_status   out varchar2
    );

    function get_notification (
        p_batch_number in number,
        p_event_name   in varchar2,
        p_acc_id       in number,
        p_user_id      in number
    ) return notify_t
        pipelined
        deterministic;

    procedure process_webform_enroll (
        p_enroll_source          in varchar2,
        p_ssn                    in varchar2,
        p_first_name             in varchar2,
        p_last_name              in varchar2,
        p_middle_name            in varchar2,
        p_title                  in varchar2,
        p_gender                 in varchar2,
        p_birth_date             in varchar2,
        p_id_type                in varchar2,
        p_id_number              in varchar2,
        p_address                in varchar2,
        p_city                   in varchar2,
        p_state                  in varchar2,
        p_zip                    in varchar2,
        p_phone                  in varchar2,
        p_email                  in varchar2,
        p_carrier_id             in number,
        p_health_plan_eff_date   in varchar2,
        p_entrp_id               in varchar2,
        p_account_type           in varchar2_tbl,
        p_transaction_id         in number,
        p_verification_date      in varchar2,
        p_id_verification_status in varchar,
        p_user_id                in number,
        p_plan_type_var          in varchar2,
        p_deductible_var         in varchar2,
        p_lang_pref              in varchar2,
        p_ip_address             in varchar2,
        p_ben_plan_id            in varchar2_tbl,
        p_plan_type              in varchar2_tbl,
        p_coverage_type          in varchar2_tbl,
        p_effective_date         in varchar2_tbl,
        p_annual_election        in varchar2_tbl,
        p_pay_contrib            in varchar2_tbl,
        p_pay_cycle              in varchar2_tbl,
        p_pay_date               in varchar2_tbl,
        p_cov_tier_name          in varchar2_tbl,
        p_deductible             in varchar2_tbl,
        p_event_code             in varchar2_tbl,
        p_dep_ssn                in varchar2_tbl,
        p_debit_card             in varchar2_tbl,
        p_person_type            in varchar2_tbl,
        p_dep_first_name         in varchar2_tbl,
        p_dep_middle_name        in varchar2_tbl,
        p_dep_last_name          in varchar2_tbl,
        p_dep_gender             in varchar2_tbl,
        p_dep_birth_date         in varchar2_tbl,
        p_dep_relative           in varchar2_tbl,
        p_dep_card_ssn           in varchar2_tbl,
        p_batch_number           in out number,
        x_error_message          out varchar2,
        x_return_status          out varchar2
    );

end pc_online_enroll_dml;
/

