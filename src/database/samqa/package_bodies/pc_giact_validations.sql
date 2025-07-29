create or replace package body samqa.pc_giact_validations as

-- Giac API call using soap 
/*PROCEDURE soap_giact_call (p_batch_number     IN NUMBER
                          ,p_entity_id        IN NUMBER
                          ,p_request          IN CLOB 
						  ,x_response        OUT CLOB
                          ,x_return_status   OUT VARCHAR2
                          ,x_error_message   OUT VARCHAR2
                          )
IS
        l_response             CLOB;
        l_envelope             CLOB;
    --  l_headers APEX_WEB_SERVICE.T_HTTP_HEADER_TAB;
        v_xml                  XMLTYPE;
        v_ItemReferenceId      VARCHAR2(50);
        v_CreatedDate          VARCHAR2(50);
        v_VerificationResponse VARCHAR2(50);
        v_AccountResponseCode  VARCHAR2(100);
        v_BankName             VARCHAR2(100);
        v_sqlcode              VARCHAR2(100);
        v_sqlerrm              VARCHAR2(500);
BEGIN
    pc_log.log_error('pc_giact_validations.soap_giact_call begin ','p_entity_id :='||p_entity_id||' p_request '||p_request);
    apex_web_service.g_request_headers(1).name  := 'Content-Type';
    apex_web_service.g_request_headers(1).value := 'application/soap+xml; charset=utf-8';
    -- Make the SOAP call
    utl_http.set_wallet('file:/home/oracle/apex_wallet');
    l_response := APEX_WEB_SERVICE.MAKE_REST_REQUEST
	              (p_url         => 'https://sandbox.api.giact.com/VerificationServices/V5/InquiriesWS-5-8.asmx?wsdl',
                   p_http_method => 'POST',
                   p_BODY   => p_request
				   );
    dbms_output.put_line(l_response);
    v_xml           :=  XMLTYPE(l_response);
    x_response      := l_response;
    x_error_message := 'Success';
    x_return_status := 'S';

EXCEPTION
    WHEN OTHERS THEN
       -- Log error
       v_sqlcode := SQLCODE;
       v_sqlerrm := sqlerrm;
       x_error_message := 'Error';
       x_return_status := 'E';
       pc_giact_validations.insert_giact_api_errors
              (p_batch_number => p_batch_number
              ,p_entity_id    => p_entity_id
              ,p_sqlcode      => v_sqlcode
              ,p_sqlerrm     => v_sqlerrm
              ,p_request     => p_request
              );
    RAISE;
 END soap_giact_call;
*/
  --Called from php with input all the bank details with json format
  -- Validate the bank details, check for duplicate banks, send to giac and receive the response
  -- store the values in the log table and insert into bank_accounts,
    procedure process_bank_giact (
        p_bank_json     in varchar2,
        p_batch_number  in varchar2,
        p_user_id       in number,
        p_bank_acct_id  out number,
        p_bank_status   out varchar2,
        p_bank_message  out varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

  -- Variables for GIACT API call
        l_request_xml           clob;
        l_response              clob;
        l_json_api_response     clob;
        l_response_code         varchar2(10);
        l_response_xml          xmltype;
 -- l_giac_authenticate     VARCHAR2(10);
  --l_giac_verify           VARCHAR2(10);
  --l_giac_response         CLOB;
        l_json_data             clob := p_bank_json;
        l_return_status         varchar2(1);
        l_bank_status           varchar2(10);
        x_bank_status           varchar2(10);
        x_bank_acct_id          number;
        l_error_message         varchar2(2000);
        x_duplicate_bank_exists varchar2(200);
        x_bank_details_exists   varchar2(200);
        x_active_bank_exists    varchar2(200);
        l_giact_verify          varchar2(200);
        l_giact_authenticate    varchar2(200);
        l_giact_response        varchar2(200);
        l_sqlcode               varchar2(200);
        l_bank_account_type     varchar2(200);
        lc_bank_acct_id         number;
        l_request_id            number;
        l_product_type          varchar2(200);
        x_bank_account_usage    varchar2(200);
        l_entity_id             number;
        l_json_response         clob;
        l_api_error_message     varchar2(2000);
        duplicate_error exception;
        bank_details_exists_error exception;
        erreur exception;
        setup_error exception;
    begin
  -- Parse the JSON data using SQL and insert into the temporary table
        for x in (
            select
                bank_data.*
            from
                    json_table ( l_json_data, '$[*]'
                        columns (
                            entity_id varchar2 ( 100 ) path '$.entity_id',
                            entity_type varchar2 ( 100 ) path '$.entity_type',
                            bank_routing_number varchar2 ( 100 ) path '$.bank_routing_number',
                            bank_acct_num varchar2 ( 100 ) path '$.bank_acct_num',
                            bank_acct_id varchar2 ( 100 ) path '$.bank_acct_id',
                            bank_name varchar2 ( 100 ) path '$.bank_name',
                            display_name varchar2 ( 100 ) path '$.display_name',
                            bank_account_type varchar2 ( 100 ) path '$.bank_account_type',
                            bank_account_usage varchar2 ( 100 ) path '$.bank_account_usage',
                            acc_id varchar2 ( 100 ) path '$.acc_id',
                            acc_num varchar2 ( 100 ) path '$.acc_num',
                            business_name varchar2 ( 100 ) path '$.business_name',
                            first_name varchar2 ( 100 ) path '$.first_name',
                            last_name varchar2 ( 100 ) path '$.last_name',
                            entrp_id varchar2 ( 100 ) path '$.entrp_id',
                            ssn varchar2 ( 100 ) path '$.ssn',
                            user_id varchar2 ( 100 ) path '$.user_id',
                            product_type varchar2 ( 100 ) path '$.product_type',
                            pay_invoice_online varchar2 ( 10 ) path '$.pay_invoice_online',
                            source varchar2 ( 100 ) path '$.source',
                            bank_json varchar2 ( 4000 ) format json path '$'
                        )
                    )
                bank_data
        ) loop
            pc_user_bank_acct.get_bank_account_usage(
                p_product_type    => x.product_type,
                p_account_usage   => x.bank_account_usage,
                x_bank_acct_usage => x_bank_account_usage,
                x_return_status   => l_return_status,
                x_error_message   => l_error_message
            );

            pc_giact_validations.insert_website_api_requests(
                p_entity_id      => x.entity_id,
                p_entity_type    => x.entity_type,
                p_request_body   => p_bank_json,
                p_response_body  => null,
                p_batch_number   => p_batch_number,
                p_user_id        => p_user_id,
                p_processed_flag => 'N',
                x_request_id     => l_request_id,
                x_return_status  => l_return_status,
                x_error_message  => l_error_message
            );

            l_bank_status := null;
            l_entity_id := x.entity_id;
            pc_log.log_error('pc_giact_validations.process_bank_giact calling pc_user_bank_acct.validate_giac_bank_details  ', 'p_bank_json ' || p_bank_json
            );
            pc_log.log_error('pc_giact_validations.process_bank_giact calling pc_user_bank_acct.validate_giac_bank_details  ', 'x.acc_id ' || x.acc_id
            );
            pc_log.log_error('pc_giact_validations.process_bank_giact calling pc_user_bank_acct.validate_giac_bank_details  ', 'x.bank_routing_number '
                                                                                                                               || x.bank_routing_number
                                                                                                                               || ' x.bank_acct_num :='
                                                                                                                               || x.bank_acct_num
                                                                                                                               || ' x.bank_acct_id :='
                                                                                                                               || x.bank_acct_id
                                                                                                                               || 'x.bank_name :='
                                                                                                                               || x.bank_name
                                                                                                                               || 'x.bank_account_type :='
                                                                                                                               || x.bank_account_type
                                                                                                                               || 'x_bank_account_usage :='
                                                                                                                               || x_bank_account_usage
                                                                                                                               || 'x.user_id :='
                                                                                                                               || x.user_id
                                                                                                                               || 'x.entity_type :='
                                                                                                                               || x.entity_type
                                                                                                                               || 'x.ssn  :='
                                                                                                                               || x.ssn
                                                                                                                               ); 
    -- Validate the bank details, check for duplicates and other necessary checkings
            pc_user_bank_acct.validate_giac_bank_details(
                p_bank_routing_num      => x.bank_routing_number,
                p_bank_acct_num         => x.bank_acct_num,
                p_bank_acct_id          => x.bank_acct_id,
                p_bank_name             => x.bank_name,
                p_bank_account_type     => x.bank_account_type,
                p_acc_id                => x.acc_id,
                p_entrp_id              => x.entrp_id,
                p_ssn                   => x.ssn,
                p_entity_type           => x.entity_type,
                p_user_id               => x.user_id,
                p_account_usage         => x_bank_account_usage,
                p_pay_invoice_online    => x.pay_invoice_online,
                p_source                => x.source,
                p_duplicate_bank_exists => x_duplicate_bank_exists,
                p_bank_details_exists   => x_bank_details_exists,
                p_active_bank_exists    => x_active_bank_exists,
                x_error_message         => l_error_message,
                x_return_status         => l_return_status
            );

            pc_log.log_error('pc_giact_validations.process_bank_giact **1 pc_user_bank_acct.validate_giac_bank_details  ', 'l_return_status '
                                                                                                                           || l_return_status
                                                                                                                           || ' x_duplicate_bank_exists :='
                                                                                                                           || x_duplicate_bank_exists
                                                                                                                           || ' x_bank_details_exists :='
                                                                                                                           || x_bank_details_exists
                                                                                                                           || ' x_active_bank_exists :='
                                                                                                                           || x_active_bank_exists
                                                                                                                           );

            if nvl(l_return_status, 'N') <> 'S' then
                raise erreur;
            end if;
            if nvl(x_duplicate_bank_exists, 'N') = 'Y' then
                raise duplicate_error;
            end if;
            if nvl(x_bank_details_exists, '*') in ( 'I', 'D', 'W', 'P', 'E',
                                                    'O' ) then
                raise bank_details_exists_error;
            end if;

        -- If there is already a bank account with Active status, then the same bank details should not go to Giact, instead it should
        -- directly insert the data into bank_accounts table
            if x_active_bank_exists = 'Y' then
                for xx in (
                    select
                        *
                    from
                        table ( pc_user_bank_acct.get_existing_bank_giact_details(
                            p_routing_number     => x.bank_routing_number,
                            p_bank_acct_num      => x.bank_acct_num,
                            p_bank_acct_id       => x.bank_acct_id,
                            p_bank_name          => x.bank_name,
                            p_bank_account_type  => x.bank_account_type,
                            p_ssn                => x.ssn,
                            p_entity_id          => x.entity_id,
                            p_entity_type        => x.entity_type,
                            p_bank_account_usage => x.bank_account_usage
                        ) )
                ) loop
                    if nvl(x_bank_acct_id, 0) = 0 then
                        x_bank_acct_id := pc_user_bank_acct.get_bank_acct_id(
                            p_entity_id          => x.entity_id,
                            p_entity_type        => x.entity_type,
                            p_bank_acct_num      => x.bank_acct_num,
                            p_bank_name          => null,
                            p_bank_routing_num   => x.bank_routing_number,
                            p_bank_account_usage => nvl(x_bank_account_usage, 'ONLINE'),
                            p_bank_acct_type     => null
                        );

                        if nvl(x_bank_acct_id, 0) = 0 then
                            pc_log.log_error('pc_giact_validations.process_bank_giact **1.1 pc_user_bank_acct.validate_giac_bank_details  '
                            , 'xx.bank_acct_verified ' || xx.bank_acct_verified);
				 -- Inserting the details into bank_accounts table
                            pc_user_bank_acct.giact_insert_bank_account(
                                p_entity_id             => x.entity_id,
                                p_entity_type           => x.entity_type,
                                p_display_name          => x.display_name,
                                p_bank_acct_type        => x.bank_account_type,
                                p_bank_routing_num      => lpad(x.bank_routing_number, 9, 0),
                                p_bank_acct_num         => xx.bank_acct_num,
                                p_bank_name             => x.bank_name,
                                p_bank_account_usage    => nvl(x_bank_account_usage, 'ONLINE'),
                                p_user_id               => p_user_id,
                                p_bank_status           => 'A',
                                p_giac_verify           => xx.giac_verify,
                                p_giac_authenticate     => xx.giac_authenticate,
                                p_giac_response         => xx.giac_response,
                                p_business_name         => x.business_name,
                                p_bank_acct_verified    => xx.bank_acct_verified  -- Swamy 12772
                                ,
                                p_existing_bank_account => 'Y',
                                x_bank_status           => x_bank_status,
                                x_bank_acct_id          => x_bank_acct_id,
                                x_return_status         => l_return_status,
                                x_error_message         => l_error_message
                            );

                            if nvl(l_return_status, 'N') <> 'S' then
                                raise erreur;
                            else
                                p_bank_acct_id := x_bank_acct_id;
                                p_bank_status := 'A';
                                p_bank_message := 'Your bank account has been added successfully!';
                            end if;

                        else
                            update bank_accounts
                            set
                                display_name = x.display_name,
                                bank_name = x.bank_name,
                                business_name = x.business_name,
                                last_update_date = sysdate,
                                last_updated_by = p_user_id
                            where
                                    bank_acct_id = x_bank_acct_id
                                and entity_id = x.entity_id
                                and entity_type = x.entity_type;

                            p_bank_acct_id := x_bank_acct_id;
                            p_bank_status := 'A';
                            p_bank_message := 'Your bank account has been added successfully!';
                        end if;

                    end if;
                end loop;
            else
                pc_log.log_error('pc_giact_validations.process_bank_giact pc_giact_validations.giact_api_request_formation', 'x.entity_id '
                                                                                                                             || x.entity_id
                                                                                                                             || ' x.entity_TYPE :='
                                                                                                                             || x.entity_type
                                                                                                                             ); 
           -- Based on the input bank details form the request which would be sent to giac.
                if x.bank_account_type = 'C' then
                    l_bank_account_type := 'Checking';
                else
                    l_bank_account_type := 'Savings';
                end if;

                pc_giact_validations.giact_api_request_formation(
                    p_entity_id           => x.entity_id,
                    p_entity_type         => x.entity_type,
                    p_acc_num             => x.acc_num,
                    p_bank_routing_number => x.bank_routing_number,
                    p_bank_account_number => x.bank_acct_num,
                    p_bank_account_type   => l_bank_account_type,
                    p_bank_name           => x.bank_name,
                    p_business_name       => x.business_name,
                    p_first_name          => x.first_name,
                    p_last_name           => x.last_name,
                    p_request_xml         => l_request_xml,
                    x_return_status       => l_return_status,
                    x_error_message       => l_error_message
                );

                pc_log.log_error('pc_giact_validations.process_bank_giact **1 pc_giact_validations.giact_api_request_formation', 'l_RETURN_STATUS '
                                                                                                                                 || l_return_status
                                                                                                                                 || ' x.entity_TYPE :='
                                                                                                                                 || x.entity_type
                                                                                                                                 );

                if nvl(l_return_status, 'N') <> 'S' then
                    raise erreur;
                end if;
            -- Send the details to giact
                pc_giact_api.soap_giact_call(
                    p_batch_number  => p_batch_number,
                    p_entity_id     => x.entity_id,
                    p_request       => l_request_xml,
                    x_response      => l_response,
                    x_return_status => l_return_status,
                    x_error_message => l_error_message
                );

                pc_log.log_error('pc_giact_validations.process_bank_giact **1 pc_giact_validations.soap_giact_call', 'l_RETURN_STATUS ' || l_return_status
                );
                if nvl(l_return_status, 'N') <> 'S' then
                    raise erreur;
                end if;
            -- If there is a response from giact 
                if l_response is not null then
                -- Convert the xml response from giac to jason format and get the giact values
                    pc_giact_validations.api_response_json_formation(
                        p_xml_response       => l_response,
                        p_giact_verify       => l_giact_verify,
                        p_giact_authenticate => l_giact_authenticate,
                        p_giact_response     => l_giact_response,
                        p_json_response      => l_json_api_response,
                        p_api_error_message  => l_api_error_message,
                        x_return_status      => l_return_status,
                        x_error_message      => l_error_message
                    );

                    pc_log.log_error('pc_giact_validations.process_bank_giact **1 pc_giact_validations.api_response_json_formation', 'l_RETURN_STATUS '
                                                                                                                                   || l_return_status
                                                                                                                                   || ' l_api_error_message :='
                                                                                                                                   || l_api_error_message
                                                                                                                                   );
                    if nvl(l_return_status, 'N') <> 'S' then
                        raise erreur;
                    end if;

                -- log the request sent to giact and response from giact
                    pc_giact_validations.insert_api_request_log(
                        p_entity_id                   => x.entity_id,
                        p_entity_type                 => x.entity_type,
                        p_enroll_renewal_batch_number => p_batch_number,
                        p_request_xml_data            => l_request_xml,
                        p_response_xml_data           => l_response,
                        p_response_json_data          => l_json_api_response,
                        p_user_id                     => p_user_id,
                        p_website_api_request_id      => l_request_id,
                        x_return_status               => l_return_status,
                        x_error_message               => l_error_message
                    );

                    pc_log.log_error('pc_giact_validations.process_bank_giact **1 pc_giact_validations.insert_api_request_log', 'l_RETURN_STATUS ' || l_return_status
                    );
                    if nvl(l_return_status, 'N') <> 'S' then
                        raise erreur;
                    end if;
                -- Get the bank status based on the response from giact
                    pc_user_bank_acct.validate_giact_response(
                        p_gverify       => l_giact_verify,
                        p_gauthenticate => l_giact_authenticate,
                        x_giact_verify  => l_response_code,
                        x_bank_status   => l_bank_status,
                        x_return_status => l_return_status,
                        x_error_message => l_error_message
                    );

                    pc_log.log_error('pc_giact_validations.process_bank_giact **1.1 ', 'l_bank_status :='
                                                                                       || l_bank_status
                                                                                       || ' l_error_message :='
                                                                                       || l_error_message);
                    p_bank_status := l_bank_status;
                    p_bank_message := l_error_message;
                    pc_log.log_error('pc_giact_validations.process_bank_giact **1 pc_giact_validations.validate_giact_response', 'l_bank_status '
                                                                                                                                 || l_bank_status
                                                                                                                                 || ' l_return_status :='
                                                                                                                                 || l_return_status
                                                                                                                                 );
                    if nvl(l_return_status, 'S') not in ( 'S', 'P', 'R' ) then
                        raise erreur;
                    end if;

                    if l_response_code = 'R' then
                        raise setup_error;
                    end if;
                -- Insert the bank details along with giact details into bank_accounts table

                    pc_user_bank_acct.giact_insert_bank_account(
                        p_entity_id             => x.entity_id,
                        p_entity_type           => x.entity_type,
                        p_display_name          => x.display_name,
                        p_bank_acct_type        => x.bank_account_type,
                        p_bank_routing_num      => lpad(x.bank_routing_number, 9, 0),
                        p_bank_acct_num         => x.bank_acct_num,
                        p_bank_name             => x.bank_name,
                        p_bank_account_usage    => nvl(x_bank_account_usage, 'ONLINE'),
                        p_user_id               => p_user_id,
                        p_bank_status           => l_bank_status,
                        p_giac_verify           => l_giact_verify,
                        p_giac_authenticate     => l_giact_authenticate,
                        p_giac_response         => l_giact_response,
                        p_business_name         => x.business_name,
                        p_bank_acct_verified    => 'Y',
                        p_existing_bank_account => 'N',
                        x_bank_status           => x_bank_status,
                        x_bank_acct_id          => lc_bank_acct_id,
                        x_return_status         => l_return_status,
                        x_error_message         => l_error_message
                    );

                    if nvl(l_return_status, 'N') <> 'S' then
                        raise erreur;
                    end if;
                    pc_giact_validations.giact_request_json_formation(
                        p_batch_number        => p_batch_number,
                        p_entity_id           => x.entity_id,
                        p_entity_type         => x.entity_type,
                        p_acc_num             => x.acc_num,
                        p_bank_routing_number => x.bank_routing_number,
                        p_bank_account_number => x.bank_acct_num,
                        p_bank_account_type   => l_bank_account_type,
                        p_bank_name           => x.bank_name,
                        p_business_name       => x.business_name,
                        p_first_name          => x.first_name,
                        p_last_name           => x.last_name,
                        p_bank_acct_id        => lc_bank_acct_id,
                        p_json_response       => l_json_response,
                        x_return_status       => l_return_status,
                        x_error_message       => l_error_message
                    );

                    update website_api_requests
                    set
                        response_body = l_json_response,
                        processed_flag = 'Y'
                    where
                        request_id = l_request_id;

                    p_bank_acct_id := lc_bank_acct_id;
                end if;

            end if;

        end loop;

        x_error_message := 'Your bank account has been added successfully!';
        x_return_status := 'S';
    exception
        when erreur then
            x_error_message := l_error_message;
            x_return_status := 'E';
            pc_log.log_error('pc_giact_validations.process_bank_giact exception erreur ', 'x_error_message ' || x_error_message);
        when setup_error then
            x_return_status := 'E';
            pc_log.log_error('pc_giact_validations.process_bank_giact exception setup_error', x_error_message);
        when duplicate_error then
            x_error_message := l_error_message;
            x_return_status := 'E';
            pc_log.log_error('pc_giact_validations.process_bank_giact exception duplicate_error ', 'x_error_message ' || x_error_message
            );
        when bank_details_exists_error then
            x_error_message := l_error_message;
            x_return_status := 'E';
            pc_log.log_error('pc_giact_validations.process_bank_giact exception BANK_DETAILS_EXISTS_error ', 'x_error_message ' || x_error_message
            );
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_giact_validations.process_bank_giact exception others ', 'x_error_message '
                                                                                          || x_error_message
                                                                                          || dbms_utility.format_error_backtrace);
            l_sqlcode := sqlcode;
            pc_giact_validations.insert_giact_api_errors(
                p_batch_number => p_batch_number,
                p_entity_id    => l_entity_id,
                p_sqlcode      => l_sqlcode,
                p_sqlerrm      => x_error_message,
                p_request      => l_request_xml
            );

    end process_bank_giact;

