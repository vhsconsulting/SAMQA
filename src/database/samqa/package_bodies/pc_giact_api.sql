create or replace package body samqa.pc_giact_api as

-- Giac API call using soap 
    procedure soap_giact_call (
        p_batch_number  in number,
        p_entity_id     in number,
        p_request       in clob,
        x_response      out clob,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

        l_response             clob;
        l_envelope             clob;
    --  l_headers APEX_WEB_SERVICE.T_HTTP_HEADER_TAB;
        v_xml                  xmltype;
        v_itemreferenceid      varchar2(50);
        v_createddate          varchar2(50);
        v_verificationresponse varchar2(50);
        v_accountresponsecode  varchar2(100);
        v_bankname             varchar2(100);
        v_sqlcode              varchar2(100);
        v_sqlerrm              varchar2(500);
    begin
        pc_log.log_error('pc_giact_validations.soap_giact_call begin ', 'p_entity_id :='
                                                                        || p_entity_id
                                                                        || ' p_request '
                                                                        || p_request);
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/soap+xml; charset=utf-8';
    -- Make the SOAP call
        utl_http.set_wallet('file:/home/oracle/apex_wallet');
        l_response := apex_web_service.make_rest_request(
            p_url         => pc_giact_api.l_api_endpoint   --'https://sandbox.api.giact.com/VerificationServices/V5/InquiriesWS-5-8.asmx?wsdl',
            ,
            p_http_method => 'POST',
            p_body        => p_request
        );

        dbms_output.put_line(l_response);
        v_xml := xmltype(l_response);
        x_response := l_response;
        x_error_message := 'Success';
        x_return_status := 'S';
    exception
        when others then
       -- Log error
            v_sqlcode := sqlcode;
            v_sqlerrm := sqlerrm;
            x_error_message := 'Error';
            x_return_status := 'E';
            pc_giact_validations.insert_giact_api_errors(
                p_batch_number => p_batch_number,
                p_entity_id    => p_entity_id,
                p_sqlcode      => v_sqlcode,
                p_sqlerrm      => v_sqlerrm,
                p_request      => p_request
            );

            raise;
    end soap_giact_call;

end pc_giact_api;
/


-- sqlcl_snapshot {"hash":"b4b8b32e0e208c6ded0ac40e1be8373017194673","type":"PACKAGE_BODY","name":"PC_GIACT_API","schemaName":"SAMQA","sxml":""}