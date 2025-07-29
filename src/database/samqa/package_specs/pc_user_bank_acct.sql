create or replace package samqa.pc_user_bank_acct as
    type varchar2_tbl is
        table of varchar(20) index by binary_integer;
    type number_tbl is
        table of number index by binary_integer;
    type bank_record_row_t is record (
            bank_acc_id                varchar2(10),
            acc_id                     varchar2(10),
            acc_num                    varchar2(20),
            display_name               varchar2(255),         -- changed to 255 by jaggi #9583
            bank_acct_type             varchar2(10),
            account_type               varchar2(100),
            bank_acct_num              varchar2(20),
            bank_routing_num           varchar2(10),
            error_message              varchar2(1000),
            bank_account_usage         varchar2(20),     -- Added by Jaggi #11263
            giac_verify                varchar2(500),    -- Added by Swamy for Ticket#12309
            giac_response              varchar2(500),    -- Added by Swamy for Ticket#12534
            giac_authenticate          varchar2(500),    -- Added by Swamy for Ticket#12534
            status                     varchar2(100),     -- Added by Swamy for Ticket#12534
            status_description         varchar2(500),     -- Added by Swamy for Ticket#12534
            bank_acct_type_description varchar2(50)  -- Added by swamy for Ticket#12662
    );
    type bank_record_t is
        table of bank_record_row_t;

-- added by Joshi for 6322
    type fhra_bank_record_row_t is record (
            bank_acc_id                varchar2(10),
            acc_id                     varchar2(10),
            account_type               varchar2(100),
            acc_num                    varchar2(20),
            display_name               varchar2(255),         -- changed to 255 by jaggi #9583
            bank_routing_num           varchar2(10),
            bank_acct_num              varchar2(20),
            bank_acct_type             varchar2(10),
            bank_acct_type_name        varchar2(100),
            bank_account_usage         varchar2(30),
            bank_account_usage_display varchar2(100), -- Added by Joshi for 9515
            invoice_param_id           number,
            division_code              varchar2(10),
            division_name              varchar2(255),
            bank_status                varchar2(10),            -- Added by Swamy for Ticket#12309
            status_description         varchar2(500),    -- Added by Swamy for Ticket#12309
            giac_verify                varchar2(500),        -- Added by Swamy for Ticket#12309
            business_name              varchar2(500)   -- Added by Joshi for Ticket#12534
    );
    type fhra_bank_record_t is
        table of fhra_bank_record_row_t;
