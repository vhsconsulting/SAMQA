create or replace package samqa.pc_check_process is
    tpa constant varchar2(100) := 'T002965'
                                  || ','
                                  || '"Sterling Health Services Administration,Inc"'
                                  || ','
                                  || 'P.O. Box 71107'
                                  || ','
                                  || ''
                                  || ','
                                  || 'Oakland'
                                  || ','
                                  || 'CA'
                                  || ','
                                  || '94612';
    g_check_delivery_method constant varchar2(100) := 'USPS';
    g_delivery_inst constant varchar2(100) := 'SendToPayee';
    g_payeecountry constant varchar2(100) := 'USA';
    g_cnb_check_site_id varchar2(100) := 'sterlingadmin';
    g_check_header_line varchar2(4000) := 'TranRef'
                                          || ','
                                          || 'SiteId'
                                          || ','
                                          || 'SettlementMethod'
                                          || ','
                                          || 'PayerName'
                                          || ','
                                          || 'PayerAcctId'
                                          || ','
                                          || 'PayerAcctType'
                                          || ','
                                          || 'PayerBankId'
                                          || ','
                                          || 'PayerBankIdType'
                                          || ','
                                          || 'DeliveryMethod'
                                          || ','
                                          || 'DeliveryInstruction'
                                          || ','
                                          || 'ChkNum'
                                          || ','
                                          || 'CheckMemo'
                                          || ','
                                          || 'PayeeName'
                                          || ','
                                          || 'PayeeAddr1'
                                          || ','
                                          || 'PayeeAddr2'
                                          || ','
                                          || 'PayeeAddr3'
                                          || ','
                                          || 'PayeeCity'
                                          || ','
                                          || 'PayeeState'
                                          || ','
                                          || 'PayeePostalCode'
                                          || ','
                                          || 'PayeeCountry'
                                          || ','
                                          || 'Memo'
                                          || ','
                                          || 'BillingAcct'
                                          || ','
                                          || 'Amt'
                                          || ','
                                          || 'DueDt'
                                          || ','
                                          || 'InvoiceNumber'
                                          || ','
                                          || 'InvoiceAmount'
                                          || ','
                                          || 'InvoiceDate'
                                          || ','
                                          || 'InvoiceDiscount'
                                          || ','
                                          || 'InvoiceAdjustment'
                                          || ','
                                          || 'TxnCreators'
                                          || ','
                                          || 'Version';

/*** Template is in .30 serverr  under /u01/app/oracle/oradata/feeds/adminisource ***/
/*** Document is in  http://pier.sterlinghsa.com/index.php?c=files=file_details=3=2502=5 **/
/*** Getting the values to populate in checks ***/
    function get_employee (
        person_id  number,
        account_id number
    ) return varchar2;

    function get_employee_address (
        person_id number
    ) return varchar2;

    function get_provider (
        p_claim_id number
    ) return varchar2;

    function get_provider_acc_num (
        p_vendor_id number
    ) return varchar2;

    function get_commission_payable_to (
        p_broker_id in number
    ) return varchar2;

    function get_broker (
        p_broker_id in number
    ) return varchar2;

    function get_broker_address (
        p_broker_id in number
    ) return varchar2;

    function get_broker_info (
        p_broker_id in number
    ) return varchar2;

    function get_patient_name (
        p_claim_id in number
    ) return varchar2;

    function get_claim_number (
        p_claim_id in number
    ) return varchar2;

    function get_claim_id (
        p_check_number in number
    ) return number;

/*** Emails***/

-- PROCEDURE send_email_on_hsa_checks; commented by Joshi and added below
    procedure send_email_on_hsa_checks (
        p_file_id number
    );

    procedure send_email_on_lsa_checks (
        p_file_id number
    );
--PROCEDURE send_email_on_hra_fsa_checks(p_claim_type IN VARCHAR2); commented by Joshi for 12770
    procedure send_email_on_hra_fsa_checks (
        p_file_id in number
    ); -- Added by Joshi  for 12770																						 
    procedure send_email_on_broker_checks;

    procedure send_email_on_employer_checks;

    procedure send_email_on_cobra_checks;

    function get_file_name (
        p_action in varchar2,
        p_result in varchar2 default 'RESULT'
    ) return varchar2;

