-- liquibase formatted sql
-- changeset SAMQA:1754374142399 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\process_upload.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/process_upload.sql:null:0cd47f0ad31b26db9dda086a3d75ba01974e6b5b:create

create or replace package samqa.process_upload is
    g_ameritrade_acct_no constant integer := 3433;
    procedure process_mass_enrollments (
        pv_file_name in varchar2,
        pv_entrp_id  in number,
        p_user_id    in number
    );

    procedure export_enrollment_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    );

    procedure export_ftp_enrollment_file (
        pv_file_name   in varchar2,
        x_batch_number out number
    );

    procedure export_enrollment_file (
        pv_file_name   in varchar2,
        pv_entrp_id    in number,
        p_user_id      in number,
        p_group_number in varchar2 default null,
        x_batch_number out number
    );

    function get_carrier_id (
        p_carrier in varchar2
    ) return number;

    procedure validate_enrollments (
        pv_entrp_id    in number,
        p_user_id      in number,
        p_batch_number in number
    );

    procedure process_enrollments (
        pv_entrp_id    in number,
        p_batch_number in number
    );

    procedure process_mass_dependants (
        pv_file_name in varchar2,
        pv_entrp_id  in number,
        p_user_id    in number
    );

    procedure export_dependant_file (
        pv_file_name in varchar2,
        pv_entrp_id  in number
    );

    procedure validate_dependants (
        pv_entrp_id    in number,
        p_user_id      in number,
        x_batch_number out number
    );

    procedure process_dependants (
        pv_entrp_id    in number,
        p_batch_number in number
    );

    function get_entrp_id (
        p_acc_id in number
    ) return number;

    function get_lookup_code (
        p_lookup_name in varchar2,
        p_description in varchar2
    ) return varchar2;

    procedure process_error (
        pv_mass_enrollment_id in number
    );

    procedure validate_error_enrollments (
        pv_mass_enrollment_id in number
    );

    procedure process_error_enrollments (
        pv_mass_enrollment_id in number
    );

    procedure validate_error_dependants (
        pv_mass_enrollment_id in number
    );

    procedure process_error_dependants (
        pv_mass_enrollment_id in number
    );

    procedure process_benetrac_enrollments (
        pv_file_name in varchar2
    );

    procedure process_benetrac_dependants (
        pv_file_name in varchar2
    );

    procedure process_existing_accounts (
        p_user_id      in number default 0,
        p_batch_number in number
    );

    procedure process_existing_dependant (
        p_user_id      in number default 0,
        p_batch_number in number
    );

/*** HRA Paper and FTP feed enrollments ****/
    procedure process_hra_enrollment (
        pv_file_name in varchar2,
        p_user_id    in number
    );

    procedure export_hra_enrollment (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    );

    procedure validate_hra_enrollments (
        p_user_id      in number,
        p_batch_number in number
    );

    procedure process_hra_enrollments (
        pv_user_id     in number,
        p_batch_number in number
    );

/*** FSA Paper and FTP feed enrollments ****/
    procedure process_fsa_enrollment (
        pv_file_name in varchar2,
        p_user_id    in number
    );

    procedure export_fsa_enrollment (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    );

    procedure validate_fsa_enrollments (
        p_user_id      in number,
        p_batch_number in number
    );

    procedure process_fsa_enrollments (
        pv_user_id     in number,
        p_batch_number in number
    );

    procedure process_ftp_hsa_enrollments (
        pv_file_name   in varchar2,
        p_user_name    in varchar2,
        p_group_number in varchar2
    );

    procedure process_ftp_hsa_dependants (
        pv_file_name   in varchar2,
        p_user_name    in varchar2,
        p_group_number in varchar2
    );

    procedure process_existing_hfsa (
        p_user_id      in number default 0,
        p_batch_number in number
    );

    procedure mass_renew_employees (
        p_batch_number in number
    );

