create or replace package samqa.pc_dynamics_integration as
    function get_auth_token (
        p_env_type  in varchar2,
        p_tenant_id in varchar2
    ) return varchar2;

    function call_api (
        p_entity_name in varchar2,
        p_data        in clob
    ) return clob;

    function get_account_data (
        p_acc_id in number
    ) return clob;

    function get_broker_data (
        p_broker_id in number
    ) return clob;

    function get_ga_data (
        p_ga_id in number
    ) return clob;

    function get_update_account_data (
        p_acc_id in number
    ) return clob;

    function get_update_broker_data (
        p_acc_id in number
    ) return clob;

end pc_dynamics_integration;
/


-- sqlcl_snapshot {"hash":"f64c9de7ac12e669a9e4a9f967d582a86b8549a8","type":"PACKAGE_SPEC","name":"PC_DYNAMICS_INTEGRATION","schemaName":"SAMQA","sxml":""}