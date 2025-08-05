-- liquibase formatted sql
-- changeset SAMQA:1754373992275 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_crm_interface.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_crm_interface.sql:null:daefb5d11a31fd371d0eea7d003bca575d9facd3:create

create or replace package body samqa.pc_crm_interface as

    procedure process_interface_status (
        p_entity_name      in varchar2,
        p_entity_id        in varchar2,
        p_interface_id     in varchar2,
        p_interface_status in varchar2
    ) is
    begin
        insert into crm_interfaces (
            interface_id,
            entity_name,
            entity_id,
            interface_status,
            creation_date,
            interfaced_id
        ) values ( crm_interface_seq.nextval,
                   p_entity_name,
                   p_entity_id,
                   p_interface_status,
                   sysdate,
                   p_interface_id );

    end process_interface_status;

    procedure email_crm_imported_accounts is
        l_sql          varchar2(4000);
        l_html_message varchar2(4000);
    begin
        l_sql := 'SELECT * FROM crm_import_v WHERE acc_num IN '
                 || ' ( SELECT entity_id FROM crm_interfaces WHERE entity_name = ''ACCOUNT'' '
                 || ' and TRUNC(creation_date) = TRUNC(SYSDATE) and interface_status = ''INTERFACED'')';
        mail_utility.report_emails('oracle@sterlingadministration.com',
                                   'VHSTeam@sterlingadministration.com',
                                   'crm_accounts'
                                   || to_char(sysdate, 'MMDDYYYY')
                                   || '.xls',
                                   l_sql,
                                   l_html_message,
                                   'Accounts imported to CRM on ' || to_char(sysdate, 'MM/DD/YYYY'));

        mail_utility.report_emails('Mallikarjun@sterlingadministration.com',
                                   'shavee.kapoor@sterlingadministration.com,franco.espinoza@sterlingadministration.com,vanitha.subramanyam@sterlingadministration.com,' || 'suresh.gali@sterlingadministration.com,quy.vo@sterlingadministration.com'
                                   ,
                                   'crm_accounts'
                                   || to_char(sysdate, 'MMDDYYYY')
                                   || '.xls',
                                   l_sql,
                                   l_html_message,
                                   'SugarCRM Daily Task -  ' || to_char(sysdate, 'MM/DD/YYYY'));

        l_sql := 'SELECT * FROM crm_import_v WHERE acc_num IN '
                 || ' ( SELECT entity_id FROM crm_interfaces WHERE entity_name = ''ACCOUNT'' '
                 || ' and TRUNC(creation_date) = TRUNC(SYSDATE) and interface_status = ''NOT_INTERFACED'')';
        mail_utility.report_emails('oracle@sterlingadministration.com',
                                   'VHSTeam@sterlingadministration.com',
                                   'crm_accounts'
                                   || to_char(sysdate, 'MMDDYYYY')
                                   || '.xls',
                                   l_sql,
                                   l_html_message,
                                   'Accounts not imported to CRM on ' || to_char(sysdate, 'MM/DD/YYYY'));

    end email_crm_imported_accounts;

    -- Get all the accounts that has to be renewed in 90 days
    function get_renewal_opportunity (
        p_account_type in varchar2
    ) return renewal_row_t
        pipelined
        deterministic
    is
        l_record        renewal_rec;
        l_assigned_user varchar2(100);
        l_prev_entrp_id number;
    begin
        if p_account_type = 'POP' then
            for x in (
                select
                    *
                from
                    pop_renewal_v
            ) loop
                l_record.acc_id := x.acc_id;
                l_record.employer_name := x.name;
                l_record.acc_num := x.acc_num;
                l_record.account_type := 'CAFETERIA';
                l_record.broker_name := x.broker_name;
                l_record.broker_id := x.broker_id;
                l_record.ga_id := x.ga_id;
                l_record.ga_name := nvl(x.ga_name, 'N/A');
                l_record.ga := x.ga_name;
                l_record.css_id := x.css_id;
                l_record.start_date := to_char(x.plan_start_date, 'YYYY-MM-DD');
                l_record.end_date := to_char(x.plan_end_date, 'YYYY-MM-DD');
                l_record.eligible_ee := x.no_of_eligible;
                l_record.salesrep_id := x.salesrep_id;
                l_record.funding_options := 'NA';
                l_record.funding_option_amount := 0.00;
                l_record.salesrep_id := x.salesrep_id;
                l_record.ben_plan_id := x.ben_plan_id;
                l_record.renewal_amount := 0.00;
                l_record.total_fee := 0.00;
                l_record.optional_fee := 0.00;
                l_record.invoice_to := 'CLIENT';
                l_record.entrp_id := x.entrp_id;
                l_record.ein := x.entrp_code;
                l_record.payment_method := 'Check';
                l_record.account_manager := x.am;
                for xx in (
                    select
                        a.name,
                        b.user_id,
                        c.user_name
                    from
                        salesrep  a,
                        employee  b,
                        sam_users c
                    where
                            a.salesrep_id = l_record.account_manager
                        and a.emp_id = b.emp_id
                        and a.status = 'A'
                        and b.user_id = c.user_id (+)
                        and c.status (+) = 'A'
                ) loop
                    l_record.assigned_user := xx.user_name;
                end loop;

                pipe row ( l_record );
            end loop;

        elsif p_account_type = 'COBRA' then
            for x in (
                select
                    *
                from
                    cobra_renewal_v a
            ) loop
                l_record.acc_id := x.acc_id;
                l_record.employer_name := x.name;
                l_record.acc_num := x.acc_num;
                l_record.account_type := 'COBRA';
                l_record.broker_name := x.broker_name;
                l_record.broker_id := x.broker_id;
                l_record.ga_id := x.ga_id;
                l_record.ga_name := nvl(x.ga_name, 'N/A');
                l_record.ga := x.ga_name;
                l_record.css_id := x.css_id;
                l_record.start_date := to_char(x.plan_start_date, 'YYYY-MM-DD');
                l_record.end_date := to_char(x.plan_end_date, 'YYYY-MM-DD');
                l_record.eligible_ee := x.no_of_eligible;
                l_record.salesrep_id := x.salesrep_id;
                l_record.funding_options := 'NA';
                l_record.funding_option_amount := 0.00;
                l_record.salesrep_id := x.salesrep_id;
                l_record.ben_plan_id := null;--x.BEN_PLAN_ID;

                l_record.renewal_amount := 0.00;
                l_record.total_fee := 0.00;
                l_record.optional_fee := 0.00;
                l_record.invoice_to := 'CLIENT';
                l_record.entrp_id := x.entrp_id;
                l_record.ein := x.entrp_code;
                l_record.payment_method := 'Check';
                l_record.account_manager := x.am;
                for xx in (
                    select
                        a.name,
                        b.user_id,
                        c.user_name
                    from
                        salesrep  a,
                        employee  b,
                        sam_users c
                    where
                            a.salesrep_id = l_record.account_manager
                        and a.emp_id = b.emp_id
                        and a.status = 'A'
                        and b.user_id = c.user_id (+)
                        and c.status (+) = 'A'
                ) loop
                    l_record.assigned_user := xx.user_name;
                end loop;

                pipe row ( l_record );
            end loop;
        else
            for x in (
                select distinct
                    name,
                    acc_num,
                    acc_id,
                    entrp_id,
                    account_type,
                    no_of_eligible,
                    entrp_code,
                    plan_start_date,
                    plan_end_date,
                    date_closed,
                    broker_name,
                    broker_id,
                    ga_id,
                    ga_name,
                    salesrep_id,
                    note,
                    am,
                    css_id
                from
                    fsa_hra_erisa_5500_renewal_v
                where
                    account_type <> 'FORM_5500'
            ) -- Added where for 7761. FORM_5500 rows returned in below loop
             loop
                l_record.acc_id := x.acc_id;
                l_record.employer_name := x.name;
                l_record.acc_num := x.acc_num;
                l_record.account_type := x.account_type;
                l_record.broker_name := x.broker_name;
                l_record.broker_id := x.broker_id;
                l_record.ga_id := x.ga_id;
                l_record.ga_name := nvl(x.ga_name, 'N/A');
                l_record.ga := x.ga_name;
                l_record.css_id := x.css_id;
                l_record.start_date := to_char(x.plan_start_date, 'YYYY-MM-DD');
                l_record.end_date := to_char(x.plan_end_date, 'YYYY-MM-DD');
                l_record.date_closed := to_char(x.date_closed, 'YYYY-MM-DD');--sk added on 02_26_2019
                l_record.eligible_ee := x.no_of_eligible;
                l_record.salesrep_id := x.salesrep_id;
                l_record.funding_options := 'NA';
                l_record.funding_option_amount := 0.00;
                l_record.salesrep_id := x.salesrep_id;
                --   l_record.ben_plan_id  :=  x.BEN_PLAN_ID;

                l_record.renewal_amount := 0.00;
                l_record.total_fee := 0.00;
                l_record.optional_fee := 0.00;
                l_record.invoice_to := 'CLIENT';
                l_record.entrp_id := x.entrp_id;
                l_record.ein := x.entrp_code;
                l_record.payment_method := 'Check';
                l_record.account_manager := x.am;
                for xx in (
                    select
                        a.name,
                        b.user_id,
                        c.user_name
                    from
                        salesrep  a,
                        employee  b,
                        sam_users c
                    where
                            a.salesrep_id = l_record.account_manager
                        and a.emp_id = b.emp_id
                        and a.status = 'A'
                        and b.user_id = c.user_id (+)
                        and c.status (+) = 'A'
                ) loop
                    l_record.assigned_user := xx.user_name;
                end loop;

                if l_prev_entrp_id <> x.entrp_id then
                    pipe row ( l_record );
                end if;
                l_prev_entrp_id := x.entrp_id;
                pipe row ( l_record );
            end loop;

	 -- Added by Joshi for 7761.
            for x in (
                select distinct
                    name,
                    acc_num,
                    acc_id,
                    entrp_id,
                    account_type,
                    no_of_eligible,
                    entrp_code,
                    plan_start_date,
                    plan_end_date,
                    date_closed,
                    broker_name,
                    broker_id,
                    ga_id,
                    ga_name,
                    salesrep_id,
                    note,
                    am,
                    css_id,
                    ben_plan_number
                from
                    fsa_hra_erisa_5500_renewal_v
                where
                    account_type = 'FORM_5500'
            ) loop
                l_record.acc_id := x.acc_id;
                l_record.employer_name := x.name;
                l_record.acc_num := x.acc_num;
                l_record.account_type := x.account_type;
                l_record.broker_name := x.broker_name;
                l_record.broker_id := x.broker_id;
                l_record.ga_id := x.ga_id;
                l_record.ga_name := nvl(x.ga_name, 'N/A');
                l_record.ga := x.ga_name;
                l_record.css_id := x.css_id;
                l_record.start_date := to_char(x.plan_start_date, 'YYYY-MM-DD');
                l_record.end_date := to_char(x.plan_end_date, 'YYYY-MM-DD');
                l_record.date_closed := to_char(x.date_closed, 'YYYY-MM-DD');--sk added on 02_26_2019
                l_record.eligible_ee := x.no_of_eligible;
                l_record.salesrep_id := x.salesrep_id;
                l_record.funding_options := 'NA';
                l_record.funding_option_amount := 0.00;
                l_record.salesrep_id := x.salesrep_id;
                    --   l_record.ben_plan_id  :=  x.BEN_PLAN_ID;

                l_record.renewal_amount := 0.00;
                l_record.total_fee := 0.00;
                l_record.optional_fee := 0.00;
                l_record.invoice_to := 'CLIENT';
                l_record.entrp_id := x.entrp_id;
                l_record.ein := x.entrp_code;
                l_record.payment_method := 'Check';
                l_record.account_manager := x.am;
                l_record.ben_plan_number := x.ben_plan_number;-- added by Joshi for 7661

                for xx in (
                    select
                        a.name,
                        b.user_id,
                        c.user_name
                    from
                        salesrep  a,
                        employee  b,
                        sam_users c
                    where
                            a.salesrep_id = l_record.account_manager
                        and a.emp_id = b.emp_id
                        and a.status = 'A'
                        and b.user_id = c.user_id (+)
                        and c.status (+) = 'A'
                ) loop
                    l_record.assigned_user := xx.user_name;
                end loop;

                pipe row ( l_record );
            -- removed as plans with different plan number should be rturned.
            /*IF l_prev_entrp_id <> x.entrp_id THEN
               pipe row(l_record);
            END IF;

            l_prev_entrp_id := x.entrp_id; */

            end loop;
       -- code ends here for 7761.
        end if;
    end get_renewal_opportunity;
  -- Get all the accounts that got renewed/created today
    function get_opportunity (
        p_account_type in varchar2
    ) return renewal_row_t
        pipelined
        deterministic
    is
        l_record renewal_rec;
    begin
        if p_account_type = 'COBRA' then
            for x in (
                select
                    a.name,
                    b.acc_num,
                    b.broker_id,
                    b.ga_id,
                    pc_broker.get_broker_name(b.broker_id)        broker_name,
                    pc_sales_team.get_general_agent_name(b.ga_id) ga_name,
                    es.start_date,
                    es.end_date,
                    pc_account.get_salesrep_name(b.salesrep_id)   rep_name,
                    a.no_of_eligible,
                    a.entrp_id,
                    b.acc_id,
                    es.renewal_batch_number,
                    b.salesrep_id,
                    a.entrp_code,
                    (
                        select
                            salesrep_id
                        from
                            salesrep c
                        where
                                role_type = 'AM'
                            and c.salesrep_id = b.am_id
                    )                                             am,
                    (
                        select
                            entity_id
                        from
                            sales_team_member
                        where
                                emplr_id = a.entrp_id
                            and entity_type = 'CS_REP'
                            and status = 'A'
                            and end_date is null
                            and rownum = 1
                    )                                             css_id
                from
                    ben_plan_renewals es,
                    enterprise        a,
                    account           b
                where
                        es.acc_id = b.acc_id
                    and a.entrp_id = b.entrp_id
                    and es.plan_type = 'COBRA'
                    and b.account_type = 'COBRA'
                    and trunc(es.creation_date) >= trunc(sysdate)
                  --  AND B.ACC_NUM = 'GFSA468899'
                    and not exists (
                        select
                            *
                        from
                            crm_interfaces ci
                        where
                            ci.entity_id = to_char(es.renewal_batch_number)
                    )
            ) loop
                l_record.acc_id := x.acc_id;
                l_record.employer_name := x.name;
                l_record.acc_num := x.acc_num;
                l_record.account_type := 'COBRA';
                l_record.broker_name := x.broker_name;
                l_record.broker_id := x.broker_id;
                l_record.ga_id := x.ga_id;
                l_record.ga_name := nvl(x.ga_name, 'N/A');
                l_record.ga := x.ga_name;
                l_record.css_id := x.css_id;
                l_record.start_date := to_char(x.start_date, 'YYYY-MM-DD');
                l_record.end_date := to_char(x.end_date, 'YYYY-MM-DD');
                l_record.eligible_ee := x.no_of_eligible;
                l_record.salesrep_id := x.salesrep_id;
                l_record.funding_options := 'NA';
                l_record.funding_option_amount := 0.00;
                l_record.date_closed := to_char(sysdate, 'YYYY-MM-DD');
                l_record.salesrep_id := x.salesrep_id;
                l_record.ben_plan_id := x.renewal_batch_number;
                l_record.renewal_amount := 0.00;
                l_record.total_fee := 0.00;
                l_record.optional_fee := 0.00;
                l_record.invoice_to := 'CLIENT';
                l_record.entrp_id := x.entrp_id;
                l_record.ein := x.entrp_code;
                l_record.account_manager := x.am;
                for i in (
                    select
                        c.line_list_price price,
                        rpd.coverage_type,
                        payment_method
                    from
                        ar_quote_headers b,
                        ar_quote_lines   c,
                        rate_plan_detail rpd
                    where
                            c.rate_plan_detail_id = rpd.rate_plan_detail_id
                        and b.quote_header_id = c.quote_header_id
                        and b.batch_number = x.renewal_batch_number
                        and b.entrp_id = x.entrp_id
                ) loop
                    if i.coverage_type = 'MAIN_COBRA_SERVICE' then
                        l_record.renewal_amount := i.price;
                    end if;

                    if i.coverage_type = 'OPTIONAL_COBRA_SERVICE_CN' then
                        l_record.optional_fee := l_record.optional_fee + i.price;
                    end if;

                    if i.coverage_type = 'OPEN_ENROLLMENT_SUITE' then
                        l_record.optional_fee := l_record.optional_fee + i.price;
                    end if;

                    if i.coverage_type = 'OPTIONAL_COBRA_SERVICE_CP' then
                        l_record.optional_fee := l_record.optional_fee + i.price;
                    end if;

                    l_record.payment_method := i.payment_method;
                end loop;

                l_record.total_fee := nvl(l_record.renewal_amount, 0) + nvl(l_record.optional_fee, 0);

                for j in (
                    select  --  WM_CONCAT(FIRST_NAME) FIRST_NAME -- Wm_Concat function replaced by listagg by RPRABU on 17/10/2017
                        listagg(first_name, ',') within group(
                        order by
                            first_name
                        ) first_name
                    from
                        (
                            select distinct
                                first_name first_name
                            from
                                contact_leads
                            where
                                    contact_type = 'BROKER'
                                and ref_entity_id = x.renewal_batch_number
                                and ref_entity_type = 'BEN_PLAN_RENEWALS'
                        )
                ) loop
                    if j.first_name is not null then
                        l_record.note := 'Broker Contact ' || j.first_name;
                        l_record.invoice_to := 'BROKER';
                        l_record.broker_contact := j.first_name;
                    end if;
                end loop;

                for j in (
                    select  --WM_CONCAT(FIRST_NAME) FIRST_NAME-- Wm_Concat function replaced by listagg by RPRABU on 17/10/2017
                        listagg(first_name, ',') within group(
                        order by
                            first_name
                        ) first_name
                    from
                        (
                            select distinct
                                first_name first_name
                            from
                                contact_leads
                            where
                                    contact_type = 'GA'
                                and ref_entity_id = x.renewal_batch_number
                                and ref_entity_type = 'BEN_PLAN_RENEWALS'
                        )
                ) loop
                    if j.first_name is not null then
                        l_record.note := 'GA Contact ' || j.first_name;
                        l_record.invoice_to := 'GA';
                        l_record.ga_contact := j.first_name;
                    end if;
                end loop;

                pipe row ( l_record );
            end loop;

        elsif p_account_type = 'ERISA_WRAP' then
            for x in (
                select
                    a.name,
                    b.acc_num,
                    b.broker_id,
                    b.ga_id,
                    pc_broker.get_broker_name(b.broker_id)        broker_name,
                    pc_sales_team.get_general_agent_name(b.ga_id) ga_name,
                    bp.plan_start_date,
                    bp.plan_end_date,
                    es.note,
                    es.no_of_employees,
                    es.no_of_eligible,
                    bp.ben_plan_id,
                    a.entrp_id,
                    b.salesrep_id,
                    a.entrp_code,
                    b.acc_id,
                    (
                        select
                            salesrep_id
                        from
                            salesrep c
                        where
                                role_type = 'AM'
                            and c.salesrep_id = b.am_id
                    )                                             am,
                    (
                        select
                            entity_id
                        from
                            sales_team_member
                        where
                                emplr_id = a.entrp_id
                            and entity_type = 'CS_REP'
                            and status = 'A'
                            and end_date is null
                            and rownum = 1
                    )                                             css_id
                from
                    online_renewals           es,
                    enterprise                a,
                    account                   b,
                    ben_plan_enrollment_setup bp
                where
                        es.entrp_id = a.entrp_id
                    and a.entrp_id = b.entrp_id
                    and es.ben_plan_id = bp.ben_plan_id
                    and b.account_type = 'ERISA_WRAP'
                    and trunc(es.creation_date) >= trunc(sysdate)
                    and not exists (
                        select
                            *
                        from
                            crm_interfaces ci
                        where
                                ci.entity_id = to_char(bp.ben_plan_id)
                            and ci.entity_name = 'OPPORTUNITY'
                    )
            ) loop
                l_record.acc_id := x.acc_id;
                l_record.employer_name := x.name;
                l_record.acc_num := x.acc_num;
                l_record.account_type := 'ERISA_WRAP';
                l_record.broker_name := x.broker_name;
                l_record.broker_id := x.broker_id;
                l_record.ga_id := x.ga_id;
                l_record.ga_name := nvl(x.ga_name, 'N/A');
                l_record.ga := x.ga_name;
                l_record.css_id := x.css_id;
                l_record.start_date := to_char(x.plan_start_date, 'YYYY-MM-DD');
                l_record.end_date := to_char(x.plan_end_date, 'YYYY-MM-DD');
                l_record.eligible_ee := x.no_of_eligible;
                l_record.salesrep_id := x.salesrep_id;
                l_record.invoice_to := 'CLIENT';
                l_record.entrp_id := x.entrp_id;
                l_record.date_closed := to_char(sysdate, 'YYYY-MM-DD');
                l_record.funding_options := 'NA';
                l_record.funding_option_amount := 0.00;
                l_record.ben_plan_id := x.ben_plan_id;
                l_record.ein := x.entrp_code;
                l_record.account_manager := x.am;
                for i in (
                    select
                        c.line_list_price price,
                        rpd.coverage_type,
                        payment_method
                    from
                        ar_quote_headers b,
                        ar_quote_lines   c,
                        rate_plan_detail rpd
                    where
                            c.rate_plan_id = rpd.rate_plan_id
                        and c.rate_plan_detail_id = rpd.rate_plan_detail_id
                        and b.quote_header_id = c.quote_header_id
                        and b.ben_plan_id = x.ben_plan_id
                ) loop
                    l_record.renewal_amount := i.price;
                    l_record.payment_method := i.payment_method;
                    l_record.total_fee := i.price;
                end loop;

                for j in (
                    select --WM_CONCAT(FIRST_NAME) FIRST_NAME -- Wm_Concat function replaced by listagg by RPRABU on 17/10/2017
                        listagg(first_name, ',') within group(
                        order by
                            first_name
                        ) first_name
                    from
                        (
                            select distinct
                                first_name first_name
                            from
                                contact_leads
                            where
                                    contact_type = 'BROKER'
                                and ref_entity_id = x.ben_plan_id
                                and ref_entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                        )
                ) loop
                    if j.first_name is not null then
                        l_record.note := 'Broker Contact ' || j.first_name;
                        l_record.invoice_to := 'BROKER';
                        l_record.broker_contact := j.first_name;
                    end if;
                end loop;

                for j in (
                    select ---WM_CONCAT(FIRST_NAME) FIRST_NAME-- Wm_Concat function replaced by listagg by RPRABU on 17/10/2017
                        listagg(first_name, ',') within group(
                        order by
                            first_name
                        ) first_name
                    from
                        (
                            select distinct
                                first_name first_name
                            from
                                contact_leads
                            where
                                    contact_type = 'GA'
                                and ref_entity_id = x.ben_plan_id
                                and ref_entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                        )
                ) loop
                    if j.first_name is not null then
                        l_record.note := 'GA Contact ' || j.first_name;
                        l_record.invoice_to := 'GA';
                        l_record.ga_contact := j.first_name;
                    end if;
                end loop;

                pipe row ( l_record );
            end loop;
        elsif p_account_type in ( 'FSA', 'HRA' ) then
            for x in (
                select distinct
                    a.name,
                    b.acc_num,
                    b.broker_id,
                    b.ga_id,
                    bp.product_type                               account_type,
                    pc_broker.get_broker_name(b.broker_id)        broker_name,
                    pc_sales_team.get_general_agent_name(b.ga_id) ga_name,
                    bp.plan_start_date,
                    bp.plan_end_date,
                    decode(bp.funding_options, '-1', 'N/A', null, 'N/A',
                           bp.funding_options)                    funding_options,
                    a.entrp_id,
                    b.salesrep_id,
                    a.entrp_code,
                    b.acc_id,
                    (
                        select
                            salesrep_id
                        from
                            salesrep c
                        where
                                role_type = 'AM'
                            and c.salesrep_id = b.am_id
                    )                                             am,
                    (
                        select
                            entity_id
                        from
                            sales_team_member
                        where
                                emplr_id = a.entrp_id
                            and entity_type = 'CS_REP'
                            and status = 'A'
                            and end_date is null
                            and rownum = 1
                    )                                             css_id
                from
                    enterprise                a,
                    account                   b,
                    ben_plan_enrollment_setup bp
                where
                        a.entrp_id = b.entrp_id
                    and b.acc_id = bp.acc_id
                    and bp.status = 'A'
                    and b.account_type in ( 'FSA', 'HRA' )
                    and bp.renewal_flag = 'Y'
                    and trunc(bp.creation_date) = trunc(sysdate)
            ) loop
                l_record.entrp_id := x.entrp_id;
                l_record.date_closed := to_char(sysdate, 'YYYY-MM-DD');
             --      l_record.ben_plan_id  :=  x.ben_plan_id;
                l_record.ein := x.entrp_code;
                l_record.acc_id := x.acc_id;
                l_record.start_date := to_char(x.plan_start_date, 'YYYY-MM-DD');
                l_record.end_date := to_char(x.plan_end_date, 'YYYY-MM-DD');
                l_record.salesrep_id := x.salesrep_id;
                l_record.invoice_to := 'CLIENT';
                l_record.entrp_id := x.entrp_id;
                l_record.date_closed := to_char(sysdate, 'YYYY-MM-DD');
                l_record.account_manager := x.am;
                l_record.employer_name := x.name;
                l_record.acc_num := x.acc_num;
                l_record.account_type := x.account_type;
                l_record.broker_name := x.broker_name;
                l_record.broker_id := x.broker_id;
                l_record.ga_id := x.ga_id;
                l_record.ga_name := nvl(x.ga_name, 'N/A');
                l_record.ga := x.ga_name;
                l_record.css_id := x.css_id;
                l_record.funding_options := x.funding_options;
                l_record.funding_option_amount := 0.00;
                   --l_record.eligible_ee  :=  x.no_of_eligible;

                pipe row ( l_record );
            end loop;
        end if;
    end get_opportunity;

    procedure export_changes_report (
        p_acc_id    in number,
        p_file_name in varchar2
    ) as
        v_bfile     bfile;
        v_blob      blob;
        v_acc_id    number;
        l_doc_count number := 0;
    begin

     --Why: You need to initialize a blob object before you access or populate it.
        insert into file_attachments (
            attachment_id,
            document_name,
            document_type,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            entity_name,
            entity_id,
            document_purpose,
            description,
            attachment
        ) values ( file_attachments_seq.nextval,
                   p_file_name,
                   'application/vnd.ms-excel',
                   sysdate,
                   0,
                   sysdate,
                   0,
                   'ACCOUNT',
                   p_acc_id,
                   'CHANGES_REPORT',
                   'Uploaded from Scheduler',
                   empty_blob() ) returning attachment into v_blob;


    -- Get a BFILE locator that is associated with the physical file on the DIRECTORY

        v_bfile := bfilename('MAILER_DIR', p_file_name);
    -- Open the file using DBMS_LOB

        dbms_lob.fileopen(v_bfile, dbms_lob.file_readonly);
    -- Load the file into the BLOB pointer

        dbms_lob.loadfromfile(v_blob,
                              v_bfile,
                              dbms_lob.getlength(v_bfile));
    -- Close the file

        dbms_lob.fileclose(v_bfile);
    --COMMIT;

    exception
        when others then
            null;
    end export_changes_report;

    function get_am_role (
        p_salesrep_id in number
    ) return number is
        l_salesrep_id number;
    begin
        for x in (
            select
                salesrep_id
            from
                salesrep c
            where
                    role_type = 'AM'
                and c.salesrep_id = p_salesrep_id
        ) loop
            l_salesrep_id := x.salesrep_id;
        end loop;

        return l_salesrep_id;
    end;

    function get_salesrep_role (
        p_salesrep_id in number
    ) return number is
        l_salesrep_id number;
    begin
        for x in (
            select
                salesrep_id
            from
                salesrep c
            where
                    role_type = 'SALESREP'
                and c.salesrep_id = p_salesrep_id
        ) loop
            l_salesrep_id := x.salesrep_id;
        end loop;

        return l_salesrep_id;
    end;

    function get_account_changes_for_crm return crm_interface_t
        pipelined
        deterministic
    is

        l_record        crm_interface_rec;
        l_changed       varchar2(1) := 'N';
        excp_change exception;
        l_change_source varchar2(30);
    begin
        for x in (
            select
                c.acc_num_c,
                c.broker_hash_c,
                c.sales_director_c,
                c.account_manager_c,
                c.accountstatus_c,
                b.broker_id,
                b.salesrep_id,
                b.account_status,
                d.address,
                d.city,
                d.state,
                d.zip,
                c.address_c,
                c.city_c,
                c.state_c,
                c.zip_c,
                b.acc_num,
                to_char(b.end_date, 'YYYY-MM-DD')      end_date,
                pc_broker.get_broker_name(b.broker_id) broker_name,
                pc_broker.get_broker_lic(b.broker_id)  broker_lic,
                c.crm_id
            from
                account         b,
                person          d,
                crm_employer_mv c
            where
                ( b.last_update_date > sysdate - 25
                  or d.last_update_date > sysdate - 25 )
                and b.pers_id = d.pers_id
                and acc_id_c = b.acc_id
                and clienttype_c in ( 'SUBSCRIBER', 'Subscriber' )
        ) loop
            l_changed := 'N';
            l_change_source := null;
            begin
                if strip_bad(x.sales_director_c) <> to_char(get_salesrep_role(x.salesrep_id)) then
                    l_changed := 'Y';
                    l_change_source := 'SALESREP';
                    raise excp_change;
                end if;

                if strip_bad(x.account_manager_c) <> to_char(get_am_role(x.salesrep_id)) then
                    l_changed := 'Y';
                    l_change_source := 'AM';
                    raise excp_change;
                end if;

                if strip_bad(x.broker_hash_c) <> to_char(x.broker_id) then
                    l_changed := 'Y';
                    l_change_source := 'BROKER';
                    raise excp_change;
                end if;

                if x.accountstatus_c <> to_char(x.account_status) then
                    l_changed := 'Y';
                    l_change_source := 'ACCOUNT_STATUS';
                    raise excp_change;
                end if;

                if x.address <> x.address_c then
                    l_changed := 'Y';
                    l_change_source := 'ADDRESS';
                    raise excp_change;
                end if;

            exception
                when excp_change then
                    null;
            end;

            if l_changed = 'Y' then
                l_record.salesrep_id := to_char(get_salesrep_role(x.salesrep_id));
                l_record.am_id := to_char(get_am_role(x.salesrep_id));
                l_record.broker_id := to_char(x.broker_id);
                l_record.address := x.address;
                l_record.city := x.city;
                l_record.state := x.state;
                l_record.zip := x.zip;
                l_record.acc_num := x.acc_num;
                l_record.account_status := x.account_status;
                l_record.end_date := x.end_date;
                l_record.broker_name := x.broker_name;
                l_record.broker_lic := x.broker_lic;
                l_record.crm_id := x.crm_id;
                l_record.change_source := l_change_source;
                l_record.date_modified := to_char(sysdate, 'YYYY-MM-DD');
                pipe row ( l_record );
            end if;

        end loop;
    end get_account_changes_for_crm;

    function get_er_account_changes_for_crm return crm_interface_t
        pipelined
        deterministic
    is

        l_record        crm_interface_rec;
        l_changed       varchar2(1) := 'N';
        excp_change exception;
        l_change_source varchar2(30);
        l_am_id         number;
        l_salesrep_id   number;
    begin
        for x in (
            select
                c.acc_num_c,
                c.broker_hash_c,
                c.sales_director_c,
                c.account_manager_c,
                c.accountstatus_c,
                b.broker_id,
                b.salesrep_id,
                b.account_status,
                d.address,
                d.city,
                d.state,
                d.zip,
                c.address_c,
                c.city_c,
                c.state_c,
                c.zip_c,
                b.acc_num,
                to_char(b.end_date, 'YYYY-MM-DD')                                  end_date,
                pc_broker.get_broker_name(b.broker_id)                             broker_name,
                pc_broker.get_broker_lic(b.broker_id)                              broker_lic,
                c.crm_id,
                b.at_risk_of --column added by preethy for ticket no 6071
                ,
                pc_lookups.get_meaning(b.termination_reason, 'TERMINATION_REASON') termination_reason,
                ap.reference_flag
            from
                account            b,
                enterprise         d,
                crm_employer_mv    c,
                account_preference ap
            where
                ( b.last_update_date > sysdate - 25
                  or d.last_update_date > sysdate - 25 )
                and b.entrp_id = d.entrp_id
                and acc_id_c = b.acc_id
                and clienttype_c in ( 'EMPLOYER', 'Employer' )
                and ap.acc_id = b.acc_id
        ) loop
            l_am_id := get_am_role(x.salesrep_id);
            l_salesrep_id := get_salesrep_role(x.salesrep_id);
            l_changed := 'N';
            l_change_source := null;
            begin
                if
                    strip_bad(x.sales_director_c) <> to_char(l_salesrep_id)
                    and l_salesrep_id is not null
                then
                    l_changed := 'Y';
                    l_change_source := 'SALESREP';
                    raise excp_change;
                end if;

                if
                    strip_bad(x.account_manager_c) <> to_char(l_am_id)
                    and l_am_id is not null
                then
                    l_changed := 'Y';
                    l_change_source := 'AM';
                    raise excp_change;
                end if;

                if strip_bad(x.broker_hash_c) <> to_char(x.broker_id) then
                    l_changed := 'Y';
                    l_change_source := 'BROKER';
                    raise excp_change;
                end if;

                if x.accountstatus_c <> to_char(x.account_status) then
                    l_changed := 'Y';
                    l_change_source := 'ACCOUNT_STATUS';
                    raise excp_change;
                end if;

                if x.address <> x.address_c then
                    l_changed := 'Y';
                    l_change_source := 'ADDRESS';
                    raise excp_change;
                end if;

            exception
                when excp_change then
                    null;
            end;

            if l_changed = 'Y' then
                l_record.salesrep_id := to_char(l_salesrep_id);
                l_record.am_id := to_char(l_am_id);
                l_record.broker_id := to_char(x.broker_id);
                l_record.address := x.address;
                l_record.city := x.city;
                l_record.state := x.state;
                l_record.zip := x.zip;
                l_record.acc_num := x.acc_num;
                l_record.account_status := x.account_status;
                l_record.end_date := x.end_date;
                l_record.broker_name := x.broker_name;
                l_record.broker_lic := x.broker_lic;
                l_record.crm_id := x.crm_id;
                l_record.change_source := l_change_source;
                l_record.date_modified := to_char(sysdate, 'YYYY-MM-DD');
                l_record.at_risk_of := x.at_risk_of; --code added by preethy for ticket no:6071 on 26/07/2018
                l_record.reference_flag := x.reference_flag;
                l_record.termination_reason := x.termination_reason;
                pipe row ( l_record );
            end if;

        end loop;
    end get_er_account_changes_for_crm;

end pc_crm_interface;
/