/*** new FSA template **/

    procedure process_fsa_renewal (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    );

    procedure export_fsa_renewal (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    );

    procedure initialize_fsa_renewal (
        p_batch_number in number
    );

    procedure process_fsa_enrollments_renew (
        pv_user_id     in number,
        p_batch_number in number
    );

    procedure process_existing_hfsa_renew (
        p_user_id      in number default 0,
        p_batch_number in number
    );

    procedure validate_fsa_renewals (
        p_user_id      in number,
        p_batch_number in number
    );

    procedure mass_renew_enroll_employees (
        p_batch_number in number
    );

    procedure process_terminations (
        p_user_id      in number,
        p_batch_number in number
    );

    procedure process_annual_election_change (
        p_user_id      in number default 0,
        p_batch_number in number
    );

    function validate_annual_election (
        p_ben_plan_id in number,
        p_election    in varchar2
    ) return varchar2;

    function get_valid_state (
        p_state in varchar2
    ) return varchar2;

    function validate_ann_elec_change (
        p_ben_plan_id    in number,
        p_er_ben_plan_id in number,
        p_election       in number
    ) return varchar2;

    function get_entrp_id (
        p_entrp_acc_id in number,
        p_name         in varchar2,
        p_account_type in varchar2
    ) return number;

    procedure write_hrafsa_audit_file (
        p_batch_number in number,
        p_file_name    in varchar2
    );

    procedure write_hsa_audit_file (
        p_batch_number in number,
        p_file_name    in varchar2
    );

    procedure write_dependent_audit_file (
        p_batch_number in number,
        p_file_name    in varchar2
    );

    procedure email_files (
        p_file_name    in varchar2,
        p_report_title in varchar2
    );

    procedure notify_annual_election;

    procedure reinstate_terminated_plans (
        p_user_id      in number,
        p_batch_number in number
    );
-- 9071 Jagadeesh
    procedure process_tdameritrade_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    );
 -- 9071 Jagadeesh
    procedure export_td_ameritrade_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    );

-- 9072 Jagadeesh
    type l_cursor is ref cursor;
    type file_upload_history_row_t is record (
            file_upload_id     number,
            entrp_id           number,
            name               varchar2(75),
            batch_number       varchar2(3200),
            file_name          varchar2(3200),
            file_upload_result varchar2(3200),
            creation_date      date,
            account_type       varchar2(30),
            file_type          varchar2(100)
    );
    type file_upload_history_t is
        table of file_upload_history_row_t;
    function get_file_upload_history (
        p_entrp_code   varchar2,
        p_from_date    varchar2,
        p_to_date      varchar2,
        p_sort_column  varchar2,
        p_sort_order   varchar2,
        p_account_type varchar2
    ) return file_upload_history_t
        pipelined
        deterministic;
-- 9072 Jagadeesh
    type discrepancy_report_row_t is record (
            tpa_id             varchar2(30),
            first_name         varchar2(255),
            middle_name        varchar2(255),
            last_name          varchar2(255),
            account_number     varchar2(30),
            processing_status  varchar2(10),
            processing_message varchar2(3200),
            error_value        varchar2(2500)
    );
    type discrepancy_report_t is
        table of discrepancy_report_row_t;
    function get_discrepancy_report (
        p_batch_number in number,
        p_file_name    varchar2
    ) return discrepancy_report_t
        pipelined
        deterministic;
-- Added by Joshi for 9694/9670.
    function get_enrollment_errors (
        p_mass_enrollment_id in number
    ) return varchar2;

-- Procedure added by Swamy for Ticket#9840 on 18/05/2021
    procedure export_ease_enrollment_file (
        pv_file_name   in varchar2,
        x_batch_number out number
    );

-- Procedure added by Swamy for Ticket#9912 on 10/08/2021
    procedure process_mass_lsa_enrollments (
        pv_file_name   in varchar2,
        pv_entrp_id    in number,
        p_user_id      in number,
        p_account_type in varchar2
    );

-- Procedure added by Swamy for Ticket#9912 on 10/08/2021
    procedure validate_lsa_enrollments (
        pv_entrp_id    in number,
        p_user_id      in number,
        p_batch_number in number,
        p_account_type in varchar2
    );
-- Added by Jaggi#10125
    procedure export_ease_fsa_enrollment_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    );

-- Added by Swamy#11626
    procedure process_employer_discount (
        pv_file_name    in varchar2,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

-- Added by Swamy#11626
    procedure export_employer_discount (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    );

-- Added by Swamy#11626
    procedure validate_employer_discount (
        p_batch_number  in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

-- Added by Swamy#11626
    procedure upsert_employer_discount (
        p_batch_number  in number,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

-- Added by Joshi for EE Navigator 12360
    procedure process_edi_eenav_files;

    procedure insert_hsa_enav_staging (
        pv_file_name    in varchar2,
        p_batch_number  in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure process_hsa_edi_enav (
        pv_file_name    in varchar2,
        p_user_id       in number,
        x_batch_number  in out number,
        x_entrp_id      out number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure upload_enav_csv_file (
        p_batch_number in number,
        p_file_name    in varchar2
    );

end process_upload;
/