-- Based on the input bank details form the request to be sent to giact
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
    ) as

        l_response              clob;
        l_request               clob;
        l_request_header        clob;
        l_request_middle        clob;
        l_request_tail          clob;
        v_xml                   xmltype;
        v_itemreferenceid       varchar2(50);
        v_createddate           varchar2(50);
        v_verificationresponse  varchar2(50);
        v_accountresponsecode   varchar2(100);
        v_accountresponsecode_1 varchar2(100);
        v_customerresponsecode  varchar2(100);
        v_bankname              varchar2(100);
        v_json_bank_details     clob;
        l_pers_id               number;
    begin
        for j in (
            select
                pers_id
            from
                account
            where
                    acc_id = p_entity_id
                and p_entity_type = 'ACCOUNT'   -- Added for 12766, chances of broker id and acc id for an employee might be same number. 
        ) loop
            l_pers_id := j.pers_id;
        end loop;

        l_request_header := '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
  <soap12:Header>
    <AuthenticationHeader xmlns="http://api.giact.com/verificationservices/v5">
      <ApiUsername>'
                            || pc_giact_api.l_api_username
                            || '</ApiUsername>
      <ApiPassword>'
                            || pc_giact_api.l_api_password
                            || '</ApiPassword>
    </AuthenticationHeader>
  </soap12:Header>
  <soap12:Body>
    <PostInquiry xmlns="http://api.giact.com/verificationservices/v5">
      <Inquiry>
        <UniqueId>'
                            || p_acc_num
                            || '</UniqueId>
        <Check>
          <RoutingNumber>'
                            || p_bank_routing_number
                            || '</RoutingNumber>
          <AccountNumber>'
                            || p_bank_account_number
                            || '</AccountNumber>
          <AccountType>'
                            || p_bank_account_type
                            || '</AccountType>
          <BankName>'
                            || p_bank_name
                            || '</BankName>
        </Check>';

        pc_log.log_error('send_giact_bank_remind_notif;l_pers_id  ', l_pers_id
                                                                     || ' p_business_name :='
                                                                     || p_business_name);
        if nvl(l_pers_id, 0) <> 0 then
            l_request_middle := '<Customer>
              <FirstName>'
                                || p_first_name
                                || '</FirstName>
              <LastName>'
                                || p_last_name
                                || '</LastName>
            </Customer>';
        else
            l_request_middle := '<Customer>
              <BusinessName>'
                                || p_business_name
                                || '</BusinessName>
            </Customer>';
        end if;

        l_request_tail := '<GVerifyEnabled>true</GVerifyEnabled>
        <GAuthenticateEnabled>true</GAuthenticateEnabled>
      </Inquiry>
    </PostInquiry>
  </soap12:Body>
