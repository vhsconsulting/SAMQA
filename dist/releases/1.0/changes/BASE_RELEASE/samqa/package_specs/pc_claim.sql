-- liquibase formatted sql
-- changeset SAMQA:1754374134934 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_claim.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_claim.sql:null:37743b45eb849fd0c3dbac1748d752a7b3545be1:create

create or replace package samqa.pc_claim is
    type claim_deductible_row_t is record (
            claim_id          number,
            acc_num           varchar2(30),
            plan_type         varchar2(30),
            annual_election   number,
            plan_start_date   date,
            plan_end_date     date,
            claim_amount      number,
            deductible_amount number,
            approved_amount   number
    );
    type claim_deductible_t is
        table of claim_deductible_row_t;
    type claim_detail_row_t is record (
            claim_id             number,
            reimbursement_method varchar2(30),
            check_amount         number,
            vendor_name          varchar2(3200),
            bank_name            varchar2(3200),
            claim_pending        number,
            claim_amount         number,
            reason_code          number,
            pay_date             date,
            prov_name            varchar2(3200),
            claim_stat_meaning   varchar2(3200),
            claim_status         varchar2(320),
            claim_date           date,
            claim_type           varchar2(30)
    );
    type claim_detail_t is
        table of claim_detail_row_t;
    type ach_claim_row_t is record (
            transaction_id            number,
            acc_num                   varchar2(30),
            name                      varchar2(255),
            transaction_date          date,
            total_amount              number,
            balance                   number,
            acc_id                    number,
            pers_id                   number,
            note                      varchar2(3200),
            account_status            varchar2(30),
            claim_id                  number,            -- Added By Jaggi #9775
            account_type              varchar2(10),         -- Added by Swamy for Ticket#9912 on 10/08/2021
            claim_source              varchar2(30),
            standard_entry_class_code varchar2(10),   -- Added by Swamy for Ticket#11701(Nacha) on 14/09/2023  
            premium_date              date             -- Added by Karthe on 09/26/2024
    );
    type ach_claim_t is
        table of ach_claim_row_t;
    function get_deductible_report return claim_deductible_t
        pipelined
        deterministic;

    type claim_detail_record is record (
            detail_id        number,
            service_date     date,
            service_end_date date,
            service_price    number,
            plan_type        varchar2(30),
            pers_id          number,
            pers_patient     number,
            line_status      varchar2(30),
            amount_approved  number,
            claim_amount     number
    );
    type claim_det_tbl is
        table of claim_detail_record index by binary_integer;
/*
 ??? ???????????? ?????? CLAIM ? CLAIM_DETAIL
*/
    procedure process_ach_claim (
        p_transaction_id in number,
        p_user_id        in number
    );  -- Added by Swamy for Ticket#11556)

    procedure cancel_ach_eclaim (
        p_transaction_id in number,
        p_note           in varchar2,
        p_user_id        in number
    );

    procedure cancel_invalid_bank_txns (
        p_bank_acct_id in number,
        p_note         in varchar2,
        p_user_id      in number
    );

    procedure process_hrafsa_ach_eclaim (
        p_transaction_id in number,
        p_user_id        in number
    );
-- ??? ??.claim ?????????? CLAIM_CODE
    function claim_code (
        claim_id_in in claim.claim_id%type
    ) return claim.claim_code%type;

    function claim_type (
        claim_id_in in varchar2
    ) return varchar2;

    function claim_paid (
        claim_id_in in varchar2
    ) return number;

    function f_claim_paid (
        claim_id_in in varchar2
    ) return number;

    function get_paid_date (
        claim_id_in in claimn.claim_id%type
    ) return date;
-- ??? ??.claim ?????????? CLAIM_CODE (new)
    function claimn_code (
        claim_id_in in claimn.claim_id%type
    ) return claimn.claim_code%type;

    procedure get_deductible (
        p_acc_id          in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2,
        p_pers_id         in number,
        p_pers_patient    in number,
        p_rule_id         in number,
        p_annual_election in number,
        p_claim_amount    in number,
        x_deductible      out number,
        x_payout_amount   out number
    );

    procedure process_emp_claim (
        p_entrp_id       in number,
        p_list_bill      in number,
        p_refund_amount  in number,
        p_emp_deposit_id in number,
        p_check_number   in varchar2,
        x_batch_number   out varchar2,
        x_error_message  out varchar2
    );
