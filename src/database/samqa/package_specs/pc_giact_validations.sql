create or replace package samqa.pc_giact_validations as
--   l_api_username        VARCHAR2(100) := 'XBFSR-W120-YTWO-0RIX2-SQ2HL';
--  l_api_password        VARCHAR2(100) := '-D6gfoxzu_jnZufO'; 
--  l_api_endpoint        VARCHAR2(500) := 'https://api.giact.com/VerificationServices/V5/InquiriesWS-5-8.asmx?wsdl'; 

/*PROCEDURE soap_giact_call (p_batch_number     IN NUMBER
                          ,p_entity_id    IN NUMBER
                          ,p_request          IN CLOB 
						  ,x_response        OUT CLOB
                          ,x_return_status   OUT VARCHAR2
                          ,x_error_message   OUT VARCHAR2
                          );
*/
    procedure process_bank_giact (
        p_bank_json     in varchar2,
        p_batch_number  in varchar2,
        p_user_id       in number,
        p_bank_acct_id  out number,
        p_bank_status   out varchar2,
        p_bank_message  out varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure giact_api_request_formation (
        p_entity_id           in number,
        p_entity_type         in varchar2,
        p_acc_num             in varchar2,
        p_bank_routing_number in varchar2,
        p_bank_account_number in varchar2,
        p_bank_account_type   in varchar2,
        p_bank_name           in varchar2,
        p_business_name       in varchar2,
        p_first_name          in varchar2,
        p_last_name           in varchar2,
        p_request_xml         out clob,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    );

    procedure api_response_json_formation (
        p_xml_response       in clob,
        p_giact_verify       out varchar2,
        p_giact_authenticate out varchar2,
        p_giact_response     out varchar2,
        p_json_response      out clob,
        p_api_error_message  out varchar2,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

    procedure insert_api_request_log (
        p_entity_id                   in number,
        p_entity_type                 in varchar2,
        p_enroll_renewal_batch_number in number,
        p_request_xml_data            in clob,
        p_response_xml_data           in clob,
        p_response_json_data          in clob,
        p_user_id                     in number,
        p_website_api_request_id      in number,
        x_return_status               out varchar2,
        x_error_message               out varchar2
    );

    procedure update_invoice_details (
        p_acc_id          in number,
        p_entrp_id        in number,
        p_bank_acct_id    in number,
        p_bank_status     in varchar2,
        p_user_id         in number,
        p_bank_acct_usage in varchar2,
        p_division_code   in varchar2,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

    procedure insert_giact_api_errors (
        p_batch_number in number,
        p_entity_id    in number,
        p_sqlcode      in varchar2,
        p_sqlerrm      in varchar2,
        p_request      in clob
    );

    procedure insert_website_api_requests (
        p_entity_id      in number,
        p_entity_type    in varchar2,
        p_request_body   in clob,
        p_response_body  in clob,
        p_batch_number   in number,
        p_user_id        in number,
        p_processed_flag in varchar2,
        x_request_id     out number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    );

    procedure giact_request_json_formation (
        p_batch_number        in number,
        p_entity_id           in number,
        p_entity_type         in varchar2,
        p_acc_num             in varchar2,
        p_bank_routing_number in varchar2,
        p_bank_account_number in varchar2,
        p_bank_account_type   in varchar2,
        p_bank_name           in varchar2,
        p_business_name       in varchar2,
        p_first_name          in varchar2,
        p_last_name           in varchar2,
        p_bank_acct_id        in number,
        p_json_response       out clob,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    );

-- for enrollment and renewals
/*  PROCEDURE insert_staging_bank_giact(
                              p_bank_json        IN  VARCHAR2
                             ,p_batch_number     IN  VARCHAR2 
                             ,p_entrp_id           IN NUMBER
                             ,p_user_id          IN  NUMBER
                             ,p_User_Bank_acct_stg_Id OUT  NUMBER
                             ,p_bank_status      OUT varchar2
                             ,p_bank_message     OUT varchar2
                             , x_return_status   OUT VARCHAR2
                             , x_error_message   OUT VARCHAR2
                             ) ;
*/
-- for enrollment and renewals
    procedure populate_bank_accounts_staging (
        p_bank_in         in clob,
        p_batch_number    in varchar2,
        p_entity_id       in number,
        p_entity_type     in varchar2,
        p_user_id         in number,
        x_bank_staging_id out number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

    procedure populate_bank_accounts (
        p_batch_number  in varchar2,
        p_entrp_id      in number,
        p_product_type  in varchar2,
        p_user_id       in number,
        p_source        in varchar2,
        x_bank_acct_id  out number,
        x_bank_status   out varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    function get_staging_bank_details (
        p_bank_staging_id in number,
        p_batch_number    in varchar2,
        p_acc_id          in number
    ) return clob;

    procedure update_bank_accounts_staging (
        p_bank_staging_id in number,
        p_acc_id          in number,
        p_batch_number    in number,
        p_user_id         in number,
        p_bank_details    in clob,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

    procedure insert_bank_accounts_staging (
        p_acc_id                 in number,
        p_entrp_id               in number,
        p_bank_details           in clob,
        p_batch_number           in number,
        p_user_id                in number,
        p_website_api_request_id in number,
        p_account_type           in varchar2,
        p_validity               in varchar2,
        x_bank_staging_id        out number,
        x_return_status          out varchar2,
        x_error_message          out varchar2
    );

    procedure update_staging_bank_status (
        p_bank_staging_id in number,
        p_acc_id          in number,
        p_batch_number    in number,
        p_bank_status     in varchar2,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

-- Added by Swamy for Ticket#12698
    procedure populate_giact_renewal_staging (
        p_batch_number         in number,
        p_entrp_id             in number,
        p_user_id              in number,
        p_account_type         in varchar2,
        p_ben_plan_id          in number,
        x_staging_bank_acct_id out number,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    );

end pc_giact_validations;
/


-- sqlcl_snapshot {"hash":"e07b2ab051989461cece37351f32c39c60d00a94","type":"PACKAGE_SPEC","name":"PC_GIACT_VALIDATIONS","schemaName":"SAMQA","sxml":""}