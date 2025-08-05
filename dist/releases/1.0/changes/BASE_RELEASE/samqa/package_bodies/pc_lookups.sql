-- liquibase formatted sql
-- changeset SAMQA:1754374052350 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_lookups.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_lookups.sql:null:29a1f1324908d60a05855d8aa2fd1e1fa2fafb5c:create

create or replace package body samqa.pc_lookups as

    procedure insert_lookups (
        p_lookup_code in varchar2,
        p_lookup_name in varchar2,
        p_meaning     in varchar2
    ) is
    begin
        insert into lookups (
            lookup_code,
            lookup_name,
            description,  ---- rprabu   is added for sorting 31/05/2024
            creation_date,
            last_updated_date,
            meaning,
            seq_num
        )       ---- rprabu seq_num is added for sorting 31/05/2024
         values ( p_lookup_code,
                   p_lookup_name,
                   p_meaning,
                   sysdate,
                   sysdate,
                   p_meaning,
                   null );

    end insert_lookups;

    function get_denied_reason (
        p_lookup_code in varchar2
    ) return varchar2 is
        l_meaning varchar2(255);
    begin
        select
            meaning
        into l_meaning
        from
            lookups
        where
                lookup_name = 'CLAIM_DENY_CODE'
            and lookup_code = p_lookup_code;

        return l_meaning;
    exception
        when others then
            return null;
    end get_denied_reason;

    function get_meaning (
        p_lookup_code in varchar2,
        p_lookup_name in varchar2
    ) return varchar2 is
        l_meaning varchar2(255);
    begin
        select
            meaning
        into l_meaning
        from
            lookups
        where
                lookup_name = p_lookup_name
            and lookup_code = p_lookup_code;

        return l_meaning;
    exception
        when others then
            return null;
    end get_meaning;

    function get_fsa_plan_type (
        p_code in varchar2
    ) return varchar2 is
        l_plan_type varchar2(50);
    begin
        select
            meaning
        into l_plan_type
        from
            fsa_hra_plan_type
        where
            lookup_code = p_code;

        return l_plan_type;
    exception
        when others then
            return null;
    end get_fsa_plan_type;

    function get_claim_status (
        p_lookup_code in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            meaning
        into l_name
        from
            claim_status
        where
            lookup_code = p_lookup_code;

        return l_name;
    exception
        when others then
            return null;
    end get_claim_status;

    function get_payroll_frequncy (
        p_lookup_code in varchar2
    ) return varchar2 is
        l_meaning varchar2(50);
    begin
        select
            meaning
        into l_meaning
        from
            lookups
        where
                lookup_name = 'PAYROLL_FREQUENCY'
            and lookup_code = p_lookup_code;

        return l_meaning;
    exception
        when others then
            return null;
    end get_payroll_frequncy;

    function get_hra_bps_action (
        p_code in varchar2
    ) return varchar2 is
        l_meaning varchar2(50);
    begin
        select
            meaning
        into l_meaning
        from
            lookups
        where
                lookup_name = 'HRA_BPS_ACTION'
            and lookup_code = p_code;

        return l_meaning;
    exception
        when others then
            return null;
    end get_hra_bps_action;

    function get_enrollment_source (
        p_code in varchar2
    ) return varchar2 is
        l_meaning varchar2(255);
    begin
        select
            meaning
        into l_meaning
        from
            enrollment_source
        where
            source_code = p_code;

        return l_meaning;
    exception
        when others then
            return null;
    end get_enrollment_source;

    function get_plan_type (
        p_code in varchar2
    ) return varchar2 is
        l_plan_type varchar2(255);
    begin
        select
            plan_name
        into l_plan_type
        from
            plan_type
        where
            plan_type_code = p_code;

        return l_plan_type;
    exception
        when others then
            return null;
    end get_plan_type;

    function get_plan_type_code (
        p_plan_type varchar2
    ) return varchar2 is
        l_plan_type_code varchar2(20);
    begin
    -- SLN 14-jan-2015

        select --plan_type_code
           --Added by Jaggi #10456 on 10/11/2021  -- coverage tiers  EE+SPOUSE  EE+CHILDREN  should come as FAMILY
            case
                when upper(trim(nvl(p_plan_type, 'SINGLE'))) = 'SINGLE' then
                    plan_type_code
                else
                    '1'
            end
        into l_plan_type_code
        from
            plan_type
        where
            upper(trim(plan_name)) = upper(trim(nvl(p_plan_type, 'SINGLE')));

        return l_plan_type_code;
    end;

    function get_account_status (
        p_acc_status in number
    ) return varchar2 is
        l_status varchar2(255);
    begin
        select
            status
        into l_status
        from
            account_status
        where
            status_code = p_acc_status;

        return l_status;
    exception
        when others then
            return null;
    end get_account_status;

    function get_ach_status (
        p_acc_status in number
    ) return varchar2 is
        l_status varchar2(255);
    begin
        select
            status
        into l_status
        from
            ach_transfer_status
        where
            status_code = p_acc_status;

        return l_status;
    exception
        when others then
            return null;
    end get_ach_status;

    function get_employer (
        p_entrp_id in number
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            name
        into l_name
        from
            enterprise
        where
            entrp_id = p_entrp_id;

        return l_name;
    exception
        when others then
            return null;
    end get_employer;

    function get_broker (
        p_broker_id in number
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            first_name
            || ' '
            || last_name
        into l_name
        from
            person
        where
            pers_id = p_broker_id;

        return l_name;
    exception
        when others then
            return null;
    end get_broker;

    function get_fee_reason (
        p_reason_code in number
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            fee_name
        into l_name
        from
            fee_names
        where
            fee_code = p_reason_code;

        return l_name;
    exception
        when others then
            return null;
    end get_fee_reason;

    function get_bank_acct_type (
        p_bank_acct_type in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            bank_acct_name
        into l_name
        from
            bank_account_type
        where
            bank_acct_type = p_bank_acct_type;

        return l_name;
    exception
        when others then
            return null;
    end get_bank_acct_type;

    function get_bank_acct_usage (
        p_bank_acct_usage in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            meaning
        into l_name
        from
            bank_acct_usage
        where
            lookup_code = p_bank_acct_usage;

        return l_name;
        null;
    exception
        when others then
            return null;
    end get_bank_acct_usage;

    function get_expense_type (
        p_expense_code in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            expense_name
        into l_name
        from
            expense_type
        where
            expense_nshort = p_expense_code;

        return l_name;
        null;
    exception
        when others then
            return null;
    end get_expense_type;

    function get_expense_type_short (
        p_expense_code in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            expense_nshort
        into l_name
        from
            expense_type
        where
            expense_nshort = p_expense_code;

        return l_name;
        null;
    exception
        when others then
            return null;
    end get_expense_type_short;

    function get_web_expense_type (
        p_expense_code in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            meaning
        into l_name
        from
            web_expense_type
        where
            lookup_code = p_expense_code;

        return l_name;
        null;
    exception
        when others then
            return null;
    end get_web_expense_type;

    function get_reason_name (
        p_reason_code in number
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            reason_name
        into l_name
        from
            pay_reason
        where
            reason_code = p_reason_code;

        return l_name;
    exception
        when others then
            return null;
    end get_reason_name;

    function get_claim_type (
        p_claim_type in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            meaning
        into l_name
        from
            lookups
        where
                lookup_name = 'CLAIM_TYPE'
            and lookup_code = p_claim_type;

        return l_name;
    exception
        when others then
            return null;
    end get_claim_type;

    function get_relat_code (
        p_code in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            meaning
        into l_name
        from
            lookups
        where
                lookup_name = 'RELATIVE'
            and lookup_code = p_code;

        return l_name;
    exception
        when others then
            return null;
    end get_relat_code;

    function get_account_type (
        p_acc_type in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            meaning
        into l_name
        from
            lookups
        where
                lookup_name = 'ACCOUNT_TYPE'
            and lookup_code = p_acc_type;

        return l_name;
    exception
        when others then
            return null;
    end get_account_type;

    function get_card_allowed (
        p_lookup_code in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            meaning
        into l_name
        from
            lookups
        where
                lookup_name = 'CARD_ALLOWED'
            and lookup_code = p_lookup_code;

        return l_name;
    exception
        when others then
            return null;
    end get_card_allowed;

    function get_pay_period (
        p_lookup_code in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            meaning
        into l_name
        from
            lookups
        where
                lookup_name = 'PAY_PERIOD'
            and lookup_code = p_lookup_code;

        return l_name;
    exception
        when others then
            return null;
    end get_pay_period;

    function get_pay_type (
        p_lookup_code in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            pay_name
        into l_name
        from
            pay_type
        where
                pay_code = p_lookup_code
            and pay_type.pay_code not in ( 7, 2, 4, 6 );

        return l_name;
    exception
        when others then
            return null;
    end get_pay_type;

    function get_er_reimbursement_type (
        p_lookup_code in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            meaning
        into l_name
        from
            er_reimbursement_type
        where
            lookup_code = p_lookup_code;

        return l_name;
    exception
        when others then
            return null;
    end get_er_reimbursement_type;

    function get_funding_options (
        p_lookup_code in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            meaning
        into l_name
        from
            funding_option
        where
            lookup_code = p_lookup_code;

        return l_name;
    exception
        when others then
            return null;
    end get_funding_options;

    function get_funding_type (
        p_lookup_code in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            meaning
        into l_name
        from
            funding_type
        where
            lookup_code = p_lookup_code;

        return l_name;
    exception
        when others then
            return null;
    end get_funding_type;

    function get_nhire_contrib (
        p_lookup_code in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            meaning
        into l_name
        from
            new_hire_contrib
        where
            lookup_code = p_lookup_code;

        return l_name;
    exception
        when others then
            return null;
    end get_nhire_contrib;

    function get_emp_reg_type (
        p_lookup_code in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            meaning
        into l_name
        from
            emp_reg_type
        where
            lookup_code = p_lookup_code;

        return l_name;
    exception
        when others then
            return null;
    end get_emp_reg_type;

    function get_title (
        p_lookup_code in varchar2
    ) return varchar2 is
        l_name varchar2(300);
    begin
        select
            title
        into l_name
        from
            person_title_v
        where
            lookup_code = p_lookup_code;

        return l_name;
    exception
        when others then
            return null;
    end get_title;

    function get_claim_medical_code (
        p_lookup_code in varchar2
    ) return varchar2 is
        l_meaning varchar2(255);
    begin
        select
            meaning
        into l_meaning
        from
            lookups
        where
                lookup_name = 'CLAIM_MEDICAL_CODES'
            and lookup_code = p_lookup_code;

        return l_meaning;
    exception
        when others then
            return null;
    end get_claim_medical_code;

    function get_pay_code (
        p_lookup_code in varchar2
    ) return varchar2 is
        l_meaning varchar2(255);
    begin
        select
            meaning
        into l_meaning
        from
            lookups
        where
                lookup_name = 'PAY_TYPE'
            and lookup_code = p_lookup_code;

        return l_meaning;
    exception
        when others then
            return null;
    end get_pay_code;
 --below code added by preethy starts here

    function array_fill (
        p_array       varchar2_tbl,
        p_array_count number
    ) return varchar2_tbl is
        l_array varchar2_tbl;
    begin
        for i in 1..p_array_count loop
            if ( p_array.exists(i) ) then
                l_array(i) := p_array(i);
            else
                l_array(i) := null;
            end if;
        end loop;

        return l_array;
    end;

    procedure update_mobile_version (
        p_lookup_code   in varchar2_tbl,
        p_meaning       in varchar2_tbl,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
        l_lookup_code varchar2_tbl;
        l_meaning     varchar2_tbl;
    begin
        x_return_status := 'S';
        l_lookup_code := array_fill(p_lookup_code, p_lookup_code.count);
        l_meaning := array_fill(p_meaning, p_meaning.count);
        for i in 1..l_lookup_code.count loop
            update lookups
            set
                meaning = l_meaning(i)
            where
                    lookup_code = l_lookup_code(i)
                and lookup_name = 'MOBILE_APP';

        end loop;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
    end update_mobile_version;
--Code added by preethy ends here

   --Added by Jaggi ##9392
    function get_lookup_values (
        p_lookup_name varchar2
    ) return get_lookup_values_t
        pipelined
        deterministic
    is
        l_lookup_values get_lookup_values_row_t;
    begin
        for x in (
            select
                lookup_code,
                description
            from
                lookups
            where
                lookup_name = p_lookup_name
        ) loop
            l_lookup_values.lookup_code := x.lookup_code;
            l_lookup_values.description := x.description;
            pipe row ( l_lookup_values );
        end loop;
    end get_lookup_values;
-----------Added by Vanitha for COBRA PROJCET
    function get_code (
        p_meaning     in varchar2,
        p_lookup_name in varchar2
    ) return varchar2 is
        l_meaning varchar2(255);
    begin
        select
            lookup_code
        into l_meaning
        from
            lookups
        where
                lookup_name = p_lookup_name
            and meaning = p_meaning;

        return l_meaning;
    exception
        when others then
            return null;
    end get_code;

-- Added by Joshi for 10742
    function get_amendment_fee (
        p_account_type in varchar2
    ) return number is
        l_fee number := 0;
    begin
        select
            to_number(meaning)
        into l_fee
        from
            lookups
        where
                lookup_name = 'AMENDMENT_FEE'
            and lookup_code = p_account_type;

        return l_fee;
    exception
        when others then
            return null;
    end get_amendment_fee;

-- Added by Jaggi for 11192
    function get_hawaii_tax_rate (
        p_city_name in varchar2
    ) return number is
        l_cnt  number := 0;
        l_rate number := 0;
    begin
        select
            count(*)
        into l_cnt
        from
            lookups
        where
                lookup_code = 'OAHU_COUNTY_CITY'
            and lookup_name = upper(p_city_name);

        if l_cnt = 0 then
            l_rate := pc_lookups.get_meaning('HAWAI_NON_OAHU_COUNTY_TAX', 'HAWAII_STATE_TAX');
        else
            l_rate := pc_lookups.get_meaning('HAWAI_OAHU_COUNTY_TAX', 'HAWAII_STATE_TAX');
        end if;

        return l_rate;
    exception
        when others then
            return null;
    end get_hawaii_tax_rate;

-- Added by Joshi for 11119.
    function get_fsa_hra_monthly_fee (
        p_plan_type in varchar2
    ) return number is
        l_fee number := 0;
    begin
        select
            to_number(meaning)
        into l_fee
        from
            lookups
        where
                lookup_name = 'FSA_HRA_MAINT_FEE'
            and lookup_code = p_plan_type;

        return l_fee;
    exception
        when others then
            return null;
    end get_fsa_hra_monthly_fee;

end;
/

