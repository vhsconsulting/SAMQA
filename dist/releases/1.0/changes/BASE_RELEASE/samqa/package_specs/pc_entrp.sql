-- liquibase formatted sql
-- changeset SAMQA:1754374137561 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_entrp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_entrp.sql:null:f7674c142cc5196fa9032252cd8f312ebbccbb4d:create

create or replace package samqa.pc_entrp is

/*
????? ??? ???????????? ???????????
*/
-- ??? ??.??????????? ?????????? ???-?? ????? ? ??? ??????????????????
    function count_person (
        entrp_id_in in enterprise.entrp_id%type
    ) return number;

    function count_active_person (
        entrp_id_in    in enterprise.entrp_id%type,
        p_account_type in varchar2 default 'HSA',
        p_plan_type    in varchar2 default null
    ) return number;

    function get_acc_num (
        p_entrp_id in number
    ) return varchar2;

    function get_entrp_id (
        p_acc_num in varchar2
    ) return number;

    function get_entrp_id_from_name (
        p_entrp_name in varchar2
    ) return number;

    function get_entrp_id_for_cobra (
        p_cobra_number in number
    ) return number;

    function get_eligible_count (
        p_entrp_id in number
    ) return number;

    function get_entrp_name (
        p_entrp_id in number
    ) return varchar2;

    function count_person_status (
        entrp_id_in in enterprise.entrp_id%type,
        p_status    in number
    ) return number;

    procedure end_date_employer;

    function get_bps_acc_num (
        p_entrp_id in number
    ) return varchar2;

    function get_bps_acc_num_from_acc_id (
        p_acc_id in number
    ) return varchar2;

    function get_acc_id_from_ein (
        p_tax_id       in varchar2,
        p_account_type in varchar2 default 'HSA'
    ) return number;

    function get_entrp_id_from_ein (
        p_tax_id in varchar2
    ) return number;

    function get_entrp_id_from_ein_act (
        p_tax_id       in varchar2,
        p_account_type in varchar2 default 'HSA'
    ) return number;

    function get_acc_id (
        p_entrp_id in number
    ) return number;

    function get_payroll_integration (
        p_entrp_id in number
    ) return varchar2;

    function card_allowed (
        entrp_id_in in number
    ) return number;

    function allow_exp_enroll (
        p_entrp_id in number
    ) return varchar2;

    function get_tax_id (
        p_entrp_id in number
    ) return varchar2;

    procedure insert_enterprise (
        p_name                in varchar2,
        p_ein_number          in varchar2,
        p_address             in varchar2,
        p_city                in varchar2,
        p_state               in varchar2,
        p_zip                 in varchar2,
        p_contact_name        in varchar2,
        p_phone               in varchar2,
        p_fax_id              in varchar2,
        p_email               in varchar2,
        p_fee_plan_type       in number,
        p_card_allowed        in varchar2,
        p_office_phone_number in varchar2 /* 7857 Joshi*/,
        p_industry_type       in varchar2 default null     -----9141 rprabu 03/08/2020
        ,
        x_entrp_id            out number,
        x_error_status        out varchar2,
        x_error_message       out varchar2
    );

 -- Below Function added by Swamy for Ticket#7756
 -- Function to get the State Code for an Employer
    function get_state (
        p_entrp_id in number
    ) return varchar2;
 -- Added by jaggi Ticket#11119
    function get_city (
        p_entrp_id in number
    ) return varchar2;

-- Added by Joshi for  12775
    function get_active_entrp_id_from_ein_act (
        p_tax_id       in varchar2,
        p_account_type in varchar2 default 'HSA'
    ) return number;

end pc_entrp;
/

