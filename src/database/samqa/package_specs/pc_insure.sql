create or replace package samqa.pc_insure as
    function is_eob_allowed (
        p_entrp_id in number
    ) return varchar2;

    function get_carrier_supported (
        p_carrier_id in number
    ) return varchar2;

    function get_eob_status (
        p_ssn in varchar2
    ) return varchar2;

    function get_allow_eob (
        p_entrp_id in number
    ) return varchar2;

    procedure update_revoked_date (
        p_pers_id in number,
        p_uers_id in number
    );

    procedure update_carrier_status (
        p_ssn          in varchar2,
        p_carrier_name in varchar2,
        p_carrier_user in varchar2,
        p_carrier_pwd  in varchar2,
        p_status       in varchar2,
        p_policy_num   in varchar2,
        p_user_id      in number
    );

    procedure export_hrafsa_health_plan (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    );

    function get_carrier_id (
        p_carrier in varchar2
    ) return number;

end pc_insure;
/


-- sqlcl_snapshot {"hash":"5e318f8376673260aa42609d6ea0227555300d10","type":"PACKAGE_SPEC","name":"PC_INSURE","schemaName":"SAMQA","sxml":""}