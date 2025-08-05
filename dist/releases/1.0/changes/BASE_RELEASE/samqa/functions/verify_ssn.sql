-- liquibase formatted sql
-- changeset SAMQA:1754373928731 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\verify_ssn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/verify_ssn.sql:null:3c862383abcd89a9f7a9737b83dccddc2e0a65c6:create

create or replace function samqa.verify_ssn (
                             --lets assume that it inputs two parameters called string1, string2
    vp_parameter1 varchar2
) return varchar2 as

    ol_req          soap_api.t_request;
    ol_resp         soap_api.t_response;
    vg_funciton_fnc varchar2(256) := 'SocialSecurityNumberService.svc';
    vg_ws_address   varchar2(255) := 'http://www.imangia.net/';
begin
          -- we initilize a new request
    ol_req := soap_api.new_request(vg_funciton_fnc, 'xmlns="'
                                                    || vg_ws_address
                                                    || '"');
          -- we started to add parameters
    soap_api.add_parameter(ol_req, 'string1', 'partns:string', vp_parameter1);
          -- we call the web service
    ol_resp := soap_api.invoke(ol_req, vg_ws_address, vg_funciton_fnc);
          -- we get back the results
    return soap_api.get_return_value(ol_resp, 'result', -- result tag name
     'xmlns:m="'
                                                        || --can be change as "xmlns:n1"
                                                         vg_ws_address
                                                        || '"');
end verify_ssn;
/

