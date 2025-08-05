-- liquibase formatted sql
-- changeset SAMQA:1754373961261 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_ben_life_events.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_ben_life_events.sql:null:bb67d32945484d2800b6c1ab2d90ba4f952fa875:create

create or replace package body samqa.pc_ben_life_events as

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

    procedure insert_ben_life_events (
        p_acc_id          in number,
        p_ben_plan_id     in number,
        p_plan_type       in varchar2,
        p_life_event_code in varchar2,
        p_description     in varchar2,
        p_annual_election in number,
        p_payroll_contrib in number,
        p_effective_date  in varchar2,
        p_user_id         in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is

        p_batch_number varchar2(30);
        l_acc_num      varchar2(20);
        l_pers_id      number;
        app_exception exception;
        l_dummy        number := 0;
        l_ben_plan_id  number;
    begin
        pc_log.log_error('PC_LIFE_EVENTS.INSERT_BEN_LIFE_EVENTS', ' P_ACC_ID - '
                                                                  || p_acc_id
                                                                  || ' - '
                                                                  || ' P_BEN_PLAN_ID - '
                                                                  || p_ben_plan_id
                                                                  || ' - '
                                                                  || ' P_PLAN_TYPE  '
                                                                  || p_plan_type
                                                                  || ' - '
                                                                  || ' P_LIFE_EVENT_CODE - '
                                                                  || p_life_event_code
                                                                  || ' - '
                                                                  || ' P_DESCRIPTION - '
                                                                  || p_description
                                                                  || ' - '
                                                                  || ' P_ANNUAL_ELECTION - '
                                                                  || p_annual_election
                                                                  || ' - '
                                                                  || ' P_PAYROLL_CONTRIB - '
                                                                  || p_payroll_contrib
                                                                  || ' - '
                                                                  || ' P_EFFECTIVE_DATE -'
                                                                  || p_effective_date);

        p_batch_number := to_char(sysdate, 'MMDDYYYYHHMISS');
        if p_life_event_code = 'COBRA' then
            select
                count(*)
            into l_dummy
            from
                dual
            where
                exists (
                    select
                        1
                    from
                        ben_plan_enrollment_setup bps
                    where
                            acc_id = p_acc_id
                        and ( ( p_plan_type <> 'HRA'
                                and plan_type = p_plan_type )
                              or ( p_plan_type = 'HRA'
                                   and product_type = 'HRA' ) )
                        -- /** Vanitha : added **/
                        and trunc(plan_end_date) >= trunc(sysdate)
                        and bps.effective_end_date is null
                );

            if l_dummy = 1 then
                x_error_message := 'Employee must be terminated before electing COBRA.';
                raise app_exception;
            end if;
        end if;

        select
            acc_num,
            pers_id
        into
            l_acc_num,
            l_pers_id
        from
            account
        where
            acc_id = p_acc_id;

        if p_life_event_code = 'COBRA' then
            for x in (
                select
                    ben_plan_id,
                    effective_end_date
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = p_acc_id
                    and ( ( p_plan_type <> 'HRA'
                            and plan_type = p_plan_type )
                          or ( p_plan_type = 'HRA'
                               and product_type = 'HRA' ) )
                    and trunc(plan_end_date) >= trunc(sysdate)
                    and effective_end_date is not null
                --and    effective_end_date is  null
            ) loop
                if sysdate - x.effective_end_date > 90 then
                    x_error_message := 'Participant is past COBRA election period. Please contact administrator ';
                    raise app_exception;
                end if;

                l_ben_plan_id := x.ben_plan_id;
            end loop;
        end if;

        insert into ben_life_event_history (
            life_event_id,
            acc_num,
            acc_id,
            pers_id,
            entrp_id,
            ben_plan_id,
            life_event_code,
            description,
            annual_election,
            effective_date,
            status,
            payroll_contribution,
            batch_number,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                life_event_seq.nextval,
                l_acc_num,
                p_acc_id,
                l_pers_id,
                pc_person.get_entrp_id(p_acc_id),
                decode(p_life_event_code, 'COBRA', l_ben_plan_id, p_ben_plan_id),
                p_life_event_code,
                p_description,
                p_annual_election,
                to_date(p_effective_date, 'mm/dd/yyyy'),
                'A',
                p_payroll_contrib,
                p_batch_number,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id
            from
                dual;
         /* where not exists(select 1
                           from   ben_life_event_history bleh
                           where  bleh.ACC_NUM              =   L_ACC_NUM
                             and  bleh.ACC_ID               =   P_ACC_ID
                             and  bleh.PERS_ID              =   L_PERS_ID
                             and  bleh.ENTRP_ID             =   PC_PERSON.get_entrp_id(P_ACC_ID)
                             and  nvl(bleh.BEN_PLAN_ID,-1)  =   nvl(P_BEN_PLAN_ID,-1)
                             and  bleh.LIFE_EVENT_CODE      =   P_LIFE_EVENT_CODE
                             and  nvl(bleh.DESCRIPTION,'x') =   nvl(P_DESCRIPTION,'x')
                             and  nvl(bleh.ANNUAL_ELECTION,0)      =   nvl(P_ANNUAL_ELECTION,0)
                             and  bleh.EFFECTIVE_DATE       =   to_date(P_EFFECTIVE_DATE,'mm/dd/yyyy')
                             and  nvl(bleh.PAYROLL_CONTRIBUTION,0) =   nvl(P_PAYROLL_CONTRIB,0));
                             */
   -- if sql%rowcount > 0 then

        pc_ben_life_events.process_ben_life_events(
            p_batch_number    => p_batch_number,
            p_life_event_code => p_life_event_code,
            p_user_id         => p_user_id
        );

        commit;
   -- end if;
        x_return_status := 'S';
    exception
        when app_exception then
            rollback;
            x_return_status := 'E';
            x_error_message := 'Employee must be terminated before electing COBRA.';
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := substr(sqlerrm, 1, 250);
    end insert_ben_life_events;

-- Primarily this is for undo
-- life event change
-- purely done from SAM
    procedure update_ben_life_events (
        p_life_event_id in number,
        p_status        in varchar2,
        p_user_id       in number,
        x_return_status in varchar2,
        x_error_message in varchar2
    ) is
    begin
  -- Not now, in future - Vanitha
  -- p_life_event_code IN ('MARIAL_STATUS_CHANGE','DEP_CHANGE','EMPR_CHANGE'
  -- 'COURT_ORDER','MEDICARE','LOSS_OF_MEDICARE','ADDRESS_CHANGE',
  -- ''LOA_NO_CONTRIBUTION','LOA_POST_TAX_CONTRIBUTION','LOA_RETURN','OTHER'
  -- Just call insert annual election,
  -- annual election should be calculated and then inserted
  -- for HRA , create a contribution with new annual election
  -- or probably confirm
        null;
    end update_ben_life_events;

    procedure process_ben_life_events (
        p_batch_number    in number,
        p_life_event_code in varchar2,
        p_user_id         in number
    ) is

        l_plan_type           varchar2(30);
        l_cur_annual_election number;
        l_notification_id     number;
        l_acc_num             varchar2(20);
        l_plan_start_date     date;
        l_plan_end_date       date;
        l_life_event_desc     varchar2(100);
        l_email_address       varchar2(3200);
        l_html_message        varchar2(3200);
    begin
        for x in (
            select
                *
            from
                ben_life_event_history
            where
                    nvl(processed_status, 'N') = 'N'
                and status = 'A'
                and batch_number = nvl(p_batch_number, batch_number)
            --Ticket#2687
            --Plan should be allowed to terminate for future date also
            --AND   EFFECTIVE_DATE <= TRUNC(SYSDATE)
        ) loop
     /** Vanitha : moved here **/
            select
                acc_num
            into l_acc_num
            from
                account
            where
                acc_id = x.acc_id;

            if x.life_event_code = 'TERM_ONE_PLAN' then
                pc_termination.term_one_plan(
                    p_acc_id          => x.acc_id,
                    p_batch_number    => x.batch_number,
                    p_ben_plan_id     => x.ben_plan_id,
                    p_entrp_id        => x.entrp_id,
                    p_life_event_code => x.life_event_code,
                    p_effective_date  => x.effective_date,
                    p_user_id         => p_user_id
                );
            -- insertiung to global temporary tabl

                l_html_message := '<br/><br/> '
                                  || ' Account Number: '
                                  || x.acc_num
                                  || ' <br/> '
                                  || ' Effective Date: '
                                  || x.effective_date
                                  || ' <br/> '
                                  || ' Plan Type : '
                                  || pc_benefit_plans.get_ben_plan_type(x.ben_plan_id)
                                  || ' <br/> '
                                  || ' Employer Name : '
                                  || pc_entrp.get_entrp_name(x.entrp_id)
                                  || ' <br/> ';

                l_html_message := replace(pc_notifications.g_html_message, 'XXXBODYXXX', l_html_message);
                for xx in (
                    select
                        email
                    from
                        employee
                    where
                            dept_no = '2'
                        and term_date is null
                        and email is not null
                        and first_name <> 'Plan'
                    union
                    select
                        'vanitha.subramanyam@sterlingadministration.com'
                    from
                        dual
                ) loop
                    mail_utility.html_email(xx.email, 'onlineadmin@sterlingadministration.com', 'Plan termination for  ' || x.acc_num
                    , 'test', l_html_message);
                end loop;

            elsif x.life_event_code = 'TERM_ALL_PLAN' then
                pc_termination.term_all_plans(
                    p_acc_id          => x.acc_id,
                    p_batch_number    => x.batch_number,
                    p_life_event_code => x.life_event_code,
                    p_effective_date  => x.effective_date,
                    p_user_id         => p_user_id
                );

         -- insertiung to global temporary tabl

                l_html_message := '<br/><br/> '
                                  || ' Account Number: '
                                  || x.acc_num
                                  || ' <br/> '
                                  || ' Effective Date: '
                                  || x.effective_date
                                  || ' <br/> '
                                  || ' Employer Name : '
                                  || pc_entrp.get_entrp_name(x.entrp_id)
                                  || ' <br/> ';

                l_html_message := replace(pc_notifications.g_html_message, 'XXXBODYXXX', l_html_message);
                for xx in (
                    select
                        email
                    from
                        employee
                    where
                            dept_no = '2'
                        and term_date is null
                        and email is not null
                        and first_name <> 'Plan'
                    union
                    select
                        'vanitha.subramanyam@sterlingadministration.com'
                    from
                        dual
                ) loop
                    mail_utility.html_email(xx.email, 'onlineadmin@sterlingadministration.com', 'All the plans are terminated for  ' || x.acc_num
                    , 'test', l_html_message);
                end loop;

            elsif x.life_event_code in ( 'MARITAL_STATUS_CHANGE', 'DEP_CHANGE', 'EMPR_CHANGE', 'COURT_ORDER', 'MEDICARE',
                                         'LOSS_OF_MEDICARE', 'ADDRESS_CHANGE', 'LOA_NO_CONTRIBUTION', 'LOA_POST_TAX_CONTRIBUTION', 'LOA_RETURN'
                                         ,
                                         'OTHER', 'FMLA_ABSENCE' ) then
                select
                    annual_election,
                    plan_type,
                    plan_start_date,
                    plan_end_date
                into
                    l_cur_annual_election,
                    l_plan_type,
                    l_plan_start_date,
                    l_plan_end_date
                from
                    ben_plan_enrollment_setup
                where
                    ben_plan_id = x.ben_plan_id;

                select
                    substr(description, 1, 100)
                    || ' '
                    || x.description
                into l_life_event_desc
                from
                    lookups
                where
                        lookup_name = 'LIFE_EVENT_CODE'
                    and lookup_code = x.life_event_code;

         -- insertiung to global temporary tabl

                pc_ben_life_events.change_annual_election(
                    p_ee_acc_id       => x.acc_id,
                    p_entrp_id        => x.entrp_id,
                    p_plan_type       => l_plan_type,
                    p_amount          =>(x.annual_election - l_cur_annual_election),
                    p_batch_number    => x.batch_number,
                    p_effective_date  => x.effective_date,
                    p_user_id         => p_user_id,
                    p_plan_start_date => l_plan_start_date,
                    p_plan_end_date   => l_plan_end_date,
                    p_reason          => l_life_event_desc
                );

                l_html_message := '<br/><br/> '
                                  || ' Previous Annual Election: '
                                  || l_cur_annual_election
                                  || ' <br/> '
                                  || ' Current Annual Election: '
                                  || x.annual_election
                                  || ' <br/> '
                                  || ' Account Number: '
                                  || l_acc_num
                                  || ' <br/> '
                                  || ' Plan Type: '
                                  || l_plan_type
                                  || ' <br/> '
                                  || ' Contribution Amount : '
                                  || x.payroll_contribution
                                  || ' <br/> '
                                  || ' Effective Date : '
                                  || to_char(x.effective_date, 'MM/DD/YYYY')
                                  || ' <br/> '
                                  || ' Employer Name : '
                                  || pc_entrp.get_entrp_name(x.entrp_id)
                                  || ' <br/> ';

                l_html_message := replace(pc_notifications.g_html_message, 'XXXBODYXXX', l_html_message);
                for xx in (
                    select
                        email
                    from
                        employee
                    where
                            dept_no = '2'
                        and term_date is null
                        and email is not null
                        and first_name <> 'Plan'
                    union
                    select
                        'vanitha.subramanyam@sterlingadministration.com'
                    from
                        dual
                ) loop
                    mail_utility.html_email(xx.email, 'onlineadmin@sterlingadministration.com', 'Annual Election Changed for ' || l_acc_num
                    , 'test', l_html_message);
                end loop;

                update ben_plan_enrollment_setup
                set
                    life_event_code = x.life_event_code,
                    annual_election = x.annual_election  -- needed latest value, if life event happens more than once to calculate amt correctly
                    ,
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                    ben_plan_id = x.ben_plan_id;

                for xx in (
                    select
                        coverage_type
                    from
                        ben_plan_coverages        a,
                        ben_plan_enrollment_setup b
                    where
                            b.ben_plan_id = x.ben_plan_id
                        and a.ben_plan_id = b.ben_plan_id_main
                        and coverage_tier_name = x.cov_tier_name
                ) loop
                    update ben_plan_coverages
                    set
                        coverage_tier_name = x.cov_tier_name,
                        coverage_type = xx.coverage_type,
                        annual_election = x.annual_election,
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                        ben_plan_id = x.ben_plan_id;

                end loop;

            elsif x.life_event_code = 'COBRA' then
                update ben_plan_enrollment_setup
                set
                    effective_end_date = null,
                    status = 'A',
                    life_event_code = 'COBRA',
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                    ben_plan_id = x.ben_plan_id;

         -- insertiung to global temporary tabl
                update scheduler_details
                set
                    status = 'A',
                    last_updated_date = sysdate,
                    last_updated_by = p_user_id
                where
                        acc_id = x.acc_id
                    and scheduler_id = (
                        select
                            scheduler_id
                        from
                            scheduler_master sm
                        where
                                sm.plan_type = (
                                    select
                                        plan_type
                                    from
                                        ben_plan_enrollment_setup bps
                                    where
                                            ben_plan_id = x.ben_plan_id
                                        and bps.status <> 'R'
                                )
                            and sm.acc_id = (
                                select
                                    acc_id
                                from
                                    account
                                where
                                    entrp_id = x.entrp_id
                            )
                            and nvl(payment_end_date, sysdate) >= sysdate
                    );

                update termination_interface
                set
                    processed = 'N',
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                    acc_id = x.acc_id;

                l_html_message := 'Cobra Continuation elected for ' || l_acc_num;
                l_html_message := replace(pc_notifications.g_html_message, 'XXXBODYXXX', l_html_message);
                for xx in (
                    select
                        email
                    from
                        employee
                    where
                            dept_no = '2'
                        and term_date is null
                        and email is not null
                        and first_name <> 'Plan'
                    union
                    select
                        'vanitha.subramanyam@sterlingadministration.com'
                    from
                        dual
                ) loop
                    mail_utility.html_email(xx.email, 'onlineadmin@sterlingadministration.com', 'Cobra Continuation elected for ' || l_acc_num
                    , 'test', l_html_message);
                end loop;

           /** Vanitha : added **/

            end if;

            update ben_life_event_history
            set
                processed_status = 'Y',
                processed_date = sysdate
            where
                life_event_id = x.life_event_id;

        end loop;
  -- Notify Annual election Changes
 -- pc_notifications.hrafsa_ae_change_report;
  -- p_life_event_code = TERM_ONE_PLAN
  -- insert into termination interface
  --TODO
  --insert_termination_interface (P_ACC_ID IN NUMBER ,P_ENTRP_ID IN NUMBER ,P_LIFE_EVENT_CODE IN VARCHAR2 ,P_EFFECTIVE_DATE IN DATE ,P_USER_ID IN NUMBER ,P_PLAN_TYPE IN VARCHAR2 ,P_BEN_PLAN_ID IN NUMBER)
  -- p_life_event_code = TERM_ALL_PLAN
  -- query all plans and insert into termination interface
  -- then call pc_termination.terminate_plans
  -- also call terminate_dependants
  -- terminate debit card if p_life_event_code = TERM_ALL_PLAN
  -- inactivate the scheduler
  -- p_life_event_code IN ('MARIAL_STATUS_CHANGE','DEP_CHANGE','EMPR_CHANGE'
  -- 'COURT_ORDER','MEDICARE','LOSS_OF_MEDICARE','ADDRESS_CHANGE',
  -- ''LOA_NO_CONTRIBUTION','LOA_POST_TAX_CONTRIBUTION','LOA_RETURN','OTHER'
  -- Just call insert annual election,
  -- annual election should be calculated and then inserted
  -- for HRA , create a contribution with new annual election -- not needed
  -- or probably confirm
  -- insert alert
  -- p_life_event_code = 'COBRA'
  -- no changes but then confirm if benefit plan should be end dated or something
  -- Update life event code for ben_plan_enrollment_setup
  -- so that in office guys know where it is at
    exception
        when others then
            pc_log.log_error('PROCESS_BEN_LIFE_EVENTS', sqlerrm);
    end process_ben_life_events;

    procedure change_annual_election (
        p_ee_acc_id       in number,
        p_entrp_id        in number,
        p_plan_type       in varchar2,
        p_amount          in number,
        p_batch_number    in number,
        p_effective_date  in date,
        p_user_id         in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_reason          in varchar2
    ) as
        l_list_bill number;
    begin
        select
            employer_deposit_seq.nextval
        into l_list_bill
        from
            dual;

        pc_fin.create_employer_deposit(
            p_list_bill          => l_list_bill,
            p_entrp_id           => p_entrp_id,
            p_check_amount       => p_amount,
            p_check_date         => p_effective_date,
            p_posted_balance     => p_amount,
            p_fee_bucket_balance => 0,
            p_remaining_balance  => 0,
            p_user_id            => p_user_id,
            p_plan_type          => p_plan_type,
            p_note               => 'Life Event Annual Election change',
            p_reason_code        => 12,
            p_check_number       => p_batch_number
        );

        pc_fin.create_receipt(
            p_acc_id            => p_ee_acc_id,
            p_fee_date          => p_effective_date,
            p_entrp_id          => p_entrp_id,
            p_er_amount         => p_amount,
            p_pay_code          => 6,
            p_plan_type         => p_plan_type,
            p_debit_card_posted => 'N',
            p_list_bill         => l_list_bill,
            p_fee_reason        => 12,
            p_note              => p_reason
                      || ' - Annual Election change for plan year '
                      || p_plan_start_date
                      || ' - '
                      || p_plan_end_date,
            p_check_amount      => p_amount,
            p_user_id           => p_user_id,
            p_check_number      => p_batch_number
        );

    end;

    function get_life_events (
        p_acc_id     in number,
        p_plan_type  in varchar2,
        p_start_date in varchar2,
        p_end_date   in varchar2
    ) return life_events_table_t
        pipelined
        deterministic
    as
        l_cursor     sys_refcursor;
        l_record     life_events_row_t;
        v_start_date date;
     --v_end_date                date;
    begin
     -- v_start_date will not be accurate as I see some plans starting in February
     -- needs review if this code will be used
        v_start_date := nvl(to_date(trim(p_start_date),
    'mm/dd/yyyy'),
                            trunc(sysdate, 'YYYY'));
     --v_end_date := nvl(to_date(p_end_date,'mm/dd/yyyy'),last_day(add_months(trunc(sysdate,'YYYY'), 11)));
        open l_cursor for select
                                              *
                                          from
                                              (
                                                  select
                                                      bleh.effective_date,
                                                      bps.plan_type
                                                      || ' - '
                                                      || l.description life_event,
                                                      nvl(bleh.annual_election, 0)
                                                  from
                                                      ben_life_event_history    bleh,
                                                      lookups                   l,
                                                      ben_plan_enrollment_setup bps
                                                  where
                                                          bleh.life_event_code = l.lookup_code
                                                      and bps.ben_plan_id = bleh.ben_plan_id
                                                      and bleh.life_event_code not in ( 'TERM_ONE_PLAN', 'TERM_ALL_PLAN', 'COBRA', 'ACCOUNT_TERMINATION'
                                                      ) -- as term_one_plan should be shown only when term_all_plan not available
                                                      and bps.plan_type = nvl(
                                                          trim(p_plan_type),
                                                          bps.plan_type
                                                      )
                                                      and bps.plan_start_date = v_start_date
                                                      and trunc(bps.plan_end_date) >= sysdate
                                                      and bps.acc_id = p_acc_id
                                                      and bps.status <> 'R'
                                                      and l.lookup_name = 'LIFE_EVENT_CODE'  --COBRA has two diff lookup names
                                                  union all
                                                  select
                                                      termination_date     effective_date,
                                                      bps.plan_type
                                                      || ' - '
                                                      || 'Plan Terminated' life_event,
                                                      0                    annual_election --for term_one_plan
                                                  from
                                                      termination_interface     ti,
                                                      ben_plan_enrollment_setup bps
                                                  where
                                                          bps.acc_id = p_acc_id
                                                      and bps.plan_type = nvl(
                                                          trim(p_plan_type),
                                                          bps.plan_type
                                                      )
                                                      and bps.plan_start_date = v_start_date
                                                      and trunc(bps.plan_end_date) >= sysdate
                                                      and ti.ben_plan_id = bps.ben_plan_id
                                                      and ti.plan_type = nvl(
                                                          trim(p_plan_type),
                                                          ti.plan_type
                                                      )
                                                      and ti.acc_id = p_acc_id
                                                      and bps.status <> 'R'
                                                      and not exists (
                                                          select
                                                              1
                                                          from
                                                              ben_life_event_history    bleh1,
                                                              ben_plan_enrollment_setup bps1
                                                          where
                                                                  bps1.ben_plan_id = bleh1.ben_plan_id
                                                              and bleh1.life_event_code = 'TERM_ALL_PLAN'
                                    --and    bps.plan_type        = :p_plan_type
                                                              and bps1.plan_start_date = v_start_date
                                                              and trunc(bps1.plan_end_date) >= sysdate   --v_end_date
                                                              and bps1.acc_id = p_acc_id
                                                      )
                                                  union all
                                                  select
                                                      bleh.effective_date,
                                                      l.description life_event,
                                                      nvl(bleh.annual_election, 0) --for term_all_plan
                                                  from
                                                      ben_life_event_history    bleh,
                                                      ben_plan_enrollment_setup bps,
                                                      lookups                   l
                                                  where
                                                          bps.ben_plan_id = bleh.ben_plan_id
                                                      and bleh.life_event_code in ( 'TERM_ALL_PLAN', 'COBRA' )
                --and    bps.plan_type        = p_plan_type  --'plan type is irrelevant with term_all_plan and cobra
                                                      and bps.plan_start_date = v_start_date
                                                      and trunc(bps.plan_end_date) >= sysdate
                                                      and bps.acc_id = p_acc_id
                                                      and bleh.acc_id = p_acc_id
                                                      and bps.status <> 'R'
                                                      and bleh.life_event_code = l.lookup_code
                                                      and l.lookup_name = 'LIFE_EVENT_CODE'  --COBRA has two diff lookup names
                                              ) x
                         order by
                             x.effective_date;

        loop
            fetch l_cursor into l_record;
            exit when l_cursor%notfound;
            pipe row ( l_record );
        end loop;

        close l_cursor;
        return;
    end get_life_events;

    procedure insert_ee_ben_life_events (
        p_acc_id          in number,
        p_ben_plan_id     in number,
        p_plan_type       in varchar2,
        p_life_event_code in varchar2,
        p_description     in varchar2,
        p_annual_election in number,
        p_payroll_contrib in number,
        p_effective_date  in varchar2,
        p_cov_tier_name   in varchar2,
        p_user_id         in number,
        p_batch_number    in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is

        l_acc_num         varchar2(20);
        l_pers_id         number;
        app_exception exception;
        l_dummy           number := 0;
        l_ben_plan_id     number;
        l_setup_error exception;
        l_annual_election number := 0;
        l_update_flag     varchar2(1) := 'N';
    begin
        x_return_status := 'S';
        pc_log.log_error('INSERT_EE_BEN_LIFE_EVENTS', 'p_batch_number ' || p_batch_number);
        pc_log.log_error('INSERT_EE_BEN_LIFE_EVENTS', 'P_ACC_ID ' || p_acc_id);
        pc_log.log_error('INSERT_EE_BEN_LIFE_EVENTS', 'P_ANNUAL_ELECTION ' || p_annual_election);
        pc_log.log_error('INSERT_EE_BEN_LIFE_EVENTS', 'P_COV_TIER_NAME ' || p_cov_tier_name);
        for x in (
            select
                er.minimum_election,
                er.maximum_election,
                er.plan_start_date,
                er.plan_end_date,
                ee.plan_type,
                ee.annual_election,
                ee.grace_period         -- Added by swamy on 18/05/2018 for ticket#5657
            from
                ben_plan_enrollment_setup ee,
                ben_plan_enrollment_setup er
            where
                    ee.ben_plan_id = p_ben_plan_id
                and ee.ben_plan_id_main = er.ben_plan_id
        ) loop
            if x.plan_start_date > to_date ( p_effective_date, 'MM/DD/YYYY' ) then
                x_error_message := 'Enter Effective date after the Plan Year Start or Same Date as Plan Year Start for plan type ' || x.plan_type
                ;
                raise l_setup_error;
            end if;

            if x.plan_end_date < to_date ( p_effective_date, 'MM/DD/YYYY' ) then
                x_error_message := 'Enter Effective date before the Plan Year End for plan type ' || x.plan_type;
                raise l_setup_error;
            end if;

            if to_date ( p_effective_date, 'MM/DD/YYYY' ) > sysdate then
                x_error_message := 'Future Effective Date is not allowed for Qualifying Event Change for plan type ' || x.plan_type;
                raise l_setup_error;
            end if;

           -- The below if cond. added by swamy on 18/05/2018 for ticket#5657
            if
                upper(p_life_event_code) in ( 'TERM_ONE_PLAN', 'TERM_ALL_PLAN' )
                and to_date ( p_effective_date, 'MM/DD/YYYY' ) > ( x.plan_end_date + nvl(x.grace_period, 0) )
            then
                x_error_message := 'Termination Date cannot be greater than plan end date';
                raise l_setup_error;
            end if;

        --   IF L_PLAN_TYPE(i) NOT IN ('HRA','HRP','ACO','HR5','HR4','TRN','PKG','UA1') THEN

            if p_annual_election < x.minimum_election then
                x_error_message := 'Enter Annual Election more than the Minimum Election for plan type ' || x.plan_type;
                raise l_setup_error;
            end if;

            if p_annual_election > x.maximum_election then
                x_error_message := 'Enter Annual Election less than the Maximum Election for plan type ' || x.plan_type;
                raise l_setup_error;
            end if;

--           END IF;
            l_annual_election := x.annual_election;
        end loop;

        l_update_flag := 'N';
        if p_life_event_code = 'ANNUAL_ELEC_UPDATE' then
            if
                l_annual_election is not null
                and l_annual_election <> p_annual_election
            then
                l_update_flag := 'Y';
            end if;
        else
            l_update_flag := 'Y';
        end if;

        if
            l_update_flag = 'Y'
            and p_ben_plan_id is not null
        then
            insert into ben_life_event_history (
                life_event_id,
                acc_num,
                acc_id,
                pers_id,
                entrp_id,
                ben_plan_id,
                life_event_code,
                description,
                annual_election,
                effective_date,
                status,
                payroll_contribution,
                batch_number,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                cov_tier_name
            )
                select
                    life_event_seq.nextval,
                    pc_account.get_acc_num_from_acc_id(p_acc_id),
                    p_acc_id,
                    pc_person.pers_id_from_acc_id(p_acc_id),
                    pc_person.get_entrp_id(p_acc_id),
                    p_ben_plan_id,
                    p_life_event_code,
                    p_description,
                    p_annual_election,
                    to_date(p_effective_date, 'mm/dd/yyyy'),
                    'P',
                    p_payroll_contrib,
                    p_batch_number,
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    case
                        when p_cov_tier_name = 'null' then
                            null
                        else
                            p_cov_tier_name
                    end
                from
                    dual;

        end if;

    exception
        when l_setup_error then
            x_return_status := 'E';
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := substr(sqlerrm, 1, 250);
    end insert_ee_ben_life_events;

    procedure approve_ee_ben_life_events (
        p_acc_id          in varchar2_tbl,
        p_ben_plan_id     in varchar2_tbl,
        p_annual_election in varchar2_tbl,
        p_payroll_contrib in varchar2_tbl,
        p_effective_date  in varchar2_tbl,
        p_batch_number    in varchar2_tbl,
        p_status          in varchar2_tbl,
        p_description     in varchar2_tbl,
        p_cov_tier_name   in varchar2_tbl,
        p_process_batch   in number,
        p_user_id         in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is

        l_ben_plan_id     varchar2_tbl;
        l_status          varchar2_tbl;
        l_acc_id          varchar2_tbl;
        l_annual_election varchar2_tbl;
        l_pay_contrib     varchar2_tbl;
        l_effective_date  varchar2_tbl;
        l_batch_number    varchar2_tbl;
        l_description     varchar2_tbl;
        l_cov_tier_name   varchar2_tbl;
    begin
        l_acc_id := array_fill(p_acc_id, p_ben_plan_id.count);
        l_ben_plan_id := array_fill(p_ben_plan_id, p_ben_plan_id.count);
        l_annual_election := array_fill(p_annual_election, p_ben_plan_id.count);
        l_pay_contrib := array_fill(p_payroll_contrib, p_ben_plan_id.count);
        l_effective_date := array_fill(p_effective_date, p_ben_plan_id.count);
        l_batch_number := array_fill(p_batch_number, p_ben_plan_id.count);
        l_status := array_fill(p_status, p_ben_plan_id.count);
        l_description := array_fill(p_description, p_ben_plan_id.count);
        l_cov_tier_name := array_fill(p_cov_tier_name, p_ben_plan_id.count);

    -- todo: notifications
        for i in 1..l_acc_id.count loop
            pc_log.log_error('PROCESS_BEN_LIFE_EVENTS',
                             'batcj number ' || l_batch_number(i));
            pc_log.log_error('PROCESS_BEN_LIFE_EVENTS',
                             'L_PAY_CONTRIB ' || l_pay_contrib(i));
            pc_log.log_error('PROCESS_BEN_LIFE_EVENTS',
                             'L_ANNUAL_ELECTION ' || l_annual_election(i));
            pc_log.log_error('PROCESS_BEN_LIFE_EVENTS',
                             'L_EFFECTIVE_DATE ' || l_effective_date(i));
            pc_log.log_error('PROCESS_BEN_LIFE_EVENTS',
                             '(L_DESCRIPTION ' || l_description(i));
            pc_log.log_error('PROCESS_BEN_LIFE_EVENTS',
                             '(L_COV_TIER_NAME ' || l_cov_tier_name(i));
  --  pc_log.log_error('PROCESS_BEN_LIFE_EVENTS','(L_DESCRIPTION '||L_DESCRIPTION(i));

            if l_status(i) = 'A' then
                update ben_life_event_history
                set
                    payroll_contribution = l_pay_contrib(i),
                    annual_election = l_annual_election(i),
                    effective_date = to_date(l_effective_date(i),
        'mm/dd/yyyy'),
                    description = nvl(
                        l_description(i),
                        ''
                    ),
                    last_update_date = sysdate,
                    last_updated_by = p_user_id,
                    status = 'A',
                    cov_tier_name =
                        case
                            when l_cov_tier_name(i) = 'null' then
                                null
                            else
                                l_cov_tier_name(i)
                        end,
                    process_batch_num = p_process_batch
                where
                        ben_plan_id = l_ben_plan_id(i)
                    and acc_id = l_acc_id(i)
                    and batch_number = l_batch_number(i);

                pc_ben_life_events.process_ben_life_events(
                    p_batch_number    => l_batch_number(i),
                    p_life_event_code => null,
                    p_user_id         => p_user_id
                );

            end if;

            if l_status(i) = 'R' then
                update ben_life_event_history
                set
                    description = description || ' Rejected by Employer',
                    last_update_date = sysdate,
                    last_updated_by = p_user_id,
                    status = 'R',
                    process_batch_num = p_process_batch
                where
                        ben_plan_id = l_ben_plan_id(i)
                    and acc_id = l_acc_id(i)
                    and batch_number = l_batch_number(i);

            end if;

        end loop;

    end approve_ee_ben_life_events;

    function get_ann_elec_changes (
        p_acc_id      in number,
        p_ben_plan_id in number default null
    ) return ann_elec_change_t
        pipelined
        deterministic
    is
        l_record ann_elec_change_row_t;
    begin
        for x in (
            select
                acc_num,
                a.acc_id,
                a.ben_plan_id,
                bp.plan_type,
                a.life_event_code,
                pc_lookups.get_meaning(a.life_event_code, 'LIFE_EVENT_CODE')  event_desc,
                a.description,
                to_char(a.effective_date, 'MM/DD/YYYY')                       effective_date,
                a.annual_election,
                decode(a.processed_status, 'Y', 'Processed', 'Not Processed') status,
                a.status                                                      status_code,
                decode(a.status, 'R', 'Rejected', 'P', 'Pending Approval',
                       'A', 'Approved')                                       status_code_desc,
                bp.product_type,
                a.cov_tier_name
            from
                ben_life_event_history    a,
                ben_plan_enrollment_setup bp
            where
                    a.acc_id = p_acc_id
                and a.ben_plan_id = bp.ben_plan_id
                and bp.ben_plan_id = nvl(p_ben_plan_id, bp.ben_plan_id)
        ) loop
            l_record.acc_num := x.acc_num;
            l_record.acc_id := x.acc_id;
            l_record.plan_id := x.ben_plan_id;
            l_record.plan_type := x.plan_type;
            l_record.life_event_code := x.life_event_code;
            l_record.event_desc := x.event_desc;
            l_record.description := x.description;
            l_record.effective_date := x.effective_date;
            l_record.annual_election := x.annual_election;
            l_record.status := x.status;
            l_record.status_code := x.status_code;
            l_record.product_type := x.product_type;
            l_record.status_code_desc := x.status_code_desc;
            if x.ben_plan_id is not null then
                for xx in (
                    select
                        plan_start_date,
                        plan_end_date,
                        annual_election
                    from
                        ben_plan_enrollment_setup
                    where
                        ben_plan_id = x.ben_plan_id
                ) loop
                    l_record.plan_start_date := to_char(xx.plan_start_date, 'MM/DD/YYYY');
                    l_record.plan_end_date := to_char(xx.plan_end_date, 'MM/DD/YYYY');
                    l_record.current_annual_election := xx.annual_election;
                end loop;
            end if;

            l_record.cov_tier_name := x.cov_tier_name;
            pipe row ( l_record );
        end loop;
    end get_ann_elec_changes;

    function get_er_ann_elec_changes (
        p_entrp_id in number
    ) return ann_elec_change_t
        pipelined
        deterministic
    is
        l_record ann_elec_change_row_t;
    begin
        for x in (
            select
                acc_num,
                acc_id,
                ben_plan_id,
                pc_benefit_plans.get_ben_plan_type(ben_plan_id)             plan_type,
                life_event_code,
                pc_lookups.get_meaning(life_event_code, 'LIFE_EVENT_CODE')  event_desc,
                description,
                to_char(effective_date, 'MM/DD/YYYY')                       effective_date,
                annual_election,
                decode(processed_status, 'Y', 'Processed', 'Not Processed') status,
                batch_number,
                status                                                      status_code,
                pers_id,
                cov_tier_name
            from
                ben_life_event_history
            where
                entrp_id = p_entrp_id
        ) loop
            l_record.acc_num := x.acc_num;
            l_record.acc_id := x.acc_id;
            l_record.plan_id := x.ben_plan_id;
            l_record.plan_type := x.plan_type;
            l_record.life_event_code := x.life_event_code;
            l_record.event_desc := x.event_desc;
            l_record.description := x.description;
            l_record.effective_date := x.effective_date;
            l_record.annual_election := x.annual_election;
            l_record.status := x.status;
            l_record.status_code := x.status_code;
            l_record.pers_name := pc_person.get_person_name(x.pers_id);
            l_record.product_type := pc_lookups.get_meaning(x.plan_type, 'FSA_HRA_PRODUCT_MAP');
            l_record.batch_number := x.batch_number;
            if x.ben_plan_id is not null then
                for xx in (
                    select
                        plan_start_date,
                        plan_end_date,
                        annual_election
                    from
                        ben_plan_enrollment_setup
                    where
                        ben_plan_id = x.ben_plan_id
                ) loop
                    l_record.plan_start_date := to_char(xx.plan_start_date, 'MM/DD/YYYY');
                    l_record.plan_end_date := to_char(xx.plan_end_date, 'MM/DD/YYYY');
                    l_record.current_annual_election := xx.annual_election;
                end loop;
            end if;

            if x.status_code = 'A' then
                for xx in (
                    select
                        b.coverage_tier_name
                    from
                        ben_plan_enrollment_setup a,
                        ben_plan_coverages        b
                    where
                            a.ben_plan_id = x.ben_plan_id
                        and a.ben_plan_id = b.ben_plan_id
                        and a.acc_id = x.acc_id
                ) loop
                    l_record.cov_tier_name := xx.coverage_tier_name;
                end loop;
            else
                l_record.cov_tier_name := x.cov_tier_name;
            end if;

            pipe row ( l_record );
        end loop;
    end get_er_ann_elec_changes;

    function get_approved_ann_elec_changes (
        p_entrp_id     in number,
        p_batch_number in number
    ) return ann_elec_change_t
        pipelined
        deterministic
    is
        l_record ann_elec_change_row_t;
    begin
        for x in (
            select
                a.acc_id,
                a.ben_plan_id,
                pc_benefit_plans.get_ben_plan_type(a.ben_plan_id)            plan_type,
                a.life_event_code,
                pc_lookups.get_meaning(a.life_event_code, 'LIFE_EVENT_CODE') event_desc,
                a.effective_date,
                a.annual_election,
                pc_person.get_person_name(b.pers_id)                         person_name,
                batch_number
            from
                ben_life_event_history a,
                account                b
            where
                    a.acc_id = b.acc_id
                and a.process_batch_num = p_batch_number
                and a.entrp_id = p_entrp_id
                and a.status = 'A'
        ) loop
            l_record.acc_id := x.acc_id;
            l_record.plan_id := x.ben_plan_id;
            l_record.plan_type := x.plan_type;
            l_record.life_event_code := x.life_event_code;
            l_record.event_desc := x.event_desc;
            l_record.effective_date := to_char(x.effective_date, 'MM/DD/YYYY');
            l_record.annual_election := x.annual_election;
            l_record.pers_name := x.person_name;
            l_record.batch_number := x.batch_number;
            if x.ben_plan_id is not null then
                for xx in (
                    select
                        plan_start_date,
                        plan_end_date,
                        annual_election
                    from
                        ben_plan_enrollment_setup
                    where
                        ben_plan_id = x.ben_plan_id
                ) loop
                    l_record.plan_start_date := to_char(xx.plan_start_date, 'MM/DD/YYYY');
                    l_record.plan_end_date := to_char(xx.plan_end_date, 'MM/DD/YYYY');
                end loop;
            end if;

            for xx in (
                select
                    b.coverage_tier_name
                from
                    ben_plan_enrollment_setup a,
                    ben_plan_coverages        b
                where
                        a.ben_plan_id = x.ben_plan_id
                    and a.ben_plan_id = b.ben_plan_id
                    and a.acc_id = x.acc_id
            ) loop
                l_record.cov_tier_name := xx.coverage_tier_name;
            end loop;

            pipe row ( l_record );
        end loop;
    end get_approved_ann_elec_changes;

end;
/