</soap12:Envelope>';
        p_request_xml := l_request_header
                         || l_request_middle
                         || l_request_tail;
        x_error_message := 'Success';
        x_return_status := 'S';
    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_giact_validations.giact_api_request_formation exception others ', 'x_error_message ' || x_error_message
            );
    end giact_api_request_formation;

-- Convert the response from giact to json format and get the required giact information 
    procedure api_response_json_formation (
        p_xml_response       in clob,
        p_giact_verify       out varchar2,
        p_giact_authenticate out varchar2,
        p_giact_response     out varchar2,
        p_json_response      out clob,
        p_api_error_message  out varchar2,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is

        l_response              clob;
        l_request               clob;
        l_request_header        clob;
        l_request_middle        clob;
        l_request_tail          clob;
        v_xml                   xmltype;
        v_itemreferenceid       varchar2(50);
        v_createddate           varchar2(50);
        v_verificationresponse  varchar2(50);
        v_accountresponsecode   varchar2(100);
        v_accountresponsecode_1 varchar2(100);
        v_customerresponsecode  varchar2(100);
        v_bankname              varchar2(100);
        v_api_error_message     varchar2(2000);
        v_json_bank_details     clob;
        l_pers_id               number;
    begin
        pc_log.log_error('api_response_json_formation **2 p_xml_response ', p_xml_response);
        select
            itemreferenceid,
            createddate,
            verificationresponse,
            replace(accountresponsecode, '_', '') accountresponsecode,
            bankname,
            customerresponsecode,
            errormessage
        into
            v_itemreferenceid,
            v_createddate,
            v_verificationresponse,
            v_accountresponsecode,
            v_bankname,
            v_customerresponsecode,
            v_api_error_message
        from
            xmltable ( xmlnamespaces ( 'http://www.w3.org/2003/05/soap-envelope' as "soap",  -- SOAP Namespace
             'http://api.giact.com/verificationservices/v5' as "ns" -- API Namespace
             ),
            '/soap:Envelope/soap:Body/ns:PostInquiryResponse/ns:PostInquiryResult'
                    passing xmltype(p_xml_response)
                columns
                    itemreferenceid varchar2(50) path 'ns:ItemReferenceId',
                    createddate varchar2(50) path 'ns:CreatedDate',
                    verificationresponse varchar2(50) path 'ns:VerificationResponse',
                    accountresponsecode varchar2(10) path 'ns:AccountResponseCode',
                    bankname varchar2(100) path 'ns:BankName',
                    customerresponsecode varchar2(100) path 'ns:CustomerResponseCode',
                    errormessage varchar2(100) path 'ns:ErrorMessage'
            );

        pc_log.log_error('api_response_json_formation **1 p_xml_response := ', p_xml_response);
        pc_log.log_error('api_response_json_formation **1 v_AccountResponseCode ', v_accountresponsecode);
        select
            (
                json_object(
                    key 'ITEMREFERENCEID' value v_itemreferenceid,
                    key 'VERIFICATIONRESPONSE' value v_verificationresponse,
                    key 'ACCOUNTRESPONSECODE' value v_accountresponsecode,
                    key 'BANKNAME' value v_bankname,
                    key 'CUSTOMERRESPONSECODE' value v_customerresponsecode,
                            key 'ERRORMESSAGE' value v_api_error_message
                )
            ) v_bank_details
        into v_json_bank_details
        from
            dual;

        p_json_response := v_json_bank_details;
        p_giact_verify := v_accountresponsecode;
        p_giact_authenticate := v_customerresponsecode;
        p_giact_response := v_verificationresponse;
        p_api_error_message := v_api_error_message;
        x_error_message := 'Success';
        x_return_status := 'S';
    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_giact_validations.api_response_json_formation exception others ', 'x_error_message ' || x_error_message
            );
    end api_response_json_formation;

 -- logging the details      
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
    ) is
        pragma autonomous_transaction;
    begin
        insert into api_request_log (
            request_log_id,
            entity_id,
            entity_type,
            enroll_renewal_batch_number,
            request_xml_data,
            response_xml_data,
            response_json_data,
            api_name,
            request_timestamp,
            created_by,
            website_api_request_id
        ) values ( request_log_seq.nextval,
                   p_entity_id,
                   p_entity_type,
                   p_enroll_renewal_batch_number,
                   p_request_xml_data,
                   p_response_xml_data,
                   p_response_json_data,
                   'GIACT',
                   systimestamp,
                   p_user_id,
                   p_website_api_request_id );

        x_error_message := 'Success';
        x_return_status := 'S';
        commit;
    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_giact_validations.insert_api_request_log exception others ', 'x_error_message ' || x_error_message);
    end insert_api_request_log;

