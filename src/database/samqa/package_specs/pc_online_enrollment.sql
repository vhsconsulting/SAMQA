create or replace package samqa.pc_online_enrollment is
    type varchar2_tbl is
        table of varchar2(3200) index by binary_integer;

-- Added by Joshi for 12367.
    type beneficiary_rec is record (
            beneficiary_id        beneficiary.beneficiary_id%type,
            beneficiary_name      beneficiary.beneficiary_name%type,
            beneficiary_type      beneficiary.beneficiary_type%type,
            beneficiary_type_desc varchar2(100),
            relat_code            varchar2(30),
            effective_date        beneficiary.effective_date%type,
            distribution          beneficiary.distribution%type
    );
    type beneficiary_t is
        table of beneficiary_rec;
    procedure pc_insert_enrollment (
        p_first_name                 in varchar2,
        p_last_name                  in varchar2,
        p_middle_name                in varchar2,
        p_title                      in varchar2,
        p_gender                     in varchar2,
        p_birth_date                 in date,
        p_ssn                        in varchar2,
        p_id_type                    in varchar2,
        p_id_number                  in varchar2,
        p_address                    in varchar2,
        p_city                       in varchar2,
        p_state                      in varchar2,
        p_zip                        in varchar2,
        p_phone                      in varchar2,
        p_email                      in varchar2,
        p_carrier_id                 in number,
        p_plan_type                  in varchar2,
        p_health_plan_eff_date       in date,
        p_deductible                 in number,
        p_plan_code                  in number,
        p_broker_lic                 in varchar2,
        p_entrp_id                   in number,
        p_fee_pay_type               in number,
        p_er_contribution            in number,
        p_ee_contribution            in number,
        p_er_fee_contribution        in number,
        p_ee_fee_contribution        in number,
        p_contribution_frequency     in varchar2,
        p_debit_card_flag            in varchar2,
        p_user_name                  in varchar2,
        p_user_password              in varchar2,
        p_password_reminder_question in varchar2,
        p_password_reminder_answer   in varchar2,
        p_bank_name                  in varchar2,
        p_routing_number             in number,
        p_account_type               in varchar2,
        p_bank_account_number        in varchar2,
        p_enrollment_status          in varchar2,
        p_ip_address                 in varchar2,
        p_lang_perf                  in varchar2,
        p_id_verification_status     in varchar2,
        p_transaction_id             in varchar2,
        p_verification_date          in varchar2,
        p_business_name              in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_gverify                    in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_gauthenticate              in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_gresponse                  in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_giact_verify               in varchar2,
        p_bank_status                in varchar2       -- Added by Swamy for Ticket#10978 13062024
        ,
        p_bank_acct_id               out number       -- Added by Swamy for Ticket#10978 13062024
        ,
        x_enrollment_id              out number,
        x_error_message              out varchar2,
        x_return_status              out varchar2
    );

    procedure pc_insert_enrollment_plb (
        p_first_name                 in varchar2,
        p_last_name                  in varchar2,
        p_middle_name                in varchar2,
        p_title                      in varchar2,
        p_gender                     in varchar2,
        p_birth_date                 in date,
        p_ssn                        in varchar2,
        p_id_type                    in varchar2,
        p_id_number                  in varchar2,
        p_address                    in varchar2,
        p_city                       in varchar2,
        p_state                      in varchar2,
        p_zip                        in varchar2,
        p_phone                      in varchar2,
        p_email                      in varchar2,
        p_carrier_id                 in number,
        p_plan_type                  in varchar2,
        p_health_plan_eff_date       in date,
        p_deductible                 in number,
        p_plan_code                  in number,
        p_broker_lic                 in varchar2,
        p_entrp_acc_num              in varchar2,
        p_fee_pay_type               in number,
        p_er_contribution            in number,
        p_ee_contribution            in number,
        p_er_fee_contribution        in number,
        p_ee_fee_contribution        in number,
        p_contribution_frequency     in varchar2,
        p_debit_card_flag            in varchar2,
        p_user_name                  in varchar2,
        p_user_password              in varchar2,
        p_password_reminder_question in varchar2,
        p_password_reminder_answer   in varchar2,
        p_bank_name                  in varchar2,
        p_routing_number             in number,
        p_account_type               in varchar2,
        p_bank_account_number        in varchar2,
        p_enrollment_status          in varchar2,
        p_ip_address                 in varchar2,
        x_enrollment_id              out number,
        x_error_message              out varchar2,
        x_return_status              out varchar2
    );

    procedure pc_emp_batch_enrollment (
        p_batch_number  in varchar2,
        p_entrp_id      in varchar2,
        p_file_name     in varchar2,
        p_lang_perf     in varchar2,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure pc_enroll_batch (
        p_first_name_tbl     in varchar2_tbl,
        p_last_name_tbl      in varchar2_tbl,
        p_email_tbl          in varchar2_tbl,
        p_ssn_tbl            in varchar2_tbl,
        p_birth_date_tbl     in varchar2_tbl,
        p_state_tbl          in varchar2_tbl,
        p_effective_date_tbl in varchar2_tbl,
        p_entrp_id           in number,
        p_ip_address         in varchar2,
        p_lang_perf          in varchar2,
        p_batch_number       in varchar2,
        p_user_id            in number,
        p_enroll_source      in varchar2   -- Added By Jaggi ##9699
        ,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

    procedure pc_update_enrollment (
        p_enrollment_id          in number,
        p_first_name             in varchar2,
        p_last_name              in varchar2,
        p_middle_name            in varchar2,
        p_title                  in varchar2,
        p_gender                 in varchar2,
        p_birth_date             in date,
        p_ssn                    in varchar2,
        p_id_type                in varchar2,
        p_id_number              in varchar2,
        p_address                in varchar2,
        p_city                   in varchar2,
        p_state                  in varchar2,
        p_zip                    in varchar2,
        p_phone                  in varchar2,
        p_email                  in varchar2,
        p_carrier_id             in number,
        p_plan_type              in varchar2,
        p_health_plan_eff_date   in date,
        p_deductible             in varchar2,
        p_plan_code              in number,
        p_broker_lic             in varchar2,
        p_entrp_id               in number,
        p_debit_card_flag        in varchar2,
        p_ip_address             in varchar2,
        p_id_verification_status in varchar2,
        p_transaction_id         in varchar2,
        p_verification_date      in varchar2,
        p_dep_first_name         in varchar2_tbl,
        p_dep_middle_name        in varchar2_tbl,
        p_dep_last_name          in varchar2_tbl,
        p_dep_gender             in varchar2_tbl,
        p_dep_birth_date         in varchar2_tbl,
        p_dep_ssn                in varchar2_tbl,
        p_dep_relative           in varchar2_tbl,
        p_dep_flag               in varchar2_tbl,
        p_beneficiary_name       in varchar2_tbl,
        p_beneficiary_type       in varchar2_tbl,
        p_beneficiary_relation   in varchar2_tbl,
        p_ben_distiribution      in varchar2_tbl,
        p_dep_debit_card_flag    in varchar2_tbl,
        x_error_message          out varchar2,
        x_return_status          out varchar2
    );

    procedure pc_delete_enrollment (
        p_enrollment_id in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure pc_insert_dependant (
        p_subscriber_ssn       in varchar2,
        p_first_name           in varchar2,
        p_middle_name          in varchar2,
        p_last_name            in varchar2,
        p_gender               in varchar2,
        p_birth_date           in varchar2,
        p_ssn                  in varchar2,
        p_relative             in varchar2,
        p_dep_flag             in varchar2,
        p_account_type         in varchar2,
        p_beneficiary_type     in varchar2 default null,
        p_beneficiary_relation in varchar2 default null,
        p_effective_date       in date default null,
        p_distiribution        in varchar2 default null,
        p_debit_card_flag      in varchar2 default 'N',
        x_enrollment_id        out varchar2,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    );

    procedure pc_insert_dependant_plb (
        p_subscriber_ssn       in varchar2,
        p_first_name           in varchar2,
        p_middle_name          in varchar2,
        p_last_name            in varchar2,
        p_gender               in varchar2,
        p_birth_date           in varchar2,
        p_ssn                  in varchar2,
        p_relative             in varchar2,
        p_dep_flag             in varchar2,
        p_beneficiary_type     in varchar2 default null,
        p_beneficiary_relation in varchar2 default null,
        p_effective_date       in date default null,
        p_distiribution        in varchar2 default null,
        p_debit_card_flag      in varchar2 default 'N',
        x_enrollment_id        out varchar2,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    );

    procedure update_address (
        p_pers_id       in number,
        p_address       in varchar2,
        p_city          in varchar2,
        p_state         in varchar2,
        p_zip           in varchar2,
        p_phone         in varchar2,
        p_email         in varchar2,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure update_user (
        p_user_id       in number,
        p_user_name     in varchar2,
        p_password      in varchar2,
        p_pwd_question  in varchar2,
        p_pwd_answer    in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure delete_dependant (
        p_pers_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure delete_beneficiary (
        p_beneficiary_id in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    );


    -- HRA excel enrollment
    procedure pc_hra_emp_batch_enrollment (
        p_batch_number  in varchar2,
        p_entrp_id      in varchar2,
        p_file_name     in varchar2,
        p_lang_perf     in varchar2,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure validate_online_fsa_enroll (
        p_batch_number in number,
        p_user_id      in number
    );

      -- FSA excel enrollment
    procedure pc_fsa_emp_batch_enrollment (
        p_batch_number  in varchar2,
        p_entrp_id      in varchar2,
        p_file_name     in varchar2,
        p_lang_perf     in varchar2,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    function check_user_registered (
        p_ssn in varchar2
    ) return varchar2;

 --  PROCEDURE update_dependant;
    function array_fill (
        p_array       varchar2_tbl,
        p_array_count number
    ) return varchar2_tbl;
 --  PROCEDURE update_beneficiary;

  /** Changes for Online HRA/FSA template with GO LIVE date of 04/20/2012*/
    procedure pc_hrafsa_emp_batch_enrollment (
        p_batch_number   in varchar2,
        p_entrp_id       in varchar2,
        p_file_name      in varchar2,
        p_lang_perf      in varchar2,
        p_user_id        in number,
        p_enroll_source  in varchar2 default 'EXCEL',
        p_process_type   in varchar2 default null            --- Added by rprabu on 30/07/2019 for 7919
        ,
        p_file_upload_id out number                      --- Added by rprabu on 30/07/2019 for 7919
        ,
        x_error_message  out varchar2,
        x_return_status  out varchar2
    );

    procedure initialize_hrafsa_enrollment (
        p_batch_number  in number,
        p_entrp_id      in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure load_hrafsa_enrollment (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_user_id       in number  --- 7781 rprabu 30/05/2019
        ,
        p_enroll_source in varchar2 default 'EXCEL',
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure validate_hrafsa_enrollment (
        p_batch_number in number,
        p_entrp_id     in number
    );

    procedure process_changes_enrollment (
        p_batch_number  in number,
        p_entrp_id      in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure process_renewals (
        p_batch_number  in number,
        p_entrp_id      in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure process_hrafsa_enrollment (
        p_batch_number  in varchar2,
        p_entrp_id      in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure process_terminations (
        p_entrp_id     in number,
        p_batch_number in number
    );

  -- end of 4/20/2012 changes
    procedure process_annual_election_change (
        p_batch_number in number
    );

      --Ticket#5422.Enroll Dependants
    procedure process_dependants (
        p_batch_number  in varchar2,
        p_entrp_id      in varchar2,
        p_file_name     in varchar2,
        p_lang_perf     in varchar2,
        p_user_id       in number,
        p_enroll_source in varchar2 default 'EXCEL',
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure validate_dependants (
        pv_entrp_id    in number,
        p_user_id      in number,
        p_source       in varchar2 default null,
        p_batch_number in number,
        x_error_status out varchar2
    );

-- Added by Swamy for 12367.
    procedure upsert_beneficiary (
        p_pers_id              in number,
        p_beneficiary_id       in number,
        p_first_name           in varchar2,
        p_beneficiary_type     in varchar2,
        p_beneficiary_relation in varchar2,
        p_user_id              in number,
        p_distiribution        in number,
        p_note                 in varchar2,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    );

-- Added by Joshi for 12367.
    function get_beneficiary (
        p_pers_id in number
    ) return beneficiary_t
        pipelined
        deterministic;

end pc_online_enrollment;
/


-- sqlcl_snapshot {"hash":"52a6b3ff433c533cba9ac5192fad3c8d002170ae","type":"PACKAGE_SPEC","name":"PC_ONLINE_ENROLLMENT","schemaName":"SAMQA","sxml":""}