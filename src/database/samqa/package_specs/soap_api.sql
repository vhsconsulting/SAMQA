create or replace package samqa.soap_api as
-- --------------------------------------------------------------------------
-- Name         : http://www.oracle-base.com/dba/miscellaneous/soap_api
-- Author       : Tim Hall
-- Description  : SOAP related functions for consuming web services.
-- Ammedments   :
--   When         Who       What
--   ===========  ========  =================================================
--   04-OCT-2003  Tim Hall  Initial Creation
--   23-FEB-2006  Tim Hall  Parameterized the "soap" envelope tags.
--   25-MAY-2012  Tim Hall  Added debug switch.
--   29-MAY-2012  Tim Hall  Allow parameters to have no type definition.
--                          Change the default envelope tag to "soap".
--                          add_complex_parameter: Include parameter XML manually.
-- --------------------------------------------------------------------------

    type t_request is record (
            method       varchar2(256),
            namespace    varchar2(256),
            body         varchar2(32767),
            envelope_tag varchar2(30)
    );
    type t_response is record (
            doc          xmltype,
            envelope_tag varchar2(30)
    );
    function new_request (
        p_method       in varchar2,
        p_namespace    in varchar2,
        p_envelope_tag in varchar2 default 'soap'
    ) return t_request;

    procedure add_parameter (
        p_request in out nocopy t_request,
        p_name    in varchar2,
        p_value   in varchar2,
        p_type    in varchar2 := null
    );

    procedure add_complex_parameter (
        p_request in out nocopy t_request,
        p_xml     in varchar2
    );

    function invoke (
        p_request in out nocopy t_request,
        p_url     in varchar2,
        p_action  in varchar2
    ) return t_response;

    function get_return_value (
        p_response  in out nocopy t_response,
        p_name      in varchar2,
        p_namespace in varchar2
    ) return varchar2;

    procedure debug_on;

    procedure debug_off;

end soap_api;
/


-- sqlcl_snapshot {"hash":"650f8433cf91a7847cbb7bd3320d3e407909eaff","type":"PACKAGE_SPEC","name":"SOAP_API","schemaName":"SAMQA","sxml":""}