-- ??? ??.claim ?????????? ???-?? ????????? ?????
    function count_claim_detail (
        claim_id_in in claim.claim_id%type
    ) return number;

-- ??? ??.claim ?????????? ????? ????????? ?????
    function sum_claim_detail (
        claim_id_in in claim.claim_id%type
    ) return claim_detail.sure_amount%type;

-- ??? ??.claim ?????????? ????? CLAIM-? (new)
    function sum_claimn_detail (
        claim_id_in in claimn.claim_id%type
    ) return number;

-- ??? ??.claim ?????????? ???-?? ????? ??? ????
    function count_claim_payment (
        claim_id_in in claim.claim_id%type
    ) return number;

-- ??? ??.claim ?????????? ????? ????? ??? ????
    function sum_claim_payment (
        claim_id_in in claim.claim_id%type
    ) return number;

-- ??? ??.claim ?????????? ???-?? ????? ??? ???? (new)
    function count_claimn_payment (
        claim_id_in in claimn.claim_id%type
    ) return number;

-- ??? ??.claim ?????????? ????? ????? ??? ???? (new)
    function sum_claimn_payment (
        claim_id_in in claimn.claim_id%type
    ) return number;

-- ??? ??.claim ?????????? ???????????? ??????? ??? ????
    function rest_claim (
        claim_id_in in claim.claim_id%type
    ) return number;

-- ??? ??.claim ?????????? ???????????? ??????? ??? ???? (new)
    function rest_claimn (
        claim_id_in in claimn.claim_id%type
    ) return number;

    function get_claim_paid (
        p_acc_id       in number,
        p_claim_type   in varchar2,
        p_claim_amount in number
    ) return number;

    function get_claim_3000_per_week (
        p_acc_id in number
    ) return number;

    function get_claim_8000_per_month (
        p_acc_id in number
    ) return number;

    function get_denied_bank_draft (
        p_acc_id in number
    ) return number;

    procedure create_disbursement (
        p_vendor_id     in number,
        p_provider_name in varchar2,
        p_address1      in varchar2,
        p_address2      in varchar2,
        p_city          in varchar2,
        p_state         in varchar2,
        p_zipcode       in varchar2,
        p_claim_date    in varchar2,
        p_claim_amount  in number,
        p_claim_type    in varchar2,
        p_acc_num       in varchar2,
        p_note          in varchar2,
        p_dos           in varchar2,
        p_acct_num      in varchar2,
        p_patient_name  in varchar2,
        p_date_received in varchar2,
        p_payment_mode  in varchar2 default 'P' --P : Payment, FP : Fee Bucket Refund
        ,
        p_user_id       in number,
        p_batch_number  in varchar2
    );

