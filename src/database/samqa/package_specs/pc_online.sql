create or replace package samqa.pc_online is
    type varchar2_tbl is
        table of varchar(3200) index by binary_integer;
    type number_tbl is
        table of number index by binary_integer;
    type alerts_row is record (
        message varchar2(1000)
    );
    type alerts_t is
        table of alerts_row;
    function alert_box_message (
        p_tax_id       in varchar2,
        p_account_type in varchar2
    ) return alerts_t
        pipelined
        deterministic;

    procedure terminate_employee (
        p_pers_tbl      in varchar2_tbl,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure change_plan (
        p_acc_id        in number,
        p_plan_code     in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure update_insure (
        p_pers_id        in number,
        p_insur_id       in number,
        p_deductible     in number,
        p_effective_date in varchar2,
        p_plan_type      in varchar2,
        p_user_id        in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    );

    procedure create_card (
        p_pers_id       in varchar2_tbl,
        p_acc_id        in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure close_card (
        p_pers_id       in varchar2_tbl,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

------  Ticket 8472-Lost  Debit card added by rprabu 27/01/2020
    procedure order_lost_stolen (
        p_pers_id       in varchar2_tbl,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure end_date_dependant (
        p_pers_id       in varchar2_tbl,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure create_vendor (
        p_vendor_name         in varchar2,
        p_vendor_acc_num      in varchar2,
        p_address             in varchar2,
        p_city                in varchar2,
        p_state               in varchar2,
        p_zipcode             in varchar2,
        p_acc_num             in varchar2,
        p_user_id             in varchar2,
        p_orig_sys_vendor_ref in varchar2 default null,
        x_vendor_id           out number,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    );

    procedure create_disbursement (
        p_acc_num         in varchar2,
        p_acc_id          in number,
        p_vendor_id       in number,
        p_vendor_acc_num  in varchar2,
        p_date_of_service in varchar2,
        p_amount          in number,
        p_patient_name    in varchar2,
        p_note            in varchar2,
        p_user_id         in number,
        x_claim_id        out number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

    procedure update_disbursement (
        p_register_id     in number,
        p_change_num      in number,
        p_claim_id        in number,
        p_vendor_id       in number,
        p_vendor_acc_num  in varchar2,
        p_date_of_service in varchar2,
        p_amount          in number,
        p_patient_name    in varchar2,
        p_note            in varchar2,
        p_user_id         in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

    procedure cancel_disbursement (
        p_register_id   in number,
        p_change_num    in number,
        p_claim_id      in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure pc_insert_enrollment_dep (
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
        p_id_verification_status     in varchar2,
        p_transaction_id             in varchar2,
        p_verification_date          in varchar2,
        p_dep_first_name             in varchar2_tbl,
        p_dep_middle_name            in varchar2_tbl,
        p_dep_last_name              in varchar2_tbl,
        p_dep_gender                 in varchar2_tbl,
        p_dep_birth_date             in varchar2_tbl,
        p_dep_ssn                    in varchar2_tbl,
        p_dep_relative               in varchar2_tbl,
        p_dep_flag                   in varchar2_tbl,
        p_beneficiary_name           in varchar2_tbl,
        p_beneficiary_type           in varchar2_tbl,
        p_beneficiary_relation       in varchar2_tbl,
        p_ben_distiribution          in varchar2_tbl,
        p_dep_debit_card_flag        in varchar2_tbl,
        p_lang_perf                  in varchar2,
        p_business_name              in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_gverify                    in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_gauthenticate              in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_gresponse                  in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_giact_verify               in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_bank_status                in varchar2       -- Added by Swamy for Ticket#10978 13062024
        ,
        p_bank_acct_id               out number       -- Added by Swamy for Ticket#10978 13062024
        ,
        x_enrollment_id              out number,
        x_error_message              out varchar2,
        x_return_status              out varchar2
    );

    procedure check_fraud (
        p_first_name    in varchar2,
        p_last_name     in varchar2,
        p_ssn           in varchar2,
        p_address       in varchar2,
        p_city          in varchar2,
        p_state         in varchar2,
        p_zip           in varchar2,
        p_drivlic       in varchar2,
        p_phone         in varchar2,
        p_email         in varchar2,
        x_fraud_accunt  out varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    function allow_change_plan (
        p_ssn in varchar2
    ) return varchar2;

end pc_online;
/


-- sqlcl_snapshot {"hash":"2386196d2fddf2d041986fc10ba441d7153915ca","type":"PACKAGE_SPEC","name":"PC_ONLINE","schemaName":"SAMQA","sxml":""}