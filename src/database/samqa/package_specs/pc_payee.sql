create or replace package samqa.pc_payee as
    procedure add_payee (
        p_payee_name          in varchar2,
        p_payee_acc_num       in varchar2,
        p_address             in varchar2,
        p_city                in varchar2,
        p_state               in varchar2,
        p_zipcode             in varchar2,
        p_acc_num             in varchar2,
        p_user_id             in varchar2,
        p_orig_sys_vendor_ref in varchar2 default null,
        p_acc_id              in number,
        p_payee_type          in varchar2,
        p_payee_tax_id        in varchar2,
        p_payee_nick_name     in varchar2 default null,
        x_vendor_id           out number,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    );

    procedure update_payee (
        p_payee_name    in varchar2,
        p_payee_acc_num in varchar2,
        p_address       in varchar2,
        p_city          in varchar2,
        p_state         in varchar2,
        p_zipcode       in varchar2,
        p_user_id       in varchar2,
        p_payee_tax_id  in varchar2,
        p_vendor_id     in number
--, P_PAYEE_NICK_NAME    IN VARCHAR2 DEFAULT NULL
        ,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure delete_payee (
        p_vendor_id     in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    function get_payee (
        p_acc_id       in number,
        p_service_type in varchar2,
        p_address      in varchar2,
        p_city         in varchar2,
        p_state        in varchar2,
        p_zip          in varchar2
    ) return number;

    function get_payee_name (
        p_vendor_id in number
    ) return varchar2;

    procedure add_eob_provider (
        p_payee_name      in varchar2,
        p_address1        in varchar2,
        p_address2        in varchar2,
        p_city            in varchar2,
        p_state           in varchar2,
        p_zipcode         in varchar2,
        p_user_id         in varchar2,
        p_payee_npi       in varchar2 default null,
        p_acc_id          in number,
        p_payee_tax_id    in varchar2,
        p_provider_id     in number,
        p_payee_nick_name in varchar2 default null,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

end pc_payee;
/


-- sqlcl_snapshot {"hash":"a00dd86ca86daf7635ec7c2f88288a527dd9b380","type":"PACKAGE_SPEC","name":"PC_PAYEE","schemaName":"SAMQA","sxml":""}