-- updatinf the invoice parameters and scheduler details
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
    ) is
        l_account_type    varchar2(100);
        l_bank_usage_type varchar2(100);
    begin
        for x in (
            select
                account_type
            from
                account
            where
                    acc_id = p_acc_id
                and entrp_id is not null
        ) loop
            pc_log.log_error('pc_giact_validations.update_invoice_details', 'X.ACCOUNT_TYPE := '
                                                                            || x.account_type
                                                                            || ' p_bank_acct_id :='
                                                                            || p_bank_acct_id
                                                                            || ' p_bank_status :='
                                                                            || p_bank_status
                                                                            || ' p_acc_id :='
                                                                            || p_acc_id
                                                                            || ' p_bank_acct_usage :='
                                                                            || p_bank_acct_usage
                                                                            || ' P_DIVISION_CODE :='
                                                                            || p_division_code
                                                                            || ' l_Account_type :='
                                                                            || l_account_type);

            if
                p_bank_acct_id is not null
                and p_bank_status = 'A'
            then
                if x.account_type = 'HSA' then
                    for s in (
                        select
                            scheduler_id
                        from
                            scheduler_master
                        where
                                acc_id = p_acc_id
                            and ( ( recurring_flag = 'N'
                                    and payment_start_date >= trunc(sysdate)
                                    and nvl(status, 'A') in ( 'A', 'P' ) )
                                  or ( recurring_flag = 'Y'
                                       and payment_end_date >= trunc(sysdate)
                                       and nvl(status, 'A') = 'A' ) )
                    ) loop
                        pc_log.log_error('giact_integrate_bank_details', 'scheduler_id: ' || s.scheduler_id);
                        update scheduler_master
                        set
                            bank_acct_id = p_bank_acct_id,
                            note = nvl(note, ' ')
                                   || ' Bank account changed online on '
                                   || to_char(sysdate, 'mm/dd/yyyy')
                                   || ' by username '
                                   || pc_users.get_user_name(p_user_id),
                            last_updated_date = sysdate,
                            last_updated_by = p_user_id
                        where
                                scheduler_id = s.scheduler_id
                            and payment_method = 'ACH'
                            and amount > 0;

                        update ach_transfer
                        set
                            bank_acct_id = p_bank_acct_id,
                            last_update_date = sysdate,
                            last_updated_by = p_user_id
                        where
                                scheduler_id = s.scheduler_id
                            and status in ( 1, 2 );

                    end loop;

                elsif x.account_type in ( 'FSA', 'HRA', 'COBRA' ) then
                 -- Invoice_parameters, the invoice type is stored as FEE,CLAIM,FUNDING. but in bank_accounts the bank acct usage is stored as INVOICE,CLAIMS,FUNDING.
                    if upper(p_bank_acct_usage) = 'INVOICE' then
                        l_bank_usage_type := 'FEE';
                    elsif upper(p_bank_acct_usage) = 'CLAIMS' then
                        l_bank_usage_type := 'CLAIM';
                    elsif upper(p_bank_acct_usage) = 'FUNDING' then
                        l_bank_usage_type := 'FUNDING';
                    else
                     -- For Employee sidenav add/update bank account, the p_bank_acct_usage will be passed as NULL, and it should be stored as ONLINE.
                        l_bank_usage_type := nvl(
                            upper(p_bank_acct_usage),
                            'ONLINE'
                        );
                    end if;

                    update invoice_parameters
                    set
                        payment_method = 'DIRECT_DEPOSIT',
                        autopay = 'Y',
                        bank_acct_id = p_bank_acct_id,
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                            entity_type = 'EMPLOYER'
                        and entity_id = p_entrp_id
                        and invoice_type = l_bank_usage_type
                        and nvl(division_code, '*') = nvl(p_division_code,
                                                          nvl(division_code, '*'))
                        and product_type = l_account_type
                        and status = 'A';

                end if;

            end if;

        end loop;

        for x in (
            select
                acc_id
            from
                account a,
                person  p
            where
                    acc_id = p_acc_id
                and a.pers_id = p.pers_id
                and a.account_type = 'COBRA'
                and p.person_type = 'QB'
        ) loop
            pc_log.log_error('giact_integrate_bank_details', ' X.ACC_ID := '
                                                             || x.acc_id
                                                             || ' p_bank_acct_id :='
                                                             || p_bank_acct_id
                                                             || ' p_bank_status :='
                                                             || p_bank_status
                                                             || ' X.ACC_ID :='
                                                             || x.acc_id
                                                             || 'p_bank_acct_id :='
                                                             || p_bank_acct_id);

            if
                x.acc_id is not null
                and p_bank_acct_id is not null
                and p_bank_status = 'A'
            then
                update bank_accounts
                set
                    bank_account_usage = 'INVOICE'
                where
                        bank_acct_id = p_bank_acct_id
                    and entity_id = x.acc_id
                    and entity_type = 'ACCOUNT';

            end if;

        end loop;

    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_giact_validations.update_invoice_details exception others ', 'x_error_message ' || x_error_message);
    end update_invoice_details;

    procedure insert_giact_api_errors (
        p_batch_number in number,
        p_entity_id    in number,
        p_sqlcode      in varchar2,
        p_sqlerrm      in varchar2,
        p_request      in clob
    ) is
        pragma autonomous_transaction;
    begin
        insert into giact_api_errors (
            batch_number,
            error_code,
            error_message,
            error_backtrace,
            error_timestamp,
            request_data,
            entity_id
        ) values ( p_batch_number,
                   p_sqlcode,
                   p_sqlerrm,
                   dbms_utility.format_error_backtrace(),
                   systimestamp,
                   p_request,
                   p_entity_id );

        commit;
    exception
        when others then
            pc_log.log_error('pc_giact_validations.insert_giact_api_errors exception others ', 'x_error_message ' || sqlerrm);
    end insert_giact_api_errors;

 -- logging the details      
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
    ) is
        pragma autonomous_transaction;
    begin
        pc_log.log_error('pc_giact_validations.insert_website_api_requests INSERT INTO website_api_requests ', 'begin p_batch_number ' || p_batch_number
        );
        insert into website_api_requests (
            request_id,
            request_type,
            request_method,
            request_body,
            response_body,
            entity_id,
            entity_type,
            batch_number,
            processed_flag,
            created_by,
            creation_date
        ) values ( website_api_requests_seq.nextval,
                   'BANK_ACCOUNT',
                   'GIACT',
                   p_request_body,
                   p_response_body,
                   p_entity_id,
                   p_entity_type,
                   p_batch_number,
                   p_processed_flag,
                   p_user_id,
                   sysdate ) returning request_id into x_request_id;

        x_error_message := 'Success';
        x_return_status := 'S';
        commit;
    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_giact_validations.insert_website_api_requests exception others ', 'x_error_message ' || x_error_message
            );
    end insert_website_api_requests;

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
    ) is
        v_json_bank_details clob;
    begin
        select
            (
                json_object(
                    key 'BATCH_NUMBER' value p_batch_number,
                    key 'ENTITY_ID' value p_entity_id,
                    key 'ENTITY_TYPE' value p_entity_type,
                    key 'ACC_NUM' value p_acc_num,
                    key 'BANK_ROUTING_NUMBER' value p_bank_routing_number,
                            key 'BANK_ACCOUNT_NUMBER' value p_bank_account_number,
                    key 'BANK_ACCOUNT_TYPE' value p_bank_account_type,
                    key 'BANK_NAME' value p_bank_name,
                    key 'BUSINESS_NAME' value p_business_name,
                    key 'FIRST_NAME' value p_first_name,
                            key 'LAST_NAME' value p_last_name,
                    key 'BANK_ACCT_ID' value p_bank_acct_id
                )
            ) v_bank_details
        into v_json_bank_details
        from
            dual;

        p_json_response := v_json_bank_details;
        x_error_message := 'Success';
        x_return_status := 'S';
    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_giact_validations.giact_request_json_formation exception others ', 'x_error_message ' || x_error_message
            );
    end giact_request_json_formation;

