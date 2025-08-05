create or replace package samqa.pc_834_enrollment_edi as
    type segment_counter_record is record (
            ins     number,
            ref_0f  number,
            ref_1l  number,
            ref_17  number,
            mem_dtp number,
            mem_nm1 number,
            mem_per number,
            mem_n3  number,
            mem_n4  number,
            mem_dmg number,
            icm     number,
            lui     number,
            hd      number,
            st      number,
            se      number,
            ref_38  number,
            bgn     number,
            n1_p5   number,
            n1_in   number,
            n1_bo   number
    );
    type hd_segment_record is record (
            dtp    number,
            amt    number,
            ref_17 number
    );
    type detail_record is record (
            detail_id                 number,
            person_type               varchar2(10),
            relationship_cd           varchar2(2),
            maintenance_cd            varchar2(3),
            maintenance_reason        varchar2(3),
            benefit_status_cd         varchar2(1),
            cobra_qualifying_event    varchar2(2),
            employment_status_cd      varchar2(2),
            student_status_cd         varchar2(1),
            handicap_ind              varchar2(1),
            subscriber_number         varchar2(30),
            division_cd               varchar2(30),
            termination_dt            varchar2(35),
            cobra_qualifying_event_dt varchar2(35),
            cobra_begin_dt            varchar2(35),
            cobra_end_dt              varchar2(35),
            enrollment_begin_date     varchar2(35),
            employment_start_date     varchar2(35),
            employment_end_date       varchar2(35),
            gender                    varchar2(1),
            marital_status            varchar2(1),
            first_name                varchar2(35),
            middle_name               varchar2(35),
            last_name                 varchar2(35),
            address                   varchar2(110),
            city                      varchar2(30),
            state                     varchar2(2),
            zip                       varchar2(30),
            orig_system_ref           varchar2(30),
            phone_work                varchar2(100),
            phone_home                varchar2(100),
            phone_cell                varchar2(100),
            phone_extension           varchar2(100),
            email                     varchar2(80),
            coverage_level            varchar2(3),
            coverage_maintenance_cd   varchar2(3),
            benefit_begin_dt          varchar2(35),
            benefit_end_dt            varchar2(35),
            insurance_line_code       varchar2(3),
            coverage_description      varchar2(50),
            birth_date                varchar2(35),
            ssn                       varchar2(80),
            carrier_name              varchar2(50),
            policy_number             varchar2(30),
            deductible                number,
            pref_language             varchar2(80),
            annual_election           varchar2(50),
            payroll_frequency         varchar2(1),
            contribution_amt          number,
            debit_card                varchar2(1),
            status_cd                 varchar2(10)
    );
    type header_record is record (
            trans_control_num     varchar2(9),
            trans_purpose_cd      varchar2(2),
            trans_ref_id          varchar2(30),
            trans_create_dt       varchar2(8),
            trans_create_time     varchar2(8),
            time_zone_cd          varchar2(2),
            previous_trans_ref_id varchar2(30),
            action_cd             varchar2(2),
            master_policy_num     varchar2(30),
            file_effective_dt     varchar2(8),
            maint_effective_dt    varchar2(8),
            enrollment_dt         varchar2(8),
            sponsor_id            varchar2(80),
            sponsor_name          varchar2(60),
            insurer_id            varchar2(80),
            insurer_name          varchar2(60),
            broker_id             varchar2(80),
            broker_name           varchar2(60),
            tpa_id                varchar2(80),
            tpa_name              varchar2(60),
            broker_account        varchar2(35),
            tpa_account           varchar2(35),
            records_received      number,
            records_processed     number,
            records_failed        number,
            segments_received     number,
            status_cd             varchar2(10)
    );
    type error_record is record (
            detail_id              number,
            segment_element_ind    varchar2(1),
            element_position       varchar2(5),
            element_ref_number     varchar2(5),
            bad_element_data       varchar2(80),
            segment_cd             varchar2(3),
            segment_position_count number(5),
            loop_id                varchar2(5),
            syntax_err_cd          varchar2(2),
            error_desc             varchar2(100)
    );
    procedure convert_string_to_date (
        date_string  varchar2,
        success_flag out boolean,
        date_value   out date
    );

    procedure convert_string_to_date_time (
        date_string  varchar2,
        time_string  varchar2,
        success_flag out boolean,
        date_value   out date
    );

    procedure convert_string_to_number (
        number_string varchar2,
        success_flag  out boolean,
        number_value  out number
    );

    procedure build_segment_error (
        p_segment_cd             varchar2,
        p_segment_position_count number,
        p_loop_id                varchar2,
        p_syntax_err_cd          varchar2,
        p_error_desc             varchar2,
        p_err_row                in out error_record
    );

    procedure insert_detail_row (
        p_batch_number in number,
        det_row        in out detail_record,
        err_row        in out error_record,
        file_line      number,
        p_header_id    in number
    );

    procedure build_element_error (
        p_element_position   varchar2,
        p_element_ref_number varchar2,
        p_bad_element_data   varchar2,
        p_syntax_err_cd      varchar2,
        p_error_desc         varchar2,
        p_err_row            in out error_record
    );

    procedure insert_header_row (
        p_batch_number in number,
        header_row     in out header_record,
        err_row        in out error_record,
        file_line      number
    );

    procedure validate_segment_repeat (
        hdr_det_ind  varchar2,
        seg          varchar2,
        seg01        varchar2,
        loop_id      varchar2,
        error_desc   out varchar2,
        success_flag out boolean
    );

    procedure process_enrollment_header (
        p_batch_number in number
    );

    procedure process_enrollment_detail (
        p_batch_number in number
    );

    procedure process_edi_subscriber (
        p_batch_number in number,
        p_detail_id    in number default null
    );

    procedure process_edi_dependant (
        p_batch_number in number
    );

    procedure process_edi_file (
        p_file_name in varchar2
    );

    procedure alter_edi_location (
        p_file_name in varchar2
    );

    procedure export_edi_report (
        pv_file_name in varchar2,
        p_user_id    in number
    );

/** in case when we get the enrollments from other ways, orig sys vendor ref is null
we need to update it ***/
    procedure update_orig_sys_ref_person;

    procedure send_email_on_new_enrollment (
        p_batch_number in number
    );

    g_mail_list constant varchar2(3200) := 'benefits@sterlingadministration.com,vanitha.subramanyam@sterlingadministration.com,'
                                           || 'sarah.soman@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,'
                                           || 'rupesh.aujikar@sterlingadministration.com';
end pc_834_enrollment_edi;
/


-- sqlcl_snapshot {"hash":"21e931f842901771973395d706d52391441a3a88","type":"PACKAGE_SPEC","name":"PC_834_ENROLLMENT_EDI","schemaName":"SAMQA","sxml":""}