-- Code ends here Joshi - 6322

    function get_bank_details (
        p_acc_num in varchar2
    ) return bank_record_t
        pipelined
        deterministic;

    procedure upsert_bank_acct (
        p_acc_num          in varchar2,
        p_display_name     in varchar2,
        p_bank_acct_type   in varchar2,
        p_bank_routing_num in varchar2,
        p_bank_acct_num    in varchar2,
        p_bank_name        in varchar2,
        p_user_id          in number,
        p_account_type     in varchar2,
        x_bank_acct_id     in out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    );

    procedure insert_user_bank_acct (
        p_acc_num          in varchar2,
        p_display_name     in varchar2,
        p_bank_acct_type   in varchar2,
        p_bank_routing_num in varchar2,
        p_bank_acct_num    in varchar2,
        p_bank_name        in varchar2,
        p_user_id          in number,
        x_bank_acct_id     out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    );

    procedure update_user_bank_acct (
        p_bank_acct_id      in number,
        p_display_name      in varchar2,
        p_bank_routing_num  in varchar2,
        p_bank_acct_num     in varchar2,
        p_bank_name         in varchar2,
        p_bank_account_type in varchar2,
        p_user_id           in number,
        x_return_status     out varchar2,
        x_error_message     out varchar2
    );

    procedure delete_user_bank_acct (
        p_acc_num       in varchar2,
        p_bank_acct_id  in varchar2_tbl,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    function get_user_bank_acct_from_acc_id (
        p_acc_id in number
    ) return number;

    function get_bank_name (
        p_bank_acc_id in number
    ) return varchar2;

    function get_user_bank_acct_from_bank (
        p_acc_id      in number,
        p_account_num in varchar2,
        p_routing_num in varchar2,
        p_bank_name   in varchar2
    ) return number;

    function get_active_bank_acct (
        p_acc_id      in number,
        p_account_num in varchar2,
        p_routing_num in varchar2,
        p_bank_name   in varchar2
    ) return number;

    function get_bank_acct_status (
        p_bank_acct_id in number
    ) return varchar2;

    procedure upload_bank_acct (
        p_file_name in varchar2,
        p_user_id   in number
    );

 -- Added by Joshi for 6322
 -- Added by Joshi 9142 (p_enity_type, p_entity_id)
    function get_fhra_bank_details (
        p_entity_id    in number,
        p_entity_type  in varchar2,
        p_invoice_type in varchar2 default null
    ) return fhra_bank_record_t
        pipelined
        deterministic;

    procedure fhra_upsert_bank_acct (
        p_entrp_id         in number,
        p_acc_num          in varchar2,
        p_display_name     in varchar2,
        p_bank_acct_type   in varchar2,
        p_bank_routing_num in varchar2,
        p_bank_acct_num    in varchar2,
        p_bank_name        in varchar2,
        p_user_id          in number,
        p_account_type     in varchar2,
        p_account_usage    in varchar2,
        p_division_code    in varchar2,
        p_edit_flag        in varchar2,
        p_entity_id        in number    -- Added by Joshi for 9412
        ,
        p_entity_type      in varchar2  -- Added by Joshi for 9412
        ,
        x_bank_acct_id     in number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    );

    procedure fhra_delete_user_bank_acct (
        p_entrp_id         in number,
        p_acc_num          in varchar2,
        p_bank_acct_id     in varchar2_tbl,
        p_invoice_type     in varchar2_tbl,
        p_invoice_param_id in varchar2_tbl,
        p_user_id          in number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    );
-- Code ends here - 6322
-- Added by Joshi for 9142 on 07/23/2020
    procedure insert_bank_account (
        p_entity_id          in number,
        p_entity_type        in varchar2,
        p_display_name       in varchar2,
        p_bank_acct_type     in varchar2,
        p_bank_routing_num   in varchar2,
        p_bank_acct_num      in varchar2,
        p_bank_name          in varchar2,
        p_bank_account_usage in varchar2 default 'ONLINE',
        p_user_id            in number,
        x_bank_acct_id       out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

 -- Added by Swamy for Ticket#9387 on 21/08/2020
    function check_bank_acct (
        p_entity_id          in number,
        p_entity_type        in varchar2,
        p_bank_acct_type     in varchar2,
        p_routing_number     in varchar2,
        p_bank_acct_num      in varchar2,
        p_bank_name          in varchar2,
        p_bank_account_usage in varchar2
    ) -- Added by Joshi for 10431
     return varchar2;

-- Added by Joshi for 10105.
    procedure export_user_bank_upload_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    );

    procedure validate_userbank_upload_data (
        p_batch_number in number,
        p_user_id      in number
    );

    procedure process_user_bank_upload_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    );

    procedure process_user_bank_accounts (
        p_batch_number  in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

 -- Start Added by swmay for ticket#10747
    function get_broker_bank_details (
        p_acc_id        in number,
        p_user_id       in number,
        p_bank_acct_num in varchar2
    ) return bank_record_t
        pipelined
        deterministic;

 --  Added by Jaggi for ticket#10747
    function validate_bank_info (
        p_entity_id       in number,
        p_entity_type     in varchar2 default 'ACCOUNT',
        p_routing_number  in varchar2,
        p_bank_acct_num   in varchar2,
        p_bank_name       in varchar2,
        p_bank_acct_id    in number,
        p_bank_acct_usage in varchar2 default 'ONLINE' -- Added by Swamy for Ticket#12309
    ) return varchar2;

-- Added by Swamy for Ticket#10993(Dev Ticket#10747)
    procedure update_bro_emp_bank_stage (
        p_entrp_id       in number,
        p_batch_number   in number,
        p_user_id        in number,
        p_account_type   in varchar2,
        p_page_validity  in varchar2,
        p_bank_authorize in varchar2,
        p_acct_usage     in varchar2,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    );

-- Added by Jaggi #11262
    procedure remit_insert_bank_account (
        p_entity_id          in number,
        p_entity_type        in varchar2,
        p_display_name       in varchar2,
        p_bank_acct_type     in varchar2,
        p_bank_routing_num   in varchar2,
        p_bank_acct_num      in varchar2,
        p_bank_name          in varchar2,
        p_bank_account_usage in varchar2 default 'COBRA_DISBURSE',
        p_user_id            in number,
        x_bank_acct_id       out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

--  Added by Swamy for Ticket#12058
    function check_duplicate_bank_account (
        p_routing_number    in varchar2,
        p_bank_acct_num     in varchar2,
        p_bank_acct_id      in number,
        p_bank_name         in varchar2,
        p_bank_account_type in varchar2,
        p_acc_id            in number,
        p_ssn               in varchar2 default null,
        p_user_id           in number   -- Added by Swamy for Ticket#12309  
    ) return varchar2;

-- Added by Swamy for 10978. 
    function get_giact_verify_response (
        p_gverify       in varchar2,
        p_gauthenticate in varchar2
    ) return varchar2;

-- Added by Swamy for 10978.
    procedure giac_insert_user_bank_acct (
        p_acc_num          in varchar2,
        p_entity_id        in number      -- Added by Swamy for Ticket#12309
        ,
        p_entity_type      in varchar2    -- Added by Swamy for Ticket#12309
        ,
        p_display_name     in varchar2,
        p_bank_acct_type   in varchar2,
        p_bank_routing_num in varchar2,
        p_bank_acct_num    in varchar2,
        p_bank_name        in varchar2,
        p_business_name    in varchar2,
        p_user_id          in number,
        p_gverify          in varchar2,
        p_gauthenticate    in varchar2,
        p_gresponse        in varchar2,
        p_giact_verify     in varchar2,
        p_bank_status      in varchar2,
        p_auto_pay         in varchar2   -- Added by Swamy for Ticket#12309
        ,
        p_bank_acct_usage  in varchar2   -- Added by Swamy for Ticket#12309
        ,
        p_division_code    in varchar2 default null  -- Added by Swamy for Ticket#12309
        ,
        p_source           in varchar2 default null  -- Added by Swamy for Ticket#12362 (12309)
        ,
        x_bank_acct_id     out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    );

-- Added by Swamy for 10978.
    procedure giac_update_user_bank_acct (
        p_bank_acct_id      in out number,
        p_display_name      in varchar2,
        p_bank_routing_num  in varchar2,
        p_bank_acct_num     in varchar2,
        p_bank_name         in varchar2,
        p_bank_account_type in varchar2,
        p_user_id           in number,
        p_gverify           in varchar2,
        p_gauthenticate     in varchar2,
        p_gresponse         in varchar2,
        p_giact_verify      in varchar2,
        p_bank_status       in varchar2,
        x_return_status     out varchar2,
        x_error_message     out varchar2
    );                                    

-- Added by Swamy for 10978.
    procedure validate_giact_response (
        p_gverify       in varchar2,
        p_gauthenticate in varchar2,
        x_giact_verify  out varchar2,
        x_bank_status   out varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );
-- Added by Swamy for 10978. 
    function check_active_user_bank_acct (
        p_acc_id in number
    ) return number;

-- Added by Swamy for 10978. 
-- For the same tax id(entrp code), check if for the same tax id, if any product has the same active bank account ,if yes then it should not go to giact.It should directly add the account,
-- bcos if the account is already verified by giact and is active then rechecking the same bank details will cost double for sterling.in order to avoid this we need directly add the account without sending to giact.
    function check_active_employer_bank_account (
        p_routing_number    in varchar2,
        p_bank_acct_num     in varchar2,
        p_bank_acct_id      in number,
        p_bank_name         in varchar2,
        p_bank_account_type in varchar2,
        p_entrp_id          in number
    ) return varchar2;  

-- Added by Swamy for 10978. 
-- For the same tax id(entrp code), check if for the same tax id, if any product has the same active bank account ,if yes then it should not go to giact.It should directly add the account,
-- bcos if the account is already verified by giact and is active then rechecking the same bank details will cost double for sterling.in order to avoid this we need directly add the account without sending to giact.
    function check_active_employee_bank_account (
        p_routing_number    in varchar2,
        p_bank_acct_num     in varchar2,
        p_bank_acct_id      in number,
        p_bank_name         in varchar2,
        p_bank_account_type in varchar2,
        p_ssn               in varchar2
    ) return varchar2;

-- Added by Swamy for 10978. 
    function giac_enable_side_navigation (
        p_acc_id in number
    ) return varchar2;

-- Added by Swamy for 10978. 
    procedure validate_giac_bank_details (
        p_bank_routing_num      in varchar2,
        p_bank_acct_num         in varchar2,
        p_bank_acct_id          in number,
        p_bank_name             in varchar2,
        p_bank_account_type     in varchar2,
        p_acc_id                in number,
        p_entrp_id              in number,
        p_ssn                   in varchar2,
        p_entity_type           in varchar2,
        p_user_id               in number       -- Added by Swamy for Ticket#12309
        ,
        p_account_usage         in varchar2 default null   -- Added by Swamy for Ticket#12309
        ,
        p_pay_invoice_online    in varchar2 default 'N'   -- Added by Swamy for Ticket#12309
        ,
        p_source                in varchar2 default null  -- Added by Swamy for Ticket#12309
        ,
        p_duplicate_bank_exists out varchar2,
        p_bank_details_exists   out varchar2,
        p_active_bank_exists    out varchar2,
        x_error_message         out varchar2,
        x_return_status         out varchar2
    );
-- Added by Swamy for Ticket#12309
    function get_bank_acct_id (
        p_entity_id          in number,
        p_entity_type        in varchar2,
        p_bank_acct_num      in varchar2,
        p_bank_name          in varchar2,
        p_bank_routing_num   in varchar2,
        p_bank_account_usage in varchar2,
        p_bank_acct_type     in varchar2
    ) return number;                    

-- Added by Swamy for 10978. 
-- For the same tax id(entrp code), check if for the same tax id, if any product has the same active bank account ,if yes then it should not go to giact.It should directly add the account,
-- bcos if the account is already verified by giact and is active then rechecking the same bank details will cost double for sterling.in order to avoid this we need directly add the account without sending to giact.
    procedure get_active_employer_bank_account (
        p_routing_number    in varchar2,
        p_bank_acct_num     in varchar2,
        p_bank_acct_id      in number,
        p_bank_name         in varchar2,
        p_bank_account_type in varchar2,
        p_entrp_id          in number,
        x_gverify           out varchar2,
        x_gauthenticate     out varchar2,
        x_gresponse         out varchar2,
        x_bank_acct_id      out number,
        x_return_status     out varchar2,
        x_error_message     out varchar2
    );

-- Added by Swamy for 10978. 
-- For the same tax id(entrp code), check if for the same tax id, if any product has the same active bank account ,if yes then it should not go to giact.It should directly add the account,
-- bcos if the account is already verified by giact and is active then rechecking the same bank details will cost double for sterling.in order to avoid this we need directly add the account without sending to giact.
    procedure get_active_employee_bank_account (
        p_routing_number    in varchar2,
        p_bank_acct_num     in varchar2,
        p_bank_acct_id      in number,
        p_bank_name         in varchar2,
        p_bank_account_type in varchar2,
        p_ssn               in varchar2,
        x_gverify           out varchar2,
        x_gauthenticate     out varchar2,
        x_gresponse         out varchar2,
        x_bank_acct_id      out number,
        x_return_status     out varchar2,
        x_error_message     out varchar2
    );

 --Added by Joshi for 12309.(show existing bank accounts based on the invoice type). used in pay_invoice
 -- show bank drop down
    function get_existing_bank_details (
        p_entity_id    in number,
        p_entity_type  in varchar2,
        p_invoice_type in varchar2 default null
    ) return fhra_bank_record_t
        pipelined
        deterministic;       

-- Added by Swamy for Ticket#12309
-- For Pay Now Invoice, the all the Pay now button should be disabled for the employer
-- if there is any pending review/pending documentation status.
    function check_pending_bank_exisits (
        p_entity_id          in number,
        p_entity_type        in varchar2,
        p_bank_account_usage in varchar2
    ) return varchar2;

-- Added by Swamy for Ticket#12534 
    procedure insert_user_bank_acct_staging (
        p_user_bank_acct_stg_id  in number,
        p_entrp_id               in number,
        p_batch_number           in number,
        p_account_type           in varchar2,
        p_acct_usage             in varchar2,
        p_display_name           in varchar2,
        p_bank_acct_type         in varchar2,
        p_bank_routing_num       in varchar2,
        p_bank_acct_num          in varchar2,
        p_bank_name              in varchar2,
        p_validity               in varchar2,
        p_bank_authorize         in varchar2,
        p_user_id                in number,
        p_entity_type            in varchar2,
        p_giac_response          in varchar2,
        p_giac_verify            in varchar2,
        p_giac_authenticate      in varchar2,
        p_bank_acct_verified     in varchar2,
        p_bank_status            in varchar2,
        p_business_name          in varchar2,
        p_giac_verified_response in varchar2,
        p_annual_optional_remit  in varchar2,
        x_user_bank_acct_stg_id  out number,
        x_error_status           out varchar2,
        x_error_message          out varchar2
    );
-- Added by Swamy for Ticket#12534 
    procedure giact_manage_bank_account (
        p_bank_status     in varchar2,
        p_entity_type     in varchar2,
        p_entity_id       in number,
        p_bank_acct_id    in number,
        p_inactive_reason in varchar2,
        p_user_id         in number,
        x_error_status    out varchar2,
        x_error_message   out varchar2
    );
-- Added by Swamy for Ticket#12534 
    procedure giact_insert_bank_account (
        p_entity_id             in number,
        p_entity_type           in varchar2,
        p_display_name          in varchar2,
        p_bank_acct_type        in varchar2,
        p_bank_routing_num      in varchar2,
        p_bank_acct_num         in varchar2,
        p_bank_name             in varchar2,
        p_bank_account_usage    in varchar2 default 'ONLINE',
        p_user_id               in number,
        p_bank_status           in varchar2,
        p_giac_verify           in varchar2,
        p_giac_authenticate     in varchar2,
        p_giac_response         in varchar2,
        p_business_name         in varchar2,
        p_bank_acct_verified    in varchar2,
        p_existing_bank_account in varchar2,
        x_bank_status           out varchar2,
        x_bank_acct_id          out number,
        x_return_status         out varchar2,
        x_error_message         out varchar2
    );

    function check_active_broker_ga_bank_account (
        p_routing_number    in varchar2,
        p_bank_acct_num     in varchar2,
        p_bank_acct_id      in number,
        p_bank_name         in varchar2,
        p_bank_account_type in varchar2,
        p_broker_ga_id      in number
    ) return varchar2;

    function get_bank_acct_num (
        p_bank_acct_id in number
    ) return varchar2;

    type giact_details_record_row_t is record (
            bank_acct_id       number,
            bank_acct_num      varchar2(20),
            giac_authenticate  varchar2(500),
            giac_verify        varchar2(500),
            giac_response      varchar2(500),
            bank_acct_verified varchar2(20)
    );
    type giact_record_t is
        table of giact_details_record_row_t;
    function get_existing_bank_giact_details (
        p_routing_number     in varchar2,
        p_bank_acct_num      in varchar2,
        p_bank_acct_id       in number,
        p_bank_name          in varchar2,
        p_bank_account_type  in varchar2,
        p_ssn                in varchar2,
        p_entity_id          in number,
        p_entity_type        in varchar2,
        p_bank_account_usage in varchar2
    ) return giact_record_t
        pipelined
        deterministic;

    procedure update_giac_details (
        p_entity_id         in number,
        p_entity_type       in varchar2,
        p_bank_acct_id      in number,
        p_gresponse         in varchar2,
        p_giac_verify       in varchar2,
        p_giac_authenticate in varchar2,
        x_return_status     out varchar2,
        x_error_message     out varchar2
    );
-- To display the banner in account summary and in portfolio page that the bank account is in pending documentation
    function check_bank_pending_document (
        p_acc_id    in number,
        p_broker_id in number,
        p_ga_id     in number
    ) return varchar2;

--Added by Joshi for 12396.
    procedure insert_gaict_bank_remind_notif (
        p_bank_acct_id    in number,
        p_bank_age        in number,
        p_notif_type      in varchar2,
        p_email           in varchar2,
        p_notification_id in number,
        p_template_name   in varchar2
    );

    procedure send_giact_bank_remind_notif;

    procedure bank_staging_validations (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_user_id       in number,
        p_acct_usage    in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );
-- Added by Swamy for Ticket#12527
    procedure get_bank_account_usage (
        p_product_type    in varchar2,
        p_account_usage   in varchar2,
        x_bank_acct_usage out varchar2,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

 -- Added by Swamy for Ticket#12527      
    procedure giact_pay_invoice_online (
        p_bank_json     in clob,
        p_entity_id     in number,
        p_invoice_id    in number,
        p_entrp_id      in number,
        p_auto_pay      in varchar2,
        p_division_code in varchar2,
        p_user_id       in number,
        x_bank_acct_id  out number,
        x_bank_status   out varchar2,
        x_bank_message  out varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure giact_cancel_pay_now (
        p_bank_acct_id  in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    function is_active_bank_exist (
        p_entity_type      varchar2,
        p_entity_id        number,
        p_bank_routing_num in varchar2,
        p_bank_acct_num    in varchar2
    ) return varchar2;

-- Added by Swamy for Ticket#12527
    procedure get_entity_details (
        p_acc_id            in number,
        p_product_type      in varchar2,
        p_acct_payment_fees in varchar2,
        x_entity_id         out number,
        x_entity_type       out varchar2,
        x_return_status     out varchar2,
        x_error_message     out varchar2
    );

end pc_user_bank_acct;
/


-- sqlcl_snapshot {"hash":"c99113a4c9fe00814195dea4d716b0bdaa91a199","type":"PACKAGE_SPEC","name":"PC_USER_BANK_ACCT","schemaName":"SAMQA","sxml":""}