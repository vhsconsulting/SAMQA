-- liquibase formatted sql
-- changeset SAMQA:1754374074595 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_plan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_plan.sql:null:68c2bdf27a8a7df335db95685364236d61ab5479:create

create or replace package body samqa.pc_plan is

    function plan_name (
        plan_code_in in plans.plan_code%type
    ) return plans.plan_name%type is

        cursor c1 (
            p_plan_code plans.plan_code%type
        ) is
        select
            plan_name
        from
            plans
        where
            plan_code = p_plan_code;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(plan_code_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return r1.plan_name;
        else
            return null;
        end if;
    end plan_name;

    function fsetup (
        plan_code_in in plans.plan_code%type
    ) return plan_fee.fee_amount%type is
    begin
        return pc_plan.fee_value(plan_code_in, 1);
    end fsetup;

    function fsetup_er (
        p_entrp_id in number
    ) return plan_fee.fee_amount%type is
        l_fee number;
    begin
        for x in (
            select
                fee_setup
            from
                account
            where
                entrp_id = p_entrp_id
        ) loop
            l_fee := x.fee_setup;
        end loop;

        return l_fee;
    end fsetup_er;

    function fcustom_fee_value (
        p_entrp_id in number,
        p_fee_code in number
    ) return number is
        l_fee number;
    begin
        for x in (
            select
                rpd.rate_plan_cost
            from
                rate_plans       rp,
                rate_plan_detail rpd
            where
                    rp.entity_id = p_entrp_id
                and rp.entity_type = 'EMPLOYER'
                and rp.rate_plan_id = rpd.rate_plan_id
                and rp.status = 'A'
                and trunc(rp.effective_date) < trunc(sysdate)
                /*We should not calculate fees when rate plan setup has been end dated */
                and ( rpd.effective_end_date is null
                      or trunc(rpd.effective_end_date) > trunc(sysdate) )
                and rpd.rate_code = to_char(p_fee_code)
        ) loop
            l_fee := x.rate_plan_cost;
        end loop;

        return l_fee;
    end;

    function fmonth (
        plan_code_in in plans.plan_code%type
    ) return plan_fee.fee_amount%type is
    begin
        return pc_plan.fee_value(plan_code_in, 2);
    end fmonth;

    function fee_value (
        plan_code_in in plan_fee.plan_code%type,
        fee_code_in  in plan_fee.fee_code%type,
        num_in       in number default 1
    ) return plan_fee.fee_amount%type is

        cursor c1 is
        select
            plan_code,
            fee_code,
            fee_amount,
            note
        from
            plan_fee
        where
                plan_code = plan_code_in
            and fee_code = fee_code_in;

        r1     c1%rowtype;
        tmpvar number;
    begin
        open c1;
        fetch c1 into r1;
        close c1;
        if num_in = 1 then -- default, need first value of fee
            tmpvar := r1.fee_amount;
        elsif num_in > 1 then -- need second value of fee
            tmpvar := to_number ( substr(r1.note, 1, 3) ); -- I do not want add new field in PLAN_FEE table
        else
            tmpvar := null; -- not default, but < 1, say 0 or NULL
        end if;

        return tmpvar;
    exception
        when others then
            return null; -- say, error TO_NUMBER(NOTE)
    end fee_value;

    function fsetup_online (
        plan_code_in in plans.plan_code%type
    ) return plan_fee.fee_amount%type is
    begin
   /*IF plan_code_in = 0 THEN
      RETURN 28;
   ELSIF plan_code_in = -1 THEN
     RETURN 15;
   ELSE
      RETURN Pc_Plan.fee_value(plan_code_in, 1);
   END IF;  */

        if plan_code_in = 0 then
            return 0;  -- changing from 28 to 15 for 9/1/2011 effective date-- Changing to 0 -10/27/2017
        elsif plan_code_in = -1 then
            return 0; -- changing from 15 to 5 for 9/1/2011 effective date--Changing to 0 -10/27/2017
        else
            return pc_plan.fee_value(plan_code_in, 1);
        end if;
    end;

    function fee_amount (
        acc_num_in   in varchar2,
        plan_name_in in plans.plan_name%type,
        fee_code_in  in plan_fee.fee_code%type
    ) return plan_fee.fee_amount%type is
        l_amount number := null;
    begin
        for x in (
            select
                fee_amount
            from
                (
                    select
                        nvl((
                            select distinct
                                plan_sign
                            from
                                plans
                            where
                                plan_sign = substr(acc_num_in, 1, 3)
                        ),
                            'SHA') plan_sign
                    from
                        dual
                )        c,
                plan_fee a,
                plans    b
            where
                    a.plan_code = b.plan_code
                and b.plan_sign = c.plan_sign
                and upper(b.plan_name) = nvl((
                    select
                        upper(plan_name)
                    from
                        plans
                    where
                            plan_sign = c.plan_sign
                        and upper(plan_name) = plan_name_in
                ),
                                             upper(b.plan_name))
                and fee_code = fee_code_in
        ) loop
            l_amount := x.fee_amount;
        end loop;

        return l_amount;
    end fee_amount;

    function plan_code (
        acc_num_in   in varchar2,
        plan_name_in in plans.plan_name%type
    ) return number is
        l_plan_code number := null;
    begin
        for x in (
            select
                b.plan_code
            from
                (
                    select
                        nvl((
                            select distinct
                                plan_sign
                            from
                                plans
                            where
                                plan_sign = substr(acc_num_in, 1, 3)
                        ),
                            'SHA') plan_sign
                    from
                        dual
                )        c,
                plan_fee a,
                plans    b
            where
                    a.plan_code = b.plan_code
                and b.plan_sign = c.plan_sign
                and upper(b.plan_name) = nvl((
                    select
                        upper(plan_name)
                    from
                        plans
                    where
                            plan_sign = c.plan_sign
                        and upper(plan_name) = plan_name_in
                ),
                                             upper(b.plan_name))
        ) loop
            l_plan_code := x.plan_code;
        end loop;

        return l_plan_code;
    end plan_code;

    function fsetup_hra (
        p_entrp_id in number
    ) return number is
        l_fee_setup number;
    begin
        for x in (
            select
                fee_setup
            from
                account
            where
                entrp_id = p_entrp_id
        ) loop
            l_fee_setup := x.fee_setup;
        end loop;

        return nvl(l_fee_setup, 0);
    end fsetup_hra;

    function fmonth_hra (
        p_entrp_id in number
    ) return number is
        l_fee_month number;
    begin
        for x in (
            select
                fee_maint
            from
                account
            where
                entrp_id = p_entrp_id
        ) loop
            l_fee_month := x.fee_maint;
        end loop;

        return nvl(l_fee_month, 0);
    end fmonth_hra;

    function fsetup_paper (
        plan_code_in in plans.plan_code%type,
        p_entrp_id   in number
    ) return number is
        l_fee_setup number;
    begin
        if p_entrp_id is null then
            l_fee_setup := 0;  -- Paper Enrollment for 9/1/2011 effective date--Changing from 15 to 0 .10/27/2017
        end if;
        return nvl(l_fee_setup,
                   pc_plan.fee_value(plan_code_in, 1));
    end fsetup_paper;

    function fmonth_er (
        p_entrp_id in number
    ) return plan_fee.fee_amount%type is
        l_fee number;
    begin
  -- Teamster's have custom rate plans, so we take the monthly fee for them
        for x in (
            select
                b.rate_plan_cost fee_maint
            from
                rate_plans       a,
                rate_plan_detail b
            where
                    a.entity_id = p_entrp_id
                and a.entity_type = 'EMPLOYER'
                and a.rate_plan_id = b.rate_plan_id
                and a.status = 'A'
                and a.effective_date < sysdate
                and b.effective_end_date is null
                and b.rate_code = '2'
        ) loop
            l_fee := x.fee_maint;
        end loop;

        return l_fee;
    end fmonth_er;

    function fsetup_custom_rate (
        p_entrp_id   in number,
        plan_code_in in plans.plan_code%type
    ) return number is
        l_fee number;
    begin
  -- Teamster's have custom rate plans, so we take the monthly fee for them
        for x in (
            select
                b.rate_plan_cost fee_setup
            from
                rate_plans       a,
                rate_plan_detail b
            where
                    a.entity_id = p_entrp_id
                and a.entity_type = 'EMPLOYER'
                and a.rate_plan_id = b.rate_plan_id
                and a.status = 'A'
                and a.effective_date < sysdate
                and b.effective_end_date is null
                and b.rate_code = '1'
        ) loop
            l_fee := x.fee_setup;
        end loop;

        return l_fee;
    end fsetup_custom_rate;

    function get_account_type (
        p_plan_code in varchar2
    ) return varchar2 is
        l_account_type varchar2(100);
    begin
        for x in (
            select
                account_type
            from
                plans
            where
                plan_code = p_plan_code
        ) loop
            l_account_type := x.account_type;
        end loop;

        return l_account_type;
    end get_account_type;

    function fsetup_edi (
        plan_code_in in plans.plan_code%type,
        p_entrp_id   in number
    ) return number is
        l_fee_setup number := 0;--Changing from 15 to 0--10/27/2017
    begin
  --For EDI vendors if no setup fee is defined we charge 15$,else we charge as per
  --setup
        begin
            select
                fcustom_fee_value(p_entrp_id, 1) --Fee code 1 is for Setup fee
            into l_fee_setup
            from
                dual;

        exception
            when no_data_found then
                l_fee_setup := 0; --EDI Enrollment--Changing from 15 to 0.10/27/2017
        end;

        return ( l_fee_setup );
    end fsetup_edi;

    function fannual (
        plan_code_in in plans.plan_code%type
    ) return plan_fee.fee_amount%type is
    begin
        return pc_plan.fee_value(plan_code_in, 100);
    end fannual;

    function get_hra_fsa_fees (
        p_plans              in varchar2,
        p_entrp_id           in number,
        p_setup_renewal      in varchar2,
        p_ndt_flag           varchar2,           --- Added by RPRABU 6346 ticket
        p_total_of_employees number
    )    --- Added by RPRABU 6346 ticket
     return number is

        l_cost                number := 0;
        v_plan_count          number;
        l_no_of_employee      number := 100;
        l_account_type        varchar2(100);
        l_plan_code           varchar2(30);
        l_ndt_preference      varchar2(100) := null;       --- Added by RPRABU 6346 ticket
        l_ndt_fees            number := 0;                        --- Added By Rprabu 6346 Ticket
        l_ndt_fees_chargeable varchar2(1) := 'N';	    --- Added By Rprabu 6346 Ticket
        l_plans               varchar2(4000);
        l_trn_pkg_count       integer := 0;
        l_trn_pkg_ua1_count   integer := 0;
    begin
        pc_log.log_error('GET_HRA_FSA_FEES', 'P_PLANS' || p_plans);
        pc_log.log_error('GET_HRA_FSA_FEES', 'P_ENTRP_ID' || p_entrp_id);
        for x in (
            select distinct
                pc_lookups.get_meaning(column_value, 'FSA_HRA_PRODUCT_MAP') product_type
            from
                table ( cast(str2tbl(p_plans) as varchar2_4000_tbl) )
            where
                column_value is not null
        ) loop
            l_account_type := x.product_type;
        end loop;

        for x in (
            select
                no_of_eligible,
                b.plan_code,
                b.account_type
            from
                enterprise e,
                account    b
            where
                    e.entrp_id = p_entrp_id
                and e.entrp_id = b.entrp_id
        ) loop
            l_no_of_employee := x.no_of_eligible;
            l_plan_code := x.plan_code;
            if
                x.account_type = 'FSA'
                and l_account_type = 'HRA'
            then
                l_plan_code := 510; -- If it is stacked plan , assuming that it is HRA comprehensive plan
            end if;

        end loop;

        pc_log.log_error('GET_HRA_FSA_FEES', 'l_no_of_employee' || l_no_of_employee);
        select
            count(distinct column_value)
        into v_plan_count
        from
            table ( cast(str2tbl(p_plans) as varchar2_4000_tbl) )
        where
            column_value is not null;

        if l_account_type = 'HRA' then
	           ----------------NDT Calculations for HRA ----------------------------
            if l_plan_code is null then
                for i in (
                    select
                        plan_code,
                        ndt_preference
                    from
                        online_fsa_hra_staging
                    where
                        entrp_id = p_entrp_id
                ) loop
                    l_plan_code := i.plan_code;
                    l_ndt_preference := i.ndt_preference;
                end loop;
            end if;

            for x in (
                select
                    rpd.rate_plan_cost
                from
                    rate_plans       rp,
                    rate_plan_detail rpd
                where
                        rp.rate_plan_id = rpd.rate_plan_id
                    and rp.rate_plan_name = 'HRA_STANDARD_FEES'
                    and rp.account_type = l_account_type
                    and rp.rate_plan_type = 'INVOICE'
                    and rp.effective_end_date is null
                    and rpd.coverage_type = p_setup_renewal ---nvl Below Query Added by RPRABU 6346 ticket
                    and nvl(p_total_of_employees, l_no_of_employee) between rpd.minimum_range and nvl(rpd.maximum_range, 100000)
                    and rpd.rate_basis = l_plan_code
            ) loop
                l_cost := x.rate_plan_cost;
            end loop;
				----------------NDT Calculations for HRA ----------------------------
            if p_ndt_flag = 'Y' then
                l_ndt_fees := 0;
                for y in (
                    select
                        nvl(rpd.rate_plan_cost, 0) rate_plan_cost
                    from
                        rate_plans       rp,
                        rate_plan_detail rpd
                    where
                            rp.rate_plan_id = rpd.rate_plan_id
                        and rp.rate_plan_name = 'HRA_STANDARD_FEES'
                        and rp.account_type = l_account_type
                        and rp.rate_plan_type = 'INVOICE'
                        and rp.effective_end_date is null
                        and rpd.coverage_type = p_setup_renewal   ---'Setup_Fee' For Hra
                        and p_total_of_employees between rpd.minimum_range and nvl(rpd.maximum_range, 100000)
                        and rpd.rate_basis = 'NDT'
                        and rate_code = 1
                ) loop
                    l_ndt_fees := y.rate_plan_cost;
                end loop;

                l_cost := l_cost + l_ndt_fees;
            end if;  --- If  p_ndt_flag = 'Y'  all HRA cases finished.
        else

		       -- Added code by Joshi for 8154
        -- TRN:PKG:UA1 should be considered as 1 plan
            select
                count(distinct column_value)
            into l_trn_pkg_ua1_count
            from
                table ( cast(str2tbl(p_plans) as varchar2_4000_tbl) )
            where
                column_value in ( 'TRN', 'PKG', 'UA1' );

        -- TRN:PKG should be considered as 1 plan
            select
                count(distinct column_value)
            into l_trn_pkg_count
            from
                table ( cast(str2tbl(p_plans) as varchar2_4000_tbl) )
            where
                column_value in ( 'TRN', 'PKG' );

            pc_log.log_error('GET_HRA_FSA_FEES', 'l_trn_pkg_count: ' || l_trn_pkg_count);
            if l_trn_pkg_ua1_count = 3 then
                l_plans := replace(p_plans, ',PKG', '');
                l_plans := replace(l_plans, 'PKG,', '');
                l_plans := replace(l_plans, ',UA1', '');
                l_plans := replace(l_plans, 'UA1,', '');
            else
                if l_trn_pkg_count = 2 then
                    l_plans := replace(p_plans, ',PKG', '');
                    l_plans := replace(l_plans, 'PKG,', '');
                else
                    l_plans := p_plans;
                end if;
            end if;

            pc_log.log_error('GET_HRA_FSA_FEES', 'l_plans: ' || l_plans);
            select
                count(distinct column_value)
            into v_plan_count
            from
                table ( cast(str2tbl(l_plans) as varchar2_4000_tbl) )
            where
                column_value is not null;
        -- code ends here

            pc_log.log_error('GET_HRA_FSA_FEES', 'V_PLAN_COUNT: ' || v_plan_count);
            if v_plan_count >= 3 then
                for x in (
                    select
                        rpd.rate_plan_cost
                    from
                        rate_plans       rp,
                        rate_plan_detail rpd
                    where
                            rp.rate_plan_id = rpd.rate_plan_id
                        and rp.rate_plan_name = 'FSA_STANDARD_FEES'
                        and rp.account_type = l_account_type
                        and rp.rate_plan_type = 'INVOICE'
                        and rp.effective_end_date is null
                        and rpd.coverage_type = p_setup_renewal--- Nvl(P_Total_Of_Employees,L_No_Of_Employee)  Added By Rprabu 6346 Ticket
                        and nvl(p_total_of_employees, l_no_of_employee) between rpd.minimum_range and nvl(rpd.maximum_range, 100000)
                        and rpd.rate_basis = 'FSA:DCA:LPF:TRN:PKG:UA1'
                ) loop
                    l_cost := x.rate_plan_cost;
                end loop;
            else
                for x in (
                    select
                        rpd.rate_plan_cost
                    from
                        rate_plans       rp,
                        rate_plan_detail rpd
                    where
                            rp.rate_plan_id = rpd.rate_plan_id
                        and rp.rate_plan_name = 'FSA_STANDARD_FEES'
                        and rp.account_type = l_account_type
                        and rp.rate_plan_type = 'INVOICE'
                        and rp.effective_end_date is null
                        and rpd.coverage_type = p_setup_renewal --- Nvl(P_Total_Of_Employees,L_No_Of_Employee)  Added By Rprabu 6346 Ticket
                        and nvl(p_total_of_employees, l_no_of_employee) between rpd.minimum_range and nvl(rpd.maximum_range, 100000)
                        and rpd.rate_basis = (
                            select
                                listagg(column_value, ':') within group(
                                order by
                                    column_value
                                )
                            from
                                (
										 -- select distinct column_value from TABLE(CAST(str2tbl(P_PLANS) as VARCHAR2_4000_TBL)))))
                                    select distinct
                                        column_value
                                    from
                                        table ( cast(str2tbl(l_plans) as varchar2_4000_tbl) )
                                )
                        )
                ) loop
                    l_cost := x.rate_plan_cost;
                end loop;
            end if;  --- If V_Plan_Count >= 3
        end if;    ----L_ACCOUNT_TYPE   = 'HRA'
        pc_log.log_error('GET_HRA_FSA_FEES', 'l_cost' || l_cost);

		   ----------------NDT Calculations For FSA PLANS----------------------------
        if
            p_ndt_flag = 'Y'
            and l_account_type = 'FSA'
        then       --- Added by RPRABU 6346 ticket
            l_ndt_fees := 0;
            l_ndt_fees_chargeable := 'N';
            for x in (
                select
                    column_value
                from
                    table ( cast(str2tbl(p_plans) as varchar2_4000_tbl) )
                where
                    column_value is not null
            ) loop
                if x.column_value in ( 'FSA', 'DCA', 'LPF' ) then   ---- NDT_CHARGEABLE_PLANS --------------
                    l_ndt_fees_chargeable := 'Y';
                    exit;
                end if;
            end loop;

            if l_ndt_fees_chargeable = 'Y' then
                for z in (
                    select
                        nvl(rpd.rate_plan_cost, 0) rate_plan_cost
                    from
                        rate_plans       rp,
                        rate_plan_detail rpd
                    where
                            rp.rate_plan_id = rpd.rate_plan_id
                        and rp.rate_plan_name = 'FSA_STANDARD_FEES'
                        and rp.account_type = l_account_type
                        and rp.rate_plan_type = 'INVOICE'
                        and rp.effective_end_date is null
                        and rpd.coverage_type = p_setup_renewal   ---'Setup_Fee' For Fsa
                        and ( p_total_of_employees between rpd.minimum_range and nvl(rpd.maximum_range, 100000) )
                        and rpd.rate_basis = 'NDT'
                        and rate_code = 1
                ) loop
                    l_cost := l_cost + z.rate_plan_cost;
                end loop;
            end if;

        end if;

        if
            p_ndt_flag = 'Y'
            and p_total_of_employees = 0
        then
            l_cost := 0;
        end if;
        return l_cost;
    end get_hra_fsa_fees;

-- Added by Joshi 5363. to get the monthly fee for e-HSA plan.
    function fmonth_ehsa_paper (
        plan_code_in in plans.plan_code%type
    ) return plan_fee.fee_amount%type is
    begin
        return pc_plan.fee_value(plan_code_in, 181);
    end fmonth_ehsa_paper;

-- For Ticet#6588

    function get_minimum (
        plan_code_in in plans.plan_code%type
    ) return number is
        l_bal number := 20;
    begin
        for x in (
            select
                minimum_bal
            from
                plans
            where
                plan_code = plan_code_in
        ) loop
            l_bal := x.minimum_bal;
        end loop;

        return l_bal;
    end get_minimum;

    function can_create_card_on_pend (
        plan_code_in in plans.plan_code%type
    ) return varchar2 is
        l_flag varchar2(1) := 'N';
    begin
        for x in (
            select
                create_card_on_pend
            from
                plans
            where
                plan_code = plan_code_in
        ) loop
            l_flag := x.create_card_on_pend;
        end loop;

        return l_flag;
    end can_create_card_on_pend;
-- 6588

end pc_plan;
/