-- Refund fee bucket balance for closed
-- accounts to subscribers
    procedure process_feebucket_refund (
        p_provider_name in varchar2,
        p_claim_date    in varchar2,
        p_claim_amount  in number,
        p_claim_type    in varchar2,
        p_acc_num       in varchar2,
        p_note          in varchar2,
        p_user_id       in number,
        p_batch_number  in varchar2
    );

    function has_document (
        claim_id_in in number
    ) return varchar2;

    procedure create_fsa_disbursement (
        p_acc_num            in varchar2,
        p_acc_id             in number,
        p_vendor_id          in number,
        p_vendor_acc_num     in varchar2,
        p_amount             in number,
        p_patient_name       in varchar2,
        p_note               in varchar2,
        p_user_id            in number,
        p_service_start_date in varchar2,
        p_service_end_date   in varchar2,
        p_date_received      in varchar2,
        p_service_type       in varchar2,
        p_claim_source       in varchar2,
        p_claim_method       in varchar2,
        p_bank_acct_id       in number,
        p_pay_reason         in number,
        p_doc_flag           in varchar2,
        p_insurance_category in varchar2,
        p_claim_category     in varchar2,
        p_memo               in varchar2,
        x_claim_id           out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

    procedure create_hra_disbursement (
        p_acc_num            in varchar2,
        p_acc_id             in number,
        p_vendor_id          in number,
        p_vendor_acc_num     in varchar2,
        p_amount             in number,
        p_patient_name       in varchar2,
        p_note               in varchar2,
        p_user_id            in number,
        p_service_start_date in varchar2,
        p_service_end_date   in varchar2,
        p_date_received      in varchar2,
        p_service_type       in varchar2,
        p_claim_source       in varchar2,
        p_claim_method       in varchar2,
        p_bank_acct_id       in number,
        p_pay_reason         in number,
        p_doc_flag           in varchar2,
        p_insurance_category in varchar2,
        p_claim_category     in varchar2,
        p_memo               in varchar2,
        x_claim_id           out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

    procedure validate_hra_fsa_disbursement (
        p_acc_id             in number,
        p_amount             in number,
        p_service_start_date in date,
        p_service_end_date   in date,
        p_service_type       in varchar2,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

    procedure update_hra_fsa_disbursement (
        p_acc_id             in number,
        p_claim_amount       in number,
        p_service_start_date in date,
        p_service_end_date   in date,
        p_service_type       in varchar2,
        p_patient_name       in varchar2,
        p_note               in varchar2,
        p_pay_reason         in varchar2,
        p_memo               in varchar2,
        p_insurance_caterogy in varchar2,
        p_expense_category   in varchar2,
        p_user_id            in number,
        p_doc_flag           in varchar2,
        p_claim_id           in number,
        p_claim_status       in varchar2,
        p_plan_start_date    in date,
        p_plan_end_date      in date,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

    procedure cancel_hra_fsa_disbursement (
        p_claim_id      in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure process_hra_fsa_disbursement (
        p_claim_id          in number,
        p_claim_status      in varchar2,
        p_approved_amount   in number,
        p_denied_amount     in number,
        p_deductible_amount in number,
        p_denied_reason     in varchar2,
        p_note              in varchar2,
        p_user_id           in number,
        x_return_status     out varchar2,
        x_error_message     out varchar2
    );

    procedure deny_hra_fsa_disbursement (
        p_claim_id      in number,
        p_claim_status  in varchar2,
        p_denied_reason in varchar2,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure process_finance_claim (
        p_claim_id      in number,
        p_claim_status  in varchar2,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure insert_payment (
        p_acc_id        in number,
        p_claim_id      in number,
        p_reason_code   in number,
        p_amount        in number,
        p_plan_type     in varchar2 default null,
        p_payment_date  in date default sysdate,
        p_pay_num       in varchar2 default null,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure import_uploaded_claims (
        p_user_id      number,
        p_batch_number in varchar2
    );

    procedure process_uploaded_claims (
        p_batch_number in varchar2,
        p_user_id      in number
    );

    procedure reprocess_approved_claims (
        p_user_id number
    );

    procedure update_claim_status (
        p_claim_id in number
    );

    procedure process_claim_status (
        p_claim_id in number
    );

    procedure update_claim_totals (
        p_claim_id in number
    );

/*** processing cheyenne claims for HRA hat has no debit card claims ***/
    procedure process_non_dc_hra_fsa_claims;
/*** Denying claims with multiple debit card swipes ***/
    procedure process_mdup_dc_hra_fsa_claims;
/*
Procedure calc_deductible(p_acc_num   IN VARCHAR2
                         ,p_plan_type IN VARCHAR2
                         ,p_claim_amt IN NUMBER
                         ,p_deductible_amt OUT NUMBER
                         ,p_pay_out_amt OUT NUMBER);
*/

    function get_claim_paid_ytd (
        p_acc_id number
    ) return number;

    procedure ins_deductible_balance (
        p_acc_id            in number,
        p_pers_id           in number,
        p_pers_patient      in number,
        p_claim_id          in number,
        p_deductible_amount in number,
        p_pay_date          in date,
        p_status            in varchar2,
        p_note              in varchar2,
        p_user_id           in number
    );

    procedure process_nsf_hsa_claim (
        p_claim_id in number,
        p_user_id  in number
    );

/** Process broker commissions ***/
    procedure process_broker_claim (
        p_broker_id         in number,
        p_broker_lic        in varchar2,
        p_vendor_id         in number,
        p_bank_acct_id      in number,
        p_commission        in number,
        p_reimburse_method  in varchar2,
        p_period_start_date in date,
        p_period_end_date   in date,
        p_note              in varchar2,
        p_account_type      in varchar2,
        x_transaction_id    out number,
        x_error_message     out varchar2
    );

    procedure validate_claim_detail (
        p_claim_id      in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure validate_transaction_limits (
        p_claim_id in number
    );

    function get_monthly_claim_amount (
        p_claim_id         in number,
        p_pers_id          in number,
        p_service_type     in varchar2,
        p_service_date     in date,
        p_service_end_date in date
    ) return number;

    function get_monthly_claim_paid (
        p_claim_id         in number,
        p_pers_id          in number,
        p_service_type     in varchar2,
        p_service_date     in date,
        p_service_end_date in date
    ) return number;

    procedure process_emp_refund (
        p_entrp_id            in number,
        p_pay_code            in number,
        p_refund_amount       in number,
        p_emp_payment_id      in number,
        p_substantiate_reason in varchar2 default null  -- Added by Swamy for Ticket#5692
        ,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    );

    procedure create_feebucket_check (
        p_batch_number in number,
        p_user_id      in number
    );

    function is_duplicate_claim (
        p_claim_id in number
    ) return varchar2;

    function get_claim_payment_method (
        p_entrp_id in number
    ) return varchar2;

    procedure create_online_hsa_disbursement (
        p_acc_num          in varchar2,
        p_acc_id           in number,
        p_vendor_id        in number,
        p_bank_acct_id     in number,
        p_amount           in number,
        p_claim_date       in varchar2,
        p_note             in varchar2,
        p_memo             in varchar2,
        p_user_id          in number,
        p_claim_type       in varchar2,
        p_service_date     in pc_online_enrollment.varchar2_tbl,
        p_service_end_date in pc_online_enrollment.varchar2_tbl,
        p_service_price    in pc_online_enrollment.varchar2_tbl,
        p_patient_dep_name in pc_online_enrollment.varchar2_tbl,
        p_medical_code     in pc_online_enrollment.varchar2_tbl,
        p_detail_note      in pc_online_enrollment.varchar2_tbl,
        p_eob_detail_id    in pc_online_enrollment.varchar2_tbl,
        p_eob_id           in varchar2,
        x_claim_id         out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    );

    procedure update_hsa_disbursement (
        p_claim_id         in varchar2,
        p_acc_id           in number,
        p_amount           in number,
        p_note             in varchar2,
        p_memo             in varchar2,
        p_user_id          in number,
        p_service_date     in pc_online_enrollment.varchar2_tbl,
        p_service_end_date in pc_online_enrollment.varchar2_tbl,
        p_service_price    in pc_online_enrollment.varchar2_tbl,
        p_patient_dep_name in pc_online_enrollment.varchar2_tbl,
        p_medical_code     in pc_online_enrollment.varchar2_tbl,
        p_detail_note      in pc_online_enrollment.varchar2_tbl,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    );

    procedure cancel_hsa_disbursement (
        p_claim_id      in varchar2,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure process_online_hsa_claim (
        p_claim_id      in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure process_hsa_claim (
        p_claim_id in number default null,
        p_user_id  in number
    );

    function get_web_claim_detail (
        p_acc_id            in number,
        p_reason_code       in varchar2,
        p_status            in varchar2,
        p_claim_date_from   in varchar2,
        p_claim_date_to     in varchar2,
        p_pay_date_from     in varchar2,
        p_pay_date_to       in varchar2,
        p_request_date_from in varchar2,
        p_request_date_to   in varchar2
    ) return claim_detail_t
        pipelined
        deterministic;

    procedure create_new_disbursement (
        p_vendor_id      in number,
        p_provider_name  in varchar2,
        p_address1       in varchar2,
        p_address2       in varchar2,
        p_city           in varchar2,
        p_state          in varchar2,
        p_zipcode        in varchar2,
        p_claim_date     in varchar2,
        p_claim_amount   in number,
        p_claim_type     in varchar2,
        p_acc_num        in varchar2,
        p_note           in varchar2,
        p_dos            in varchar2,
        p_acct_num       in varchar2,
        p_patient_name   in varchar2,
        p_date_received  in varchar2,
        p_payment_mode   in varchar2 default 'P'  --P : Payment, FP : Fee Bucket Refund
        ,
        p_user_id        in number,
        p_batch_number   in varchar2,
        p_termination    in varchar2 default 'N',
        p_reason_code    in number,
        p_service_status in number default 2,
        p_claim_source   in varchar2 default 'INTERNAL' -- added by Joshi for 6792
    );

    procedure schedule_mobile_ach (
        p_acc_id           in number,
        p_bank_acct_id     in number,
        p_transaction_type in varchar2,
        p_amount           in number default 0,
        p_fee_amount       in number default 0,
        p_transaction_date in date,
        p_reason_code      in number,
        p_status           in varchar2,
        p_user_id          in number,
        p_pay_code         in number default 5,
        x_transaction_id   out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    );

    procedure process_takeover_claim (
        p_batch_number in varchar2,
        p_user_id      in number
    );

    function get_pending_claim_amount (
        p_claim_id         in number,
        p_pers_id          in number,
        p_service_type     in varchar2,
        p_service_date     in date,
        p_service_end_date in date
    ) return number;

    procedure create_split_claim (
        p_claim_id         in number,
        p_claim_amount     in number,
        p_plan_start_date  in date,
        p_plan_end_date    in date,
        p_service_date     in date,
        p_service_end_date in date,
        p_user_id          in number,
        x_claim_id         out number
    );

    function get_ach_claim_detail (
        p_trans_from_date in date,
        p_trans_to_date   in date
    ) return ach_claim_t
        pipelined
        deterministic;

    procedure check_doc_for_debit_card_txn (
        p_claim_id in number default null
    );

    procedure update_claim_to_review (
        p_claim_id in number,
        p_user_id  in number
    );

    procedure check_grace_period_claim (
        p_claim_id in number
    );

    procedure update_hsa_claim_amount (
        p_claim_id      in number,
        p_claim_amount  in number,
        p_memo          in varchar2,
        p_note          in varchar2,
        p_user_id       in number,
        x_error_message out varchar2
    );

    procedure error_hsa_disbursement (
        p_claim_id      in varchar2,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    function get_claim_offset_number (
        p_claim_id      in number,
        p_offset_reason in varchar2
    ) return number;

    function get_remaining_offset (
        p_claim_id in number
    ) return number;

    procedure update_source_claim (
        p_claim_amt       in number,
        p_rem_amt         in number,
        p_claim_id        in number,
        p_offset_amt      in number,
        p_unsub_claim_amt in number,
        p_unsub_claim_id  in number,
        x_error_status    out varchar2,
        x_error_message   out varchar2
    );

    procedure mobile_hrafsa_disbursement (
        p_acc_num            in varchar2,
        p_acc_id             in number,
        p_amount             in number,
        p_patient_name       in varchar2,
        p_service_start_date in varchar2,
        p_service_end_date   in varchar2,
        p_service_type       in varchar2,
        p_claim_method       in varchar2,
        p_bank_acct_id       in number,
        p_vendor_id          in number,
        p_vendor_acc_num     in varchar2,
        p_insurance_category in varchar2,
        p_description        in varchar2,
        p_note               in varchar2,
        p_memo               in varchar2,
        p_user_id            in number,
        x_claim_id           out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

    procedure schedule_mobile_check (
        p_acc_id           in number,
        p_vendor_id        in number,
        p_amount           in number default 0,
        p_transaction_date in date,
        p_reason_code      in number,
        p_user_id          in number,
        p_pay_code         in number default 5,
        p_memo             in varchar2,
        x_claim_id         out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    );

-- Automatically denies the claim after run out and grace period
    procedure deny_claims_end_grace_runout;

    procedure update_claim_payments (
        p_ben_plan_id   in number,
        p_entrp_id      in number,
        p_start_date    in varchar2,
        p_end_date      in varchar2,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    procedure substantiate_previous_year (
        p_claim_id              in number,
        p_substantiation_reason in varchar2,
        p_user_id               in number,
        p_offset_amount         in number,
        p_service_type          in varchar2
    );

-- Procedure created by swamy on 10/05/2018 wrt Ticket#5692
    procedure auto_employer_payment (
        p_claim_id            in number,
        p_substantiate_reason in varchar2,
        p_check_amount        in number,
        p_list_bill           in varchar2,
        p_app_user            in number,
        p_acc_num             in varchar2,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    );

-- Added by Joshi for 6596.
    procedure create_outideinvestment_claim (
        p_acc_id   number,
        p_amount   number,
        p_user_id  number,
        p_claim_id out number
    );

-- Added By Jaggi #9775
    function get_trans_fraud_flag (
        p_acc_id in number
    ) return varchar2;

 -- Added by Joshi for 10320.
    function get_claim_payment_method_for_lsa return varchar2;

    procedure deny_lsa_disbursement (
        p_claim_id      in number,
        p_claim_status  in varchar2,
        p_denied_reason in varchar2,
        p_user_id       in number,
        p_denied_amount in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

 -- Added by swamy for Ticket#10399 on 28/09/2021
    procedure process_lsa_disbursement (
        p_claim_id        in number,
        p_claim_status    in varchar2,
        p_approved_amount in number,
        p_denied_amount   in number,
        p_denied_reason   in varchar2,
        p_note            in varchar2,
        p_user_id         in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

 -- Added by swamy for Ticket#10399 on 28/09/2021
    function get_lsa_ach_claim_detail (
        p_trans_from_date in date,
        p_trans_to_date   in date
    ) return ach_claim_t
        pipelined
        deterministic;

-- Added by Jaggi #10108
    procedure upload_receipts (
        p_receipt_name  in varchar2,
        p_receipt_doc   in blob,
        p_file_type     in varchar2,
        p_mime_type     in varchar2,
        p_user_id       in number,
        p_acc_id        in number,
        p_batch_num     in number,
        x_receipt_id    out varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

 -- Added by Jaggi #10108
    procedure mob_copy_receipts (
        p_claim_id in number,
        p_receipts in pc_online_enrollment.varchar2_tbl,
        p_user_id  in number
    );
-- Added by Jaggi #10108
    procedure mob_delete_receipts (
        p_receipt_id    in pc_online_enrollment.varchar2_tbl,
        p_user_id       in number,
        p_employer_id   in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );
-- Added by Jaggi #10108
    procedure mob_delete_file_attachments (
        p_attachment_id in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

 -- Added by Joshi #10108
    type receipt_row_t is record (
            receipt_id    number,
            receipt_name  varchar2(300),
            receipt_doc   blob,
            receipt_ext   varchar2(300),
            creation_date date,
            mime_type     varchar2(500),
            file_type     varchar2(10)
    );
    type receipt_record_t is
        table of receipt_row_t;

  -- Added by Joshi #10108
    function get_claim_receipts (
        p_user_id in number
    ) return receipt_record_t
        pipelined
        deterministic;

    procedure process_ach_refund (
        p_transaction_id in number,
        p_note           varchar2,
        p_user_id        in number
    );  -- Added by Joshi for 11698

-- Added by Swamy for Ticket#12286 25072024
    function get_service_type (
        p_claim_id in number,
        p_acc_id   in number
    ) return varchar2;

-- Added by Joshi for Ticket#12625 
    procedure process_refund_by_ach (
        p_entrp_id       in number,
        p_pay_code       in number,
        p_refund_amount  in number,
        p_emp_payment_id in number,
        p_bank_acct_id   in number,
        p_reason_code    in varchar2,
        p_user_id        in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    );

end pc_claim;
/

