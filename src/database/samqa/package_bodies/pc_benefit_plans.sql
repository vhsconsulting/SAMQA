create or replace package body samqa.pc_benefit_plans as

    function check_dup_plans (
        p_acc_id          in number,
        p_plan_type       in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_number     in varchar2
    ) return varchar2 is
        l_error_message varchar2(255);
        l_plan_exp exception;
    begin
        pc_log.log_error('check_dup_plan_type,p_acc_id', p_acc_id);
        pc_log.log_error('check_dup_plan_type,p_plan_type ', p_plan_type);

    -- .    No individual can have more than one of any type of FSA
        for x in (
            select
                count(*) cnt
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and trunc(plan_start_date) = p_plan_start_date
                and trunc(plan_end_date) = p_plan_end_date
                and status in ( 'P', 'A' )
                and plan_type = p_plan_type
                and ben_plan_number = p_plan_number
        ) loop
            if x.cnt > 0 then
                l_error_message := p_plan_type || ' is already setup for this account within the given plan start and end date ';
                raise l_plan_exp;
            end if;
        end loop;

        return l_error_message;
    exception
        when l_plan_exp then
            return l_error_message;
    end check_dup_plans;

    function check_dup_plan_type (
        p_acc_id          in number,
        p_plan_type       in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return varchar2 is
        l_error_message varchar2(255);
        l_plan_exp exception;
    begin
        pc_log.log_error('check_dup_plan_type,p_acc_id', p_acc_id);
        pc_log.log_error('check_dup_plan_type,p_plan_type ', p_plan_type);

    -- .    No individual can have more than one of any type of FSA
        for x in (
            select
                count(*) cnt
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and trunc(plan_start_date) = p_plan_start_date
                and trunc(plan_end_date) = p_plan_end_date
                and status in ( 'P', 'A' )
                and plan_type = p_plan_type
        ) loop
            if x.cnt > 0 then
                l_error_message := p_plan_type || ' is already setup for this account within the given plan start and end date ';
                raise l_plan_exp;
            end if;
        end loop;

        if pc_lookups.get_meaning(p_plan_type, 'FSA_HRA_PRODUCT_MAP') = 'HRA' then
            for x in (
                select
                    count(*) cnt
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = p_acc_id
                    and p_plan_start_date >= trunc(plan_start_date)
                    and p_plan_start_date <= trunc(plan_end_date)
                    and status in ( 'P', 'A' )
                    and plan_type = p_plan_type
            ) loop
                if x.cnt > 0 then
                    l_error_message := p_plan_type || ' is already setup for this account .Select suitable non-overlapping dates ';
                    raise l_plan_exp;
                end if;
            end loop;
        end if;

   /*  FOR X IN (SELECT  COUNT(*) CNT
                FROM  BEN_PLAN_ENROLLMENT_SETUP
               WHERE  ACC_ID = P_ACC_ID
               AND    STATUS IN ('P','A')
               AND    TRUNC(PLAN_END_DATE) > p_plan_start_date
               AND    PLAN_TYPE = P_PLAN_TYPE)
     LOOP

          IF X.CNT > 0 THEN
             L_ERROR_MESSAGE := p_plan_type ||' is already setup for this account and is active , duplicate plan types are not allowed ';
             RAISE l_plan_exp;

          END IF;

     END LOOP;*/
     -- .    No individual can have a Healthcare FSA and Limited Purpose FSA
        if p_plan_type in ( 'FSA', 'LPF' ) then
            for x in (
                select
                    count(*) cnt
                from
                    ben_plan_enrollment_setup a,
                    account                   b
                where
                        a.acc_id = p_acc_id
                    and b.entrp_id is null
                    and a.acc_id = b.acc_id
                    and trunc(a.plan_start_date) = p_plan_start_date
                    and trunc(a.plan_end_date) = p_plan_end_date
                    and a.status in ( 'P', 'A' )
                    and a.plan_type = decode(p_plan_type, 'FSA', 'LPF', 'FSA')
            ) loop
                if x.cnt > 1 then
                    l_error_message := 'Cannot have Health care FSA and Limited Purpose FSA benefit plans ';
                    raise l_plan_exp;
                end if;
            end loop;
        end if;

        return l_error_message;
    exception
        when l_plan_exp then
            return l_error_message;
    end check_dup_plan_type;

    function get_ee_annual_election (
        p_acc_id    in number,
        p_plan_type in varchar2
    ) return number is
        l_annual_election number;
    begin
        for x in (
            select
                annual_election
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and plan_type = p_plan_type
                and status <> 'R'
                and trunc(plan_start_date) <= trunc(sysdate)
                and trunc(plan_end_date) >= trunc(sysdate)
        ) loop
            l_annual_election := x.annual_election;
        end loop;

        return l_annual_election;
    end get_ee_annual_election;

    function get_ee_annual_election (
        p_acc_id          in number,
        p_plan_type       in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return number is
        l_annual_election number;
    begin
        for x in (
            select
                annual_election
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and plan_type = p_plan_type
                and status <> 'R'
                and plan_start_date = p_plan_start_date
                and plan_end_date = p_plan_end_date
        ) loop
            l_annual_election := x.annual_election;
        end loop;

        return l_annual_election;
    end get_ee_annual_election;

    function get_hra_ben_plan_type (
        p_acc_id       in number,
        p_account_type in varchar2
    ) return varchar2 is
        l_plan_type varchar2(3200);
    begin
        for x in (
            select
                plan_type
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and product_type = 'HRA'
                and status <> 'R'
                and trunc(plan_start_date) <= trunc(sysdate)
                and trunc(plan_end_date) >= trunc(sysdate)
        ) loop
            l_plan_type := x.plan_type;
        end loop;

        return l_plan_type;
    end get_hra_ben_plan_type;

    function get_ben_account_type (
        p_acc_id in number
    ) return varchar2 is
        l_plan_type varchar2(3200);
    begin
        for x in (
            select
                acc_id,
                sum(
                    case
                        when product_type = 'HRA' then
                            1
                        else
                            0
                    end
                ) hra_cnt,
                sum(
                    case
                        when product_type = 'FSA' then
                            1
                        else
                            0
                    end
                ) fsa_cnt
            from
                ben_plan_enrollment_setup
            where
                    trunc(plan_end_date) >= trunc(sysdate)
                and acc_id = p_acc_id
                and status = 'A'
            group by
                acc_id
        ) loop
            if
                x.hra_cnt > 0
                and x.fsa_cnt > 0
            then
                l_plan_type := 'HRAFSA';
            end if;

            if
                x.hra_cnt = 0
                and x.fsa_cnt > 0
            then
                l_plan_type := 'FSA';
            end if;

            if
                x.hra_cnt > 0
                and x.fsa_cnt = 0
            then
                l_plan_type := 'HRA';
            end if;

        end loop;

        return l_plan_type;
    end get_ben_account_type;

    function get_entrp_ben_account_type (
        p_entrp_id in number
    ) return varchar2 is
        l_plan_type varchar2(3200);
    begin
        for x in (
            select
                acc_id,
                sum(
                    case
                        when product_type = 'HRA' then
                            1
                        else
                            0
                    end
                ) hra_cnt,
                sum(
                    case
                        when product_type = 'FSA' then
                            1
                        else
                            0
                    end
                ) fsa_cnt
            from
                ben_plan_enrollment_setup
            where
                entrp_id = p_entrp_id
            group by
                acc_id
        ) loop
            if
                x.hra_cnt > 0
                and x.fsa_cnt > 0
            then
                l_plan_type := 'Stacked';
            end if;

            if
                x.hra_cnt = 0
                and x.fsa_cnt > 0
            then
                l_plan_type := 'FSA';
            end if;

            if
                x.hra_cnt > 0
                and x.fsa_cnt = 0
            then
                l_plan_type := 'HRA';
            end if;

        end loop;

        return l_plan_type;
    end get_entrp_ben_account_type;

    function get_ben_plan_type (
        p_ben_plan_id in number
    ) return varchar2 is
        l_plan_type varchar2(3200);
    begin
        for x in (
            select
                plan_type
            from
                ben_plan_enrollment_setup
            where
                    ben_plan_id = p_ben_plan_id
                and status in ( 'P', 'I', 'A' )
        ) loop
            l_plan_type := x.plan_type;
        end loop;

        return l_plan_type;
    end get_ben_plan_type;

    function get_ben_plan_status (
        p_er_ben_plan_id in number,
        p_acc_id         in number
    ) return varchar2 is
        l_plan_status varchar2(3200);
    begin
        for x in (
            select
                pc_lookups.get_meaning(status, 'BEN_PLAN_STATUS') status --DECODE(STATUS,'I','Inactive','Active') status
            from
                ben_plan_enrollment_setup
            where
                    ben_plan_id_main = p_er_ben_plan_id
                and acc_id = p_acc_id
        ) loop
            l_plan_status := x.status;
        end loop;

        return l_plan_status;
    end get_ben_plan_status;

    function check_validity (
        p_acc_id          in number,
        p_plan_type       in varchar2,
        p_annual_election in number,
        p_effective_date  in date,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return varchar2 is
        l_error_message varchar2(255);
        l_exists        varchar2(255) := 'N';
    begin
        for x in (
            select
                a.minimum_election,
                a.maximum_election,
                a.annual_election,
                a.plan_start_date,
                a.plan_end_date
            from
                ben_plan_enrollment_setup a,
                account                   ee,
                person                    c,
                account                   er
            where
                    ee.acc_id = p_acc_id
                and ee.pers_id = c.pers_id
                and er.entrp_id = c.entrp_id
                and er.account_type = 'FSA'
                and ee.account_type = 'FSA'
                and a.status <> 'R'
                and er.acc_id = a.acc_id
                and a.plan_type = p_plan_type
        ) loop
         --.    Annual elections for an individual.s Healthcare FSA or Limited Purpose FSA should be checked against the employer.s set minimum and maximum, if set.
        -- .    All annual elections should be checked against the IRS Limits outlined above.
            l_exists := 'Y';
            if
                p_plan_type in ( 'FSA', 'LPF' )
                and p_annual_election is not null
            then
                if
                    nvl(x.minimum_election, 0) > 0
                    and nvl(x.maximum_election, 0) > 0
                    and p_annual_election < nvl(x.minimum_election, 0)
                    and p_annual_election > nvl(x.maximum_election, p_annual_election)
                then
                    l_error_message := 'Annual Election '
                                       || p_annual_election
                                       || ' exceeds employer allowed annual election limits '
                                       || nvl(x.minimum_election, 0)
                                       || ' and '
                                       || nvl(x.maximum_election, p_annual_election);

                end if;

            else
         /*    IF p_annual_election > pc_param.get_fsa_irs_limit('INDIVIDUAL_CONTRIBUTION',
                                                              P_PLAN_TYPE,SYSDATE) THEN
                L_ERROR_MESSAGE := 'Annual Election '|| p_annual_election|| ' exceeds IRS allowed annual election limits '||
                                pc_param.get_fsa_irs_limit('INDIVIDUAL_CONTRIBUTION',
                                                              P_PLAN_TYPE,SYSDATE)||' for plan type '||P_PLAN_TYPE;
             END IF;*/
                null;
            end if;

            pc_log.log_error('PC_BENEFIT_PLANS.effective_date', p_effective_date);
            pc_log.log_error('PC_BENEFIT_PLANS,X.PLAN_START_DATE', x.plan_start_date);
            pc_log.log_error('PC_BENEFIT_PLANS,X.PLAN_end_DATE', x.plan_end_date);
            if
                p_effective_date >= x.plan_start_date
                and p_effective_date <= x.plan_end_date
            then
                null;
            else
                l_error_message := 'Effective Date '
                                   || p_effective_date
                                   || '  cannot be outside of the plan year '
                                   || x.plan_start_date
                                   || ' AND '
                                   || x.plan_end_date
                                   || ' offered by employer ';
            end if;

        end loop;

        if l_exists = 'N' then
            l_error_message := p_plan_type || ' plan type is not offered by employer ';
        end if;
        return l_error_message;
    end check_validity;

    procedure end_date_benefit_plans is
    begin
        update ben_plan_enrollment_setup
        set
            effective_end_date = sysdate,
            status = 'I'
        where
            trunc(plan_end_date) + nvl(runout_period_days, 0) + decode(grace_period, 2.5, 75, null, 0,
                                                                       grace_period) <= trunc(sysdate);

    end end_date_benefit_plans;

    function get_ben_plan (
        p_er_ben_plan_id in number,
        p_acc_id         in number
    ) return number is
        l_count number;
    begin
        for x in (
            select
                ben_plan_id
            from
                ben_plan_enrollment_setup
            where
                    ben_plan_id_main = p_er_ben_plan_id
                and acc_id = p_acc_id
                and status in ( 'P', 'I', 'A' )
        ) loop
            l_count := x.ben_plan_id;
        end loop;

        return l_count;
    end;

    function get_annual_election (
        p_er_ben_plan_id in number,
        p_acc_id         in number
    ) return number is
        l_annual_election number;
    begin
        for x in (
            select
                annual_election
            from
                ben_plan_enrollment_setup
            where
                    ben_plan_id_main = p_er_ben_plan_id
                and acc_id = p_acc_id
                and status in ( 'P', 'I', 'A' )
        ) loop
            l_annual_election := x.annual_election;
        end loop;

        return l_annual_election;
    end;

    function get_cov_tier_name (
        p_er_ben_plan_id in number,
        p_acc_id         in number
    ) return varchar2 is
        l_cov_tier_name varchar2(3200);
    begin
        for x in (
            select
                b.coverage_tier_name
            from
                ben_plan_enrollment_setup a,
                ben_plan_coverages        b
            where
                    a.ben_plan_id_main = p_er_ben_plan_id
                and a.ben_plan_id = b.ben_plan_id
                and a.status in ( 'P', 'I', 'A' )
                and a.acc_id = p_acc_id
        ) loop
            l_cov_tier_name := x.coverage_tier_name;
        end loop;

        return l_cov_tier_name;
    end get_cov_tier_name;

    function get_deductible (
        p_er_ben_plan_id in number,
        p_acc_id         in number
    ) return varchar2 is
        l_deductible varchar2(100);
    begin
        for x in (
            select
                b.deductible
            from
                ben_plan_enrollment_setup a,
                ben_plan_coverages        b
            where
                    a.ben_plan_id_main = p_er_ben_plan_id
                and a.ben_plan_id = b.ben_plan_id
                and a.status in ( 'P', 'I', 'A' )
                and a.acc_id = p_acc_id
        ) loop
            l_deductible := x.deductible;
        end loop;

        return l_deductible;
    end get_deductible;

    procedure add_renew_employees (
        p_acc_id          in number,
        p_annual_election in number,
        p_er_ben_plan_id  in number,
        p_user_id         in number,
        p_cov_tier_name   in varchar2 default null,
        p_effective_date  in date default null,
        p_batch_number    in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2,
        p_status          in varchar2 default 'A',
        p_life_event_code in varchar2 default null
    ) is
    begin
        x_return_status := 'S';
        insert into ben_plan_enrollment_setup (
            ben_plan_id,
            ben_plan_name,
            ben_plan_number,
            plan_start_date,
            plan_end_date,
            status,
            runout_period_days,
            runout_period_term,
            funding_options,
            reimbursement_type,
            reimbursement_ded,
            rollover,
            term_eligibility,
            funding_type,
            acc_id,
            new_hire_contrib,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            note,
            plan_type,
            annual_election,
            effective_date,
            ben_plan_id_main,
            batch_number,
            grace_period,
            sf_ordinance_flag,
            allow_substantiation,
            product_type,
            life_event_code,
            claim_reimbursed_by
        )  -- Column added by swamy on 17/05/2018 wrt Ticket#5693)
            select
                ben_plan_seq.nextval,
                emp_plan.ben_plan_name,
                emp_plan.ben_plan_number,
                emp_plan.plan_start_date,
                emp_plan.plan_end_date,
                p_status,
                emp_plan.runout_period_days,
                emp_plan.runout_period_term,
                emp_plan.funding_options,
                emp_plan.reimbursement_type,
                emp_plan.reimbursement_ded,
                emp_plan.rollover,
                emp_plan.term_eligibility,
                emp_plan.funding_type,
                p_acc_id,
                emp_plan.new_hire_contrib,
                sysdate,
                nvl(
                    get_user_id(v('APP_USER')),
                    p_user_id
                ) -- 7781 rprabu
                ,
                sysdate,
                p_user_id,
                emp_plan.note,
                emp_plan.plan_type,
                p_annual_election,
                nvl(p_effective_date, sysdate)
           --   , CASE WHEN EMP_PLAN.PLAN_START_DATE > SYSDATE THEN EMP_PLAN.PLAN_START_DATE ELSE SYSDATE END
                ,
                emp_plan.ben_plan_id,
                p_batch_number,
                emp_plan.grace_period,
                decode(emp_plan.appl_all_emp, 'Y', emp_plan.sf_ordinance_flag),
                emp_plan.allow_substantiation,
                pc_lookups.get_meaning(emp_plan.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                nvl(p_life_event_code, 'OPEN_ENROLLMENT'),
                emp_plan.claim_reimbursed_by   -- Column added by swamy on 17/05/2018 wrt Ticket#5693
            from
                ben_plan_enrollment_setup emp_plan
            where
                ben_plan_id = p_er_ben_plan_id;

        if p_cov_tier_name is not null then
            insert into ben_plan_coverages (
                coverage_id,
                ben_plan_id,
                acc_id,
                coverage_type,
                deductible,
                start_date,
                end_date,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                fixed_funding_amount,
                annual_election,
                fixed_funding_flag,
                deductible_rule_id,
                coverage_tier_name,
                max_rollover_amount
            )--Added 04/14/2015
                select
                    coverage_seq.nextval,
                    c.ben_plan_id,
                    p_acc_id,
                    b.coverage_type,
                    b.deductible,
                    b.start_date,
                    b.end_date,
                    sysdate,
                    0,
                    sysdate,
                    0,
                    b.fixed_funding_amount,
                    p_annual_election,
                    b.fixed_funding_flag,
                    b.deductible_rule_id,
                    b.coverage_tier_name,
                    max_rollover_amount   --Added 04/14/2015
                from
                    ben_plan_coverages        b,
                    ben_plan_enrollment_setup c
                where
                        b.ben_plan_id = c.ben_plan_id_main
                    and c.ben_plan_id_main = p_er_ben_plan_id
                    and c.acc_id = p_acc_id
                    and c.status in ( 'P', 'I', 'A' )
                    and trunc(c.creation_date) = trunc(sysdate)
                    and upper(b.coverage_tier_name) = upper(ltrim(rtrim(p_cov_tier_name)));

        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end;

    procedure insert_benefit_plan (
        p_er_ben_plan_id  in number,
        p_acc_id          in number,
        p_effective_date  in varchar2,
        p_annual_election in number,
        p_coverage_level  in varchar2,
        p_batch_number    in number default null,
        p_cov_tier_name   in varchar2 default null,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is
        l_ee_ben_plan_id number;
    begin
        x_return_status := 'S';
        select
            ben_plan_seq.nextval
        into l_ee_ben_plan_id
        from
            dual;

        pc_log.log_error('insert_benefit_plan ', 'INSERTED BEN  PLAN'
                                                 || 'p_er_ben_plan_id '
                                                 || p_er_ben_plan_id
                                                 || ' effective date '
                                                 || p_effective_date);

     -- Add benefit plan
        insert into ben_plan_enrollment_setup (
            ben_plan_id,
            ben_plan_name,
            ben_plan_number,
            plan_start_date,
            plan_end_date,
            status,
            runout_period_days,
            runout_period_term,
            funding_options,
            reimbursement_type,
            reimbursement_ded,
            rollover,
            term_eligibility,
            funding_type,
            acc_id,
            new_hire_contrib,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            note,
            plan_type,
            annual_election,
            effective_date,
            ben_plan_id_main,
            batch_number,
            grace_period,
            sf_ordinance_flag,
            allow_substantiation,
            product_type
        )
            select
                l_ee_ben_plan_id,
                emp_plan.ben_plan_name,
                emp_plan.ben_plan_number,
                emp_plan.plan_start_date,
                emp_plan.plan_end_date,
                'A',
                emp_plan.runout_period_days,
                emp_plan.runout_period_term,
                emp_plan.funding_options,
                emp_plan.reimbursement_type,
                emp_plan.reimbursement_ded,
                emp_plan.rollover,
                emp_plan.term_eligibility,
                emp_plan.funding_type,
                p_acc_id,
                emp_plan.new_hire_contrib,
                sysdate,
                0,
                sysdate,
                0,
                emp_plan.note,
                emp_plan.plan_type,
                p_annual_election -- I need to get coverage level to know annual election
                ,
                nvl(
                    format_to_date(p_effective_date),
                    emp_plan.plan_start_date
                ),
                emp_plan.ben_plan_id,
                p_batch_number,
                emp_plan.grace_period,
                decode(emp_plan.appl_all_emp, 'Y', emp_plan.sf_ordinance_flag),
                emp_plan.allow_substantiation,
                pc_lookups.get_meaning(emp_plan.plan_type, 'FSA_HRA_PRODUCT_MAP')
            from
                ben_plan_enrollment_setup emp_plan
            where
                    emp_plan.ben_plan_id = p_er_ben_plan_id
                and emp_plan.plan_start_date <= format_to_date(p_effective_date)
                and emp_plan.plan_end_date >= format_to_date(p_effective_date)
                and not exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup ee_plan
                    where
                            ee_plan.acc_id = p_acc_id
                        and ee_plan.status <> 'R'
                        and ee_plan.plan_start_date <= format_to_date(p_effective_date)
                        and ee_plan.plan_end_date >= format_to_date(p_effective_date)
                        and ee_plan.plan_type = emp_plan.plan_type
                        and ee_plan.ben_plan_name = emp_plan.ben_plan_name
                );

        dbms_output.put_line('p_er_ben_plan_id ' || p_er_ben_plan_id);
        dbms_output.put_line('p_coverage_level ' || p_coverage_level);
        pc_log.log_error('insert_benefit_plan ', 'INSERTED BEN  PLAN'
                                                 || 'p_er_ben_plan_id '
                                                 || p_er_ben_plan_id);
        if
            p_coverage_level is not null
            and p_cov_tier_name is null
        then
            insert into ben_plan_coverages (
                coverage_id,
                ben_plan_id,
                acc_id,
                coverage_type,
                deductible,
                start_date,
                end_date,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                fixed_funding_amount,
                annual_election,
                fixed_funding_flag,
                deductible_rule_id,
                max_rollover_amount
            )
                select
                    coverage_seq.nextval,
                    l_ee_ben_plan_id,
                    p_acc_id,
                    b.coverage_type,
                    b.deductible,
                    b.start_date,
                    b.end_date,
                    sysdate,
                    0,
                    sysdate,
                    0,
                    b.fixed_funding_amount,
                    p_annual_election,
                    b.fixed_funding_flag,
                    b.deductible_rule_id,
                    b.max_rollover_amount
                from
                    ben_plan_coverages b
                where
                        b.ben_plan_id = p_er_ben_plan_id
                    and b.coverage_type = p_coverage_level;

        end if;

        if p_cov_tier_name is not null then
            insert into ben_plan_coverages (
                coverage_id,
                ben_plan_id,
                acc_id,
                coverage_type,
                deductible,
                start_date,
                end_date,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                fixed_funding_amount,
                annual_election,
                fixed_funding_flag,
                deductible_rule_id,
                coverage_tier_name,
                max_rollover_amount
            )
                select
                    coverage_seq.nextval,
                    l_ee_ben_plan_id,
                    p_acc_id,
                    b.coverage_type,
                    b.deductible,
                    b.start_date,
                    b.end_date,
                    sysdate,
                    0,
                    sysdate,
                    0,
                    b.fixed_funding_amount,
                    p_annual_election,
                    b.fixed_funding_flag,
                    b.deductible_rule_id,
                    b.coverage_tier_name,
                    b.max_rollover_amount
                from
                    ben_plan_coverages b
                where
                        b.ben_plan_id = p_er_ben_plan_id
                    and b.coverage_tier_name = p_cov_tier_name;

        end if;

    exception
        when others then
            pc_log.log_error('insert_benefit_plan ', sqlerrm);
            x_error_message := sqlerrm;
            x_return_status := 'E';
    end insert_benefit_plan;

    procedure insert_benefit_plan (
        p_er_ben_plan_id  in number,
        p_acc_id          in number,
        p_effective_date  in varchar2,
        p_annual_election in number,
        p_coverage_level  in varchar2,
        p_eob_required    in varchar2 default null,
        p_batch_number    in number default null,
        p_cov_tier_name   in varchar2 default null,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is
        l_ee_ben_plan_id number;
    begin
        x_return_status := 'S';
        select
            ben_plan_seq.nextval
        into l_ee_ben_plan_id
        from
            dual;

        dbms_output.put_line('a');
        pc_log.log_error('insert_benefit_plan ', 'INSERTED BEN  PLAN'
                                                 || 'p_er_ben_plan_id '
                                                 || p_er_ben_plan_id
                                                 || ' effective date '
                                                 || p_effective_date);

        pc_log.log_error('test check', '  p_er_ben_plan_id==>'
                                       || p_er_ben_plan_id
                                       || '  p_acc_id==>'
                                       || p_acc_id
                                       || '   p_effective_date==>'
                                       || p_effective_date
                                       || '  p_annual_election==>'
                                       || p_annual_election
                                       || '   p_coverage_level==>'
                                       || p_coverage_level
                                       || '   p_eob_required==>'
                                       || p_eob_required
                                       || '  p_batch_number==>'
                                       || p_batch_number
                                       || '   p_cov_tier_name==>'
                                       || p_cov_tier_name);
     -- Add benefit plan
        insert into ben_plan_enrollment_setup (
            ben_plan_id,
            ben_plan_name,
            ben_plan_number,
            plan_start_date,
            plan_end_date,
            status,
            runout_period_days,
            runout_period_term,
            funding_options,
            reimbursement_type,
            reimbursement_ded,
            rollover,
            term_eligibility,
            funding_type,
            acc_id,
            new_hire_contrib,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            note,
            plan_type,
            annual_election,
            effective_date,
            ben_plan_id_main,
            batch_number,
            grace_period,
            sf_ordinance_flag,
            allow_substantiation,
            product_type,
            eob_required
        )
            select
                l_ee_ben_plan_id,
                emp_plan.ben_plan_name,
                emp_plan.ben_plan_number,
                emp_plan.plan_start_date,
                emp_plan.plan_end_date,
                'A',
                emp_plan.runout_period_days,
                emp_plan.runout_period_term,
                emp_plan.funding_options,
                emp_plan.reimbursement_type,
                emp_plan.reimbursement_ded,
                emp_plan.rollover,
                emp_plan.term_eligibility,
                emp_plan.funding_type,
                p_acc_id,
                emp_plan.new_hire_contrib,
                sysdate,
                0,
                sysdate,
                0,
                emp_plan.note,
                emp_plan.plan_type,
                p_annual_election -- I need to get coverage level to know annual election
                ,
                nvl(
                    format_to_date(p_effective_date),
                    emp_plan.plan_start_date
                ),
                emp_plan.ben_plan_id,
                p_batch_number,
                emp_plan.grace_period,
                decode(emp_plan.appl_all_emp, 'Y', emp_plan.sf_ordinance_flag),
                emp_plan.allow_substantiation,
                pc_lookups.get_meaning(emp_plan.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                p_eob_required
            from
                ben_plan_enrollment_setup emp_plan
            where
                    emp_plan.ben_plan_id = p_er_ben_plan_id
                and emp_plan.plan_start_date <= format_to_date(p_effective_date)
                and emp_plan.plan_end_date >= format_to_date(p_effective_date)
                and not exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup ee_plan
                    where
                            ee_plan.acc_id = p_acc_id
                        and ee_plan.status <> 'R'
                        and ee_plan.plan_start_date <= format_to_date(p_effective_date)
                        and ee_plan.plan_end_date >= format_to_date(p_effective_date)
                        and ee_plan.plan_type = emp_plan.plan_type
                        and ee_plan.ben_plan_name = emp_plan.ben_plan_name
                );

        dbms_output.put_line('b');
        dbms_output.put_line('p_er_ben_plan_id ' || p_er_ben_plan_id);
        dbms_output.put_line('p_coverage_level ' || p_coverage_level);
        pc_log.log_error('insert_benefit_plan ', 'INSERTED BEN  PLAN'
                                                 || 'p_er_ben_plan_id '
                                                 || p_er_ben_plan_id);
        if
            p_coverage_level is not null
            and p_cov_tier_name is null
        then
            insert into ben_plan_coverages (
                coverage_id,
                ben_plan_id,
                acc_id,
                coverage_type,
                deductible,
                start_date,
                end_date,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                fixed_funding_amount,
                annual_election,
                fixed_funding_flag,
                deductible_rule_id
            )
                select
                    coverage_seq.nextval,
                    l_ee_ben_plan_id,
                    p_acc_id,
                    b.coverage_type,
                    b.deductible,
                    b.start_date,
                    b.end_date,
                    sysdate,
                    0,
                    sysdate,
                    0,
                    b.fixed_funding_amount,
                    p_annual_election,
                    b.fixed_funding_flag,
                    b.deductible_rule_id
                from
                    ben_plan_coverages b
                where
                        b.ben_plan_id = p_er_ben_plan_id
                    and b.coverage_type = p_coverage_level;

            dbms_output.put_line('c');
        end if;

        if p_cov_tier_name is not null then
            insert into ben_plan_coverages (
                coverage_id,
                ben_plan_id,
                acc_id,
                coverage_type,
                deductible,
                start_date,
                end_date,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                fixed_funding_amount,
                annual_election,
                fixed_funding_flag,
                deductible_rule_id,
                coverage_tier_name
            )
                select
                    coverage_seq.nextval,
                    l_ee_ben_plan_id,
                    p_acc_id,
                    b.coverage_type,
                    b.deductible,
                    b.start_date,
                    b.end_date,
                    sysdate,
                    0,
                    sysdate,
                    0,
                    b.fixed_funding_amount,
                    p_annual_election,
                    b.fixed_funding_flag,
                    b.deductible_rule_id,
                    b.coverage_tier_name
                from
                    ben_plan_coverages b
                where
                        b.ben_plan_id = p_er_ben_plan_id
                    and b.coverage_tier_name = p_cov_tier_name;

            dbms_output.put_line('d');
        end if;

    exception
        when others then
            pc_log.log_error('insert_benefit_plan ', sqlerrm);
            x_error_message := sqlerrm;
            x_return_status := 'E';
    end insert_benefit_plan;

    function get_er_ben_plan (
        p_entrp_id       in number,
        p_plan_type      in varchar2,
        p_effective_date in date
    ) return number is
        l_er_ben_plan_id number;
    begin
        for x in (
            select
                ben_plan_id
            from
                ben_plan_enrollment_setup
            where
                    entrp_id = p_entrp_id
                and plan_type = p_plan_type
                and trunc(plan_start_date) <= p_effective_date
                and trunc(plan_end_date) >= p_effective_date
        ) loop
            l_er_ben_plan_id := x.ben_plan_id;
        end loop;

        return l_er_ben_plan_id;
    end get_er_ben_plan;

    procedure create_annual_election (
        p_batch_number  in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_list_bill    number;
        l_exists       varchar2(1) := 'N';
        l_check_number varchar2(30);
    begin
        x_return_status := 'S';
        for x in (
            select
                a.ben_plan_id,
                a.entrp_id,
                a.plan_type,
                a.plan_start_date,
                sum(nvl(b.annual_election, 0)) check_amount
            from
                ben_plan_enrollment_setup a,
                ben_plan_enrollment_setup b
            where
                    b.batch_number = p_batch_number
                and a.ben_plan_id = b.ben_plan_id_main
                and a.entrp_id is not null
                and a.plan_type is not null
                and b.status = 'A'
               -- AND   TRUNC(A.PLAN_END_DATE) >= TRUNC(SYSDATE)
            group by
                a.ben_plan_id,
                a.entrp_id,
                a.plan_type,
                a.plan_start_date
            having
                sum(nvl(b.annual_election, 0)) > 0
        ) loop
            l_list_bill := null;
            l_check_number := 'AE:'
                              || to_char(p_batch_number)
                              || ':'
                              || x.ben_plan_id;

            for kk in (
                select
                    list_bill
                from
                    employer_deposits
                where
                        entrp_id = x.entrp_id
                    and check_number = l_check_number
                    and plan_type = x.plan_type
            ) loop
                l_list_bill := kk.list_bill;
            end loop;

            if l_list_bill is null then
                select
                    employer_deposit_seq.nextval
                into l_list_bill
                from
                    dual;

                pc_fin.create_employer_deposit(
                    p_list_bill          => l_list_bill,
                    p_entrp_id           => x.entrp_id,
                    p_check_amount       => x.check_amount,
                    p_check_date         => x.plan_start_date,
                    p_posted_balance     => x.check_amount,
                    p_fee_bucket_balance => 0,
                    p_remaining_balance  => 0,
                    p_user_id            => p_user_id,
                    p_plan_type          => x.plan_type,
                    p_note               => 'Posting Annual election',
                    p_reason_code        => 12,
                    p_check_number       => l_check_number
                );

            else
                update employer_deposits
                set
                    check_amount = x.check_amount,
                    last_update_date = sysdate,
                    last_updated_by = 0,
                    posted_balance = x.check_amount
                where
                        entrp_id = x.entrp_id
                    and check_number = l_check_number;

            end if;

            for xx in (
                select
                    *
                from
                    ben_plan_enrollment_setup
                where
                        ben_plan_id_main = x.ben_plan_id
                    and batch_number = p_batch_number
                    and status = 'A'
            ) loop
                begin
                    pc_fin.create_receipt(
                        p_acc_id            => xx.acc_id,
                        p_fee_date          => xx.effective_date,
                        p_entrp_id          => x.entrp_id,
                        p_er_amount         => nvl(xx.annual_election, 0),
                        p_pay_code          => 6,
                        p_plan_type         => x.plan_type,
                        p_debit_card_posted => 'N',
                        p_list_bill         => l_list_bill,
                        p_fee_reason        => 12,
                        p_note              => 'Posting Annual Election',
                        p_check_amount      => x.check_amount,
                        p_user_id           => p_user_id,
                        p_check_number      => l_check_number
                    );

                exception
                    when others then
                        dbms_output.put_line('ACC ID ' || xx.acc_id);
                end;
            end loop;

        end loop;

    end create_annual_election;

    procedure update_deductible_rule (
        p_er_ben_plan_id in number
    ) is
    begin
        for x in (
            select
                er_bc.deductible_rule_id,
                ee_bp.acc_id,
                ee_bp.ben_plan_id,
                er_bp.acc_id er_acc_id,
                er_bc.max_rollover_amount
            from
                ben_plan_enrollment_setup er_bp,
                ben_plan_coverages        er_bc,
                ben_plan_enrollment_setup ee_bp,
                ben_plan_coverages        ee_bc
            where
                    er_bp.ben_plan_id = ee_bp.ben_plan_id_main
                and er_bc.ben_plan_id = er_bp.ben_plan_id
                and ee_bc.ben_plan_id = ee_bp.ben_plan_id
                and er_bp.ben_plan_id = p_er_ben_plan_id
                and ee_bp.status <> 'R'
                and er_bc.deductible_rule_id is not null
                and ee_bc.deductible_rule_id is null
        ) loop
            update ben_plan_coverages
            set
                deductible_rule_id = x.deductible_rule_id,
                max_rollover_amount = x.max_rollover_amount
            where
                ben_plan_id = x.ben_plan_id;

        end loop;

        for x in (
            select
                er_bc.deductible_rule_id,
                ee_bp.acc_id,
                ee_bp.ben_plan_id,
                er_bp.acc_id er_acc_id,
                er_bc.max_rollover_amount
            from
                ben_plan_enrollment_setup er_bp,
                ben_plan_coverages        er_bc,
                ben_plan_enrollment_setup ee_bp,
                ben_plan_coverages        ee_bc
            where
                    er_bp.ben_plan_id = ee_bp.ben_plan_id_main
                and er_bc.ben_plan_id = er_bp.ben_plan_id
                and ee_bp.status <> 'R'
                and ee_bc.ben_plan_id = ee_bp.ben_plan_id
                and er_bp.ben_plan_id = p_er_ben_plan_id
        ) loop
            update ben_plan_coverages
            set
                max_rollover_amount = x.max_rollover_amount
            where
                ben_plan_id = x.ben_plan_id;

        end loop;

    end update_deductible_rule;

    procedure create_benefit_coverage (
        p_er_ben_plan_id in number,
        p_cov_tier_name  in varchar2,
        p_acc_id         in number default null,
        p_user_id        in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    ) is
    begin
        x_return_status := 'S';
        insert into ben_plan_coverages (
            coverage_id,
            ben_plan_id,
            acc_id,
            coverage_type,
            deductible,
            start_date,
            end_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            fixed_funding_amount,
            annual_election,
            fixed_funding_flag,
            deductible_rule_id,
            coverage_tier_name,
            max_rollover_amount   --Added 04/14/2015
        )
            select
                coverage_seq.nextval,
                b.ben_plan_id,
                b.acc_id,
                c.coverage_type,
                c.deductible,
                c.start_date,
                c.end_date,
                sysdate,
                0,
                sysdate,
                0,
                c.fixed_funding_amount,
                b.annual_election,
                c.fixed_funding_flag,
                c.deductible_rule_id,
                c.coverage_tier_name,
                c.max_rollover_amount   --Added 04/14/2015
            from
                ben_plan_enrollment_setup a,
                ben_plan_enrollment_setup b,
                ben_plan_coverages        c
            where
                    a.ben_plan_id = p_er_ben_plan_id
                and a.ben_plan_id = b.ben_plan_id_main
                and a.entrp_id is not null
                and a.plan_type is not null
                and ( b.product_type = 'HRA'
                      or ( b.plan_type in ( 'FSA', 'LPF' )
                           and nvl(b.grace_period, 0) = 0 ) )
                and a.status <> 'R'
                and b.status <> 'R'
                and a.ben_plan_id = c.ben_plan_id
                and b.acc_id = nvl(p_acc_id, b.acc_id)
                and upper(c.coverage_tier_name) = upper(p_cov_tier_name)
                and not exists (
                    select
                        *
                    from
                        ben_plan_coverages d
                    where
                            d.ben_plan_id = b.ben_plan_id
                        and upper(c.coverage_tier_name) = upper(d.coverage_tier_name)
                );

    end create_benefit_coverage;

    procedure create_fsa_coverage (
        p_ben_plan_id   in number,
        p_cov_tier_name in varchar2,
        p_user_id       in number
    ) is
    begin
        insert into ben_plan_coverages (
            coverage_id,
            ben_plan_id,
            acc_id,
            coverage_type,
            deductible,
            start_date,
            end_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            fixed_funding_amount,
            annual_election,
            fixed_funding_flag,
            deductible_rule_id,
            coverage_tier_name,
            max_rollover_amount
        )
            select
                coverage_seq.nextval,
                ben_plan_id,
                acc_id,
                'SINGLE',
                null,
                plan_start_date,
                plan_end_date,
                sysdate,
                p_user_id,
                sysdate,
                nvl(
                    v('USER_ID'),
                    0
                ),
                p_user_id,
                annual_election,
                null,
                null,
                nvl('SINGLE', p_cov_tier_name)
            -- ,  500 Commented by Joshi on 11/05/2023. changed to $610(ticket:11860)
          --  , 610 
                ,
                pc_benefit_plans.max_rollover_amount  -- Added by joshi for 12413
            from
                ben_plan_enrollment_setup c
            where
                    ben_plan_id = p_ben_plan_id
                and not exists (
                    select
                        *
                    from
                        ben_plan_coverages d
                    where
                            d.ben_plan_id = c.ben_plan_id
                        and upper(d.coverage_tier_name) = nvl('SINGLE', p_cov_tier_name)
                );

    end create_fsa_coverage;

    procedure add_fsa_cov_tier (
        p_ben_plan_id   in number,
        p_entrp_id      in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

        l_return_status   varchar2(100);
        l_error_message   varchar2(1000);
        l_batch_number    number(30);
        l_annual_election number(10);
        l_success         varchar2(100);
--l_ee_assigned  NUMBER(10);
    begin
        l_batch_number := batch_num_seq.nextval;
 --Assuming for FSA type only 1 record is created.
/*  SELECT NVL(annual_election,0)
  INTO l_annual_election
  FROM ben_plan_coverages
  WHERE ben_plan_id = P_BEN_PLAN_ID;*/
        for x in (
            select
                c.ben_plan_id,
                b.coverage_type,
                b.deductible,
                b.start_date,
                b.end_date,
                b.fixed_funding_amount,
                b.annual_election,
                b.fixed_funding_flag,
                b.deductible_rule_id,
                b.coverage_tier_name,
                b.max_rollover_amount
            from
                ben_plan_coverages        b,
                ben_plan_enrollment_setup c
            where
                    b.ben_plan_id = c.ben_plan_id_main
                and c.ben_plan_id_main = p_ben_plan_id
                and c.plan_type in ( 'FSA', 'LPF' )
                and ( nvl(c.grace_period, 0) = 0 )
                and c.status in ( 'P', 'I', 'A' )
        ) loop
            update ben_plan_coverages
            set
                coverage_type = x.coverage_type,
                deductible = x.deductible,
                start_date = x.start_date,
                end_date = x.end_date,
                last_update_date = sysdate,
                last_updated_by = p_user_id,
                fixed_funding_amount = x.fixed_funding_amount,
                annual_election = x.annual_election,
                fixed_funding_flag = x.fixed_funding_flag,
                deductible_rule_id = x.deductible_rule_id,
                coverage_tier_name = x.coverage_tier_name,
                max_rollover_amount = x.max_rollover_amount
            where
                ben_plan_id = x.ben_plan_id;

        end loop;

        insert into ben_plan_coverages (
            coverage_id,
            ben_plan_id,
            acc_id,
            coverage_type,
            deductible,
            start_date,
            end_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            fixed_funding_amount,
            annual_election,
            fixed_funding_flag,
            deductible_rule_id,
            coverage_tier_name,
            max_rollover_amount
        )
            select
                coverage_seq.nextval,
                c.ben_plan_id,
                a.acc_id,
                b.coverage_type,
                b.deductible,
                b.start_date,
                b.end_date,
                sysdate,
                0,
                sysdate,
                0,
                b.fixed_funding_amount,
                b.annual_election,
                b.fixed_funding_flag,
                b.deductible_rule_id,
                b.coverage_tier_name,
                b.max_rollover_amount
            from
                ben_plan_coverages        b,
                ben_plan_enrollment_setup c,
                person                    d,
                account                   a
            where
                    b.ben_plan_id = c.ben_plan_id_main
                and c.ben_plan_id_main = p_ben_plan_id
                and a.acc_id = c.acc_id
                and d.pers_id = a.pers_id
                and a.account_type = 'FSA'
                and c.plan_type in ( 'FSA', 'LPF' )
                and ( nvl(c.grace_period, 0) = 0 )
                and b.coverage_tier_name = 'SINGLE'
                and c.status in ( 'P', 'I', 'A' )
                and not exists (
                    select
                        *
                    from
                        ben_plan_coverages e
                    where
                        e.ben_plan_id = c.ben_plan_id
                );

    end add_fsa_cov_tier;

    procedure hra_rollover (
        p_entrp_id      in number,
        p_ben_plan_id   in number,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
        l_setup_error exception;
    begin
        for x in (
            select
                entrp_id,
                er_acc_id,
                plan_type,
                er_name,
                plan_start_date,
                plan_end_date,
                er_ben_plan_id,
                sum(balance) balance
            from
                (
                    select
                        case
                            when termination_date is not null
                                 and termination_date < plan_end_date then
                                0
                            else
                                decode(max_rollover_amount,
                                       0,
                                       acc_balance,
                                       least(max_rollover_amount, acc_balance))
                        end                                 balance,
                        a.entrp_id,
                        pc_entrp.get_acc_id(a.entrp_id)     er_acc_id,
                        pc_entrp.get_entrp_name(a.entrp_id) er_name,
                        a.plan_type,
                        a.plan_start_date,
                        a.plan_end_date,
                        a.ben_plan_id_main                  er_ben_plan_id
                    from
                        fsa_hra_employees_v a,
                        ben_plan_coverages  b
                    where
                            a.entrp_id = p_entrp_id
                        and a.ben_plan_id_main = p_ben_plan_id
                        and a.ben_plan_id = b.ben_plan_id
                        and a.status <> 'R'
                        and ( a.termination_date is null
                              or a.termination_date > sysdate )
                        and exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup c
                            where
                                    c.acc_id = a.acc_id
                                and plan_end_date > sysdate
                                and c.status in ( 'P', 'I', 'A' )
                        )
                        and a.product_type = 'HRA'
                )
            group by
                entrp_id,
                er_acc_id,
                plan_type,
                er_name,
                plan_start_date,
                plan_end_date,
                er_ben_plan_id
        ) loop
            if x.plan_end_date > sysdate then
                x_error_message := 'Cannot perform rollover for current plan year';
                raise l_setup_error;
            end if;
            if x.er_ben_plan_id is null then
                x_error_message := 'Cannot process rollover as there are no renewed HRA plans for this employer';
                raise l_setup_error;
            end if;

    /*  FOR Xx IN ( SELECT *
                 FROM SCHEDULER_MASTER
                 WHERE acc_id = x.ER_ACC_ID
                 AND   plan_type = x.plan_type
                 AND   orig_system_source = 'ROLLOVER'
                 AND   orig_system_ref = P_BEN_PLAN_ID)
      LOOP
	             x_error_message := 'There is already a Rollover transaction processed for this employer ';
	             RAISE l_setup_error;
      END LOOP;*/
            pc_schedule.create_rollover(
                p_entrp_id        => x.entrp_id,
                p_ben_plan_id     => p_ben_plan_id,
                p_acc_id          => x.er_acc_id,
                p_amount          => x.balance,
                p_plan_type       => x.plan_type,
                p_er_name         => x.er_name,
                p_user_id         => p_user_id,
                p_plan_start_date => x.plan_start_date,
                p_plan_end_date   => x.plan_end_date
            );

        end loop;
    exception
        when l_setup_error then
            x_return_status := 'E';
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            null;
    end hra_rollover;

    procedure enable_sfo (
        p_sf_flg        in varchar,
        p_ben_plan_id   in number,
        p_qtly_date     in date,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
    begin
        pc_log.log_error('Enable_SFO ', 'P_BEN_PLAN_ID '
                                        || p_ben_plan_id
                                        || ' P_QTLY_DATE '
                                        || p_qtly_date);
    --If Sanfrancisco flag is 'Yes' in the SF Ordinance Employees Page Then
        if p_sf_flg = 'Y' then
            update ben_plan_enrollment_setup
            set
                sf_ordinance_flag = 'Y',
                qtly_rprt_start_date = p_qtly_date,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    ben_plan_id = p_ben_plan_id
                and status in ( 'P', 'A' );

        else --If Sanfrancisco flag is 'No' in the SF Ordinance Employees Page Then
            update ben_plan_enrollment_setup
            set
                sf_ordinance_flag = 'N',
                qtly_rprt_start_date = null,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    ben_plan_id = p_ben_plan_id
                and status in ( 'P', 'A' );

        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            null;
    end enable_sfo;

    function get_effective_date (
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date,
        p_plan_type  in varchar2
    ) return date is
        l_date date;
    begin
        for x in (
            select
                min(plan_start_date) plan_start_date
            from
                ben_plan_enrollment_setup
            where
                    entrp_id = p_entrp_id
                and ben_plan_id_main is null
                and plan_type = p_plan_type
                and status <> 'R'
                and plan_start_date <= p_start_date
                and plan_end_date >= p_end_date
        ) loop
            l_date := x.plan_start_date;
        end loop;

        if l_date is null then
            for x in (
                select
                    min(plan_start_date) plan_start_date
                from
                    ben_plan_enrollment_setup
                where
                        entrp_id = p_entrp_id
                    and ben_plan_id_main is null
                    and status <> 'R'
                    and plan_start_date <= p_start_date
                    and plan_end_date >= p_end_date
            ) loop
                l_date := x.plan_start_date;
            end loop;

        end if;

        if l_date is null then
            for x in (
                select
                    max(plan_start_date) plan_start_date
                from
                    ben_plan_enrollment_setup
                where
                        entrp_id = p_entrp_id
                    and ben_plan_id_main is null
                    and status <> 'R'
                    and plan_start_date <= p_start_date
                    and plan_end_date >= p_end_date
                    and plan_end_date < sysdate
            ) loop
                l_date := x.plan_start_date;
            end loop;
        end if;

        return l_date;
    end;

    function get_frequency (
        p_entrp_id      in number,
        p_pay_cycle     in varchar2,
        p_eff_date      in varchar2,
        p_plan_end_date in varchar2
    ) return number is
        l_freq_number number := 0;
        l_pay_count   number;
        l_frequency   varchar2(50);
    begin
        pc_log.log_error('get_frequency', 'P_EFF_DATE' || p_eff_date);
        pc_log.log_error('get_frequency', 'P_PLAN_END_DATE' || p_plan_end_date);
        pc_log.log_error('get_frequency', 'P_ENTRP_ID' || p_entrp_id);
        pc_log.log_error('get_frequency', 'P_PAY_CYCLE' || p_pay_cycle);
        l_freq_number := pc_schedule.get_frequency(p_pay_cycle, to_date(p_eff_date, 'MM/DD/YYYY'), to_date(p_plan_end_date, 'MM/DD/YYYY'
        ));

        return l_freq_number;

   /* commented by Joshi for 8127 and added below code.
   IF P_ENTRP_ID IS NOT NULL AND IS_NUMBER(P_PAY_CYCLE) = 'N' THEN
    SELECT COUNT(distinct period_date)
    INTO   l_freq_number
    FROM PAYROLL_CALENDAR
    WHERE ENTRP_ID = P_ENTRP_ID
    AND   FREQUENCY = P_PAY_CYCLE
    AND   PERIOD_DATE
    BETWEEN TO_DATE(P_EFF_DATE,'MM/DD/YYYY') AND TO_DATE(P_PLAN_END_DATE,'MM/DD/YYYY');

       PC_LOG.LOG_ERROR('get_frequency','l_freq_number' ||l_freq_number);

  END IF;
  IF P_ENTRP_ID IS NOT NULL AND  l_freq_number = 0 THEN
     IF IS_NUMBER(P_PAY_CYCLE) = 'Y' THEN
        SELECT COUNT(distinct period_date)
        INTO   l_freq_number
        FROM PAYROLL_CALENDAR
        WHERE ENTRP_ID = P_ENTRP_ID
        AND   SCHEDULER_ID = P_PAY_CYCLE
        AND   PERIOD_DATE
        BETWEEN TO_DATE(P_EFF_DATE,'MM/DD/YYYY') AND TO_DATE(P_PLAN_END_DATE,'MM/DD/YYYY');
    END IF;
  END IF;
    IF l_freq_number = 0 THEN
      IF IS_NUMBER(P_PAY_CYCLE) = 'Y' THEN

	    /* commented by Joshi for 8127 and added below code.
        SELECT COUNT(distinct period_date)
        INTO   l_freq_number
        FROM PAYROLL_CALENDAR
        WHERE ENTRP_ID IS NULL
        AND   SCHEDULER_ID = P_PAY_CYCLE
        AND   PERIOD_DATE
        BETWEEN TO_DATE(P_EFF_DATE,'MM/DD/YYYY') AND TO_DATE(P_PLAN_END_DATE,'MM/DD/YYYY');

		-- Added by Joshi for 8127.
        SELECT DISTINCT FREQUENCY
        INTO   l_frequency
        FROM PAYROLL_CALENDAR
        WHERE ENTRP_ID IS NULL
        AND   SCHEDULER_ID = P_PAY_CYCLE ;
        --AND   PERIOD_DATE
        --BETWEEN TO_DATE(P_EFF_DATE,'MM/DD/YYYY') AND TO_DATE(P_PLAN_END_DATE,'MM/DD/YYYY');
        l_freq_number := pc_schedule.GET_FREQUENCY(l_frequency, TO_DATE(P_EFF_DATE,'MM/DD/YYYY'),TO_DATE(P_PLAN_END_DATE,'MM/DD/YYYY'));

     ELSE
           SELECT COUNT(distinct period_date)
        INTO   l_freq_number
        FROM PAYROLL_CALENDAR
        WHERE ENTRP_ID IS NULL
        AND   FREQUENCY = P_PAY_CYCLE
        AND   PERIOD_DATE
        BETWEEN TO_DATE(P_EFF_DATE,'MM/DD/YYYY') AND TO_DATE(P_PLAN_END_DATE,'MM/DD/YYYY');
        commented  Added by Joshi for 8127.
        l_freq_number := pc_schedule.GET_FREQUENCY(P_PAY_CYCLE, TO_DATE(P_EFF_DATE,'MM/DD/YYYY'),TO_DATE(P_PLAN_END_DATE,'MM/DD/YYYY'));
       END IF;

    END IF;
       PC_LOG.LOG_ERROR('get_frequency','l_freq_number' ||l_freq_number);

    RETURN l_freq_number;
    */
    end get_frequency;

    function calculate_pay_period (
        p_plan_type     in varchar2,
        p_entrp_id      in number,
        p_ann_election  in number,
        p_pay_cycle     in varchar2,
        p_eff_date      in varchar2,
        p_plan_end_date in varchar2
    ) return number is
        l_pay_contribution number;
        l_freq_number      number;
    begin
        pc_log.log_error('calculate_pay_period,P_ANN_ELECTION', p_ann_election);
        pc_log.log_error('calculate_pay_period,P_PLAN_TYPE', p_plan_type);
        pc_log.log_error('calculate_pay_period,P_PAY_CYCLE', p_pay_cycle);
        pc_log.log_error('calculate_pay_period,P_PLAN_END_DATE', p_plan_end_date);
        if p_plan_type in ( 'TRN', 'PKG', 'UA1' ) then
            l_freq_number := get_frequency(p_entrp_id,
                                           p_pay_cycle,
                                           p_eff_date,
                                           to_char(add_months(to_date(p_eff_date, 'MM/DD/YYYY'), 12) - 1,
                                                   'MM/DD/YYYY'));

            pc_log.log_error('calculate_pay_period,L_FREQ_NUMBER', l_freq_number);
        else
            l_freq_number := get_frequency(p_entrp_id, p_pay_cycle, p_eff_date, p_plan_end_date);
            pc_log.log_error('calculate_pay_period,L_FREQ_NUMBER', l_freq_number);
        end if;

        if l_freq_number > 0 then
            return round(p_ann_election / l_freq_number, 2);
        else
            return null;
        end if;

    end calculate_pay_period;

    procedure update_plans_nightly as
    begin
        update ben_plan_enrollment_setup
        set
            effective_date = plan_start_date
        where
                effective_date < plan_start_date
            and status <> 'R';

		-- Commented the below code by Swamy for Ticket#7717
		-- This procedure is run in cron in 216.109.157.30, /u01/app/oracle/oradata/mysql_load/nightly.sql
		-- When the plan is Terminated, the status of the Plan should not be set to InActive.
        /*
		UPDATE BEN_PLAN_ENROLLMENT_SETUP
        SET    status = 'I'
        WHERE TRUNC(EFFECTIVE_END_DATE) = TRUNC(SYSDATE)
        AND   STATUS <> 'R';
        */

        for x in (
            select
                entrp_id,
                product_type,
                count(ben_plan_id),
                min(plan_end_date) plan_end_date
            from
                ben_plan_enrollment_setup
            where
                status <> 'R'
            group by
                entrp_id,
                product_type
            having
                count(ben_plan_id) > 1
        ) loop
            update ben_plan_enrollment_setup
            set
                renewal_flag = 'Y',
                renewal_date = least(plan_start_date, last_update_date)
            where
                    plan_start_date > x.plan_end_date
                and entrp_id = x.entrp_id
                and product_type = x.product_type
                and renewal_flag is null
                and nvl(status, '*') <> 'P';   -- Added by Swamy for Ticket#11730 22/09/2023 , For Pending Status in FORM_5500 the flag should not be set to Y

            update ben_plan_enrollment_setup
            set
                renewal_flag = 'Y',
                renewal_date = least(effective_date, last_update_date)
            where
                    plan_start_date > x.plan_end_date
                and acc_id in (
                    select
                        a.acc_id
                    from
                        account a, person  b
                    where
                            a.pers_id = b.pers_id
                        and b.entrp_id = x.entrp_id
                )
                and product_type = x.product_type
                and renewal_flag is null
                and nvl(status, '*') <> 'P';  -- Added by Swamy for Ticket#11730 22/09/2023 , For Pending Status in FORM_5500 the flag should not be set to Y

        end loop;

        update ben_plan_enrollment_setup
        set
            product_type = pc_lookups.get_meaning(plan_type, 'FSA_HRA_PRODUCT_MAP')
        where
            product_type is null
            and acc_id in (
                select
                    acc_id
                from
                    account
                where
                        account.acc_id = ben_plan_enrollment_setup.acc_id
                    and account.account_type in ( 'HRA', 'FSA' )
            );

        for x in (
            select
                acc_id,
                min(effective_date) effective_date
            from
                ben_plan_enrollment_setup
            where
                ben_plan_id_main is not null
                and status <> 'R'
            group by
                acc_id
        ) loop
            update account
            set
                start_date = nvl(x.effective_date, start_date)
            where
                acc_id = x.acc_id;

        end loop;

    end update_plans_nightly;

    procedure hra_fsa_rollover (
        p_entrp_id      in number,
        p_ben_plan_id   in number,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
        l_setup_error exception;
    begin
        for x in (
            select
                entrp_id,
                er_acc_id,
                plan_type,
                er_name,
                plan_start_date,
                plan_end_date,
                er_ben_plan_id,
                sum(balance) balance
            from
                (
                    select
                        case
                            when termination_date is not null
                                 and termination_date < plan_end_date then
                                0
                            else
                                decode(max_rollover_amount,
                                       0,
                                       acc_balance,
                                       least(max_rollover_amount, acc_balance))
                        end                                 balance,
                        a.entrp_id,
                        pc_entrp.get_acc_id(a.entrp_id)     er_acc_id,
                        pc_entrp.get_entrp_name(a.entrp_id) er_name,
                        a.plan_type,
                        a.plan_start_date,
                        a.plan_end_date,
                        ben_plan_id_main                    er_ben_plan_id
                    from
                        fsa_hra_employees_v a,
                        ben_plan_coverages  b
                    where
                            a.entrp_id = p_entrp_id
                        and a.ben_plan_id_main = p_ben_plan_id
                        and a.ben_plan_id = b.ben_plan_id
                        and a.status <> 'R'
                        and ( a.termination_date is null
                              or a.termination_date > sysdate )
                        and a.acc_id not in (
                            select
                                b.acc_id
                            from
                                scheduler_master  a, scheduler_details b
                            where
                                    a.scheduler_id = b.scheduler_id
                                and a.orig_system_ref = p_ben_plan_id
                        ) --Added to remove acc's which have been already processed in rollover
                        and exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup c
                            where
                                    c.acc_id = a.acc_id
                                and plan_end_date > sysdate
                                and product_type = 'HRA'
                                and status <> 'P'
                        )
                        and a.product_type = 'HRA'
                    union
                    select
                        case
                            when termination_date is not null
                                 and termination_date < plan_end_date then
                                0
                            else
                                decode(max_rollover_amount,
                                       0,
                                       acc_balance,
                                       least(max_rollover_amount, acc_balance))
                        end                                 balance,
                        a.entrp_id,
                        pc_entrp.get_acc_id(a.entrp_id)     er_acc_id,
                        pc_entrp.get_entrp_name(a.entrp_id) er_name,
                        a.plan_type,
                        a.plan_start_date,
                        a.plan_end_date,
                        ben_plan_id_main                    er_ben_plan_id
                    from
                        fsa_hra_employees_v a,
                        ben_plan_coverages  b
                    where
                            a.entrp_id = p_entrp_id
                        and a.ben_plan_id_main = p_ben_plan_id
                        and a.ben_plan_id = b.ben_plan_id
                        and a.status <> 'R'
                        and ( a.termination_date is null
                              or a.termination_date > sysdate )
                        and a.acc_id not in (
                            select
                                b.acc_id
                            from
                                scheduler_master  a, scheduler_details b
                            where
                                    a.scheduler_id = b.scheduler_id
                                and a.orig_system_ref = p_ben_plan_id
                        ) --Added to remove acc's which have been already processed in rollover
                        and exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup c
                            where
                                    c.acc_id = a.acc_id
                                and plan_end_date > sysdate
                                and plan_type in ( 'FSA', 'LPF' )
                                and status <> 'P'
                        )
                        and a.plan_type in ( 'FSA', 'LPF' )
                )  --FSA Rollover
            group by
                entrp_id,
                er_acc_id,
                plan_type,
                er_name,
                plan_start_date,
                plan_end_date,
                er_ben_plan_id
        ) loop
            if x.plan_end_date > sysdate then
                x_error_message := 'Cannot perform rollover for current plan year';
                raise l_setup_error;
            end if;
            if x.er_ben_plan_id is null then
                x_error_message := 'Cannot process rollover as there are no renewed HRA plans for this employer';
                raise l_setup_error;
            end if;

    /*  FOR Xx IN ( SELECT *
                 FROM SCHEDULER_MASTER
                 WHERE acc_id = x.ER_ACC_ID
                 AND   plan_type = x.plan_type
                 AND   orig_system_source = 'ROLLOVER'
                 AND   orig_system_ref = P_BEN_PLAN_ID)
      LOOP
                     x_error_message := 'There is already a Rollover transaction processed for this employer ';
                     RAISE l_setup_error;
      END LOOP;*/
            pc_schedule.create_rollover(
                p_entrp_id        => x.entrp_id,
                p_ben_plan_id     => p_ben_plan_id,
                p_acc_id          => x.er_acc_id,
                p_amount          => x.balance,
                p_plan_type       => x.plan_type,
                p_er_name         => x.er_name,
                p_user_id         => p_user_id,
                p_plan_start_date => x.plan_start_date,
                p_plan_end_date   => x.plan_end_date
            );

        end loop;
    exception
        when l_setup_error then
            x_return_status := 'E';
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            null;
    end hra_fsa_rollover;

    function display_coverage_tier (
        p_plan_type    in varchar2,
        p_grace_period in number,
        p_ben_plan_id  in number
    ) return varchar2 is
    begin
        if p_plan_type in ( 'FSA', 'LPF' ) then
            if
                ( p_ben_plan_id is not null )
                and ( p_grace_period = 0
                or p_grace_period is null )
            then
                return 'Y';
            else
                return null;
            end if;

        elsif
            ( p_ben_plan_id is not null )
            and pc_lookups.get_meaning(p_plan_type, 'FSA_HRA_PRODUCT_MAP') = 'HRA'
        then
            return 'Y';
        else
            return null;
        end if;
    exception
        when others then
            return null;
    end display_coverage_tier;

    procedure create_pop_plan (
        p_acc_id in number
    ) is
        l_renewal_flag varchar2(1) := 'N';
    begin
        for x in (
            select
                acc_num,
                plan_code,
                acc_id,
                entrp_id,
                decode(plan_code, 511, 'BASIC_POP', 'COMP_POP')      plan_type,
                decode(plan_code, 511, 'Basic POP', 'Cafeteria POP') plan_name  /*Ticket#5862 */,
                start_date,
                add_months(start_date, 60) - 1                       end_date,
                add_months(start_date, 12) - 1                       plan_end_date
            from
                account
            where
                    account_type = 'POP'
                and plan_code in ( 511, 512 )
                and entrp_id is not null
                and acc_id = p_acc_id /* Ticket#6455 PROD issue of plan getting craeted automatically */
                and not exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup b
                    where
                            account.acc_id = b.acc_id
                        and b.status <> 'R'
                )
        ) loop
            if x.plan_type = 'BASIC_POP' then  /* 5 yrs for Basic */
                insert into ben_plan_enrollment_setup (
                    ben_plan_id,
                    acc_id,
                    entrp_id,
                    plan_type,
                    ben_plan_name,
                    status,
                    plan_start_date,
                    plan_end_date,
                    effective_date,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( ben_plan_seq.nextval,
                           x.acc_id,
                           x.entrp_id,
                           x.plan_type,
                           x.plan_name,
                           'A',
                           x.start_date,
                           x.end_date,
                           x.start_date,
                           sysdate,
                           0,
                           sysdate,
                           0 );

            else  /* 1 yr for Cafeteria */
                insert into ben_plan_enrollment_setup (
                    ben_plan_id,
                    acc_id,
                    entrp_id,
                    plan_type,
                    ben_plan_name,
                    status,
                    plan_start_date,
                    plan_end_date,
                    effective_date,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( ben_plan_seq.nextval,
                           x.acc_id,
                           x.entrp_id,
                           x.plan_type,
                           x.plan_name,
                           'A',
                           x.start_date,
                           x.plan_end_date,
                           x.start_date,
                           sysdate,
                           0,
                           sysdate,
                           0 );

            end if;
          /*For Ticket#5862 ,now we no longer create NDT plan or Cafetrila Plan */
          /*
            IF X.PLAN_TYPE = 'COMP_POP' THEN
              FOR xx in 1 .. 5 LOOP
                    L_RENEWAL_FLAG := 'N';

                   IF add_months(X.START_DATE,(xx-1)*12) < SYSDATE THEN
                      IF xx > 1 THEN
                        L_RENEWAL_FLAG := 'Y';
                      END IF;
                       INSERT INTO BEN_PLAN_ENROLLMENT_SETUP
                       (BEN_PLAN_ID, PLAN_TYPE,ben_PLAN_NAME,ACC_ID,ENTRP_ID,STATUS,PLAN_START_DATE
                       , PLAN_END_DATE,EFFECTIVE_DATE,CREATION_DATE,CREATED_BY
                       ,LAST_UPDATE_DATE,LAST_UPDATED_BY,NON_DISCRM_FLAG,RENEWAL_FLAG)
                        VALUES
                        (BEN_PLAN_SEQ.NEXTVAL ,'NDT','Non Discrimination',X.ACC_ID,X.ENTRP_ID,'A'
                         ,add_months(X.START_DATE,(xx-1)*12)
                         ,add_months(X.START_DATE,(xx)*12)-1,x.START_DATE,SYSDATE,0,SYSDATE,0,'Y',L_RENEWAL_FLAG);
                    END IF;
              END LOOP;
            END IF;
        */
        end loop;
    end;

    procedure insert_plan_notice (
        p_entrp_id    in number,
        p_plan_type   in varchar2,
        p_notice_type in varchar2,
        p_user_id     in number
    ) is
    begin
        if
            p_notice_type = 'LAST_QTR_NDT'
            and p_plan_type in ( 'FSA', 'HRA' )
        then
            for x in (
                select
                    ben_plan_id
                from
                    ben_plan_enrollment_setup
                where
                        entrp_id = p_entrp_id
                    and ( ( p_plan_type = 'HRA'
                            and product_type = p_plan_type )
                          or ( p_plan_type = 'FSA'
                               and plan_type in ( 'FSA', 'LPF', 'DCA' ) ) )
                    and status <> 'R'
                     /*AND   TRUNC(PLAN_end_DATE) = '31-DEC-2015'*/
                    and plan_start_date <= sysdate
            ) loop
                insert into plan_notices (
                    plan_notice_id,
                    entity_id,
                    entity_type,
                    notice_type,
                    notice_review_sent,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                )
                    select
                        plan_notice_seq.nextval,
                        x.ben_plan_id,
                        'BEN_PLAN_ENROLLMENT_SETUP',
                        p_notice_type,
                        sysdate,
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id
                    from
                        dual
                    where
                        not exists (
                            select
                                *
                            from
                                plan_notices
                            where
                                    entity_id = x.ben_plan_id
                                and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                                and notice_type = p_notice_type
                        );

            end loop;
        /*Ticket 4919 */
        elsif
            p_notice_type = 'LAST_QTR_NDT'
            and p_plan_type = 'NDT'
        then
            for x in (
                select
                    ben_plan_id
                from
                    ben_plan_enrollment_setup
                where
                        entrp_id = p_entrp_id
                    --AND   PLAN_TYPE = 'NDT'
                    and plan_type in ( 'COMP_POP', 'COMP_POP_RENEW', 'NDT' ) -- 7793: Joshi included other POP plans
                    and status <> 'R'
                     /*AND   TRUNC(PLAN_end_DATE) = '31-DEC-2015'*/
                    and plan_start_date <= sysdate
            ) loop
                insert into plan_notices (
                    plan_notice_id,
                    entity_id,
                    entity_type,
                    notice_type,
                    notice_review_sent,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                )
                    select
                        plan_notice_seq.nextval,
                        x.ben_plan_id,
                        'BEN_PLAN_ENROLLMENT_SETUP',
                        p_notice_type,
                        sysdate,
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id
                    from
                        dual
                    where
                        not exists (
                            select
                                *
                            from
                                plan_notices
                            where
                                    entity_id = x.ben_plan_id
                                and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                                and notice_type = p_notice_type
                        );

            end loop;
        else
            for x in (
                select
                    ben_plan_id
                from
                    ben_plan_enrollment_setup
                where
                        entrp_id = p_entrp_id
                    and ( ( p_plan_type = 'HRA'
                            and product_type = p_plan_type )
                          or ( p_plan_type = 'FSA'
                               and plan_type in ( 'FSA', 'LPF', 'DCA' ) ) )
                    and status <> 'R'
                    and plan_end_date > sysdate
            ) loop
                insert into plan_notices (
                    plan_notice_id,
                    entity_id,
                    entity_type,
                    notice_type,
                    notice_review_sent,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                )
                    select
                        plan_notice_seq.nextval,
                        x.ben_plan_id,
                        'BEN_PLAN_ENROLLMENT_SETUP',
                        p_notice_type,
                        sysdate,
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id
                    from
                        dual
                    where
                        not exists (
                            select
                                *
                            from
                                plan_notices
                            where
                                    entity_id = x.ben_plan_id
                                and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                                and notice_type = p_notice_type
                        );

            end loop;
        end if;
    end insert_plan_notice;

    function get_plan_name (
        p_plan_type   in varchar2,
        p_ben_plan_id in number default null
    ) return varchar2 is
        l_plan_name varchar2(255);
    begin
        if
            pc_lookups.get_meaning(p_plan_type, 'FSA_HRA_PRODUCT_MAP') = 'HRA'
            and p_ben_plan_id is not null
        then
            for x in (
                select
                    plan_type
                    || '-'
                    || ben_plan_name ben_plan_name
                from
                    ben_plan_enrollment_setup
                where
                    ben_plan_id = p_ben_plan_id
            ) loop
                l_plan_name := x.ben_plan_name;
            end loop;
        else
            l_plan_name := pc_lookups.get_meaning(p_plan_type, 'FSA_PLAN_TYPE');
        end if;

        return l_plan_name;
    end get_plan_name;

    procedure create_er_deposit (
        p_entrp_id     in number,
        p_check_number in varchar2,
        p_plan_type    in varchar2,
        p_check_amount in number,
        p_user_id      in number,
        p_reason_code  in number,
        x_list_bill    out number,
        p_check_date   in date default sysdate
    ) is
        l_list_bill    number;
        l_exists       varchar2(1) := 'N';
        l_check_number varchar2(255);
    begin
        for kk in (
            select
                list_bill
            from
                employer_deposits
            where
                    entrp_id = p_entrp_id
                and check_number = p_check_number
                and plan_type = p_plan_type
        ) loop
            l_list_bill := kk.list_bill;
        end loop;

        if l_list_bill is null then
            select
                employer_deposit_seq.nextval
            into l_list_bill
            from
                dual;

            pc_fin.create_employer_deposit(
                p_list_bill          => l_list_bill,
                p_entrp_id           => p_entrp_id,
                p_check_amount       => p_check_amount,
                p_check_date         => nvl(p_check_date, sysdate),
                p_posted_balance     => p_check_amount,
                p_fee_bucket_balance => 0,
                p_remaining_balance  => 0,
                p_user_id            => p_user_id,
                p_plan_type          => p_plan_type,
                p_note               =>
                        case
                            when p_reason_code = 12 then
                                'Posting Annual election'
                            else
                                'Posting Contribution'
                        end,
                p_reason_code        => p_reason_code,
                p_check_number       => p_check_number
            );

        else
            update employer_deposits
            set
                check_amount = p_check_amount,
                last_update_date = sysdate,
                last_updated_by = 0,
                posted_balance = p_check_amount
            where
                    entrp_id = p_entrp_id
                and check_number = p_check_number;

        end if;

        x_list_bill := l_list_bill;
    end create_er_deposit;

    procedure process_annual_election (
        p_batch_number in number,
        p_user_id      in number
    ) is
        l_list_bill    number;
        l_exists       varchar2(1) := 'N';
        l_check_number varchar2(255);
    begin
        for x in (
            select
                a.ben_plan_id_main,
                c.entrp_id,
                a.plan_type,
                a.plan_start_date,
                a.plan_end_date,
                sum(nvl(c.annual_election, 0)) check_amount
            from
                ben_plan_enrollment_setup a,
                ben_plan_approvals        c
            where
                    c.batch_number = p_batch_number
                and c.ben_plan_id = a.ben_plan_id
                and c.status = 'A'
                and a.status = 'A'
                and a.effective_date between a.plan_start_date and a.plan_end_date
            group by
                a.ben_plan_id_main,
                c.entrp_id,
                a.plan_type,
                a.plan_start_date,
                a.plan_end_date
            having
                sum(nvl(c.annual_election, 0)) > 0
        ) loop
            l_list_bill := null;
            l_check_number := 'AE:'
                              || to_char(p_batch_number)
                              || ':'
                              || x.ben_plan_id_main;

            create_er_deposit(
                p_entrp_id     => x.entrp_id,
                p_check_number => l_check_number,
                p_plan_type    => x.plan_type,
                p_check_amount => x.check_amount,
                p_user_id      => p_user_id,
                p_reason_code  => 12,
                x_list_bill    => l_list_bill
            );

            pc_log.log_error('PROCESS_ANNUAL_ELECTION', ' L_LIST_BILL' || l_list_bill);
            pc_log.log_error('PROCESS_ANNUAL_ELECTION', ' X.PLAN_START_DATE' || x.plan_start_date);
            pc_log.log_error('PROCESS_ANNUAL_ELECTION', ' X.PLAN_END_DATE' || x.plan_end_date);
            pc_log.log_error('PROCESS_ANNUAL_ELECTION', ' P_BATCH_NUMBER' || p_batch_number);
            pc_log.log_error('PROCESS_ANNUAL_ELECTION', ' x.BEN_PLAN_ID_MAIN' || x.ben_plan_id_main);
            for xx in (
                select
                    a.*
                from
                    ben_plan_enrollment_setup a,
                    ben_plan_approvals        c
                where
                        c.batch_number = p_batch_number
                    and a.ben_plan_id_main = x.ben_plan_id_main
                    and c.ben_plan_id = a.ben_plan_id
                    and a.effective_date between a.plan_start_date and a.plan_end_date
                    and a.plan_start_date = x.plan_start_date
                    and a.plan_end_date = x.plan_end_date
                    and c.status = 'A'
                    and a.status = 'A'
            ) loop
                begin
                    pc_log.log_error('PC_FIN.CREATE_RECEIPT', 'Before');
                    pc_fin.create_receipt(
                        p_acc_id            => xx.acc_id,
                        p_fee_date          => xx.effective_date,
                        p_entrp_id          => x.entrp_id,
                        p_er_amount         => nvl(xx.annual_election, 0),
                        p_pay_code          => 6,
                        p_plan_type         => x.plan_type,
                        p_debit_card_posted => 'N',
                        p_list_bill         => l_list_bill,
                        p_fee_reason        => 12,
                        p_note              => 'Posting Annual Election',
                        p_check_amount      => x.check_amount,
                        p_user_id           => p_user_id,
                        p_check_number      => l_check_number
                    );

                exception
                    when others then
                        pc_log.log_error('PROCESS_ANNUAL_ELECTION', 'batch_number' || p_batch_number);
                        pc_log.log_error('PC_FIN.CREATE_RECEIPT', 'sqlerrm' || sqlerrm);
                end;

                pc_log.log_error('PC_FIN.CREATE_RECEIPT', 'after');
            end loop;

        end loop;

        pc_log.log_error('PROCESS_ANNUAL_ELECTION', 'Before prefund');

      -- process pre funded
        for x in (
            select
                a.ben_plan_id_main,
                c.entrp_id,
                a.plan_type,
                a.plan_start_date,
                a.plan_end_date,
                sum(nvl(c.annual_election, 0)) check_amount
            from
                ben_plan_enrollment_setup a,
                ben_plan_approvals        c
            where
                    c.batch_number = p_batch_number
                and c.ben_plan_id = a.ben_plan_id
                and c.status = 'A'
                and a.status = 'A'
                and a.funding_type = 'PRE_FUND'
            group by
                a.ben_plan_id_main,
                c.entrp_id,
                a.plan_type,
                a.plan_end_date,
                a.plan_start_date
            having
                sum(nvl(c.annual_election, 0)) > 0
        ) loop
            pc_log.log_error('PROCESS_ANNUAL_ELECTION', 'CREATE_ER_DEPOSIT');
            l_list_bill := null;
            l_check_number := 'PC:'
                              || to_char(p_batch_number)
                              || ':'
                              || x.ben_plan_id_main;

            pc_log.log_error('PC_FIN.CREATE_ER_DEPOSIT', 'sqlerrm' || sqlerrm);
            pc_log.log_error('PROCESS_ANNUAL_ELECTION', 'L_CHECK_NUMBER :' || l_check_number);
            create_er_deposit(
                p_entrp_id     => x.entrp_id,
                p_check_number => l_check_number,
                p_plan_type    => x.plan_type,
                p_check_amount => x.check_amount,
                p_user_id      => p_user_id,
                p_reason_code  => 11,
                x_list_bill    => l_list_bill,
                p_check_date   => greatest(x.plan_start_date, sysdate)
            );

            pc_log.log_error('PROCESS_ANNUAL_ELECTION', 'CREATE_ER_DEPOSIT :' || l_list_bill);
            pc_log.log_error('PROCESS_ANNUAL_ELECTION:CREATE_ER_DEPOSIT', ' L_LIST_BILL' || l_list_bill);
            for xx in (
                select
                    a.*
                from
                    ben_plan_enrollment_setup a,
                    ben_plan_approvals        c
                where
                        c.batch_number = p_batch_number
                    and c.ben_plan_id = a.ben_plan_id
                    and a.ben_plan_id_main = x.ben_plan_id_main
                    and a.effective_date between a.plan_start_date and a.plan_end_date
                    and a.plan_start_date = x.plan_start_date
                    and a.plan_end_date = x.plan_end_date
                    and c.status = 'A'
                    and a.status = 'A'
            ) loop
                begin
                    pc_fin.create_receipt(
                        p_acc_id            => xx.acc_id,
                        p_fee_date          => xx.effective_date,
                        p_entrp_id          => x.entrp_id,
                        p_er_amount         => nvl(xx.annual_election, 0),
                        p_pay_code          => 4,
                        p_plan_type         => x.plan_type,
                        p_debit_card_posted => 'N',
                        p_list_bill         => l_list_bill,
                        p_fee_reason        => 11,
                        p_note              => 'Posting Prefunded Payroll Contribution',
                        p_check_amount      => x.check_amount,
                        p_user_id           => p_user_id,
                        p_check_number      => l_check_number
                    );

                exception
                    when others then
                        pc_log.log_error('PROCESS_ANNUAL_ELECTION', 'batch_number' || p_batch_number);
                        pc_log.log_error('PC_FIN.CREATE_RECEIPT2', 'sqlerrm' || sqlerrm);
                end;
            end loop;

        end loop;

        pc_log.log_error('PROCESS_ANNUAL_ELECTION', 'after prefund');
    end process_annual_election;
/* FUNCTION get_calendar_frequency (P_PAY_CYCLE IN VARCHAR2) RETURN NUMBER
 IS
    l_freq_number NUMBER := 0;
    l_pay_count   NUMBER;
  BEGIN
     SELECT COUNT(*)
    INTO   l_freq_number
    FROM PAYROLL_CALENDAR a, PAY_CYCLE b
    WHERE upper(b.name) = upper(P_PAY_CYCLE)
    AND   A.PAY_CYCLE_ID = B.PAY_CYCLE_ID;

    RETURN l_freq_number;


END get_calendar_frequency;*/
    procedure update_employees_coverage (
        p_er_ben_plan_id in number,
        p_tier_name      in varchar2,
        p_deductible     in number
    ) is
    begin
        for x in (
            select
                ee_bp.acc_id,
                ee_bp.ben_plan_id,
                ee_bc.coverage_type
            from
                ben_plan_enrollment_setup er_bp,
                ben_plan_coverages        er_bc,
                ben_plan_enrollment_setup ee_bp,
                ben_plan_coverages        ee_bc
            where
                    er_bp.ben_plan_id = ee_bp.ben_plan_id_main
                and er_bc.ben_plan_id = er_bp.ben_plan_id
                and ee_bc.ben_plan_id = ee_bp.ben_plan_id
                and er_bp.ben_plan_id = p_er_ben_plan_id
                and ee_bp.status <> 'R'
                and upper(ee_bc.coverage_type) = upper(p_tier_name)
        ) loop
            update ben_plan_coverages
            set
                deductible = p_deductible
            where
                    ben_plan_id = p_er_ben_plan_id
                and upper(coverage_type) = upper(p_tier_name);

            update ben_plan_coverages
            set
                deductible = p_deductible
            where
                    acc_id = x.acc_id
                and ben_plan_id = x.ben_plan_id;

        end loop;
    end update_employees_coverage;

    procedure insert_er_benefit_plan (
        p_acc_id               in number,
        p_entrp_id             in number,
        p_effective_date       in varchar2,
        p_plan_type            in varchar2,
        p_fiscal_end_date      in varchar2,
        p_eff_date             in varchar2,
        p_org_eff_date         in varchar2,
        p_plan_start_date      in varchar2,
        p_plan_end_date        in varchar2,
        p_takeover             in varchar2,
        p_user_id              in number,
        p_is_5500              in varchar2 default null,
        p_plan_name            in varchar2 default null,
        p_plan_number          in varchar2 default null,
        p_coll_plan            in varchar2 default null,
        p_plan_fund_code       in varchar2 default null,
        p_plan_benefit_code    in varchar2 default null,
        p_grandfathered        in varchar2 default null,
        p_administered         in varchar2 default null,
        p_clm_lang_in_spd      in varchar2 default null,
        p_subsidy_in_spd_apndx in varchar2 default null,
        p_final_filing_flag    in varchar2 default null,
        p_wrap_plan_5500       in varchar2 default null,
        p_wrap_opt_flg         in varchar2 default '1'    -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        ,
        p_erissa_erap_doc_type in varchar2  -- added by Joshi for 7791
        ,
        x_ben_plan_id          out number,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    ) is
        l_er_ben_plan_id number;
    begin
        x_return_status := 'S';
        select
            ben_plan_seq.nextval
        into l_er_ben_plan_id
        from
            dual;

        pc_log.log_error('insert_ER_benefit_plan ', 'INSERTED BEN  PLAN'
                                                    || 'p_er_ben_plan_id '
                                                    || l_er_ben_plan_id
                                                    || ' effective date '
                                                    || p_effective_date);

        pc_log.log_error('insert_ER_benefit_plan ', 'INSERTED BEN  PLAN'
                                                    || 'p_er_ben_plan_id '
                                                    || l_er_ben_plan_id
                                                    || ' ORG effective date '
                                                    || p_org_eff_date
                                                    || ' p_fiscal_end_date :='
                                                    || p_fiscal_end_date);

     -- Add ER benefit plan
        insert into ben_plan_enrollment_setup (
            ben_plan_id,
            ben_plan_name,
            ben_plan_number,
            plan_start_date,
            plan_end_date,
            status,
            acc_id,
            plan_type,
            effective_date,
            entrp_id,
            original_eff_date,
            takeover,
            fiscal_end_date,
            is_5500,
            is_collective_plan,
            plan_funding_code,
            plan_benefit_code,
            clm_lang_in_spd,
            subsidy_in_spd_apndx,
            grandfathered,
            self_administered,
            final_filing_flag,
            wrap_plan_5500,
            wrap_opt_flg         -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
            ,
            erissa_erap_doc_type -- Added by Joshi for 7791
            ,
            creation_date,
            created_by
        ) values ( l_er_ben_plan_id,
                   case
                       when p_plan_name is null then
                           decode(p_plan_type, 'COMP_POP', 'Cafeteria Plan', p_plan_type) -- Plan name same as Plan type
                       else
                           p_plan_name
                   end,
                   p_plan_number,
                   to_date(p_plan_start_date, 'mm/dd/rrrr'),
                   to_date(p_plan_end_date, 'mm/dd/rrrr'),
                   'A',
                   p_acc_id,
                   p_plan_type,
                   to_date(p_effective_date, 'mm/dd/rrrr'),
                   p_entrp_id,
                   to_date(p_org_eff_date, 'mm/dd/rrrr'),
                   p_takeover,
                   to_date(p_fiscal_end_date, 'mm/dd/rrrr'),
                   p_is_5500,
                   p_coll_plan,
                   p_plan_fund_code,
                   p_plan_benefit_code,
                   p_clm_lang_in_spd,
                   p_subsidy_in_spd_apndx,
                   p_grandfathered,
                   p_administered,
                   p_final_filing_flag,
                   p_wrap_plan_5500,
                   p_wrap_opt_flg               -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                   ,
                   p_erissa_erap_doc_type,
                   sysdate,
                   p_user_id ) return l_er_ben_plan_id into x_ben_plan_id;

        pc_log.log_error('insert_ER_benefit_plan ', 'Created Plan Success');
    exception
        when others then
            pc_log.log_error('PC_BENEFIT_PLAN.insert_ER_benefit_plan', sqlerrm);
    end insert_er_benefit_plan;

    procedure change_annual_election (
        p_batch_number  in number,
        p_user_id       in number,
        p_source        in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

        l_list_bill       number;
        l_exists          varchar2(1) := 'N';
        l_check_number    varchar2(100);
        l_check_amount    number;
        l_entrp_id        number;
        l_pf_list_bill    number;
        l_pf_check_number varchar2(100);
        l_pf_amount       number;
    begin
        x_return_status := 'S';
        if p_source = 'ONLINE' then
            pc_log.log_error('create_employer_deposit', ' create_employer_deposit');
            for x in (
                select
                    me.entrp_id,
                    me.batch_number,
                    bp.ben_plan_id_main,
                    sum(x.annual_election - bp.annual_election) amount,
                    bp.plan_type,
                    bp.funding_type
                from
                    online_enrollment         me,
                    online_enroll_plans       x,
                    ben_plan_enrollment_setup bp
                where
                        me.enrollment_id = x.enrollment_id
                    and me.batch_number = x.batch_number
                    and x.plan_type = bp.plan_type
                    and me.acc_id = bp.acc_id
                    and x.action in ( 'A', 'C' )
                    and me.action in ( 'A', 'C' )
                    and bp.status = 'A'
                    and nvl(x.status, 'S') = 'S'
                    and nvl(me.enrollment_status, 'S') = 'S'
                    and x.ben_plan_id = bp.ben_plan_id
                    and bp.ben_plan_id_main = x.er_ben_plan_id
                    and x.annual_election != bp.annual_election
                    and me.batch_number = p_batch_number
                group by
                    me.entrp_id,
                    me.batch_number,
                    bp.ben_plan_id_main,
                    bp.plan_type,
                    bp.funding_type
            ) loop
                l_check_number := 'AE:'
                                  || to_char(p_batch_number)
                                  || ':'
                                  || x.ben_plan_id_main;

                l_list_bill := employer_deposit_seq.nextval;
                pc_fin.create_employer_deposit(
                    p_list_bill          => l_list_bill,
                    p_entrp_id           => x.entrp_id,
                    p_check_amount       => x.amount,
                    p_check_date         => sysdate,
                    p_posted_balance     => x.amount,
                    p_fee_bucket_balance => 0,
                    p_remaining_balance  => 0,
                    p_user_id            => p_user_id,
                    p_plan_type          => x.plan_type,
                    p_note               => 'Posting Annual election',
                    p_reason_code        => 12,
                    p_check_number       => l_check_number
                );

                pc_log.log_error('CHANGE_ANNUAL_ELECTION', ' L_CHECK_NUMBER' || l_check_number);
                if x.funding_type = 'PRE_FUND' then
                    l_pf_check_number := 'PC:'
                                         || to_char(p_batch_number)
                                         || ':'
                                         || x.ben_plan_id_main;

                    l_pf_list_bill := employer_deposit_seq.nextval;
                    pc_log.log_error('CHANGE_ANNUAL_ELECTION', ' L_PF_CHECK_NUMBER' || l_pf_check_number);
                    pc_log.log_error('CHANGE_ANNUAL_ELECTION', ' L_PF_LIST_BILL' || l_pf_list_bill);
                    pc_fin.create_employer_deposit(
                        p_list_bill          => l_pf_list_bill,
                        p_entrp_id           => x.entrp_id,
                        p_check_amount       => x.amount,
                        p_check_date         => sysdate,
                        p_posted_balance     => x.amount,
                        p_fee_bucket_balance => 0,
                        p_remaining_balance  => 0,
                        p_user_id            => p_user_id,
                        p_plan_type          => x.plan_type,
                        p_note               => 'Posting Annual election',
                        p_reason_code        => 11,
                        p_check_number       => l_pf_check_number
                    );

                    pc_log.log_error('CHANGE_ANNUAL_ELECTION', ' L_PF_CHECK_NUMBER' || l_pf_check_number);
                end if;

                pc_log.log_error('CHANGE_ANNUAL_ELECTION', ' changing annual election');
                for xx in (
                    select
                        me.acc_id,
                        me.entrp_id,
                        x.plan_type,
                        bp.plan_end_date,
                        bp.ben_plan_id,
                        bp.plan_start_date,
                        x.enroll_plan_id,
                        x.er_ben_plan_id,
                        x.annual_election,
                        x.annual_election - bp.annual_election amount--pier 2683
                        ,
                        bp.annual_election                     ee_annual_election,
                        me.created_by,
                        me.enrollment_id,
                        x.action,
                        bp.funding_type
                    from
                        online_enrollment         me,
                        online_enroll_plans       x,
                        ben_plan_enrollment_setup bp
                    where
                            me.enrollment_id = x.enrollment_id
                        and me.batch_number = x.batch_number
                        and x.plan_type = bp.plan_type
                        and me.acc_id = bp.acc_id
                        and x.action in ( 'A', 'C' )
                        and me.action in ( 'A', 'C' )
                        and bp.status = 'A'
                        and bp.ben_plan_id_main = x.er_ben_plan_id
                        and x.annual_election != bp.annual_election
                        and me.batch_number = p_batch_number
                ) loop
                    update ben_plan_enrollment_setup
                    set
                        annual_election = nvl(xx.annual_election, 0),
                        batch_number = p_batch_number
                    where
                            ben_plan_id = xx.ben_plan_id
                        and acc_id = xx.acc_id;

                    pc_fin.create_receipt(
                        p_acc_id            => xx.acc_id,
                        p_fee_date          => greatest(xx.plan_start_date, sysdate),
                        p_entrp_id          => xx.entrp_id,
                        p_er_amount         => nvl(xx.amount, 0),
                        p_pay_code          => 6,
                        p_plan_type         => xx.plan_type,
                        p_debit_card_posted => 'N',
                        p_list_bill         => l_list_bill,
                        p_fee_reason        => 12,
                        p_note              => 'Changing Annual Election',
                        p_check_amount      => nvl(x.amount, 0),
                        p_user_id           => p_user_id,
                        p_check_number      => l_check_number
                    );

                    if x.funding_type = 'PRE_FUND' then
                        pc_fin.create_receipt(
                            p_acc_id            => xx.acc_id,
                            p_fee_date          => greatest(xx.plan_start_date, sysdate),
                            p_entrp_id          => xx.entrp_id,
                            p_er_amount         => nvl(xx.amount, 0),
                            p_pay_code          => 6,
                            p_plan_type         => xx.plan_type,
                            p_debit_card_posted => 'N',
                            p_list_bill         => l_pf_list_bill,
                            p_fee_reason        => 11,
                            p_note              => 'Changing Annual Election',
                            p_check_amount      => nvl(x.amount, 0),
                            p_user_id           => p_user_id,
                            p_check_number      => l_pf_check_number
                        );
                    end if;

                end loop;

            end loop;

        end if;

    end change_annual_election;

-- Added By Swamy For Ticket#5824
    function get_rollover (
        p_acc_id     in number,
        p_plan_type  in varchar2,
        p_start_date in date,
        p_end_date   in date
    ) return number is
        v_rollover number;
    begin
        for i in (
            select
                sum(nvl(amount, 0) + nvl(amount_add, 0)) amount
            from
                income a
            where
                    acc_id = p_acc_id --348503 --348509 --348497
 --   And Reason_Mode     <> 'C'
                and fee_code = 17
                and plan_type = p_plan_type
                and trunc(fee_date) >= p_start_date
                and trunc(fee_date) <= p_end_date
      --And Amount > 0
        ) loop
            v_rollover := i.amount;
        end loop;

        v_rollover := nvl(v_rollover, 0);
        return v_rollover;
    end get_rollover;
-- End By Swamy For Ticket#5824

    procedure add_renew_employees_edi (
        p_acc_id          in number,
        p_annual_election in number,
        p_er_ben_plan_id  in number,
        p_user_id         in number,
        p_cov_tier_name   in varchar2 default null,
        p_effective_date  in date default null,
        p_batch_number    in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2,
        p_status          in varchar2 default 'A',
        p_life_event_code in varchar2 default null
    ) is
        l_account_type varchar2(100);
        l_plan_type    varchar2(100);
    begin
        x_return_status := 'S';

      -- Added by Joshi ##9675 SAM File Upload Renewal Issue
      -- l_account_type := pc_account.get_account_type(P_ACC_ID);
        l_plan_type := get_ben_plan_type(p_er_ben_plan_id);
        if l_plan_type not in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' ) then
            insert into ben_plan_enrollment_setup (
                ben_plan_id,
                ben_plan_name,
                ben_plan_number,
                plan_start_date,
                plan_end_date,
                status,
                runout_period_days,
                runout_period_term,
                funding_options,
                reimbursement_type,
                reimbursement_ded,
                rollover,
                term_eligibility,
                funding_type,
                acc_id,
                new_hire_contrib,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                note,
                plan_type,
                annual_election,
                effective_date,
                ben_plan_id_main,
                batch_number,
                grace_period,
                sf_ordinance_flag,
                allow_substantiation,
                product_type,
                life_event_code,
                claim_reimbursed_by
            )  -- Column added by swamy on 17/05/2018 wrt Ticket#5693)
                select
                    ben_plan_seq.nextval,
                    emp_plan.ben_plan_name,
                    emp_plan.ben_plan_number,
                    emp_plan.plan_start_date,
                    emp_plan.plan_end_date,
                    p_status,
                    emp_plan.runout_period_days,
                    emp_plan.runout_period_term,
                    emp_plan.funding_options,
                    emp_plan.reimbursement_type,
                    emp_plan.reimbursement_ded,
                    emp_plan.rollover,
                    emp_plan.term_eligibility,
                    emp_plan.funding_type,
                    p_acc_id,
                    emp_plan.new_hire_contrib,
                    sysdate,
                    nvl(
                        get_user_id(v('APP_USER')),
                        p_user_id
                    ) -- 7781 rprabu
                    ,
                    sysdate,
                    p_user_id,
                    emp_plan.note,
                    emp_plan.plan_type,
                    p_annual_election,
                    nvl(p_effective_date, sysdate)
             --   , CASE WHEN EMP_PLAN.PLAN_START_DATE > SYSDATE THEN EMP_PLAN.PLAN_START_DATE ELSE SYSDATE END
                    ,
                    emp_plan.ben_plan_id,
                    p_batch_number,
                    emp_plan.grace_period,
                    decode(emp_plan.appl_all_emp, 'Y', emp_plan.sf_ordinance_flag),
                    emp_plan.allow_substantiation,
                    pc_lookups.get_meaning(emp_plan.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                    nvl(p_life_event_code, 'OPEN_ENROLLMENT'),
                    emp_plan.claim_reimbursed_by   -- Column added by swamy on 17/05/2018 wrt Ticket#5693
                from
                    ben_plan_enrollment_setup emp_plan
                where
                    ben_plan_id = p_er_ben_plan_id;

        else
            insert into ben_plan_enrollment_setup (
                ben_plan_id,
                ben_plan_name,
                ben_plan_number,
                plan_start_date,
                plan_end_date,
                status,
                runout_period_days,
                runout_period_term,
                funding_options,
                reimbursement_type,
                reimbursement_ded,
                rollover,
                term_eligibility,
                funding_type,
                acc_id,
                new_hire_contrib,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                note,
                plan_type,
                annual_election,
                effective_date,
                ben_plan_id_main,
                batch_number,
                grace_period,
                sf_ordinance_flag,
                allow_substantiation,
                product_type,
                life_event_code,
                claim_reimbursed_by
            )  -- Column added by swamy on 17/05/2018 wrt Ticket#5693)
                select
                    ben_plan_seq.nextval,
                    emp_plan.ben_plan_name,
                    emp_plan.ben_plan_number,
                    emp_plan.plan_start_date,
                    emp_plan.plan_end_date,
                    p_status,
                    emp_plan.runout_period_days,
                    emp_plan.runout_period_term,
                    emp_plan.funding_options,
                    emp_plan.reimbursement_type,
                    emp_plan.reimbursement_ded,
                    emp_plan.rollover,
                    emp_plan.term_eligibility,
                    emp_plan.funding_type,
                    p_acc_id,
                    emp_plan.new_hire_contrib,
                    sysdate,
                    nvl(
                        get_user_id(v('APP_USER')),
                        p_user_id
                    ) -- 7781 rprabu
                    ,
                    sysdate,
                    p_user_id,
                    emp_plan.note,
                    emp_plan.plan_type,
                    bpc.annual_election,
                    nvl(p_effective_date, sysdate)
             --   , CASE WHEN EMP_PLAN.PLAN_START_DATE > SYSDATE THEN EMP_PLAN.PLAN_START_DATE ELSE SYSDATE END
                    ,
                    emp_plan.ben_plan_id,
                    p_batch_number,
                    emp_plan.grace_period,
                    decode(emp_plan.appl_all_emp, 'Y', emp_plan.sf_ordinance_flag),
                    emp_plan.allow_substantiation,
                    pc_lookups.get_meaning(emp_plan.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                    nvl(p_life_event_code, 'OPEN_ENROLLMENT'),
                    emp_plan.claim_reimbursed_by   -- Column added by swamy on 17/05/2018 wrt Ticket#5693
                from
                    ben_plan_enrollment_setup emp_plan,
                    ben_plan_coverages        bpc
                where
                        emp_plan.ben_plan_id = p_er_ben_plan_id
                    and emp_plan.ben_plan_id = bpc.ben_plan_id
                    and upper(bpc.coverage_tier_name) = upper(ltrim(rtrim(p_cov_tier_name)));

        end if;

        if p_cov_tier_name is not null then
            insert into ben_plan_coverages (
                coverage_id,
                ben_plan_id,
                acc_id,
                coverage_type,
                deductible,
                start_date,
                end_date,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                fixed_funding_amount,
                annual_election,
                fixed_funding_flag,
                deductible_rule_id,
                coverage_tier_name,
                max_rollover_amount
            )--Added 04/14/2015
                select
                    coverage_seq.nextval,
                    c.ben_plan_id,
                    p_acc_id,
                    b.coverage_type,
                    b.deductible,
                    b.start_date,
                    b.end_date,
                    sysdate,
                    0,
                    sysdate,
                    0,
                    b.fixed_funding_amount,
                    b.annual_election,
                    b.fixed_funding_flag,
                    b.deductible_rule_id,
                    b.coverage_tier_name,
                    max_rollover_amount   --Added 04/14/2015
                from
                    ben_plan_coverages        b,
                    ben_plan_enrollment_setup c
                where
                        b.ben_plan_id = c.ben_plan_id_main
                    and c.ben_plan_id_main = p_er_ben_plan_id
                    and c.acc_id = p_acc_id
                    and c.status in ( 'P', 'I', 'A' )
                    and trunc(c.creation_date) = trunc(sysdate)
                    and upper(b.coverage_tier_name) = upper(ltrim(rtrim(p_cov_tier_name)));

        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end add_renew_employees_edi;

  -- Added by Swamy for DB Upgrade on 17/08/2021

    function get_benefit_codes_info (
        p_entity_id number
    ) return tbl_benefit_codes
        pipelined
        deterministic
    is
        l_record rec_benefit_codes;
    begin
--
        for x in (
            select
                to_number(null) benefit_code_id,
                lookup_code     benefit_code_name,
                meaning         description,
                null            fully_insured_flag,
                null            self_insured_flag,
                null            check_box
            from
                lookups a
            where
                    lookup_name = 'BENEFIT_CODES'
                and not exists (
                    select
                        1
                    from
                        benefit_codes
                    where
                            benefit_code_name = a.lookup_code
                        and entity_id = p_entity_id
                        and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                )
            union
            select
                benefit_code_id,
                benefit_code_name,
                description,
                fully_insured_flag,
                self_insured_flag,
                'Y' check_box
            from
                benefit_codes
            where
                    entity_id = p_entity_id
                and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
        ) loop
            l_record.benefit_code_id := x.benefit_code_id;
            l_record.benefit_code_name := x.benefit_code_name;
            l_record.description := x.description;
            l_record.fully_insured_flag := x.fully_insured_flag;
            l_record.self_insured_flag := x.self_insured_flag;
            l_record.check_box := x.check_box;
            pipe row ( l_record );
        end loop;
    exception
        when others then
            pc_log.log_error('get_benefit_codes_info',
                             'others  ' || sqlerrm(sqlcode));
    end get_benefit_codes_info;

-- Added by Swamy for Ticket#10431(Renewal Resubmit)
    procedure update_ben_plan_enrollment_setup (
        p_ben_plan_id                 in number,
        p_plan_start_date             in date,
        p_plan_end_date               in date,
        p_runout_period_days          in number,
        p_runout_period_term          in varchar2,
        p_funding_options             in varchar2,
        p_rollover                    in varchar2,
        p_new_hire_contrib            in varchar2,
        p_last_update_date            in date,
        p_last_updated_by             in number,
        p_effective_date              in date,
        p_minimum_election            in number,
        p_maximum_election            in number,
        p_grace_period                in number,
        p_batch_number                in number,
        p_non_discrm_flag             in varchar2,
        p_plan_docs_flag              in varchar2,
        p_renewal_flag                in varchar2,
        p_renewal_date                in date,
        p_open_enrollment_start_date  in date,
        p_open_enrollment_end_date    in date,
        p_eob_required                in varchar2,
        p_deduct_tax                  in varchar2,
        p_update_limit_match_irs_flag in varchar2,
        p_pay_acct_fees               in varchar2,
        p_source                      in varchar2,
        p_account_type                in varchar2,
        p_fiscal_end_date             in varchar2,
        p_plan_name                   in varchar2,
        p_plan_number                 in varchar2,
        p_takeover                    in varchar2,-- added by Joshi for 7791
        p_org_eff_date                in varchar2,
        p_plan_type                   in varchar2,
        p_short_plan_yr               in varchar2,
        p_plan_doc_ndt_flag           in varchar2,
        x_return_status               out varchar2,
        x_error_message               out varchar2
    ) is
 --X_RETURN_STATUS   VARCHAR2(100);
--X_ERROR_MESSAGE  VARCHAR2(100);
        l_non_discrm_flag varchar2(10);
        l_plan_docs_flag  varchar2(10);
    begin
        x_return_status := 'S';
        pc_log.log_error('pc_benefit_plans.update_ben_plan_enrollment_setup P_Account_type ', p_account_type
                                                                                              || ' p_plan_type :='
                                                                                              || p_plan_type);
        if p_account_type = 'ERISA_WRAP' then
            update ben_plan_enrollment_setup
            set
                plan_start_date = nvl(p_plan_start_date, plan_start_date),
                plan_end_date = nvl(p_plan_end_date, plan_end_date),
                runout_period_days = nvl(p_runout_period_days, runout_period_days),
                runout_period_term = nvl(p_runout_period_term, runout_period_term),
                funding_options = nvl(p_funding_options, funding_options),
                rollover = nvl(p_rollover, rollover),
                new_hire_contrib = nvl(p_new_hire_contrib, new_hire_contrib),
                last_update_date = nvl(p_last_update_date, last_update_date),
                last_updated_by = nvl(p_last_updated_by, last_updated_by),
                effective_date = nvl(p_effective_date, effective_date),
                minimum_election = nvl(p_minimum_election, minimum_election),
                maximum_election = nvl(p_maximum_election, maximum_election),
                grace_period = nvl(p_grace_period, grace_period),
                non_discrm_flag = nvl(p_non_discrm_flag, non_discrm_flag),
                plan_docs_flag = nvl(p_plan_docs_flag, plan_docs_flag),
                renewal_flag = nvl(p_renewal_flag, renewal_flag),
                renewal_date = nvl(p_renewal_date, renewal_date),
                open_enrollment_start_date = nvl(p_open_enrollment_start_date, open_enrollment_start_date),
                open_enrollment_end_date = nvl(p_open_enrollment_end_date, open_enrollment_end_date),
                eob_required = nvl(p_eob_required, eob_required),
                deduct_tax = nvl(p_deduct_tax, deduct_tax),
                update_limit_match_irs_flag = nvl(p_update_limit_match_irs_flag, update_limit_match_irs_flag)
            where
                ben_plan_id = p_ben_plan_id;

            update ben_plan_renewals
            set
                pay_acct_fees = p_pay_acct_fees,
                source = p_source,
                start_date = p_plan_start_date,
                end_date = p_plan_end_date,
                last_updated_date = p_last_update_date,
                last_updated_by = p_last_updated_by
            where
                renewed_plan_id = p_ben_plan_id;

        elsif p_account_type = 'POP' then
            if p_plan_type = 'COMP_POP_RENEW' then
                l_non_discrm_flag := nvl(p_plan_doc_ndt_flag, 'N');
                l_plan_docs_flag := 'Y';
            else
                l_non_discrm_flag := 'N';
                l_plan_docs_flag := 'N';
            end if;

            update ben_plan_enrollment_setup
            set
                ben_plan_name =
                    case
                        when p_plan_name is null then
                            decode(p_plan_type, 'COMP_POP', 'Cafeteria Plan', p_plan_type) -- Plan name same as Plan type
                        else
                            p_plan_name
                    end,
                ben_plan_number = p_plan_number,
                plan_start_date = p_plan_start_date,
                plan_end_date = p_plan_end_date,
                plan_type = p_plan_type,
                effective_date = p_effective_date,
                original_eff_date = to_date(p_org_eff_date, 'mm/dd/yyyy'),
                takeover = p_takeover,
                fiscal_end_date = to_date(p_fiscal_end_date, 'mm/dd/yyyy'),
                renewal_date = sysdate,
                renewal_flag = 'Y',
                plan_docs_flag = l_plan_docs_flag,
                non_discrm_flag = l_non_discrm_flag,
                short_plan_yr_flag = p_short_plan_yr  -- Swamy #12057 26022024 
            where
                ben_plan_id = p_ben_plan_id;

            update ben_plan_renewals
            set
                pay_acct_fees = p_pay_acct_fees,
                source = p_source,
                start_date = p_plan_start_date,
                end_date = p_plan_end_date,
                last_updated_date = p_last_update_date,
                last_updated_by = p_last_updated_by,
                plan_type = decode(p_plan_type, 'COMP_POP_RENEW', 'COMP_POP', 'BASIC_POP')
            where
                renewed_plan_id = p_ben_plan_id;

        end if;

    exception
        when others then
            pc_log.log_error('pc_benefit_plans.update_ben_plan_enrollment_setup', sqlerrm);
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end update_ben_plan_enrollment_setup;

end pc_benefit_plans;
/


-- sqlcl_snapshot {"hash":"137cb7c832725a27229958a73a2a097aa53cc5c6","type":"PACKAGE_BODY","name":"PC_BENEFIT_PLANS","schemaName":"SAMQA","sxml":""}