-- Insert the bank details to user_bank_Acct_staging table.
    procedure populate_bank_accounts_staging (
        p_bank_in         in clob,
        p_batch_number    in varchar2,
        p_entity_id       in number,
        p_entity_type     in varchar2,
        p_user_id         in number,
        x_bank_staging_id out number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is

  -- Variables for GIACT API call
        l_request_xml                clob;
        l_response                   clob;
        l_json_api_response          clob;
        l_response_code              varchar2(10);
        l_response_xml               xmltype;
        l_json_data                  clob := p_bank_in;
        l_return_status              varchar2(1);
        lc_return_status             varchar2(1);
        l_bank_status                varchar2(10);
        x_bank_status                varchar2(10);
        x_bank_acct_id               number;
        l_error_message              varchar2(2000);
        lc_error_message             varchar2(2000);
        x_duplicate_bank_exists      varchar2(200);
        x_bank_details_exists        varchar2(200);
        x_active_bank_exists         varchar2(200);
        l_giact_verify               varchar2(200);
        l_giact_authenticate         varchar2(200);
        l_giact_response             varchar2(200);
        l_sqlcode                    varchar2(200);
        l_bank_account_type          varchar2(200);
        l_api_error_message          varchar2(2000);
        l_account_type               varchar2(20);
        l_user_bank_acct_stg_id      number;
        lc_bank_acct_id              number;
        l_entity_id                  number;
        l_request_id                 number;
        l_bank_staging_id            number;
        l_edit_bank                  varchar2(1);
        l_json_response              clob;
        l_previous_bank_details      clob;
        v_validate_giac_bank_details clob;
        jobj                         json_object_t;
        duplicate_error exception;
        bank_details_exists_error exception;
        erreur exception;
        setup_error exception;
    begin
   /*
    -- Below is the details of the Giact Flow.
    website_api_request => Log Table to store the deatils of the bank sent as json. This is only a Log table and all the records in this table is not necessarly sent to bank_Accounts table.
                        => Only records which are in user_bank_Acct_staging is sent to bank_Accounts table.
    user_bank_Acct_staging => Staging table to store the bank deatils in json format in column bank_Details. All the records in this table would be sent to bank_Accounts table.
	                       => when the record in sent to bank_account table then the processed_flag will be set to Y.
	api_request_log     => Log table which logs the details of the bank details sent to GIACT and the response received from GIACT.
	Please note := The link between all the 3 tables would be request_id of website_api_request. The corresponding column name in user_bank_Acct_staging and api_request_log is website_api_request_id.

	1) When user enters the data from online the data will be inserted into website_api_request
	2) In case of Edit of bank deatils,Check if the user has changed only bank name/bank account type/bank account usage. IN case of only these change then the details should not go to GIACT again.
	3) In case of Edit,If there is change in bank account number/routing number then the details should again go GIACT.
	4) Check if the bank account number/bank routing number is already present in Active status for the same EIN, if yes then do not send the details to GIACT, instead add the same bank details as Active status.
	5) If no, then Send the details to GIACT logging the bank details to api_request_log and also log the response back from GIACT to api_request_log table.
	6) If case of Pending bank then the status would be P(Pending for Documentaion), When the user uploads the document then the status would change to W(Pending Review).
    7) During final submit procedure populate_bank_Accounts is called which will insert the data from user_bank_Acct_staging to Bank_accounts Table. The processed Flag will be changed to Y.
    8) Update the online_compliance_staging table with the Bank_Acct_ID/Bank_Acct_num which is used during enroll/renewal invoice generation.
	9) In case of W/P status, the Account staus will change to 11 (Pending Bank Verification).'
   10) For W/P status SAM User will approve the record in page 461(Manage GIACT Bank Accounts) which will change the Account status 3 (Pending Activation).	
	*/


  -- Parse the JSON data using SQL and insert into the temporary table
        for x in (
            select
                bank_data.*
            from
                    json_table ( l_json_data, '$[*]'
                        columns (
                            entity_id varchar2 ( 100 ) path '$.entity_id',
                            entity_type varchar2 ( 100 ) path '$.entity_type',
                            bank_routing_number varchar2 ( 100 ) path '$.bank_routing_number',
                            bank_acct_num varchar2 ( 100 ) path '$.bank_acct_num',
                            bank_acct_id varchar2 ( 100 ) path '$.bank_acct_id',
                            bank_name varchar2 ( 100 ) path '$.bank_name',
                            display_name varchar2 ( 100 ) path '$.display_name',
                            bank_account_type varchar2 ( 100 ) path '$.bank_account_type',
                            bank_account_usage varchar2 ( 100 ) path '$.bank_account_usage',
                            acc_id varchar2 ( 100 ) path '$.acc_id',
                            acc_num varchar2 ( 100 ) path '$.acc_num',
                            business_name varchar2 ( 100 ) path '$.business_name',
                            first_name varchar2 ( 100 ) path '$.first_name',
                            last_name varchar2 ( 100 ) path '$.last_name',
                            entrp_id varchar2 ( 100 ) path '$.entrp_id',
                            ssn varchar2 ( 100 ) path '$.ssn',
                            user_id varchar2 ( 100 ) path '$.user_id',
                            account_usage varchar2 ( 100 ) path '$.account_usage',
                            pay_invoice_online varchar2 ( 10 ) path '$.pay_invoice_online',
                            source varchar2 ( 100 ) path '$.source',
                            bank_staging_id varchar2 ( 100 ) path '$.bank_staging_id',
                            annual_optional_remit varchar2 ( 100 ) path '$.annual_optional_remit',
                            account_type varchar2 ( 100 ) path '$.account_type',
                            fees_payment_flag varchar2 ( 100 ) path '$.fees_payment_flag',
                            bank_json varchar2 ( 4000 ) format json path '$'
                        )
                    )
                bank_data
        ) loop
            jobj := null;
            if upper(x.fees_payment_flag) = 'ACH' then
                v_validate_giac_bank_details := p_bank_in;
                l_account_type := pc_account.get_account_type(x.acc_id);
                pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging calling pc_user_bank_acct.insert_website_api_requests  '
                , 'p_bank_in '
                                                                                                                                              || p_bank_in
                                                                                                                                              || ' x.bank_staging_id :='
                                                                                                                                              || x.bank_staging_id
                                                                                                                                              )
                                                                                                                                              ; 
        -- Log the details into website_api_request table
                pc_giact_validations.insert_website_api_requests(
                    p_entity_id      => x.entity_id,
                    p_entity_type    => x.entity_type,
                    p_request_body   => p_bank_in,
                    p_response_body  => null,
                    p_batch_number   => p_batch_number,
                    p_user_id        => p_user_id,
                    p_processed_flag => 'N',
                    x_request_id     => l_request_id,
                    x_return_status  => l_return_status,
                    x_error_message  => l_error_message
                );

                l_bank_status := null;
                l_entity_id := x.entity_id;

    -- in case of edit, the staging id would exists, fetech the bank details of that staging id and check if only bank name/bank account usage/bank account type is changed.
	-- If only these are changed then no need to send the details agin to GIACT.
                l_previous_bank_details := pc_giact_validations.get_staging_bank_details(
                    p_bank_staging_id => x.bank_staging_id,
                    p_batch_number    => p_batch_number,
                    p_acc_id          => x.acc_id
                );

                pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging calling pc_user_bank_acct.insert_website_api_requests  '
                ,
                                 'x.bank_staging_id '
                                 || x.bank_staging_id
                                 || ' JSON_VALUE(l_previous_bank_details,''$.bank_routing_number'')  :='
                                 || json_value(l_previous_bank_details, '$.bank_routing_number')
                                 || ' x.bank_routing_number :='
                                 || x.bank_routing_number
                                 || ' JSON_VALUE(l_previous_bank_details,''$.bank_acct_num'') :='
                                 || json_value(l_previous_bank_details, '$.bank_acct_num')
                                 || ' x.bank_acct_num :='
                                 || x.bank_acct_num);

                if
                    x.bank_staging_id is not null
                    and json_value(l_previous_bank_details, '$.bank_routing_number') = x.bank_routing_number
                    and json_value(l_previous_bank_details, '$.bank_acct_num') = x.bank_acct_num
                then
                    l_edit_bank := 'Y';
                    jobj := json_object_t.parse(l_previous_bank_details);
                    if json_value(l_previous_bank_details, '$.bank_name') <> x.bank_name then
                        jobj.put('bank_name', x.bank_name);
                        jobj.put('display_name', x.display_name);
                    end if;

                    if json_value(l_previous_bank_details, '$.bank_account_type') <> x.bank_account_type then
                        jobj.put('bank_account_type', x.bank_account_type);
                    end if;

                    if json_value(l_previous_bank_details, '$.bank_account_usage') <> x.bank_account_usage then
                        jobj.put('bank_account_usage', x.bank_account_usage);
                    end if;

            -- Update the user_bank_Acct_staging table.
                    pc_giact_validations.update_bank_accounts_staging(
                        p_bank_staging_id => x.bank_staging_id,
                        p_acc_id          => x.acc_id,
                        p_batch_number    => p_batch_number,
                        p_user_id         => p_user_id,
                        p_bank_details    => jobj.to_clob(),
                        x_return_status   => l_return_status,
                        x_error_message   => l_error_message
                    );

                    if nvl(l_return_status, 'N') <> 'S' then
                        raise erreur;
                    end if;
                    l_bank_staging_id := x.bank_staging_id;
                else
                    l_edit_bank := 'N';
    -- Delete the staging bank details 
                    delete from user_bank_acct_staging
                    where
                        user_bank_acct_stg_id = x.bank_staging_id;

                    pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging calling pc_user_bank_acct.validate_giac_bank_details  '
                    , 'x.acc_id '
                                                                                                                                                 || x.acc_id
                                                                                                                                                 || ' l_request_id :='
                                                                                                                                                 || l_request_id
                                                                                                                                                 )
                                                                                                                                                 ; 

	-- Insert the New details into user_bank_Acct_staging table 
                    pc_giact_validations.insert_bank_accounts_staging(
                        p_acc_id                 => x.acc_id,
                        p_entrp_id               => x.entrp_id,
                        p_bank_details           => p_bank_in,
                        p_batch_number           => p_batch_number,
                        p_user_id                => p_user_id,
                        p_website_api_request_id => l_request_id,
                        p_account_type           => l_account_type,
                        p_validity               => 'V',
                        x_bank_staging_id        => l_bank_staging_id,
                        x_return_status          => l_return_status,
                        x_error_message          => l_error_message
                    );

    -- Check the basic vaidations in staging table 
                    pc_user_bank_acct.bank_staging_validations(
                        p_batch_number  => p_batch_number,
                        p_entrp_id      => p_entity_id,
                        p_user_id       => p_user_id,
                        p_acct_usage    => x.account_usage,
                        x_return_status => l_return_status,
                        x_error_message => l_error_message
                    );

                    if nvl(l_return_status, 'N') <> 'S' then
                        raise erreur;
                    end if;

    -- Validate the bank details, check for duplicates and other necessary checkings
                    pc_user_bank_acct.validate_giac_bank_details(
                        p_bank_routing_num      => x.bank_routing_number,
                        p_bank_acct_num         => x.bank_acct_num,
                        p_bank_acct_id          => x.bank_acct_id,
                        p_bank_name             => x.bank_name,
                        p_bank_account_type     => x.bank_account_type,
                        p_acc_id                => x.entity_id,
                        p_entrp_id              => x.entrp_id,
                        p_ssn                   => x.ssn,
                        p_entity_type           => x.entity_type,
                        p_user_id               => x.user_id,
                        p_account_usage         => x.account_usage,
                        p_pay_invoice_online    => x.pay_invoice_online,
                        p_source                => x.source,
                        p_duplicate_bank_exists => x_duplicate_bank_exists,
                        p_bank_details_exists   => x_bank_details_exists,
                        p_active_bank_exists    => x_active_bank_exists,
                        x_error_message         => lc_error_message,
                        x_return_status         => lc_return_status
                    );

                    pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging **1 pc_user_bank_acct.validate_giac_bank_details  '
                    , 'l_return_status '
                                                                                                                                             || l_return_status
                                                                                                                                             || ' x_duplicate_bank_exists :='
                                                                                                                                             || x_duplicate_bank_exists
                                                                                                                                             || ' x_bank_details_exists :='
                                                                                                                                             || x_bank_details_exists
                                                                                                                                             || ' x_active_bank_exists :='
                                                                                                                                             || x_active_bank_exists
                                                                                                                                             )
                                                                                                                                             ; 
       -- Store the return valus into json variable 
                    jobj := json_object_t.parse(v_validate_giac_bank_details);
                    jobj.put('bank_staging_id', l_bank_staging_id);
                    jobj.put('duplicate_bank_exists', x_duplicate_bank_exists);
                    jobj.put('bank_details_exists', x_bank_details_exists);
                    jobj.put('active_bank_exists', x_active_bank_exists);
                    jobj.put('return_status', lc_return_status);
                    jobj.put('error_message', lc_error_message);

        -- Update the staging deatils 
                    pc_giact_validations.update_bank_accounts_staging(
                        p_bank_staging_id => l_bank_staging_id,
                        p_acc_id          => x.acc_id,
                        p_batch_number    => p_batch_number,
                        p_user_id         => p_user_id,
                        p_bank_details    => jobj.to_clob() --v_validate_giac_bank_details
                        ,
                        x_return_status   => l_return_status,
                        x_error_message   => l_error_message
                    );

                    if nvl(l_return_status, 'N') <> 'S' then
                        raise erreur;
                    end if;
                    if nvl(lc_return_status, 'N') <> 'S' then
                        l_return_status := lc_return_status;
                        l_error_message := lc_error_message;
                        raise erreur;
                    end if;

                    if nvl(x_duplicate_bank_exists, 'N') = 'Y' then
                        l_return_status := lc_return_status;
                        l_error_message := lc_error_message;
                        raise duplicate_error;
                    end if;

                    if nvl(x_bank_details_exists, '*') in ( 'I', 'D', 'W', 'P', 'E',
                                                            'O' ) then
                        l_return_status := lc_return_status;
                        l_error_message := lc_error_message;
                        raise bank_details_exists_error;
                    end if;

        -- If there is already a bank account with Active status, then the same bank details should not go to Giact, instead it should
        -- directly insert the data into bank_accounts table
                    if x_active_bank_exists = 'Y' then
                        for xx in (
                            select
                                *
                            from
                                table ( pc_user_bank_acct.get_existing_bank_giact_details(
                                    p_routing_number     => x.bank_routing_number,
                                    p_bank_acct_num      => x.bank_acct_num,
                                    p_bank_acct_id       => x.bank_acct_id,
                                    p_bank_name          => x.bank_name,
                                    p_bank_account_type  => x.bank_account_type,
                                    p_ssn                => x.ssn,
                                    p_entity_id          => x.entity_id,
                                    p_entity_type        => x.entity_type,
                                    p_bank_account_usage => x.bank_account_usage
                                ) )
                        ) loop
                            jobj.put('active_bank_exists_id', x.bank_acct_id);
                            jobj.put('giac_response', xx.giac_response);
                            jobj.put('giac_verify', xx.giac_verify);
                            jobj.put('giac_authenticate', xx.giac_authenticate);
                            jobj.put('bank_status', 'A');
                            jobj.put('bank_message', 'Your bank account has been added successfully!');
                        end loop;

                        pc_giact_validations.update_bank_accounts_staging(
                            p_bank_staging_id => l_bank_staging_id,
                            p_acc_id          => x.acc_id,
                            p_batch_number    => p_batch_number,
                            p_user_id         => p_user_id,
                            p_bank_details    => jobj.to_clob(),
                            x_return_status   => l_return_status,
                            x_error_message   => l_error_message
                        );

                        if nvl(l_return_status, 'N') <> 'S' then
                            raise erreur;
                        end if;
                    else
                        pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging pc_giact_validations.giact_api_request_formation'
                        , 'x.entity_id '
                                                                                                                                               || x.entity_id
                                                                                                                                               || ' x.entity_TYPE :='
                                                                                                                                               || x.entity_type
                                                                                                                                               )
                                                                                                                                               ; 
           -- Based on the input bank details form the request which would be sent to giac.
                        if x.bank_account_type = 'C' then
                            l_bank_account_type := 'Checking';
                        else
                            l_bank_account_type := 'Savings';
                        end if;
		   -- Request formation to be sent to GIACT
                        pc_giact_validations.giact_api_request_formation(
                            p_entity_id           => x.entity_id,
                            p_entity_type         => x.entity_type,
                            p_acc_num             => x.acc_num,
                            p_bank_routing_number => x.bank_routing_number,
                            p_bank_account_number => x.bank_acct_num,
                            p_bank_account_type   => l_bank_account_type,
                            p_bank_name           => x.bank_name,
                            p_business_name       => x.business_name,
                            p_first_name          => x.first_name,
                            p_last_name           => x.last_name,
                            p_request_xml         => l_request_xml,
                            x_return_status       => l_return_status,
                            x_error_message       => l_error_message
                        );

                        pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging **1 pc_giact_validations.giact_api_request_formation'
                        , 'l_RETURN_STATUS '
                                                                                                                                                   || l_return_status
                                                                                                                                                   || ' x.entity_TYPE :='
                                                                                                                                                   || x.entity_type
                                                                                                                                                   )
                                                                                                                                                   ;

                        if nvl(l_return_status, 'N') <> 'S' then
                            raise erreur;
                        end if;
            -- Send the details to giact
                        pc_giact_api.soap_giact_call(
                            p_batch_number  => p_batch_number,
                            p_entity_id     => x.entity_id,
                            p_request       => l_request_xml,
                            x_response      => l_response,
                            x_return_status => l_return_status,
                            x_error_message => l_error_message
                        );

                        pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging **1 pc_giact_validations.soap_giact_call'
                        , 'l_RETURN_STATUS ' || l_return_status);
                        if nvl(l_return_status, 'N') <> 'S' then
                            raise erreur;
                        end if;
            -- If there is a response from giact 
                        if l_response is not null then
                -- Convert the xml response from giac to jason format and get the giact values
                            pc_giact_validations.api_response_json_formation(
                                p_xml_response       => l_response,
                                p_giact_verify       => l_giact_verify,
                                p_giact_authenticate => l_giact_authenticate,
                                p_giact_response     => l_giact_response,
                                p_json_response      => l_json_api_response,
                                p_api_error_message  => l_api_error_message,
                                x_return_status      => l_return_status,
                                x_error_message      => l_error_message
                            );

                            pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging **1 pc_giact_validations.api_response_json_formation'
                            , 'l_RETURN_STATUS '
                                                                                                                                                       || l_return_status
                                                                                                                                                       || ' l_api_error_message :='
                                                                                                                                                       || l_api_error_message
                                                                                                                                                       || ' l_giact_response :='
                                                                                                                                                       || l_giact_response
                                                                                                                                                       || ' l_giact_verify :='
                                                                                                                                                       || l_giact_verify
                                                                                                                                                       || 'l_giact_authenticate :='
                                                                                                                                                       || l_giact_authenticate
                                                                                                                                                       )
                                                                                                                                                       ;

                            if upper(l_giact_response) = 'ERROR' then
                                l_return_status := 'E';
                                l_error_message := l_api_error_message;
                                raise erreur;
                            elsif nvl(l_return_status, 'N') <> 'S' then
                                raise erreur;
                            end if;

                -- log the request sent to giact and response from giact
                            pc_giact_validations.insert_api_request_log(
                                p_entity_id                   => x.entity_id,
                                p_entity_type                 => x.entity_type,
                                p_enroll_renewal_batch_number => p_batch_number,
                                p_request_xml_data            => l_request_xml,
                                p_response_xml_data           => l_response,
                                p_response_json_data          => l_json_api_response,
                                p_user_id                     => p_user_id,
                                p_website_api_request_id      => l_request_id,
                                x_return_status               => l_return_status,
                                x_error_message               => l_error_message
                            );

                            pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging **1 pc_giact_validations.insert_api_request_log'
                            , 'l_RETURN_STATUS ' || l_return_status);
                            if nvl(l_return_status, 'N') <> 'S' then
                                raise erreur;
                            end if;
                -- Get the bank status based on the response from giact
                            pc_user_bank_acct.validate_giact_response(
                                p_gverify       => l_giact_verify,
                                p_gauthenticate => l_giact_authenticate,
                                x_giact_verify  => l_response_code,
                                x_bank_status   => l_bank_status,
                                x_return_status => lc_return_status,
                                x_error_message => lc_error_message
                            );

                            pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging **1.1 ', 'l_bank_status :='
                                                                                                           || l_bank_status
                                                                                                           || ' l_error_message :='
                                                                                                           || l_error_message);
                            pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging **1 pc_giact_validations.validate_giact_response'
                            , 'l_bank_status ' || l_bank_status);
                            jobj.put('giac_response', l_giact_response);
                            jobj.put('giac_verify', l_giact_verify);
                            jobj.put('giac_authenticate', l_giact_authenticate);
                            jobj.put('bank_status', l_bank_status);
                            jobj.put('giac_verified_response', l_response_code);
                            jobj.put('bank_acct_verified', 'N');
                            jobj.put('bank_message', lc_error_message);
                            pc_giact_validations.update_bank_accounts_staging(
                                p_bank_staging_id => l_bank_staging_id,
                                p_acc_id          => x.acc_id,
                                p_batch_number    => p_batch_number,
                                p_user_id         => p_user_id,
                                p_bank_details    => jobj.to_clob(),
                                x_return_status   => l_return_status,
                                x_error_message   => l_error_message
                            );

                            pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging **12 ', 'l_return_status '
                                                                                                          || l_return_status
                                                                                                          || ' l_error_message :='
                                                                                                          || l_error_message
                                                                                                          || ' l_response_code :='
                                                                                                          || l_response_code);

                            if nvl(l_return_status, 'N') <> 'S' then
                                raise erreur;
                            end if;
                            pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging **12.1 ', 'lc_return_status :='
                                                                                                            || lc_return_status
                                                                                                            || ' lc_error_message :='
                                                                                                            || lc_error_message);
                            if l_response_code in ( 'R', 'E' ) then
                                l_return_status := lc_return_status;
                                l_error_message := lc_error_message;
                                raise setup_error;
                            end if;

                            update website_api_requests
                            set
                                response_body = l_json_api_response,
                                processed_flag = 'Y'
                            where
                                request_id = l_request_id;

                            pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging **10.1 ', 'l_request_id :=' || l_request_id
                            );
                        end if;

                    end if;

                end if;

            end if;

        end loop;

        x_bank_staging_id := l_bank_staging_id;
        if l_edit_bank = 'Y' then
            x_error_message := 'Your bank account has been Edited successfully!';
        else
            x_error_message := 'Your bank account has been added successfully!';
        end if;

        x_return_status := 'S';
        pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging **10.2 end ', 'x_return_status :='
                                                                                            || x_return_status
                                                                                            || ' l_bank_staging_id :='
                                                                                            || l_bank_staging_id);
    exception
        when erreur then
            x_error_message := l_error_message;
            x_return_status := 'E';
            rollback;
            pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging exception erreur ', 'x_error_message ' || x_error_message
            );
        when setup_error then
            x_return_status := 'E';
            x_error_message := l_error_message;
            rollback;
            pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging exception setup_error', x_error_message);
        when duplicate_error then
            x_error_message := l_error_message;
            x_return_status := 'E';
            rollback;
            pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging exception duplicate_error ', 'x_error_message ' || x_error_message
            );
        when bank_details_exists_error then
            x_error_message := l_error_message;
            x_return_status := 'E';
            rollback;
            pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging exception BANK_DETAILS_EXISTS_error ', 'x_error_message ' || x_error_message
            );
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            rollback;
            pc_log.log_error('pc_giact_validations.populate_bank_Accounts_staging exception others ', 'x_error_message '
                                                                                                      || x_error_message
                                                                                                      || dbms_utility.format_error_backtrace
                                                                                                      );
            l_sqlcode := sqlcode;
            pc_giact_validations.insert_giact_api_errors(
                p_batch_number => p_batch_number,
                p_entity_id    => l_entity_id,
                p_sqlcode      => l_sqlcode,
                p_sqlerrm      => x_error_message,
                p_request      => l_request_xml
            );

    end populate_bank_accounts_staging;

