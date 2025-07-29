create or replace package samqa.pc_giact_api as
    l_api_username varchar2(100) := 'UYQEZ-IOVUOB-HZ376-X0FC-QHTCY4';
    l_api_password varchar2(100) := 'kqdHsPZm_Z-Ou076';
    l_api_endpoint varchar2(500) := 'https://sandbox.api.giact.com/VerificationServices/V5/InquiriesWS-5-8.asmx?wsdl';
  --l_api_endpoint        VARCHAR2(500) := 'https://api.giact.com/verificationservices/v5';

    procedure soap_giact_call (
        p_batch_number  in number,
        p_entity_id     in number,
        p_request       in clob,
        x_response      out clob,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

end pc_giact_api;
/


-- sqlcl_snapshot {"hash":"184138f2196e1b98eb788aae31209a3ca5222ddd","type":"PACKAGE_SPEC","name":"PC_GIACT_API","schemaName":"SAMQA","sxml":""}