-- Transactions

    procedure update_check_status (
        p_check_id in number,
        p_user_id  in number,
        p_status   in varchar2
    );

    procedure update_unmailed_checks (
        p_claim_id      in number,
        p_amount        in number,
        p_claim_amount  in number,
        p_check_id      in number,
        p_acc_status    in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    procedure insert_pay_receipt (
        p_pay_id       in number,
        p_check_amount in number,
        p_acc_id       in number,
        p_user_id      in number,
        x_check_number out number
    );

    procedure insert_check (
        p_claim_id     in number,
        p_check_amount in number,
        p_acc_id       in number,
        p_user_id      in number,
        p_status       in varchar2 default 'READY',
        p_source       in varchar2 default 'CLAIMN',
        x_check_number out number
    );

/** In office Claims **/
    procedure send_check (
        p_entrp_id  in number,
        p_status    in varchar2,
        x_file_name out varchar2
    );

/** Claims received from EDI files, because of the sheer volume it is sent seperately **/
    procedure send_edi_check (
        p_entrp_id  in number,
        x_file_name out varchar2
    );

/*** HSA claim Checks **/
    procedure send_hsa_check (
        p_entrp_id  in number,
        p_status    in varchar2,
        x_file_name out varchar2
    );
/** Employer Checks **/
    procedure send_er_check (
        x_file_name out varchar2
    );
/*** Broker  Checks **/
    procedure send_broker_check (
        p_broker_id in number,
        p_message   in varchar2,
        x_file_name out varchar2
    );
/** Employer Checks **/
    procedure send_cobra_check (
        x_file_name out varchar2
    );
/*** Employer HRA/FSA  Checks **/
    procedure send_fsa_hra_er_check (
        x_file_name out varchar2
    );

    procedure process_check_result (
        p_file_name in varchar2
    );

    procedure process_broker_check_result (
        p_file_name in varchar2
    );

    function check_mailed (
        p_entity_id   in varchar2,
        p_entity_type in varchar2
    ) return varchar2;

    function check_created (
        p_entity_id   in varchar2,
        p_entity_type in varchar2
    ) return varchar2;

    function get_paid_amount (
        p_claim_id in number
    ) return number;

    procedure update_file_status (
        p_file_name     in varchar2,
        p_file_status   in varchar2,
        p_error_message in varchar2
    );

-- Added by Joshi for 9200.
    procedure create_manual_check (
        p_acc_id           number,
        p_acc_num          varchar2,
        p_entity_name      varchar2,
        p_entity_id        varchar2,
        p_name             varchar2,
        p_address          varchar2,
        p_city             varchar2,
        p_state            varchar2,
        p_zip              varchar2,
        p_check_amount     number,
        p_check_date       date,
        p_memo             varchar2,
        p_transcation_type varchar2,
        p_check_reason     number,
        p_product_type     varchar2, -- Added by Joshi for 9792
        p_provider_flag    varchar2,
        p_user_id          number,
        x_check_number     out number
    );

-- Added by Joshi for 9200.
    procedure send_manual_check (
        x_file_name out varchar2
    );

    procedure process_manual_check_result (
        p_file_name in varchar2
    );

    procedure send_manual_broker_check (
        x_file_name out varchar2
    );

    procedure process_broker_manual_check (
        p_file_name in varchar2
    );
--PROCEDURE send_email_on_lsa_checks;   -- Added by Swamy for Ticket#9912 on 10/08/2021
    function get_vendor_detail (
        p_vendor_id number
    ) return varchar2; -- Added by Joshi for 10458
--FUNCTION get_payer_detail RETURN VARCHAR2 ;

-- Added by Joshi and swamy for 12092
    procedure send_fsa_hra_er_check_cnb (
        x_file_name out varchar2
    );

    procedure send_cobra_check_cnb (
        x_file_name out varchar2
    );

    procedure send_manual_check_cnb (
        x_file_name out varchar2
    );

    procedure insert_cnb_check_trans_detail (
        p_trans_ref     varchar2,
        p_check_number  varchar2,
        p_file_id       number,
        p_vendor_id     number,
        p_provider_flag varchar2
    );

    function get_cnb_check_payer_detail (
        p_account_type varchar2
    ) return varchar2;

    procedure send_check_cnb (
        p_entrp_id  in number,
        p_status    in varchar2,
        x_file_name out varchar2
    );

    function get_employee_name_address_cnb (
        person_id number
    ) return varchar2;

    procedure send_edi_check_cnb (
        p_entrp_id  in number,
        x_file_name out varchar2
    );

    procedure send_er_check_cnb (
        x_file_name out varchar2
    );

    procedure send_hsa_check_cnb (
        p_entrp_id  in number,
        p_status    in varchar2,
        x_file_name out varchar2
    );

    function get_provider_cnb (
        p_claim_id number
    ) return varchar2;

    procedure process_check_result_cnb (
        p_file_name in varchar2
    );

    procedure process_check_result_ack_cnb (
        p_file_name in varchar2
    );

    procedure send_email_on_manual_checks (
        p_file_id number
    );

    procedure send_email_on_edi_checks (
        p_file_id number
    ); -- Added by Joshi for 12770
end pc_check_process;
/


-- sqlcl_snapshot {"hash":"e190ec819876235c9baba32f0e40ac850a7fa9c8","type":"PACKAGE_SPEC","name":"PC_CHECK_PROCESS","schemaName":"SAMQA","sxml":""}