-- Added by Swamy for Ticket#12765(POP Giact)
-- Procedure to insert the bank details into bank_accounts table for enrollment and renewal
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
    ) is

        l_acct_usage        varchar2(100);
        l_return_status     varchar2(100);
        l_error_message     varchar2(2000);
        l_acc_id            number;
        l_entity_id         number;
        l_bank_id           number;
        l_entity_type       varchar2(100);
        l_acct_payment_fees varchar2(100);
        l_bank_status       varchar2(1);
        erreur exception;
    begin
        l_acc_id := pc_entrp.get_acc_id(p_entrp_id);
        for k in (
            select
                acct_payment_fees
            from
                online_compliance_staging
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
        ) loop
            l_acct_payment_fees := k.acct_payment_fees;
        end loop;

        for b in (
            select
                user_bank_acct_stg_id,
                json_value(bank_details, '$.entity_id')             as entity_id,
                json_value(bank_details, '$.entity_type')           as entity_type,
                json_value(bank_details, '$.bank_name')             as bank_name,
                json_value(bank_details, '$.display_name')          as display_name,
                json_value(bank_details, '$.bank_account_type')     as bank_acct_type,
                json_value(bank_details, '$.bank_routing_number')   as bank_routing_num,
                json_value(bank_details, '$.bank_acct_num')         as bank_acct_num,
                json_value(bank_details, '$.bank_account_usage')    as bank_account_usage,
                json_value(bank_details, '$.bank_status')           as bank_status,
                json_value(bank_details, '$.giac_verify')           as giac_verify,
                json_value(bank_details, '$.giac_authenticate')     as giac_authenticate,
                json_value(bank_details, '$.giac_response')         as giac_response,
                json_value(bank_details, '$.business_name')         as business_name,
                json_value(bank_details, '$.bank_acct_verified')    as bank_acct_verified,
                json_value(bank_details, '$.existing_bank_Account') as existing_bank_account,
                json_value(bank_details, '$.fees_payment_flag')     as fees_payment_flag,
                json_value(bank_details, '$.active_bank_exists_id') as bank_acct_id
            from
                user_bank_acct_staging --bank_accounts_staging  --website_api_requests
            where
                    batch_number = p_batch_number
                and acc_id = l_acc_id
                and nvl(processed_flag, 'N') = 'N'
        ) loop
            pc_log.log_error('pc_giact_validations.populate_bank_Accounts begin ', 'entity_id '
                                                                                   || b.entity_id
                                                                                   || ' b.entity_type :='
                                                                                   || b.entity_type
                                                                                   || ' bank_name :='
                                                                                   || b.bank_name
                                                                                   || ' display_name :='
                                                                                   || b.display_name
                                                                                   || ' bank_routing_num :='
                                                                                   || b.bank_routing_num
                                                                                   || ' bank_acct_type :='
                                                                                   || b.bank_acct_type
                                                                                   || 'bank_acct_num :='
                                                                                   || b.bank_acct_num
                                                                                   || 'bank_account_usage :='
                                                                                   || b.bank_account_usage
                                                                                   || ' bank_status :='
                                                                                   || b.bank_status
                                                                                   || ' giac_verify :='
                                                                                   || b.giac_verify
                                                                                   || ' giac_authenticate :='
                                                                                   || b.giac_authenticate
                                                                                   || ' giac_response :='
                                                                                   || b.giac_response
                                                                                   || ' business_name :='
                                                                                   || b.business_name
                                                                                   || ' bank_acct_verified :='
                                                                                   || b.bank_acct_verified);

            if b.fees_payment_flag = 'ACH' then
                l_entity_id := null;
                l_entity_type := null;
                l_bank_id := null;
                pc_user_bank_acct.get_bank_account_usage(
                    p_product_type    => p_product_type,
                    p_account_usage   => b.bank_account_usage,
                    x_bank_acct_usage => l_acct_usage,
                    x_return_status   => l_return_status,
                    x_error_message   => l_error_message
                );

                pc_log.log_error('pc_giact_validations.populate_bank_Accounts **1 ', 'l_acct_usage ' || l_acct_usage);
                pc_user_bank_acct.get_entity_details(
                    p_acc_id            => l_acc_id,
                    p_product_type      => p_product_type,
                    p_acct_payment_fees => l_acct_payment_fees,
                    x_entity_id         => l_entity_id,
                    x_entity_type       => l_entity_type,
                    x_return_status     => l_return_status,
                    x_error_message     => l_error_message
                );

                pc_log.log_error('pc_giact_validations.populate_bank_Accounts **2 ', 'l_Acc_id '
                                                                                     || l_acc_id
                                                                                     || ' l_acct_payment_fees :='
                                                                                     || l_acct_payment_fees
                                                                                     || 'l_entity_id :='
                                                                                     || l_entity_id
                                                                                     || 'l_entity_type :='
                                                                                     || l_entity_type);

                if nvl(b.bank_acct_id, 0) = 0 then
                    l_bank_id := pc_user_bank_acct.get_bank_acct_id(
                        p_entity_id          => l_entity_id,
                        p_entity_type        => l_entity_type,
                        p_bank_acct_num      => b.bank_acct_num,
                        p_bank_name          => null,
                        p_bank_routing_num   => b.bank_routing_num,
                        p_bank_account_usage => b.bank_account_usage,
                        p_bank_acct_type     => null
                    );
                else
                    l_bank_id := b.bank_acct_id;
                end if;

                pc_log.log_error('pc_giact_validations.populate_bank_Accounts **3 ', 'l_bank_id ' || l_bank_id);
                if nvl(l_bank_id, 0) = 0 then
                    if l_entity_type = 'ACCOUNT' then
                        update bank_accounts
                        set
                            status = 'I',
                            last_updated_by = p_user_id,
                            last_update_date = sysdate
                        where
                                entity_id = l_entity_id
                            and entity_type = l_entity_type
                            and status = 'A'
                            and bank_account_usage = 'INVOICE';

                    end if;

                    pc_log.log_error('pc_giact_validations.populate_bank_Accounts calling giact_insert_bank_account ', 'l_bank_id ' || l_bank_id
                    );
                    pc_user_bank_acct.giact_insert_bank_account(
                        p_entity_id             => l_entity_id,
                        p_entity_type           => l_entity_type,
                        p_display_name          => b.display_name,
                        p_bank_acct_type        => b.bank_acct_type,
                        p_bank_routing_num      => b.bank_routing_num,
                        p_bank_acct_num         => b.bank_acct_num,
                        p_bank_name             => b.bank_name,
                        p_bank_account_usage    => nvl(b.bank_account_usage, 'ONLINE'),
                        p_user_id               => p_user_id,
                        p_bank_status           => b.bank_status,
                        p_giac_verify           => b.giac_verify,
                        p_giac_authenticate     => b.giac_authenticate,
                        p_giac_response         => b.giac_response,
                        p_business_name         => b.business_name,
                        p_bank_acct_verified    => b.bank_acct_verified,
                        p_existing_bank_account => b.existing_bank_account,
                        x_bank_status           => l_bank_status,
                        x_bank_acct_id          => l_bank_id,
                        x_return_status         => x_return_status,
                        x_error_message         => x_error_message
                    );

                    if x_return_status <> 'S' then
                        raise erreur;
                    end if;
                else
                    pc_log.log_error('pc_giact_validations.populate_bank_Accounts update bank_account table ', 'b.bank_name ' || b.bank_name
                    );
                    update bank_accounts
                    set
                        bank_name = b.bank_name,
                        business_name = b.business_name,
                        bank_acct_type = b.bank_acct_type
                    where
                            bank_acct_id = l_bank_id
                        and entity_id = l_entity_id
                    returning status into x_bank_status;

                    l_bank_status := 'A';
                end if;

                pc_log.log_error('pc_giact_validations.populate_bank_Accounts update bank_account table ', 'b.user_bank_acct_stg_id '
                                                                                                           || b.user_bank_acct_stg_id
                                                                                                           || ' l_bank_id :='
                                                                                                           || l_bank_id
                                                                                                           || ' x_bank_acct_id :='
                                                                                                           || x_bank_acct_id
                                                                                                           || 'x_bank_status :='
                                                                                                           || x_bank_status);

                pc_file_upload.giact_insert_file_attachments(
                    p_user_bank_stg_id => b.user_bank_acct_stg_id,
                    p_attachment_id    => null,
                    p_entity_id        => l_bank_id,
                    p_entity_name      => 'GIACT_BANK_INFO',
                    p_document_purpose => 'GIACT_DOC',
                    p_batch_number     => p_batch_number,
                    p_source           => p_source,
                    x_error_status     => x_return_status,
                    x_error_message    => x_error_message
                );

            end if;

            update user_bank_acct_staging --bank_accounts_staging
            set
                bank_acct_id = l_bank_id,
                bank_status = l_bank_status,
                processed_flag = 'Y'
            where
                    user_bank_acct_stg_id = b.user_bank_acct_stg_id
                and batch_number = p_batch_number
                and acc_id = l_acc_id;

        end loop;

        x_bank_acct_id := l_bank_id;
        x_bank_status := l_bank_status;
        x_error_message := nvl(x_error_message, 'Success');
        x_return_status := nvl(x_return_status, 'S');
    exception
        when erreur then
            x_return_status := 'E';
            x_error_message := x_error_message;
            pc_log.log_error('pc_user_bank_acct.populate_bank_Accounts exception ERREUR ', 'x_error_message '
                                                                                           || x_error_message
                                                                                           || ' x_return_status :='
                                                                                           || x_return_status);
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'E';
            pc_log.log_error('pc_user_bank_acct.populate_bank_Accounts exception others ', 'x_error_message '
                                                                                           || x_error_message
                                                                                           || sqlcode);
    end populate_bank_accounts;

    function get_staging_bank_details (
        p_bank_staging_id in number,
        p_batch_number    in varchar2,
        p_acc_id          in number
    ) return clob is
        v_bank_details clob;
        jobj           json_object_t;
    begin
        pc_log.log_error('pc_giact_validations.get_staging_bank_details begin ', 'p_BANK_STAGING_ID ' || p_bank_staging_id);
        for j in (
            select
                bank_details,
                user_bank_acct_stg_id
            from
                user_bank_acct_staging
            where
                    batch_number = p_batch_number
                and acc_id = p_acc_id
                and user_bank_acct_stg_id = nvl(p_bank_staging_id, user_bank_acct_stg_id)
        ) loop
            v_bank_details := j.bank_details;
            if nvl(p_bank_staging_id, 0) = 0 then
                jobj := json_object_t.parse(v_bank_details);
                jobj.put('bank_staging_id', j.user_bank_acct_stg_id);
                v_bank_details := jobj.to_clob;
                pc_log.log_error('pc_giact_validations.get_staging_bank_details begin ', 'j.user_bank_Acct_stg_id ' || j.user_bank_acct_stg_id
                );
                pc_log.log_error('pc_giact_validations.get_staging_bank_details begin ', 'v_bank_details ' || v_bank_details);
            end if;

        end loop;

        return v_bank_details;
    exception
        when others then
            pc_log.log_error('pc_giact_validations.get_staging_bank_details exception others ', 'x_error_message ' || sqlerrm);
    end get_staging_bank_details;

    procedure update_bank_accounts_staging (
        p_bank_staging_id in number,
        p_acc_id          in number,
        p_batch_number    in number,
        p_user_id         in number,
        p_bank_details    in clob,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is
    begin
        update user_bank_acct_staging --bank_Accounts_staging
        set
            bank_details = p_bank_details
        where
                user_bank_acct_stg_id = p_bank_staging_id
            and batch_number = p_batch_number
            and acc_id = p_acc_id;

        x_return_status := 'S';
    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_giact_validations.update_website_api_requests exception others ', 'x_error_message ' || x_error_message
            );
    end update_bank_accounts_staging;

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
    ) is
    begin
        pc_log.log_error('pc_giact_validations.insert_website_api_requests INSERT INTO website_api_requests ', 'begin p_batch_number '
                                                                                                               || p_batch_number
                                                                                                               || ' p_bank_details :='
                                                                                                               || p_bank_details);
        insert into user_bank_acct_staging (
            user_bank_acct_stg_id,
            acc_id,
            batch_number,
            bank_details,
            website_api_request_id,
            account_type,
            entrp_id,
            validity,
            created_by,
            creation_date
        ) values ( user_bank_acct_stg_seq.nextval,
                   p_acc_id,
                   p_batch_number,
                   p_bank_details,
                   p_website_api_request_id,
                   p_account_type,
                   p_entrp_id,
                   p_validity,
                   p_user_id,
                   sysdate ) returning user_bank_acct_stg_id into x_bank_staging_id;

        x_error_message := 'Success';
        x_return_status := 'S';
        pc_log.log_error('pc_giact_validations.insert_website_api_requests INSERT INTO website_api_requests ', 'x_bank_staging_id ' || x_bank_staging_id
        );
    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_giact_validations.insert_bank_accounts_staging exception others ', 'x_error_message ' || x_error_message
            );
    end insert_bank_accounts_staging;

    procedure update_staging_bank_status (
        p_bank_staging_id in number,
        p_acc_id          in number,
        p_batch_number    in number,
        p_bank_status     in varchar2,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is
        l_json  clob;
        l_patch clob;
    begin
        pc_log.log_error('pc_giact_validations.update_staging_bank_status ', 'begin p_batch_number '
                                                                             || p_batch_number
                                                                             || ' p_bank_staging_id :='
                                                                             || p_bank_staging_id
                                                                             || ' p_acc_id :='
                                                                             || p_acc_id
                                                                             || ' p_bank_status :='
                                                                             || p_bank_status);

        l_patch := '{"bank_status": "'
                   || p_bank_status
                   || '"}';
        update user_bank_acct_staging
        set
            bank_details = json_mergepatch(bank_details, l_patch)
        where
                acc_id = p_acc_id
            and user_bank_acct_stg_id = p_bank_staging_id
            and batch_number = p_batch_number;

        x_error_message := 'Success';
        x_return_status := 'S';
    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'E';
            pc_log.log_error('pc_giact_validations.update_staging_bank_status exception others ', 'x_error_message ' || x_error_message
            );
    end update_staging_bank_status;

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
    ) is

        l_fees_payment_flag varchar2(10);
        l_request_id        number;
        l_acc_id            number;
        l_user_type         varchar2(10);
        l_bank_staging_id   number;
        l_bank_acct_usage   varchar2(10);
    begin
        pc_log.log_error('pc_giact_validations.populate_giact_renewal_staging  ', 'p_user_id '
                                                                                  || p_user_id
                                                                                  || ' p_entrp_id :='
                                                                                  || p_entrp_id
                                                                                  || ' p_ben_plan_id :='
                                                                                  || p_ben_plan_id
                                                                                  || ' p_account_type :='
                                                                                  || p_account_type);

        for k in (
            select
                user_type
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            l_acc_id := pc_entrp.get_acc_id(p_entrp_id);
            l_user_type := k.user_type;
        end loop;

        for j in (
            select
                upper(payment_method) payment_method
            from
                ar_quote_headers
            where
                    entrp_id = p_entrp_id
                and ben_plan_id = p_ben_plan_id
        ) loop
            l_fees_payment_flag := j.payment_method;
        end loop;

        if p_account_type in ( 'ERISA_WRAP', 'POP' ) then
            l_bank_acct_usage := 'INVOICE';
        end if;
        pc_log.log_error('pc_giact_validations.populate_giact_renewal_staging  ', 'l_fees_payment_flag ' || l_fees_payment_flag);
        if
            l_fees_payment_flag = 'ACH'
            and nvl(l_user_type, '*') not in ( 'B' )
        then
            for bank_rec in (
                select
                    entity_id,
                    entity_type,
                    bank_acct_num,
                    json_object(
                            key 'entity_id' value b.entity_id,
                            key 'entity_type' value b.entity_type,
                            key 'bank_routing_number' value b.bank_routing_num,
                            key 'bank_acct_num' value b.bank_acct_num,
                            key 'bank_acct_id' value b.bank_acct_id,
                                    key 'bank_name' value b.bank_name,
                            key 'display_name' value b.display_name,
                            key 'bank_account_type' value b.bank_acct_type,
                            key 'bank_account_usage' value b.bank_account_usage,
                            key 'business_name' value b.business_name,
                                    key 'product_type' value p_account_type,
                            key 'acc_id' value l_acc_id,
                            key 'giac_response' value b.giac_response,
                            key 'giac_authenticate' value b.giac_authenticate,
                            key 'giac_verify' value b.giac_verify,
                                    key 'business_name' value b.business_name,
                            key 'fees_payment_flag' value l_fees_payment_flag,
                            key 'giac_bank_Account_verified' value b.giac_bank_account_verified,
                            key 'bank_status' value b.status
                        )
                    bank_details
                from
                    bank_accounts b
                where
                        b.entity_id = l_acc_id
                    and b.entity_type = 'ACCOUNT'
                    and b.status = 'A'
                    and b.bank_account_usage = l_bank_acct_usage
            ) loop
                pc_log.log_error('In populate_giact_renewal_staging..bank_rec.entity_id  ID', bank_rec.entity_id
                                                                                              || 'bank_rec.entity_type :='
                                                                                              || bank_rec.entity_type
                                                                                              || 'bank_rec.bank_details :='
                                                                                              || bank_rec.bank_details
                                                                                              || ' p_batch_number :='
                                                                                              || p_batch_number);

                pc_giact_validations.insert_website_api_requests(
                    p_entity_id      => bank_rec.entity_id,
                    p_entity_type    => bank_rec.entity_type,
                    p_request_body   => bank_rec.bank_details,
                    p_response_body  => null,
                    p_batch_number   => p_batch_number,
                    p_user_id        => p_user_id,
                    p_processed_flag => 'N',
                    x_request_id     => l_request_id,
                    x_return_status  => x_return_status,
                    x_error_message  => x_error_message
                );

                pc_log.log_error('In populate_giact_renewal_staging..l_request_id ', l_request_id);
                pc_giact_validations.insert_bank_accounts_staging(
                    p_acc_id                 => l_acc_id,
                    p_entrp_id               => p_entrp_id,
                    p_bank_details           => bank_rec.bank_details,
                    p_batch_number           => p_batch_number,
                    p_user_id                => p_user_id,
                    p_website_api_request_id => l_request_id,
                    p_account_type           => p_account_type,
                    p_validity               => 'V',
                    x_bank_staging_id        => l_bank_staging_id,
                    x_return_status          => x_return_status,
                    x_error_message          => x_error_message
                );

                x_staging_bank_acct_id := l_bank_staging_id;
                pc_log.log_error('In populate_giact_renewal_staging..l_bank_staging_id ', l_bank_staging_id);
            end loop;
        end if;

    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_giact_validations.populate_giact_renewal_staging exception others ', 'x_error_message ' || x_error_message
            );
    end populate_giact_renewal_staging;

end pc_giact_validations;
/


-- sqlcl_snapshot {"hash":"9555b1eeef913cd61fc8cbcfbf28528d8d63533e","type":"PACKAGE_BODY","name":"PC_GIACT_VALIDATIONS","schemaName":"SAMQA","sxml":""}