create or replace package samqa.pc_plan is

/*
 26.03.2006 mal + fee_value
 13.01.2005 sef Creation
*/
    function plan_name (
        plan_code_in in plans.plan_code%type
    ) return plans.plan_name%type;

    function fsetup (
        plan_code_in in plans.plan_code%type
    ) return plan_fee.fee_amount%type;

    function fsetup_online (
        plan_code_in in plans.plan_code%type
    ) return plan_fee.fee_amount%type;

    function fsetup_er (
        p_entrp_id in number
    ) return plan_fee.fee_amount%type;

    function fmonth (
        plan_code_in in plans.plan_code%type
    ) return plan_fee.fee_amount%type;

    function fee_value (
        plan_code_in in plan_fee.plan_code%type,
        fee_code_in  in plan_fee.fee_code%type,
        num_in       in number default 1
    ) return plan_fee.fee_amount%type;

    function fee_amount (
        acc_num_in   in varchar2,
        plan_name_in in plans.plan_name%type,
        fee_code_in  in plan_fee.fee_code%type
    ) return plan_fee.fee_amount%type;

    function plan_code (
        acc_num_in   in varchar2,
        plan_name_in in plans.plan_name%type
    ) return number;

    function fsetup_hra (
        p_entrp_id in number
    ) return number;

    function fmonth_hra (
        p_entrp_id in number
    ) return number;

    function fsetup_paper (
        plan_code_in in plans.plan_code%type,
        p_entrp_id   in number
    ) return number;

    function fsetup_edi (
        plan_code_in in plans.plan_code%type,
        p_entrp_id   in number
    ) return number;

    function fsetup_custom_rate (
        p_entrp_id   in number,
        plan_code_in in plans.plan_code%type
    ) return number;

    function fmonth_er (
        p_entrp_id in number
    ) return plan_fee.fee_amount%type;

    function fcustom_fee_value (
        p_entrp_id in number,
        p_fee_code in number
    ) return number;

    function get_account_type (
        p_plan_code in varchar2
    ) return varchar2;

    function fannual (
        plan_code_in in plans.plan_code%type
    ) return plan_fee.fee_amount%type;

    function get_hra_fsa_fees (
        p_plans              in varchar2,
        p_entrp_id           in number,
        p_setup_renewal      in varchar2,
        p_ndt_flag           varchar2             --- Added By Rprabu 6346 Ticket Rprabu
        ,
        p_total_of_employees number
    )    --- Added by RPRABU 6346 ticket rprabu
     return number;
-- Added by Joshi for 5363.
    function fmonth_ehsa_paper (
        plan_code_in in plans.plan_code%type
    ) return plan_fee.fee_amount%type;
-- For Ticket# 6588
    function get_minimum (
        plan_code_in in plans.plan_code%type
    ) return number;

    function can_create_card_on_pend (
        plan_code_in in plans.plan_code%type
    ) return varchar2;

-- 6588

end pc_plan;
/


-- sqlcl_snapshot {"hash":"4cc67f37871670a0b1b48756976fcec68a0742c6","type":"PACKAGE_SPEC","name":"PC_PLAN","schemaName":"SAMQA","sxml":""}