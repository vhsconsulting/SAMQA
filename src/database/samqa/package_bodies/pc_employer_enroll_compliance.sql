create or replace package body samqa.pc_employer_enroll_compliance is

    function get_erisa_plan_dates (
        p_ein in varchar2
    ) return erisa_plan_date_rec_t
        pipelined
        deterministic
    is
        l_record erisa_plan_date_rec;
    begin
        for x in (
            select
                *
            from
                (
                    select
                        b.plan_start_date,
                        rank()
                        over(partition by b.acc_id
                             order by
                                 b.ben_plan_id
                        ) as plan_order
                    from
                        ben_plan_enrollment_setup b,
                        account                   a,
                        enterprise                e
                    where
                            a.acc_id = b.acc_id
                        and a.entrp_id = e.entrp_id
                        and a.account_type = 'ERISA_WRAP'
                        and e.entrp_code = p_ein
                        and exists (
                            select
                                *
                            from
                                ben_plan_enrollment_setup bs
                            where
                                    bs.acc_id = b.acc_id
                                and trunc(sysdate) between plan_start_date and plan_end_date
                        )
                )
            where
                plan_order <= 2
        ) loop
            l_record.plan_start_date := to_char(x.plan_start_date, 'mm/dd/yyyy');
            l_record.plan_order := x.plan_order;
            pipe row ( l_record );
        end loop;
    end get_erisa_plan_dates;
-----------------------------------------------------------------------------------
    function get_plan_fund_code return get_report_type_row_t
        pipelined
        deterministic
    is
        l_record get_report_type_row;
    begin
        for x in (
            select
                meaning description,
                lookup_code
            from
                lookups
            where
                lookup_name = 'PLAN_ARRANGEMENT_FORM_5500'
        ) loop
            l_record.lookup_code := x.lookup_code;
            l_record.description := x.description;
            l_record.error_status := 'S';
            pipe row ( l_record );
        end loop;
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm;
            pipe row ( l_record );
    end get_plan_fund_code;
  --------------------------------------------------

    function get_benefit_codes return get_report_type_row_t
        pipelined
        deterministic
    is
        l_record get_report_type_row;
    begin
        for x in (
            select
                meaning description,
                lookup_code
            from
                lookups
            where
                lookup_name = 'BENEFIT_CODES'
        ) loop
            l_record.lookup_code := x.lookup_code;
            l_record.description := x.description;
            l_record.error_status := 'S';
            pipe row ( l_record );
        end loop;
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm;
            pipe row ( l_record );
    end get_benefit_codes;
  ----------------------------------------
    procedure upsert_form_5500_employer_info (
        p_entrp_id                    in number,
        p_batch_number                in number,
        p_company_contact_entity      in varchar2,
        p_company_contact_others      in varchar2,
        p_company_contact_email       in varchar2,
        p_plan_admin_individual_name  in varchar2,
        p_emp_plan_sponsor_ind_name   in varchar2,
        p_disp_annual_report_ind_name in varchar2,
        p_disp_annual_report_phone_no in varchar2,
        p_form_5500_sub_option_flag   in varchar2,
        p_user_id                     in number,
        p_page_validity               in varchar2,
        x_error_status                out varchar2,
        x_error_message               out varchar2
    ) is

        l_count         number(10);
        l_enrollment_id number(10) := 0;
        lc_ben_plan_id  number(10) := 0;
        l_acc_num       varchar2(50);     ---8132
        l_inactive_plan varchar2(1);  -- 10430
    begin
        pc_log.log_error(' upsert_Form_5500_Employer_info begin : ', p_entrp_id);

   -- Added by Joshi for 10430.
        l_inactive_plan := nvl(
            pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
            'N'
        );
        for i in (
            select
                enrollment_id
            from
                online_form_5500_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            l_enrollment_id := i.enrollment_id;
        end loop;

        pc_log.log_error(' upsert 1 ', p_entrp_id);
        if l_enrollment_id > 0 then
            update online_form_5500_staging
            set
                company_contact_entity = p_company_contact_entity,
                company_contact_others = p_company_contact_others,
                company_contact_email = p_company_contact_email,
                plan_admin_individual_name = p_plan_admin_individual_name,
                emp_plan_sponsor_ind_name = p_emp_plan_sponsor_ind_name,
                disp_annual_report_ind_name = p_disp_annual_report_ind_name,
                disp_annual_report_phone_no = p_disp_annual_report_phone_no,
                form_5500_sub_option_flag = p_form_5500_sub_option_flag,
                page_validity = p_page_validity
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
                and enrollment_id = l_enrollment_id;

        else
            lc_ben_plan_id := 0;
            begin
                select
                    nvl(
                        max(ben_plan_id),
                        0
                    )
                into lc_ben_plan_id
                from
                    ben_plan_enrollment_setup
                where
                    entrp_id = p_entrp_id;

            exception
                when no_data_found then
                    lc_ben_plan_id := 0;
            end;

            pc_log.log_error(' upsert 2 ', p_entrp_id);
	  ---8132
            begin
                select
                    acc_num,
                    form_5500_staging_seq.nextval
                into
                    l_acc_num,
                    l_enrollment_id
                from
                    account
                where
                    entrp_id = p_entrp_id;

            end;

            pc_log.log_error(' upsert 3 ', p_entrp_id);
            insert into online_form_5500_staging (
                enrollment_id,
                entrp_id,
                batch_number,
                acc_num,  --8132
                company_contact_entity,
                company_contact_others,
                company_contact_email,
                plan_admin_individual_name,
                emp_plan_sponsor_ind_name,
                disp_annual_report_ind_name,
                disp_annual_report_phone_no,
                form_5500_sub_option_flag,
                page_validity,
                creation_date,
                created_by,
                source,
                inactive_plan_flag   -- Added by Joshi for 10430
            )
                select
                    l_enrollment_id,
                    p_entrp_id,
                    p_batch_number,
                    l_acc_num, ----8132
                    p_company_contact_entity,
                    p_company_contact_others,
                    p_company_contact_email,
                    p_plan_admin_individual_name,
                    p_emp_plan_sponsor_ind_name,
                    p_disp_annual_report_ind_name,
                    p_disp_annual_report_phone_no,
                    p_form_5500_sub_option_flag,
                    p_page_validity,
                    sysdate,
                    p_user_id,
         -- Decode(LC_ben_plan_id, 0,  'ENROLLMENT' , 'RENEWAL'), commented by Joshi for 10430
         -- Added by Joshi for 10430. Inactive plan registration is considered as enrollment
                    case
                        when l_inactive_plan = 'I' then
                            'ENROLLMENT'
                        else
                            decode(lc_ben_plan_id, 0, 'ENROLLMENT', 'RENEWAL')
                    end,
                    l_inactive_plan
                from
                    dual;

        end if;

        pc_log.log_error(' upsert 4 ', p_entrp_id);
    --- added by rprabu for   page issue
        pc_employer_enroll.upsert_page_validity(
            p_batch_number  => p_batch_number,
            p_entrp_id      => p_entrp_id,
            p_account_type  => 'FORM_5500',
            p_page_no       => 1,
            p_block_name    => 'COMPANY_INFORMATION',  -- 8014 rprabu 12/08/2019
            p_validity      => p_page_validity,
            p_user_id       => p_user_id,
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );

        pc_log.log_error(' upsert 5 ', p_entrp_id);
    exception
        when others then
            x_error_message := 'In PC_EMPLOYER_ENROLL_COMPLAINCE.upsert_Form_5500_Employer_info when others : ' || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error(' When Others of PC_EMPLOYER_ENROLL_COMPLAINCE.Pc_Employer_Enroll.upsert_Form_5500_Employer_info : ', x_error_message
            );
    end upsert_form_5500_employer_info;

  -----------------------------------------------------------------------------------

---    /*Ticket#7015.FORM_5500 reconstruction */    Done by RPRABU 05/12/2018
    procedure upsert_form_5500_plan_staging (
        p_entrp_id                     in number,
        p_batch_number                 in number,
        p_enrollment_detail_id         in out number,
        p_plan_name                    in varchar2,
        p_plan_number                  in varchar2,
        p_short_plan_year_flag         in varchar2,
        p_extention_flag               in varchar2,
        p_dfvc_program_flag            in varchar2,
        p_other_feature_code           in varchar2,
        p_last_employer_name           in varchar2,
        p_last_plan_name               in varchar2,
        p_last_ein                     in varchar2,
        p_last_plan_number             in varchar2,
        p_erisa_wrap_plan_flag         in varchar2,
        p_l_day_active_participants    in number,
        p_enrolled_empl_1st_day_pln_yr in number,
        p_effective_plan_date          in varchar2,
        p_plan_start_date              in varchar2,
        p_plan_end_date                in varchar2,
        p_plan_type                    in varchar2,
        p_active_participants          in number,
        p_recv_benefits                in number,
        p_future_benefits              in number,
        p_total_no_ee                  in number,
        p_is_coll_plan                 in varchar2,
        p_no_of_schedule_a_doc         in number,
        p_sponsor_name                 in varchar2,
        p_sponsor_contact_name         in varchar2,
        p_sponsor_email                in varchar2,
        p_sponsor_tel_num              in varchar2,
        p_sponsor_business_code        in varchar2,
        p_sponsor_ein                  in varchar2,
        p_admin_name_sponsor_flag      in varchar2,
        p_admin_name                   in varchar2,
        p_admin_contact_name           in varchar2,
        p_admin_email                  in varchar2,
        p_admin_tel_num                in varchar2,
        p_admin_business_code          in varchar2,
        p_admin_ein_sponsor_flag       in varchar2,
        p_admin_ein                    in varchar2,
        p_admin_addr                   in varchar2,
        p_admin_city                   in varchar2,
        p_admin_zip                    in varchar2,
        p_admin_state                  in varchar2,
        p_pre_sponsor_name_ein_flag    in varchar2,
        p_previous_sponsor_name        in varchar2,
        p_previous_sponsor_ein         in varchar2,
        p_erisa_wrap_flag              in varchar2,     ---------P_Is_5500
        p_collective_plan_flag         in varchar2, -------------P_Is_Collective_Plan
        p_report_type                  in varchar2_tbl,
        p_benefit_code_name            in varchar2_tbl,
        p_description                  in varchar2_tbl,
        p_benefit_code_fully_insured   in varchar2_tbl,
        p_benefit_code_self_insured    in varchar2_tbl,
        p_plan_fund_code               in varchar2,
        p_plan_benefit_code            in varchar2,
        p_rate_plan_id                 in varchar2_tbl,
        p_rate_plan_detail_id          in varchar2_tbl,
        p_list_price                   in varchar2_tbl,
        p_tot_price                    in varchar2,
        p_user_id                      in number,
        p_next_yr_short_plan_year_flag in varchar2,
        p_next_yr_plan_start_date      in varchar2,
        p_next_yr_plan_end_date        in varchar2,
        p_send_doc_later_flag          in varchar2,
        p_page_validity                in varchar2,
        x_error_status                 out varchar2,
        x_error_message                out varchar2
    ) is

        l_header_id            number;
        l_count                number;
        l_enrollment_id        number := null;
        l_enrollment_detail_id number := null;
        l_page_valitity        varchar2(1);
        l_total_cost           number(10);
        l_acc_num              varchar2(50); ---8132
        upsert_plan_form_5500_err exception; --15/07
    begin
      --- PRRABU 15/07
        begin
            select
                enrollment_id
            into l_enrollment_id
            from
                online_form_5500_staging   -- 8132 plan commented
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number;
 --     AND Enrollment_detail_id = P_Enrollment_detail_id; 8132 commented
        exception
            when no_data_found then
                null; ---- ticket 8034
        end;

        l_count := 0;
        pc_log.log_error('Upsert_form_5500_Plan_staging ', 'plan_name : ' || p_plan_name);
        pc_log.log_error('Upsert_form_5500_Plan_staging ', 'Loop..p_entrp_id : ' || p_entrp_id);
        pc_log.log_error('Upsert_form_5500_Plan_staging ', 'Loop..p_plan_number : ' || p_plan_number);
        for x in (
            select
                count(entrp_id) no_of_records
            from
                online_form_5500_plan_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
                and enrollment_detail_id = p_enrollment_detail_id
        ) loop
            l_count := x.no_of_records;
        end loop;
    /* Header Record */
        pc_log.log_error('Upsert_form_5500_staging', 'Loop' || l_count);
        pc_log.log_error('Upsert_form_5500_staging', 'Loop' || l_count);
	---8132
        begin
            select
                acc_num
            into l_acc_num
            from
                account
            where
                entrp_id = p_entrp_id;

        end;
        if l_count = 0
        or p_enrollment_detail_id is null then
      /* new rec */
            insert into online_form_5500_plan_staging (
                enrollment_detail_id,
                enrollment_id,
                entrp_id,
                acc_num,  ---8132
                batch_number,
                plan_name,
                plan_number,
                short_plan_year_flag,
                extention_flag,
                dfvc_program_flag,
                other_feature_code,
                last_employer_name,
                last_plan_name,
                last_ein,
                last_plan_number,
                erisa_wrap_plan_flag,
                l_day_active_participants,
                enrolled_empl_1st_day_pln_yr,
                effective_plan_date,
                plan_start_date,
                plan_end_date,
                plan_type,
                active_participants,
                recv_benefits,
                future_benefits,
                total_no_ee,
                is_coll_plan,
                no_of_schedule_a_doc,
                sponsor_name,
                sponsor_contact_name,
                sponsor_email,
                sponsor_tel_num,
                sponsor_business_code,
                sponsor_ein,
                admin_name_sameas_sponsor_flag,
                admin_name,
                admin_contact_name,
                admin_email,
                admin_tel_num,
                admin_business_code,
                admin_ein_sameas_sponsor_flag,
                admin_ein,
                admin_addr,
                admin_city,
                admin_zip,
                admin_state,
                pre_sponsor_name_ein_flag,
                previous_sponsor_name,
                previous_sponsor_ein,
                erisa_wrap_flag,
                collective_plan_flag,
                plan_fund_code,
                plan_benefit_code,
                tot_price,
                next_yr_short_plan_year_flag,
                next_yr_plan_start_date,
                next_yr_plan_end_date,
                send_doc_later_flag,
                page_validity,
                creation_date,
                created_by
            ) values ( form_5500_plan_staging_seq.nextval,
                       l_enrollment_id,
                       p_entrp_id,
                       l_acc_num, ----8132
                       p_batch_number,
                       p_plan_name,
                       p_plan_number,
                       p_short_plan_year_flag,
                       p_extention_flag,
                       p_dfvc_program_flag,
                       p_other_feature_code,
                       p_last_employer_name,
                       p_last_plan_name,
                       p_last_ein,
                       p_last_plan_number,
                       p_erisa_wrap_plan_flag,
                       p_l_day_active_participants,
                       p_enrolled_empl_1st_day_pln_yr,
                       p_effective_plan_date,
                       p_plan_start_date,
                       p_plan_end_date,
                       p_plan_type,
                       p_active_participants,
                       p_recv_benefits,
                       p_future_benefits,
                       p_total_no_ee,
                       p_is_coll_plan,
                       p_no_of_schedule_a_doc,
                       p_sponsor_name,
                       p_sponsor_contact_name,
                       p_sponsor_email,
                       p_sponsor_tel_num,
                       p_sponsor_business_code,
                       p_sponsor_ein,
                       p_admin_name_sponsor_flag,
                       p_admin_name,
                       p_admin_contact_name,
                       p_admin_email,
                       p_admin_tel_num,
                       p_admin_business_code,
                       p_admin_ein_sponsor_flag,
                       p_admin_ein,
                       p_admin_addr,
                       p_admin_city,
                       p_admin_zip,
                       p_admin_state,
                       p_pre_sponsor_name_ein_flag,
                       p_previous_sponsor_name,
                       p_previous_sponsor_ein,
                       p_erisa_wrap_flag,
                       p_collective_plan_flag,
                       p_plan_fund_code,
                       p_plan_benefit_code,
                       p_tot_price,
                       p_next_yr_short_plan_year_flag,
                       p_next_yr_plan_start_date,
                       p_next_yr_plan_end_date,
                       p_send_doc_later_flag,
                       p_page_validity,
                       sysdate,
                       p_user_id ) returning enrollment_detail_id into l_enrollment_detail_id;

            pc_log.log_error('Upsert_form_5500_staging', 'After Insert..1');
            p_enrollment_detail_id := l_enrollment_detail_id;
      ----------------
      --- added by rprabu for   page issue
            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_account_type  => 'FORM_5500',
                p_page_no       => 1,
                p_block_name    => 'PLAN_INFORMATION',
                p_validity      => p_page_validity,
                p_user_id       => p_user_id,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );
      --------------------
        else
            update online_form_5500_plan_staging
            set
                plan_name = p_plan_name,
                plan_number = p_plan_number,
                enrollment_id = l_enrollment_id,
                short_plan_year_flag = p_short_plan_year_flag,
                extention_flag = p_extention_flag,
                dfvc_program_flag = p_dfvc_program_flag,
                other_feature_code = p_other_feature_code,
                last_employer_name = p_last_employer_name,
                last_plan_name = p_last_plan_name,
                last_ein = p_last_ein,
                last_plan_number = p_last_plan_number,
                erisa_wrap_plan_flag = p_erisa_wrap_plan_flag,
                l_day_active_participants = p_l_day_active_participants,
                enrolled_empl_1st_day_pln_yr = p_enrolled_empl_1st_day_pln_yr,
                effective_plan_date = p_effective_plan_date,
                plan_start_date = p_plan_start_date,
                plan_end_date = p_plan_end_date,
                plan_type = p_plan_type,
                active_participants = p_active_participants,
                recv_benefits = p_recv_benefits,
                future_benefits = p_future_benefits,
                total_no_ee = p_total_no_ee,
                is_coll_plan = p_is_coll_plan,
                no_of_schedule_a_doc = p_no_of_schedule_a_doc,
                sponsor_name = p_sponsor_name,
                sponsor_contact_name = p_sponsor_contact_name,
                sponsor_email = p_sponsor_email,
                sponsor_tel_num = p_sponsor_tel_num,
                sponsor_business_code = p_sponsor_business_code,
                sponsor_ein = p_sponsor_ein,
                admin_name_sameas_sponsor_flag = p_admin_name_sponsor_flag,
                admin_name = p_admin_name,
                admin_contact_name = p_admin_contact_name,
                admin_email = p_admin_email,
                admin_tel_num = p_admin_tel_num,
                admin_business_code = p_admin_business_code,
                admin_ein_sameas_sponsor_flag = p_admin_ein_sponsor_flag,
                admin_ein = p_admin_ein,
                admin_addr = p_admin_addr,
                admin_city = p_admin_city,
                admin_zip = p_admin_zip,
                admin_state = p_admin_state,
                pre_sponsor_name_ein_flag = p_pre_sponsor_name_ein_flag,
                previous_sponsor_name = p_previous_sponsor_name,
                previous_sponsor_ein = p_previous_sponsor_ein,
                erisa_wrap_flag = p_erisa_wrap_flag,
                collective_plan_flag = p_collective_plan_flag,
                plan_fund_code = p_plan_fund_code,
                plan_benefit_code = p_plan_benefit_code,
                tot_price = p_tot_price,
                next_yr_short_plan_year_flag = p_next_yr_short_plan_year_flag,
                next_yr_plan_start_date = p_next_yr_plan_start_date,
                next_yr_plan_end_date = p_next_yr_plan_end_date,
                send_doc_later_flag = p_send_doc_later_flag,   --- 13/08/2019  Ticket #8016
                page_validity = p_page_validity,
                modified_date = sysdate,
                modified_by = p_user_id
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
                and enrollment_detail_id = p_enrollment_detail_id;

        end if;

        l_page_valitity := null;
        l_count := 0;
        begin
            select
                count(page_validity)
            into l_count
            from
                online_form_5500_plan_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
                and page_validity = 'I';

        end;

        if l_count > 0 then
            l_page_valitity := 'I';
        end if;
        pc_log.log_error('Upsert_form_5500_staging', 'p_batch_number : '
                                                     || p_batch_number
                                                     || ' p_entrp_id :='
                                                     || p_entrp_id
                                                     || 'P_Enrollment_detail_id :='
                                                     || p_enrollment_detail_id);
    --- added by rprabu for   page issue
        pc_employer_enroll.upsert_page_validity(
            p_batch_number  => p_batch_number,
            p_entrp_id      => p_entrp_id,
            p_account_type  => 'FORM_5500',
            p_page_no       => 1,
            p_block_name    => 'PLAN_INFORMATION',
            p_validity      => nvl(l_page_valitity, p_page_validity),
            p_user_id       => p_user_id,
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );
   /* BEGIN
      SELECT  quote_header_id
        INTO l_header_id
        FROM Ar_Quote_Headers_Staging
       WHERE batch_number       = p_batch_number
         AND entrp_id             = p_entrp_id
         AND Enrollment_detail_id = P_Enrollment_detail_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_header_id := NULL;
    END;

    IF l_header_id IS NOT NULL THEN
          UPDATE Ar_Quote_Headers_Staging
             SET Total_Quote_Price   = P_Tot_Price
           WHERE entrp_id          = p_entrp_id
             AND batch_number        = p_batch_number
             AND Enrollment_detail_id=P_Enrollment_detail_id;

          DELETE
            FROM ar_quote_lines_staging
           WHERE batch_number  = p_batch_number
             AND Quote_Header_Id =l_header_id;

    ELSIF l_header_id    IS NULL THEN
    */
    -- Commented the above and Added below by Swamy for Ticket#9242 on 24/06/2020
    -- Some how there were 2 records in Ar_Quote_Headers_Staging, for the above code there was ORA-01422: exact fetch returns more than requested number of rows.
    -- Hence commented above code and added below by deleting and reinserting the data.
        delete from ar_quote_lines_staging
        where
                batch_number = p_batch_number
            and quote_header_id = l_header_id;

        delete from ar_quote_headers_staging
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id
            and enrollment_detail_id = p_enrollment_detail_id;
      -- End of addition by Swamy for Ticket#9242

      /* Plan Options */
        insert into ar_quote_headers_staging (
            quote_header_id,
            total_quote_price,
            entrp_id,
            batch_number,
            account_type,
            enrollment_detail_id,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date
        ) values ( compliance_quote_seq.nextval,
                   p_tot_price,
                   p_entrp_id,
                   p_batch_number,
                   'FORM_5500',
                   p_enrollment_detail_id,
                   p_user_id,
                   sysdate,
                   p_user_id,
                   sysdate ) returning quote_header_id into l_header_id;
   -- END IF;
        l_total_cost := 0;
        begin
            select
                sum(total_quote_price)
            into l_total_cost
            from
                ar_quote_headers_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number;

            update online_form_5500_staging
            set
                grand_total_price = l_total_cost
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number;

        exception
            when no_data_found then
                l_header_id := null;
        end;

        pc_log.log_error('Upsert_form_5500_staging', 'After Insert QUOTE_HEADER_ID : ' || l_header_id);
        if p_rate_plan_id.count is not null then
            for i in 1..p_rate_plan_id.count loop
                if p_rate_plan_detail_id(i) is not null then
                    insert into ar_quote_lines_staging (
                        quote_line_id,
                        quote_header_id,
                        rate_plan_id,
                        rate_plan_detail_id,
                        rate_plan_name,
                        line_list_price,
                        batch_number,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date
                    ) values ( compliance_quote_lines_seq.nextval,
                               l_header_id,
                               p_rate_plan_id(i),
                               nvl(
                                   p_rate_plan_detail_id(i),
                                   0
                               ),
                               null,
                               nvl(
                                   p_list_price(i),
                                   0
                               ),
                               p_batch_number,
                               p_user_id,
                               sysdate,
                               p_user_id,
                               sysdate );

                    pc_log.log_error('Upsert_form_5500_staging',
                                     'After Insertp_rate_plan_id : ' || p_rate_plan_id(i));
                end if;
            end loop;
        end if;

        pc_log.log_error('Upsert_form_5500_staging ', 'After Insert P_Batch_Number :='
                                                      || p_batch_number
                                                      || 'P_Entrp_Id :'
                                                      || p_entrp_id
                                                      || ' P_Enrollment_detail_id :='
                                                      || p_enrollment_detail_id);

    /* UPDATE  Plan Notices */
        delete plan_notices_stage
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id
            and entity_id = p_enrollment_detail_id
            and entity_type = 'FORM_5500';

        for i in 1..p_report_type.count loop
            if p_report_type(i) is not null then
                pc_log.log_error('Upsert_form_5500_staging ',
                                 ' p_report_type(i) :=' || p_report_type(i));
                insert into plan_notices_stage (
                    plan_notice_id,
                    entrp_id,
                    batch_number,
                    entity_id,
                    entity_type,
                    notice_type,
                    creation_date,
                    last_update_date,
                    created_by,
                    last_updated_by
                ) values ( plan_notice_seq.nextval,
                           p_entrp_id,
                           p_batch_number,
                           p_enrollment_detail_id, --------entity_id
                           'FORM_5500',
                           p_report_type(i),
                           sysdate,
                           sysdate,
                           p_user_id,
                           p_user_id );

                pc_log.log_error('Upsert_form_5500_staging',
                                 'After Insert p_report_type : ' || p_report_type(i));
            end if;
        end loop;

        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.INSERT_BENEFIT_CODES_Stage in Upsert_Form_5500_Staging', 'In Procedure');

    /*BENEFIT_CODES_STAGE*/
    ---- FOr every Call of Upsert_form_5500_staging we are deleting BENEFIT_CODES_STAGE AND reinsert the same.

        delete from benefit_codes_stage
        where
                entity_id = p_enrollment_detail_id
            and entrp_id = p_entrp_id;

        if p_benefit_code_name.count > 0 then
            for i in 1..p_benefit_code_name.count loop
                if p_benefit_code_name(i) is not null then
                    insert into benefit_codes_stage (
                        entity_id,
                        entity_type,
                        benefit_code_id,
                        benefit_code_name,
                        description,
                        fully_insured_flag,
                        self_insured_flag,
                        batch_number,
                        entrp_id,
                        created_by,
                        creation_date
                    ) values ( p_enrollment_detail_id,
                               'FORM_5500',
                               benefit_code_seq.nextval,
                               p_benefit_code_name(i),
                               case p_benefit_code_name(i)
                                   when '4Q' then
                                       p_description(i)
                                       || ' ('
                                       || p_other_feature_code
                                       || ' )'--- Ticket #8010 rprabu 09/08/2019
                                   else
                                       p_description(i)
                               end,
                               p_benefit_code_fully_insured(i),
                               p_benefit_code_self_insured(i),
                               p_batch_number,
                               p_entrp_id,
                               p_user_id,
                               sysdate );

                end if;
            end loop;
        end if;

        x_error_status := 'S';
    exception
        when upsert_plan_form_5500_err then --- PRRABU 15/07
            rollback;
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.Upsert_form_5500_Plan_staging IN exception part ', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
        when others then
            x_error_message := 'In Upsert_form_5500_Plan_staging when others : ' || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.Upsert_Form_5500_Staging', sqlerrm || dbms_utility.format_error_backtrace
            );
    end upsert_form_5500_plan_staging;

  -----------------------------------------------------------------------------------

---    /*Ticket#7015.FORM_5500 reconstruction */    Done by RPRABU 05/12/2018
    procedure process_form_5500_main_tables (
        p_entrp_id      in number,
        p_batch_number  in number,
        p_user_id       in number,
      /*Ticket#6834 */
        p_source        varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is

        l_acc_id                number(10);
        l_sponsor_entrp_id      number(10);
        l_admin_entrp_id        number(10);
        x_er_ben_plan_id        number;
        l_error_status          varchar2(20);
        l_error_message         varchar2(200);
        rec                     benefit_codes_stage%rowtype;
        x_quote_header_id       number;
        l_return_status         varchar2(20);
        l_bank_id               number(10);
        l_acc_num               varchar2(50);  ---8132
        l_user_id               number(10);
        l_plan_type             varchar2(50);
        l_complete_flag         number(5);
        l_ben_plan_id_next_year number(10);
        l_renewal_plan_id       number(10); -- 8041 rprabu
        l_ben_plan_name         varchar2(100); -- 8906
        process_form_5500_err exception;
        l_renewed_by            varchar2(30);
        l_resubmit_flag         varchar2(1);
        l_inactive_plan_exist   varchar2(1);
        l_final_report          varchar2(1) := 'N';
        l_broker_id             number;
        l_authorize_req_id      number;
        l_entity_type           varchar2(30);
        l_enrolle_type          varchar2(30);
        l_entity_id             number;
        l_acct_payment_fees     varchar2(30);
        l_ga_broker_flg         varchar2(30);
        l_enrolled_by           varchar2(30);
        l_sales_team_member_id  number;
        l_acct_usage            varchar2(100);
        l_bank_count            integer;
        x_bank_status           varchar2(30);
        l_account_status        number;
        l_bank_name             varchar2(500);
        l_display_name          varchar2(500);
        l_bank_acct_id          number;
        l_inactive_flag         varchar2(1);
        l_bank_acct_type        varchar2(100);
    begin
        l_complete_flag := null;
        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 0', p_entrp_id);
        select
            acc_id,
            acc_num,
            complete_flag,
            nvl(resubmit_flag, 'N'),
            enrolle_type,
            enrolled_by
        into
            l_acc_id,
            l_acc_num,
            l_complete_flag,
            l_resubmit_flag,
            l_enrolle_type,
            l_enrolled_by
        from
            account
        where
            entrp_id = p_entrp_id;

     -- Added by Jaggi #11086
        if nvl(p_source, 'ENROLLMENT') = 'ENROLLMENT' then
            pc_account.upsert_acc_pref(
                p_entrp_id               => p_entrp_id,
                p_acc_id                 => l_acc_id,
                p_claim_pay_method       => null,
                p_auto_pay               => null,
                p_plan_doc_only          => null,
                p_status                 => 'A',
                p_allow_eob              => 'Y',
                p_user_id                => p_user_id,
                p_pin_mailer             => 'N',
                p_teamster_group         => 'N',
                p_allow_exp_enroll       => 'Y',
                p_maint_fee_paid         => null,
                p_allow_online_renewal   => 'Y',
                p_allow_election_changes => 'N',
                p_plan_action_flg        => 'N',
                p_submit_election_change => 'Y',
                p_edi_flag               => 'N',
                p_vendor_id              => null,
                p_reference_flag         => null,
                p_allow_payroll_edi      => null,
                p_fees_paid_by           => null
            );
        end if;

      -- Added by Joshi #12279
        if
            pc_account.get_broker_id(l_acc_id) = 0
            and nvl(p_source, 'ENROLLMENT') = 'ENROLLMENT'
        then
            for j in (
                select
                    broker_id
                from
                    online_users ou,
                    broker       b
                where
                        user_id = p_user_id
                    and user_type = 'B'
                    and upper(tax_id) = upper(broker_lic)
            ) loop
                update account
                set
                    broker_id = j.broker_id
                where
                    entrp_id = p_entrp_id;

            end loop;
        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES', p_entrp_id);
        pc_log.log_error('l_acc_num  PROCESS_FORM_5500_MAIN_TABLES P_Source 1: ', p_source);
        l_inactive_plan_exist := nvl(
            pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
            'N'
        );
       -- Added by Joshi 10430. need to delete existing affliated ER incase of resubmission
        if
            l_resubmit_flag = 'Y'
            and nvl(p_source, 'ENROLLMENT') <> 'RENEWAL'
        then

                  -- Added by Joshi for 12337/12339. Added condition as it was deleting all ben plan records. 
            for p in (
                select
                    to_date(plan_start_date, 'mm/dd/yyyy') plan_start_date,
                    to_date(plan_end_date, 'mm/dd/yyyy')   plan_end_date,
                    ben_plan_id,
                    ben_plan_id_next
                from
                    online_form_5500_staging      ofs,
                    online_form_5500_plan_staging ofps
                where
                        ofs.batch_number = p_batch_number
                    and ofs.batch_number = ofps.batch_number
                    and ofs.enrollment_id = ofps.enrollment_id
                    and ofs.enrollment_id = (
                        select
                            max(ofsi.enrollment_id)
                        from
                            online_form_5500_staging ofsi
                        where
                                ofsi.batch_number = ofs.batch_number
                            and ofsi.entrp_id = ofs.entrp_id
                    )
            ) loop
                if p.ben_plan_id is not null then
                    delete from ben_plan_enrollment_setup
                    where
                            acc_id = l_acc_id
                        and entrp_id = p_entrp_id
                        and ben_plan_id = p.ben_plan_id;

                end if;

                if p.ben_plan_id_next is not null then
                  -- delete pending plans also 
                    delete from ben_plan_enrollment_setup
                    where
                            acc_id = l_acc_id
                        and entrp_id = p_entrp_id
                        and ben_plan_id = p.ben_plan_id_next;

                end if;

            end loop;
               -- end by Joshi for 12337. Added condition as it was deleting all ben plan records. 

             -- Added by Joshi for 10430. need to delete existing contacts and reinsert as in case of resubmit
             -- user might update existing  contacts.
            for c in (
                select
                    contact_id
                from
                    contact_leads
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and account_type = 'FORM_5500'
                    and ref_entity_type = 'ONLINE_ENROLLMENT'
            ) loop
                delete from contact
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and contact_id = c.contact_id;

                delete from contact_role
                where
                    contact_id = c.contact_id;

            end loop;

            update user_bank_acct
            set
                status = 'I'
            where
                    acc_id = l_acc_id
                and bank_account_usage = 'INVOICE';

            delete from ar_quote_headers
            where
                entrp_id = p_entrp_id; -- added by Jaggi 05/16/2023
        end if;
       -- Ends here : 10430

        for stage_rec in (
            select
                a.plan_number,
                a.plan_name,
                a.effective_plan_date,
                a.plan_start_date,
                a.plan_end_date,
                a.enrollment_detail_id,
                a.entrp_id,
                a.erisa_wrap_flag,
                a.collective_plan_flag,
                a.plan_fund_code,
                a.plan_benefit_code,
                b.payment_method,
                a.total_no_ee,
                a.recv_benefits,
                a.future_benefits,
                a.sponsor_ein,
                a.sponsor_name,
                a.active_participants,
                a.sponsor_email,
                a.sponsor_tel_num,
                a.sponsor_business_code,
                a.sponsor_contact_name,
                a.admin_name,
                a.admin_email,
                a.admin_business_code,
                a.admin_ein,
                b.grand_total_price                                                 tot_price,
                a.created_by,
                a.admin_contact_name,
                a.admin_addr,
                a.admin_city,
                a.admin_state,
                a.admin_zip,
                a.dfvc_program_flag, --Ticket #8069 22/08/2019
                decode(a.plan_type, ' Single-Employer Plan Renewal', 'SNGL_RENEW', ' Multi-Employer Plan Renewal', 'MER_RENEW',
                       'Multiple-Employer Plan Renewal', 'MERS_RENEW', a.plan_type) plan_type,
                b.acct_payment_fees,
                a.ben_plan_id,
                a.ben_plan_id_next,     ---- 8132
                a.ben_plan_id_main,  ---- 8132
                a.l_day_active_participants,           -- 7782 rprabu 17/07/2019
                a.enrolled_empl_1st_day_pln_yr,  -- 7782 rprabu 17/07/2019
                b.source,
                next_yr_plan_start_date,
                next_yr_plan_end_date, --- 22/08
                b.form_5500_sub_option_flag   --- 8021 rprabu 13/08/2019
            from
                online_form_5500_plan_staging a,
                online_form_5500_staging      b
            where
                    a.entrp_id = p_entrp_id
                and a.entrp_id = b.entrp_id
                and a.batch_number = b.batch_number
                and a.batch_number = p_batch_number
        ) loop
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 3', p_entrp_id);
            if stage_rec.plan_type = 'Single-Employer-Plan' then
                l_plan_type := 'SNGL';
            elsif stage_rec.plan_type = 'Multi-Employer-Plan' then
                l_plan_type := 'MER';
            elsif stage_rec.plan_type = 'Multiple-Employer-Plan' then
                l_plan_type := 'MERS';
            end if;

            l_acct_payment_fees := stage_rec.acct_payment_fees;
            if
                stage_rec.source = 'ENROLLMENT'
                and p_source = 'ENROLLMENT'
            then

             ---- multiple plan types
                pc_employer_enroll.update_plan_info                           -------------   1                                                                                                                                                                                                                                                                                                                                                                                                                                                                             ----- 1
                (
                    p_entrp_id             => p_entrp_id,
                    p_fiscal_end_date      => null,
                    p_plan_type            => nvl(l_plan_type, 'SNGL'),     --- stage_rec.plan_type ,     ---- 'SNGL',                                                                                                                                                                                                                                                                                                                                                                                                                                                        --------'SNGL', --single employer plan
                    p_plan_name            => stage_rec.plan_name,
                    p_eff_date             => stage_rec.plan_start_date,    --- 22/08
                    p_org_eff_date         => stage_rec.effective_plan_date,   --- 26/08
                    p_plan_start_date      => stage_rec.plan_start_date,
                    p_plan_end_date        => stage_rec.plan_end_date,
                    p_takeover             => null,
                    p_user_id              => p_user_id,
                    p_is_5500              => stage_rec.form_5500_sub_option_flag,      --- 8021 rprabu 13/08/2019
          ---      p_is_5500			                      		 =>stage_rec.erisa_wrap_flag ,
                    p_coll_plan            => stage_rec.collective_plan_flag,
                    p_plan_fund_code       => stage_rec.plan_fund_code,
                    p_plan_benefit_code    => stage_rec.plan_benefit_code,
                    p_plan_number          => stage_rec.plan_number,
                    p_erissa_erap_doc_type => null,
                    x_er_ben_plan_id       => x_er_ben_plan_id,
                    x_error_status         => l_return_status,
                    x_error_message        => l_error_message
                );

                if l_return_status <> 'S' then
                    raise process_form_5500_err;
                end if;
			                      ---8132 14/09/2019
                update ben_plan_enrollment_setup
                set
                    renewal_flag = 'Y',
                    product_type = 'FORM_5500'  --- 7856 rprabu
                where
                    ben_plan_id = x_er_ben_plan_id;

                update online_form_5500_plan_staging
                set
                    ben_plan_id = x_er_ben_plan_id,
                    ben_plan_id_main = x_er_ben_plan_id   --8132 -----------
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number
                    and enrollment_detail_id = stage_rec.enrollment_detail_id;

            elsif
                stage_rec.source = 'RENEWAL'
                and p_source = 'RENEWAL'
            then
                x_er_ben_plan_id := 0;
                begin
                    select
                        max(ben_plan_id)
                    into x_er_ben_plan_id
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = l_acc_id
                        and ben_plan_number = stage_rec.plan_number;    ----- 8562       rprabu 09/12/2019
                exception
                    when no_data_found then
                        x_er_ben_plan_id := 0;
                end;

                pc_log.log_error('l_acc_num  PROCESS_FORM_5500_MAIN_TABLES 2  x_er_ben_plan_id  : ', x_er_ben_plan_id);
                pc_log.log_error('stage_rec.plan_number  : ', stage_rec.plan_number);
                if nvl(x_er_ben_plan_id, 0) = 0 then    -- Added by Swamy for Ticket#11126 27082024 
                    pc_employer_enroll.update_plan_info               -----3
                    (
                        p_entrp_id             => p_entrp_id,
                        p_fiscal_end_date      => null,
                        p_plan_type            => nvl(l_plan_type, 'SNGL_RENEW'), ----              For next year ben plan record .....,
                        p_plan_name            => nvl(l_ben_plan_name, stage_rec.plan_name),   --- l_ben_plan_name added for ---8906 28/03/2020 rprabu Start
                        p_eff_date             => nvl(stage_rec.plan_start_date,
                                          to_char((to_date(stage_rec.plan_end_date, 'mm/dd/yyyy') + 1), 'mm/dd/yyyy')),
                        p_org_eff_date         => to_char(to_date(stage_rec.effective_plan_date, 'mm/dd/yyyy'), 'mm/dd/yyyy'),
                        p_plan_start_date      => nvl(stage_rec.plan_start_date,
                                                 to_char((to_date(stage_rec.plan_end_date, 'mm/dd/yyyy') + 1), 'mm/dd/yyyy')),
                        p_plan_end_date        => nvl(stage_rec.plan_end_date,
                                               to_char(
                                                                       add_months(to_date(stage_rec.plan_end_date, 'mm/dd/yyyy'), 12)
                                                                       ,
                                                                       'mm/dd/yyyy'
                                                                   )),  -- Ticket #8074
                        p_takeover             => null,
                        p_user_id              => p_user_id,
                        p_is_5500              => stage_rec.form_5500_sub_option_flag,      --- 8021 rprabu 13/08/2019
                        p_coll_plan            => stage_rec.collective_plan_flag,
                        p_plan_fund_code       => stage_rec.plan_fund_code,
                        p_plan_benefit_code    => stage_rec.plan_benefit_code,
                        p_plan_number          => stage_rec.plan_number,
                        p_erissa_erap_doc_type => null,
                        x_er_ben_plan_id       => x_er_ben_plan_id,
                        x_error_status         => l_return_status,
                        x_error_message        => l_error_message
                    );
                end if;

                if x_er_ben_plan_id > 0 then
                    update ben_plan_enrollment_setup
                    set
                        status = 'A',
                        renewal_flag = 'Y',
                        last_update_date = sysdate,
                        product_type = 'FORM_5500',  --- 8132 rprabu
                        plan_funding_code = stage_rec.plan_fund_code,   -- Added by Swamy for Ticket#8347 on 07/01/2020
                        plan_benefit_code = stage_rec.plan_benefit_code -- Added by Swamy for Ticket#8347 on 07/01/2020
                    where
                        ben_plan_id = x_er_ben_plan_id;

                    update online_form_5500_plan_staging   ----- 8562       rprabu 09/12/2019
                    set
                        ben_plan_id = x_er_ben_plan_id
                    where
                            entrp_id = p_entrp_id
                        and batch_number = p_batch_number
                        and enrollment_detail_id = stage_rec.enrollment_detail_id;

                end if;  ---x_er_ben_plan_id >0

               --Insert into BEN PLAN RENEWALS
                insert into ben_plan_renewals (
                    ben_plan_id,
                    acc_id,
                    plan_type,
                    start_date,
                    end_date,
                    pay_acct_fees,--renewal phase#2
                    created_by,
                    creation_date,
                    renewal_batch_number,
                    renewed_plan_id,
                    source
                )--Renewal Phase#2.Populate renewed plan ID
                 values ( x_er_ben_plan_id,
                           l_acc_id,
                           'FORM_5500', ---   'FORM_5500'  ,
                           to_date(stage_rec.plan_start_date, 'mm/dd/yyyy'),/*Ticket#7315 */
                           to_date(stage_rec.plan_end_date, 'mm/dd/yyyy'),
                           stage_rec.acct_payment_fees,
                           p_user_id,
                           sysdate,
                           null,
                           null,
                           'ONLINE'   -- Added by joshi for 9678
                            );

                pc_log.log_error('l_acc_num  PROCESS_FORM_5500_MAIN_TABLES 555  BEN_PLAN_RENEWALS    : ', x_er_ben_plan_id);
                pc_log.log_error('l_acc_num  PROCESS_FORM_5500_MAIN_TABLES 567  NOTIFY_ER_REN_DECL_PLAN    : ', x_er_ben_plan_id);
                pc_log.log_error('l_acc_num  PROCESS_FORM_5500_MAIN_TABLES  3  New   x_er_ben_plan_id  : ', x_er_ben_plan_id);
                if l_return_status <> 'S' then
                    raise process_form_5500_err;
                end if;
            end if;  ---P_Source =  'ENROLLMENT'


            update enterprise ---2
            set
                no_of_eligible = stage_rec.total_no_ee
            where
                entrp_id = p_entrp_id;

            if p_source = 'ENROLLMENT' then
                if nvl(stage_rec.total_no_ee, 0) >= 0 then
                    insert into enterprise_census (
                        entity_id,
                        entity_type,
                        census_code,
                        census_numbers,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        ben_plan_id
                    ) values ( p_entrp_id,
                               'ENTERPRISE',
                               'NO_OF_ELIGIBLE',
                               stage_rec.total_no_ee,
                               sysdate,
                               p_user_id,
                               sysdate,
                               p_user_id,
                               x_er_ben_plan_id );

                end if;
        -- End of Addition by Swamy for Ticket#7606
        --UPDATE Enterprise Census

                if stage_rec.active_participants is not null then ------3
                    pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES', '1');
          -- For 5500 we create multiple plan entries. Hnece UPDATE Census info-ben Plan Id-- accordingly
                    insert into enterprise_census values ( p_entrp_id,
                                                           'ENTERPRISE',
                                                           'ACTIVE_PARTICIPANT',
                                                           stage_rec.active_participants,
                                                           sysdate,
                                                           stage_rec.created_by,
                                                           sysdate,
                                                           stage_rec.created_by,
                                                           x_er_ben_plan_id );

                end if;

                if stage_rec.l_day_active_participants is not null then ------3A
                    pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES', '1');
          -- For 5500 we create multiple plan entries. Hnece UPDATE Census info-ben Plan Id-- accordingly
                    insert into enterprise_census values ( p_entrp_id,
                                                           'ENTERPRISE',
                                                           'LAST_DAY_ACTIVE_PARTICIPANT',
                                                           stage_rec.l_day_active_participants,
                                                           sysdate,
                                                           stage_rec.created_by,
                                                           sysdate,
                                                           stage_rec.created_by,
                                                           x_er_ben_plan_id );

                end if;

                if stage_rec.enrolled_empl_1st_day_pln_yr is not null then ------4
                    insert into enterprise_census values ( p_entrp_id,
                                                           'ENTERPRISE',
                                                           'ENRD_EMP_1ST_DAY_NXT_PLN_YR',
                                                           stage_rec.enrolled_empl_1st_day_pln_yr,
                                                           sysdate,
                                                           stage_rec.created_by,
                                                           sysdate,
                                                           stage_rec.created_by,
                                                           x_er_ben_plan_id );

                end if;

                if stage_rec.recv_benefits is not null then ------5
                    insert into enterprise_census values ( p_entrp_id,
                                                           'ENTERPRISE',
                                                           'RETIRED_SEP_BEN',
                                                           stage_rec.recv_benefits,
                                                           sysdate,
                                                           stage_rec.created_by,
                                                           sysdate,
                                                           stage_rec.created_by,
                                                           x_er_ben_plan_id );

                end if;

                if stage_rec.future_benefits is not null then ------6
                    insert into enterprise_census values ( p_entrp_id,
                                                           'ENTERPRISE',
                                                           'RETIRED_SEP_FUT_BEN',
                                                           stage_rec.future_benefits,
                                                           sysdate,
                                                           stage_rec.created_by,
                                                           sysdate,
                                                           stage_rec.created_by,
                                                           x_er_ben_plan_id );

                end if;

                pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 5', p_entrp_id);
                if l_return_status = 'S' then --ER Ben plan ID generted AND census info complete      ----- 4
                    if stage_rec.sponsor_name is not null then
                        insert into enterprise (
                            entrp_id,
                            en_code,
                            entrp_code,
                            name,
                            contact_email,
                            contact_phone,
                            entrp_email,
                            entrp_phones,
                            irs_business_code,
                            entrp_contact,
                            created_by,
                            creation_date
                        ) values ( entrp_seq.nextval,
                                   8,
                                   stage_rec.sponsor_ein,
                                   stage_rec.sponsor_name,
                                   stage_rec.sponsor_email,
                                   stage_rec.sponsor_tel_num,
                                   stage_rec.sponsor_email,
                                   stage_rec.sponsor_tel_num,
                                   stage_rec.sponsor_business_code,
                                   stage_rec.sponsor_contact_name,
                                   stage_rec.created_by,
                                   sysdate ) returning entrp_id into l_sponsor_entrp_id;

                        pc_employer_enroll.create_enterprise_relation ----- 5

                        (
                            p_entrp_id      => p_entrp_id,                      ---Original ER
                            p_entity_id     => l_sponsor_entrp_id,             ---Affliated ER
                            p_entity_type   => 'ENTERPRISE',
                            p_relat_type    => 'PLAN_SPONSOR_ER',
                            p_user_id       => stage_rec.created_by,
                            x_return_status => l_return_status,
                            x_error_message => l_error_message
                        );

                        if l_return_status <> 'S' then
                            raise process_form_5500_err;
                        end if;
                    end if;

                    if stage_rec.admin_name is not null then
                        insert into enterprise ------ 6
                         (
                            entrp_id,
                            en_code,
                            entrp_code,
                            name,
                            contact_email,
                            contact_phone,
                            irs_business_code,
                            entrp_contact,
                            address,
                            city,
                            state,
                            zip,
                            created_by,
                            creation_date
                        ) values ( entrp_seq.nextval,
                                   9,
                                   stage_rec.admin_ein,
                                   stage_rec.admin_name,
                                   stage_rec.admin_email,
                                   stage_rec.sponsor_tel_num,
                                   stage_rec.admin_business_code,
                                   stage_rec.admin_contact_name,
                                   stage_rec.admin_addr,
                                   stage_rec.admin_city,
                                   stage_rec.admin_state,
                                   stage_rec.admin_zip,
                                   stage_rec.created_by,
                                   sysdate ) returning entrp_id into l_admin_entrp_id;

                        pc_employer_enroll.create_enterprise_relation ------ 7

                        (
                            p_entrp_id      => p_entrp_id,                       ---Original ER
                            p_entity_id     => l_admin_entrp_id,                ---Affliated ER
                            p_entity_type   => 'ENTERPRISE',
                            p_relat_type    => 'PLAN_ADMIN_ER',
                            p_user_id       => stage_rec.created_by,
                            x_return_status => l_return_status,
                            x_error_message => l_error_message
                        );

                        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 5 a : l_return_status', l_return_status
                        );
                        if l_error_status <> 'S' then
                            raise process_form_5500_err;
                        end if;
                    end if;

                end if; --Status Check

            elsif p_source = 'RENEWAL' then
                begin
                    update enterprise_census             ----1
                    set
                        census_numbers = stage_rec.total_no_ee
                    where
                            ben_plan_id = x_er_ben_plan_id
                        and census_code = 'NO_OF_ELIGIBLE'
                        and entity_type = 'ENTERPRISE';

                    if sql%notfound then
                        insert into enterprise_census (
                            entity_id,
                            entity_type,
                            census_code,
                            census_numbers,
                            creation_date,
                            created_by,
                            last_update_date,
                            last_updated_by,
                            ben_plan_id
                        ) values ( p_entrp_id,
                                   'ENTERPRISE',
                                   'NO_OF_ELIGIBLE',
                                   stage_rec.total_no_ee,
                                   sysdate,
                                   p_user_id,
                                   sysdate,
                                   p_user_id,
                                   x_er_ben_plan_id );

                    end if;

                end;

                begin
                    update enterprise_census                   --- 2
                    set
                        census_numbers = stage_rec.active_participants
                    where
                            ben_plan_id = x_er_ben_plan_id
                        and census_code = 'ACTIVE_PARTICIPANT'
                        and entity_type = 'ENTERPRISE';

                    if sql%notfound then
                        insert into enterprise_census values ( p_entrp_id,
                                                               'ENTERPRISE',
                                                               'ACTIVE_PARTICIPANT',
                                                               stage_rec.active_participants,
                                                               sysdate,
                                                               stage_rec.created_by,
                                                               sysdate,
                                                               stage_rec.created_by,
                                                               x_er_ben_plan_id );

                    end if;

                end;

                begin
                    update enterprise_census                           ---3
                    set
                        census_numbers = stage_rec.l_day_active_participants
                    where
                            ben_plan_id = x_er_ben_plan_id
                        and census_code = 'LAST_DAY_ACTIVE_PARTICIPANT'
                        and entity_type = 'ENTERPRISE';

                    if sql%notfound then
                        insert into enterprise_census values ( p_entrp_id,
                                                               'ENTERPRISE',
                                                               'LAST_DAY_ACTIVE_PARTICIPANT',
                                                               stage_rec.l_day_active_participants,
                                                               sysdate,
                                                               stage_rec.created_by,
                                                               sysdate,
                                                               stage_rec.created_by,
                                                               x_er_ben_plan_id );

                    end if;

                end;

        -- Added by Jaggi for Ticket#11036
                l_final_report := 'N';
                for k in (
                    select
                        'Y' final_report
                    from
                        plan_notices_stage
                    where
                            entrp_id = p_entrp_id
                        and batch_number = p_batch_number
                        and entity_type = 'FORM_5500'
                        and notice_type = 'FINAL_REPORT'
                        and entity_id = stage_rec.enrollment_detail_id
                ) loop
                    if k.final_report = 'Y' then
                        l_final_report := 'Y';
                    end if;
                end loop;

                begin
                    update enterprise_census                         --- 4
                    set
                        census_numbers = stage_rec.enrolled_empl_1st_day_pln_yr
                    where
                            ben_plan_id = x_er_ben_plan_id
                        and census_code = 'ENRD_EMP_1ST_DAY_NXT_PLN_YR'
                        and entity_type = 'ENTERPRISE';

                    if
                        sql%notfound
                        and l_final_report = 'N'
                    then  -- Added by Jaggi for Ticket#11036
                        insert into enterprise_census values ( p_entrp_id,
                                                               'ENTERPRISE',
                                                               'ENRD_EMP_1ST_DAY_NXT_PLN_YR',
                                                               stage_rec.enrolled_empl_1st_day_pln_yr,
                                                               sysdate,
                                                               stage_rec.created_by,
                                                               sysdate,
                                                               stage_rec.created_by,
                                                               x_er_ben_plan_id );

                    end if;

                end;

                begin
                    update enterprise_census                               --- 5
                    set
                        census_numbers = stage_rec.recv_benefits
                    where
                            ben_plan_id = x_er_ben_plan_id
                        and census_code = 'RETIRED_SEP_BEN'
                        and entity_type = 'ENTERPRISE';

                    if sql%notfound then
                        insert into enterprise_census values ( p_entrp_id,
                                                               'ENTERPRISE',
                                                               'RETIRED_SEP_BEN',
                                                               stage_rec.recv_benefits,
                                                               sysdate,
                                                               stage_rec.created_by,
                                                               sysdate,
                                                               stage_rec.created_by,
                                                               x_er_ben_plan_id );

                    end if;

                end;

                begin
                    update enterprise_census                           ---6
                    set
                        census_numbers = stage_rec.future_benefits
                    where
                            ben_plan_id = x_er_ben_plan_id
                        and census_code = 'RETIRED_SEP_FUT_BEN'
                        and entity_type = 'ENTERPRISE';

                    if sql%notfound then
                        insert into enterprise_census values ( p_entrp_id,
                                                               'ENTERPRISE',
                                                               'RETIRED_SEP_FUT_BEN',
                                                               stage_rec.future_benefits,
                                                               sysdate,
                                                               stage_rec.created_by,
                                                               sysdate,
                                                               stage_rec.created_by,
                                                               x_er_ben_plan_id );

                    end if;

                end;

            end if;--- IF ENROLLMENT IS

            if stage_rec.plan_type in ( 'Single-Employer-Plan', 'SNGL', 'SNGL_RENEW' ) then
                l_plan_type := 'SNGL_RENEW';
            elsif stage_rec.plan_type in ( 'Multi-Employer-Plan', 'MER', 'MER_RENEW' ) then
                l_plan_type := 'MER_RENEW';
            elsif stage_rec.plan_type in ( 'Multiple-Employer-Plan', 'MERS', 'MERS_RENEW' ) then
                l_plan_type := 'MERS_RENEW';
            end if;

			---8906 28/03/2020 rprabu Start
            begin
                select
                    ben_plan_name
                into l_ben_plan_name
                from
                    ben_plan_enrollment_setup
                where
                    ben_plan_id = (
                        select
                            max(ben_plan_id)
                        from
                            ben_plan_enrollment_setup
                        where
                                acc_id = l_acc_id
                            and ben_plan_number = stage_rec.plan_number
                    );    ----- 8562       rprabu 09/12/2019
            exception
                when no_data_found then
                    l_ben_plan_name := null;
            end;

            pc_log.log_error('l_acc_num  PROCESS_FORM_5500_MAIN_TABLES 2 66  l_ben_plan_name  : ', l_ben_plan_name);
			---8906 28/03/2020 rprabu End
        -- Added by Jaggi for Ticket#11036
            l_final_report := 'N';
            for k in (
                select
                    'Y' final_report
                from
                    plan_notices_stage
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number
                    and entity_type = 'FORM_5500'
                    and notice_type = 'FINAL_REPORT'
                    and entity_id = stage_rec.enrollment_detail_id
            ) loop
                if k.final_report = 'Y' then
                    l_final_report := 'Y';
                    l_return_status := 'S';
                end if;
            end loop;

            if nvl(l_final_report, 'N') = 'N' then   -- Added by Jaggi for Ticket#11036

                pc_employer_enroll.update_plan_info               -----3

                (
                    p_entrp_id             => p_entrp_id,
                    p_fiscal_end_date      => null,
                    p_plan_type            => nvl(l_plan_type, 'SNGL_RENEW'), ----              For next year ben plan record .....,
                    p_plan_name            => nvl(l_ben_plan_name, stage_rec.plan_name),   --- l_ben_plan_name added for ---8906 28/03/2020 rprabu Start
                    p_eff_date             => nvl(stage_rec.next_yr_plan_start_date,
                                      to_char((to_date(stage_rec.plan_end_date, 'mm/dd/yyyy') + 1), 'mm/dd/yyyy')),
                    p_org_eff_date         => to_char(to_date(stage_rec.effective_plan_date, 'mm/dd/yyyy'), 'mm/dd/yyyy'),
                    p_plan_start_date      => nvl(stage_rec.next_yr_plan_start_date,
                                             to_char((to_date(stage_rec.plan_end_date, 'mm/dd/yyyy') + 1), 'mm/dd/yyyy')),
                    p_plan_end_date        => nvl(stage_rec.next_yr_plan_end_date,
                                           to_char(
                                                               add_months(to_date(stage_rec.plan_end_date, 'mm/dd/yyyy'), 12),
                                                               'mm/dd/yyyy'
                                                           )),  -- Ticket #8074
                    p_takeover             => null,
                    p_user_id              => p_user_id,
                    p_is_5500              => stage_rec.form_5500_sub_option_flag,      --- 8021 rprabu 13/08/2019
                    p_coll_plan            => stage_rec.collective_plan_flag,
                    p_plan_fund_code       => stage_rec.plan_fund_code,
                    p_plan_benefit_code    => stage_rec.plan_benefit_code,
                    p_plan_number          => stage_rec.plan_number,
                    p_erissa_erap_doc_type => null,
                    x_er_ben_plan_id       => l_ben_plan_id_next_year,
                    x_error_status         => l_return_status,
                    x_error_message        => l_error_message
                );

                pc_log.log_error('l_acc_num  PROCESS_FORM_5500_MAIN_TABLES  5 up Online_Form_5500_Plan_Staging     l_ben_plan_id_next_year  : '
                , l_ben_plan_id_next_year);
                if l_ben_plan_id_next_year > 0 then
                    update ben_plan_enrollment_setup
                    set
                        status = 'P',
                        product_type = 'FORM_5500'  --- 8132 rprabu
                    where
                        ben_plan_id = l_ben_plan_id_next_year;

            ---------------8132 ---------------
                    update online_form_5500_plan_staging
                    set
                        ben_plan_id_next = l_ben_plan_id_next_year
                    where
                            entrp_id = p_entrp_id
                        and enrollment_detail_id = stage_rec.enrollment_detail_id;

                end if;

            end if;     -- Added by Jaggi for Ticket#11036
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 5 b: l_return_status', l_return_status);
            if l_return_status = 'S' then
          ---x_er_ben_plan_id
          ---x_er_ben_plan_id
                for rec in (
                    select
                        notice_type,
                        created_by
                    from
                        plan_notices_stage
                    where
                            entrp_id = p_entrp_id
                        and batch_number = p_batch_number
                        and entity_id = stage_rec.enrollment_detail_id
                        and entity_type = 'FORM_5500'
                ) loop
                    insert into plan_notices ------ 8
                     (
                        plan_notice_id,
                        entrp_id,
                        entity_id,
                        entity_type,
                        notice_type,
                        creation_date,
                        created_by,
                        ben_plan_id_pending   -- Added by Swamy for Ticket#8080
                    ) values ( plan_notice_seq.nextval,
                               p_entrp_id,
                               x_er_ben_plan_id,
                               'BEN_PLAN_ENROLLMENT_SETUP',
                               rec.notice_type,
                               sysdate,
                               rec.created_by,
                               l_ben_plan_id_next_year   -- Added by Swamy for Ticket#8080
                                );

                end loop;

                if stage_rec.dfvc_program_flag = 'Y' then   ----  Ticket #8069 22/08/2019
                    insert into plan_notices ------ 8a
                     (
                        plan_notice_id,
                        entrp_id,
                        entity_id,
                        entity_type,
                        notice_type,
                        creation_date,
                        created_by,
                        ben_plan_id_pending    -- Added by Swamy for Ticket#8080
                    ) values ( plan_notice_seq.nextval,
                               p_entrp_id,
                               x_er_ben_plan_id,
                               'BEN_PLAN_ENROLLMENT_SETUP',
                               'DFVC',
                               sysdate,
                               rec.created_by,
                               l_ben_plan_id_next_year     -- Added by Swamy for Ticket#8080
                                );

                end if;   ----  End Ticket #8069 22/08/2019
            end if;
        -----Benefit codes moved to main tables...

            begin
                pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 6', p_entrp_id);
          ----------------------------

          --Insert all the Plan documents in File attachments table
                insert into file_attachments (
                    attachment_id,
                    document_name,
                    document_type,
                    attachment,
                    entity_name,
                    entity_id,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    document_purpose
                )
                    (
                        select
                            attachment_id,
                            document_name,
                            document_type,
                            attachment,
                            'BEN_PLAN_ENROLLMENT_SETUP', ---Entity_Name ,
                            x_er_ben_plan_id,             --- Form_5500 ben Plan Id
                            creation_date,
                            created_by,
                            last_update_date,
                            last_updated_by,
                            document_purpose
                        from
                            file_attachments_staging fs
                        where
                                plan_id = stage_rec.enrollment_detail_id
                            and batch_number = p_batch_number
                            and not exists (
                                select
                                    *
                                from
                                    file_attachments
                                where
                                    fs.attachment_id = file_attachments.attachment_id
                            ) -- added by jaggi#10431
                    );

            end;

            insert into benefit_codes (
                benefit_code_id,
                entity_id,
                benefit_code_name,
                entity_type,
                description,
                fully_insured_flag,
                self_insured_flag,
                created_by,
                creation_date
            )
                select
                    benefit_code_seq.nextval,
                    x_er_ben_plan_id,
                    benefit_code_name,
                    'BEN_PLAN_ENROLLMENT_SETUP',
                    description,
                    fully_insured_flag,
                    self_insured_flag,
                    created_by,
                    creation_date
                from
                    benefit_codes_stage
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number;

            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 7', p_entrp_id);
            pc_web_compliance.insrt_ar_quote_headers                                                    ----10
            (
                p_quote_name        => null,
                p_quote_number      => null,
                p_total_quote_price => stage_rec.tot_price, -- total annual fees
                p_quote_date        => to_char(sysdate, 'mm/dd/rrrr'),
                p_payment_method    => stage_rec.payment_method,
                p_entrp_id          => p_entrp_id,
                p_bank_acct_id      => null,
                p_ben_plan_id       => x_er_ben_plan_id,
                p_user_id           => stage_rec.created_by,
                p_quote_source      => 'ONLINE',
                p_product           => 'FORM_5500',
                x_quote_header_id   => x_quote_header_id,
                x_return_status     => l_return_status,
                x_error_message     => l_error_message
            );

            if l_return_status <> 'S' then
                raise process_form_5500_err;
            end if;
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 6 a : ', l_return_status);
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 7', p_entrp_id);
            for ar_lines_rec in (
                select
                    a.*
                from
                    ar_quote_lines_staging   a,
                    ar_quote_headers_staging h
                where
                        h.batch_number = p_batch_number
                    and a.batch_number = h.batch_number
                    and h.quote_header_id = a.quote_header_id
                    and h.entrp_id = p_entrp_id
                    and h.enrollment_detail_id = stage_rec.enrollment_detail_id ----Ticket #8538   03/12/2019
            ) loop
                pc_web_compliance.insrt_ar_quote_lines ----11
                (
                    p_quote_header_id     => x_quote_header_id,
                    p_rate_plan_id        => ar_lines_rec.rate_plan_id,
                    p_rate_plan_detail_id => ar_lines_rec.rate_plan_detail_id,
                    p_line_list_price     => ar_lines_rec.line_list_price,
                    p_notes               => 'FORM5500 ONLINE ENROLLMENT',
                    p_user_id             => stage_rec.created_by,
                    x_return_status       => l_return_status,
                    x_error_message       => l_error_message
                );

              ----update added for Ticket #8538  03/12/2019
                update ar_quote_headers
                set
                    ben_plan_number = stage_rec.plan_number
                where
                    quote_header_id = x_quote_header_id;

                pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 8 a : ', l_return_status);
                if l_return_status <> 'S' then
                    raise process_form_5500_err;
                end if;
            end loop;

            l_user_id := stage_rec.created_by;
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 8', p_entrp_id);
        end loop;
      --Create Salesrep data
      --- p_entrp_id ,  p_Batch_number
      ----------
      ----------contact info into main tables...

      -- Added by Joshi for 10430. need to delete existing contacts and reinsert as in case of resubmit
     -- user might update existing  contacts.

        delete from contact
        where
            contact_id in (
                select
                    contact_id
                from
                    contact_leads
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and account_type = 'FORM_5500'
                    and ref_entity_type in ( 'ONLINE_ENROLLMENT', 'BEN_PLAN_RENEWALS' )   -- Added by Swamy Ticket#8531 and Ticket#8638
                    and lic_number is null
            );

        insert into contact (
            contact_id,
            first_name,
            last_name,
            entity_id,
            entity_type,
            email,
            status,
            start_date,
            last_updated_by,
            created_by,
            last_update_date,
            creation_date,
            can_contact,
            contact_type,
            user_id,
            phone,
            fax,
            title,
            account_type
        )
            select
                contact_id,   ----------   contact_seq.nextval,  -------- 7783 rprabu 31/10/2019 nextval commented
                substr(first_name,
                       0,
                       instr(first_name, ' ', 1, 1) - 1),
                substr(first_name,
                       instr(first_name, ' ', 1, 1) + 1,
                       length(first_name) - instr(first_name, ' ', 1, 1) + 1),
                entity_id,
                'ENTERPRISE',
                email,
                'A',
                sysdate,
                null,
                null,
                sysdate,
                sysdate,
                'Y',
                contact_type,
                null,
                phone_num,
                contact_fax,
                job_title,
                'FORM_5500'
            from
                contact_leads a
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and account_type = 'FORM_5500'
                and ref_entity_type in ( 'ONLINE_ENROLLMENT', 'BEN_PLAN_RENEWALS' )   -- Added by Swamy Ticket#8531 and Ticket#8638
                and lic_number is null                      -- Added by Swamy Ticket#8531
                and not exists (
                    select
                        1
                    from
                        contact b
                    where
                        a.contact_id = b.contact_id
                );  -------- 7783 rprabu 31/10/2019

        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.Process_Form_5500_Main_Tables', 'Contact Data Created Successfully ');
      --- For all contacts added define contact roles etc
        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 9', p_entrp_id);
        for xx in (
            select
                *
            from
                contact_leads a
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and not exists (
                    select
                        1
                    from
                        contact_role b
                    where
                        a.contact_id = b.contact_id
                )     -------- 7783 rprabu 31/10/2019
        ) loop
            insert into contact_role e (
                contact_role_id,
                contact_id,
                role_type,
                account_type,
                effective_date,
                created_by,
                last_updated_by
            ) values ( contact_role_seq.nextval,
                       xx.contact_id,
                       xx.account_type,
                       xx.account_type,
                       sysdate,
                       null,
                       null );
        --Especially for compliance we need to have both account type AND role type defined
            insert into contact_role e (
                contact_role_id,
                contact_id,
                role_type,
                account_type,
                effective_date,
                created_by,
                last_updated_by
            ) values ( contact_role_seq.nextval,
                       xx.contact_id,
                       xx.contact_type,
                       xx.account_type,
                       sysdate,
                       null,
                       null );
        --For all products we want Fee Invoice option also checked
            if xx.contact_type = 'PRIMARY'
            or xx.send_invoice in ( 'Y', '1' ) then
                insert into contact_role e (
                    contact_role_id,
                    contact_id,
                    role_type,
                    account_type,
                    effective_date,
                    created_by,
                    last_updated_by
                ) values ( contact_role_seq.nextval,
                           xx.contact_id,
                           'FEE_BILLING',
                           xx.account_type,
                           sysdate,
                           null,
                           null );

            end if;

        end loop;

        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 10', p_entrp_id);
        for form_rec in (
            select
                salesrep_id,
                decode(source, 'ENROLLMENT', 'E', 'RENEWAL', 'R') source,
                acct_payment_fees,
                enrollment_id,
                payment_method
            from
                online_form_5500_staging
            where
                    p_entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            if form_rec.salesrep_id is not null then ----12
                if form_rec.source = 'E' then
                     -- added by Jaggi #11629
                    pc_sales_team.upsert_sales_team_member(
                        p_entity_type           => 'SALES_REP',
                        p_entity_id             => form_rec.salesrep_id,
                        p_mem_role              => 'PRIMARY',
                        p_entrp_id              => p_entrp_id,
                        p_start_date            => trunc(sysdate),
                        p_end_date              => null,
                        p_status                => 'A',
                        p_user_id               => p_user_id,
                        p_pay_commission        => null,
                        p_note                  => null,
                        p_no_of_days            => null,
                        px_sales_team_member_id => l_sales_team_member_id,
                        x_return_status         => l_return_status,
                        x_error_message         => x_error_message
                    );

                    if l_return_status <> 'S' then
                        raise process_form_5500_err;
                    end if;
                end if;
            end if;

            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 10.1', p_entrp_id);
            if form_rec.payment_method = 'ACH' then   -- Added If condition swamy for Ticket#12778
                for j in (
                    select
                        bank_name,
                        bank_acct_type,
                        bank_routing_num,
                        bank_acct_num,
                        bank_status,
                        giac_verify,
                        giac_authenticate,
                        giac_response,
                        business_name,
                        bank_acct_verified,
                        user_bank_acct_stg_id
                    from
                        user_bank_acct_staging
                    where
                            entrp_id = p_entrp_id
                        and batch_number = p_batch_number
                ) loop
                    l_bank_id := 0;
                    l_entity_id := null;
                    l_entity_type := null;
                    pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 10.2', p_entrp_id
                                                                                                         || ' form_rec.acct_payment_fees:='
                                                                                                         || form_rec.acct_payment_fees
                                                                                                         || 'j.bank_acct_num :='
                                                                                                         || j.bank_acct_num
                                                                                                         || 'j.bank_routing_num :='
                                                                                                         || j.bank_routing_num);

                    pc_user_bank_acct.get_bank_account_usage(
                        p_product_type    => 'FORM_5500',
                        p_account_usage   => 'INVOICE',
                        x_bank_acct_usage => l_acct_usage,
                        x_return_status   => l_return_status,
                        x_error_message   => l_error_message
                    );

                    pc_user_bank_acct.get_entity_details(
                        p_acc_id            => l_acc_id,
                        p_product_type      => 'FORM_5500',
                        p_acct_payment_fees => form_rec.acct_payment_fees,
                        x_entity_id         => l_entity_id,
                        x_entity_type       => l_entity_type,
                        x_return_status     => l_return_status,
                        x_error_message     => l_error_message
                    );

                    pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 10.3', p_entrp_id
                                                                                                         || ' l_entity_id :='
                                                                                                         || l_entity_id
                                                                                                         || ' l_entity_type :='
                                                                                                         || l_entity_type
                                                                                                         || 'l_Acc_id :='
                                                                                                         || l_acc_id
                                                                                                         || ' l_return_status :='
                                                                                                         || l_return_status
                                                                                                         || ' l_error_message :='
                                                                                                         || l_error_message);

                    l_bank_id := pc_user_bank_acct.get_bank_acct_id(
                        p_entity_id          => l_entity_id,
                        p_entity_type        => l_entity_type,
                        p_bank_acct_num      => j.bank_acct_num,
                        p_bank_name          => null,
                        p_bank_routing_num   => j.bank_routing_num,
                        p_bank_account_usage => 'INVOICE',
                        p_bank_acct_type     => j.bank_acct_type
                    );

                    pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_id l', l_bank_id);
                    if l_bank_id = 0 then
                        pc_user_bank_acct.giact_insert_bank_account(
                            p_entity_id             => l_entity_id,
                            p_entity_type           => l_entity_type,
                            p_display_name          => j.bank_name,
                            p_bank_acct_type        => j.bank_acct_type,
                            p_bank_routing_num      => j.bank_routing_num,
                            p_bank_acct_num         => j.bank_acct_num,
                            p_bank_name             => j.bank_name,
                            p_bank_account_usage    => nvl(l_acct_usage, 'INVOICE'),
                            p_user_id               => p_user_id,
                            p_bank_status           => j.bank_status,
                            p_giac_verify           => j.giac_verify,
                            p_giac_authenticate     => j.giac_authenticate,
                            p_giac_response         => j.giac_response,
                            p_business_name         => j.business_name,
                            p_bank_acct_verified    => j.bank_acct_verified,
                            p_existing_bank_account => null,
                            x_bank_status           => x_bank_status,
                            x_bank_acct_id          => l_bank_id,
                            x_return_status         => l_return_status,
                            x_error_message         => l_error_message
                        );

                        if l_return_status <> 'S' then
                            raise process_form_5500_err;
                        end if;
                        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES **1', p_entrp_id);
                    else
                        update bank_accounts
                        set
                            bank_name = j.bank_name,
                            business_name = j.business_name,
                            bank_acct_type = j.bank_acct_type
                        where
                                bank_acct_id = l_bank_id
                            and entity_id = l_entity_id
                            and entity_type = l_entity_type;

                    end if;

            -- Added for Ticket#12767(12527)
                    update user_bank_acct_staging
                    set
                        bank_acct_id = l_bank_id
                    where
                            entrp_id = p_entrp_id
                        and batch_number = p_batch_number
                        and user_bank_acct_stg_id = j.user_bank_acct_stg_id;

                    update online_form_5500_staging
                    set
                        bank_acc_num = j.bank_acct_num,
                        bank_name = j.bank_name
                    where
                            entrp_id = p_entrp_id
                        and batch_number = p_batch_number
                        and enrollment_id = form_rec.enrollment_id;

                    pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES **11 j.User_Bank_Acct_Stg_Id', j.user_bank_acct_stg_id
                                                                                                                                 || ' l_bank_id :='
                                                                                                                                 || l_bank_id
                                                                                                                                 || 'p_batch_number :='
                                                                                                                                 || p_batch_number
                                                                                                                                 || 'p_source :='
                                                                                                                                 || p_source
                                                                                                                                 );

                    pc_file_upload.giact_insert_file_attachments(
                        p_user_bank_stg_id => j.user_bank_acct_stg_id,
                        p_attachment_id    => null,
                        p_entity_id        => l_bank_id,
                        p_entity_name      => 'GIACT_BANK_INFO',
                        p_document_purpose => 'GIACT_DOC',
                        p_batch_number     => p_batch_number,
                        p_source           => form_rec.source,
                        x_error_status     => x_error_status,
                        x_error_message    => x_error_message
                    );

                end loop;
            end if;

        end loop;   

/*
   -- Added by Swamy for Ticket#12527 
   FOR form_rec IN (SELECT salesrep_id
                          ,source
                          ,acct_payment_fees   
                     FROM online_form_5500_staging
                    WHERE p_entrp_id = p_entrp_id
                      AND Batch_number = p_Batch_number
                    )
    LOOP
                IF form_rec.salesrep_id IS NOT NULL THEN ----12
                   IF p_source = 'ENROLLMENT'  THEN
                     -- added by Jaggi #11629
                     PC_SALES_TEAM.upsert_sales_team_member(
                              p_entity_type           => 'SALES_REP'
                             ,p_entity_id             => form_rec.salesrep_id
                             ,p_mem_role              => 'PRIMARY'
                             ,p_entrp_id              => p_entrp_id
                             ,p_start_date            => trunc(sysdate)
                             ,p_end_date              => Null
                             ,p_status                => 'A'
                             ,p_user_id               => p_user_id
                             ,p_pay_commission        => NULL
                             ,p_note                  => NULL
                             ,p_no_of_days            => NULL
                             ,px_sales_team_member_id => l_sales_team_member_id
                             ,x_return_status         => l_return_status
                             ,x_error_message         => X_ERROR_MESSAGE);

                         IF l_return_status <> 'S' THEN
                             RAISE process_form_5500_err ;
                         END IF;
                    END IF;
                END IF;
                -- Add bank details
                l_acct_usage :=  'INVOICE' ; 
                l_bank_count := 0 ;   
                IF UPPER(form_rec.acct_payment_fees)= 'EMPLOYER'  THEN
                    l_entity_id := l_acc_id;
                    l_entity_type := 'ACCOUNT';
                ELSIF UPPER(form_rec.acct_payment_fees) = 'BROKER'  THEN
                    l_entity_id := pc_account.get_broker_id(l_acc_id);
                    l_entity_type := 'BROKER';
                ELSIF UPPER( form_rec.acct_payment_fees) = 'GA'  THEN
                    l_entity_id := pc_account.get_ga_id(l_acc_id);
                    l_entity_type := 'GA';
                END IF;

                FOR J IN (select bank_name
				                ,bank_acct_type
								,bank_routing_num
								,bank_acct_num
								,bank_status
								,giac_verify
								,giac_authenticate
								,giac_response
								,business_name
								,bank_acct_verified
                                ,display_name
                            from user_bank_Acct_staging
                           where entrp_id = p_entrp_id
                             and batch_number = p_batch_number
						 )
                LOOP
                 l_bank_Acct_id := 0;
                 l_bank_name := NULL;
                 l_display_name := NULL;
                 l_bank_acct_type := NULL;
                 l_inactive_flag  := 'N';

                 FOR k IN (SELECT bank_name
				                 ,display_name
								 ,bank_acct_type
								 ,bank_acct_id
                            FROM bank_Accounts
                           WHERE bank_routing_num = j.bank_routing_num
                             AND bank_acct_num    = j.bank_acct_num
                             AND status           = 'A'
                             AND bank_account_usage = l_acct_usage
                             AND entity_id        = l_entity_id
                             AND entity_type      = l_entity_type
						   )
                LOOP
                    l_bank_name    := k.bank_name;
                    l_display_name := k.display_name;
                    l_bank_Acct_id := k.bank_acct_id;
                END LOOP;

                pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_Acct_id l',l_bank_Acct_id); 

                   IF l_bank_Acct_id <> 0 AND LOWER(j.bank_name) <> LOWER(L_bank_name) OR LOWER(j.display_Name) <> LOWER(L_display_Name)
    				  OR LOWER(j.bank_acct_type) <> L_bank_acct_type 
                   THEN 
                      UPDATE BANK_ACCOUNTS
                         SET status = 'I'
                            ,last_updated_by = p_user_id
                            ,last_update_date = SYSDATE
                       WHERE bank_acct_id = l_bank_Acct_id;

                       l_inactive_flag := 'Y';
                   END IF;

                    IF ((l_bank_Acct_id = 0) OR l_inactive_flag = 'Y') THEN
                          pc_user_bank_acct.giact_insert_bank_account(
                                     p_entity_id          => l_entity_id
                                    ,p_entity_type        => l_entity_type
                                    ,p_display_name       => j.bank_name  
                                    ,p_bank_acct_type     => j.bank_acct_type 
                                    ,p_bank_routing_num   => j.bank_routing_num 
                                    ,p_bank_acct_num      => j.bank_acct_num
                                    ,p_bank_name          => j.bank_name 
                                    ,p_bank_account_usage => NVL(l_acct_usage,'INVOICE')
                                    ,p_user_id            => p_user_id
                                    ,p_bank_status        => j.bank_status
                                    ,p_giac_verify        => j.giac_verify
                                    ,p_giac_authenticate   => j.giac_authenticate
                                    ,p_giac_response       => j.giac_response
                                    ,p_business_name      => j.business_name
                                    ,p_bank_acct_verified  => j.bank_acct_verified
                                    ,p_existing_bank_Account => null
                                    ,x_bank_status        => x_bank_status
                                    ,x_bank_acct_id       => l_bank_id
                                    ,x_return_status      => l_return_status 
                                    ,x_error_message      => l_error_message);  

                    IF l_return_status <> 'S' THEN
                        Raise PROCESS_FORM_5500_ERR ;
                    END IF;
                  END IF;
                    pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.giact_insert_bank_account **1',p_entrp_id);
                END LOOP;              
    END LOOP;
*/
 --------------
 /*      FOR bank_rec IN
      (SELECT  bank_name,
          bank_acc_num ,
          acct_usage,
          payment_method,
          bank_acc_type ,
          send_invoice,
          routing_number ,
          created_by,
          salesrep_id,
          source,
           acct_payment_fees   -- Added by Josh for 12279
        FROM online_form_5500_staging
        WHERE p_entrp_id = p_entrp_id
        AND Batch_number = p_Batch_number
      )
      LOOP
        IF bank_rec.salesrep_id IS NOT NULL THEN ----12
            IF p_source = 'ENROLLMENT'  THEN
--                pc_employer_enroll.create_salesrep
--                (   p_entrp_id => p_entrp_id , p_salesrep_id => bank_rec.salesrep_id ,
--                    p_user_id => l_user_id , x_error_status => l_return_status , x_error_message => l_error_message);
            -- added by Jaggi #11629
            PC_SALES_TEAM.upsert_sales_team_member(
                     p_entity_type           => 'SALES_REP'
                    ,p_entity_id             => bank_rec.salesrep_id
                    ,p_mem_role              => 'PRIMARY'
                    ,p_entrp_id              => p_entrp_id
                    ,p_start_date            => trunc(sysdate)
                    ,p_end_date              => Null
                    ,p_status                => 'A'
                    ,p_user_id               => p_user_id
                    ,p_pay_commission        => NULL
                    ,p_note                  => NULL
                    ,p_no_of_days            => NULL
                    ,px_sales_team_member_id => l_sales_team_member_id
                    ,x_return_status         => l_return_status
                    ,x_error_message         => X_ERROR_MESSAGE);

                IF l_return_status <> 'S' THEN
                    RAISE process_form_5500_err ;
                END IF;
            END IF;
         END IF;

    	IF bank_rec.payment_method = 'ACH' AND bank_rec.bank_name IS NOT NULL THEN
            IF bank_rec.source = 'RENEWAL' THEN
                        Pc_User_Bank_Acct.Upsert_Bank_Acct
                                        (P_Acc_Num 		=> L_Acc_Num ,
                                          P_Display_Name                => Bank_Rec.Bank_Name ,
                                          p_bank_acct_type              => bank_rec.bank_acc_type ,
                                          p_bank_routing_num         	=> bank_rec.routing_number ,
                                          p_bank_acct_num               => bank_rec.bank_acc_num ,
                                          p_bank_name                   => bank_rec.bank_name ,
                                          p_user_id                     => p_user_id ,
                                          p_account_type                => 'INVOICE' ,
                                          x_bank_acct_id                => l_bank_id ,
                                          x_return_status               => l_return_status ,
                                          x_error_message               => l_error_message );
                        IF l_return_status is null then
                          l_return_status :='S';
                        END IF;
			ELSE
                 --Create Bank Info
                -- Added by Joshi  #12279
                -- Add bank details
                l_acct_usage :=  'INVOICE' ; 
                l_bank_count := 0 ;   
                IF UPPER(bank_rec.acct_payment_fees)= 'EMPLOYER'  THEN
                    l_entity_id := l_acc_id;
                    l_entity_type := 'ACCOUNT';
                ELSIF UPPER(bank_rec.acct_payment_fees) = 'BROKER'  THEN
                    l_entity_id := pc_account.get_broker_id(l_acc_id);
                    l_entity_type := 'BROKER';
                ELSIF UPPER( bank_rec.acct_payment_fees) = 'GA'  THEN
                    l_entity_id := pc_account.get_ga_id(l_acc_id);
                    l_entity_type := 'GA';
                END IF;

                pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_entity_id: ',l_entity_id);
                pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_entity_type',l_entity_type);
                pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_acct_usage l',l_acct_usage);

                SELECT COUNT(*) INTO l_bank_count
                   FROM bank_Accounts
                 WHERE bank_routing_num = bank_rec.routing_number
                      AND bank_acct_num    = bank_rec.bank_acc_num
                      AND bank_name        = bank_rec.bank_name  
                      AND status           = 'A'
                      AND entity_id        = l_entity_id
                      AND bank_account_usage = l_acct_usage
                      AND entity_type      = l_entity_type ;

                pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_count l',l_bank_count); 

                 IF l_bank_count = 0 THEN 
                    -- fee bank details      
                    pc_user_bank_acct.insert_bank_account(
                                     p_entity_id          => l_entity_id
                                    ,p_entity_type        => l_entity_type
                                    ,p_display_name       => bank_rec.bank_name  
                                    ,p_bank_acct_type     => bank_rec.bank_acc_type 
                                    ,p_bank_routing_num   => bank_rec.routing_number 
                                    ,p_bank_acct_num      => bank_rec.bank_acc_num
                                    ,p_bank_name          => bank_rec.bank_name 
                                    ,p_bank_account_usage => NVL(l_acct_usage,'INVOICE')
                                    ,p_user_id            => p_user_id
                                    ,x_bank_acct_id       => l_bank_id
                                    ,x_return_status      => l_return_status 
                                    ,x_error_message      => l_error_message);    

                    pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_id l',l_bank_id);      
                END IF;
            END IF;
        END IF;

        IF l_return_status <> 'S' THEN
            Raise PROCESS_FORM_5500_ERR ;
        END IF;
        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.insert_user_bank_acct 10',p_entrp_id);
      END LOOP;
	  */
    ---  END IF; -- double issue
        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES 12 l_return_status :', l_return_status);
    --Once Plan setup complete UPDATE teh complete flag as 1

        x_error_status := l_return_status;
        x_error_message := l_error_message;
        if
            l_return_status = 'S'
            and p_source = 'ENROLLMENT'
        then   ----13

        -- Added by Swamy for Ticket#12527 
            if nvl(x_bank_status, '*') in ( 'P', 'W' ) then
                l_account_status := 11;
            end if;

            update account
            set
                account_status = nvl(l_account_status, 3)
            where
                acc_id = l_acc_id;

            if l_inactive_plan_exist = 'I' then
                pc_employer_enroll_compliance.update_inactive_account(l_acc_id, p_user_id);
            else
                update account
                set
                    complete_flag = 1,
                    last_update_date = sysdate,
                    last_updated_by = p_user_id,
                    account_status = decode(x_bank_status, 'P', 11, 'W', 11,
                                            account_status), -- Added by Swamy for Ticket#12527
                    enrolled_date =
                        case
                            when enrolled_date is null then
                                sysdate
                            else
                                enrolled_date
                        end,-- 10431 Joshi
                    submit_by = p_user_id
                where
                    acc_id = l_acc_id;

            end if;

        elsif p_source = 'RENEWAL' then   ----13

            for u in (
                select
                    user_type
                from
                    online_users
                where
                    user_id = p_user_id
            ) loop
                if u.user_type = 'B' then
                    l_renewed_by := 'BROKER';
                elsif u.user_type = 'G' then
                    l_renewed_by := 'GA';
                else
                    l_renewed_by := 'EMPLOYER';
                end if;
            end loop;

         -- Added by Joshi for 10431 -- Renewal
            update account
            set
                renewed_by = l_renewed_by,
                renewed_date = sysdate  -- 10431 Joshi
            where
                acc_id = l_acc_id;

          -- Added by Swamy for Ticket#10747
          --Send Notifications using PC_NOTIFICATIONS
            pc_notifications.notify_broker_ren_decl_plan(
                p_acc_id       => l_acc_id,
                p_user_id      => p_user_id,
                p_entrp_id     => p_entrp_id,
                p_ben_pln_name => 'FORM_5500',
                p_ren_dec_flg  => 'R',
                p_acc_num      => l_acc_num
            );

         --Send Notifications using PC_NOTIFICATIONS
            pc_notifications.notify_er_ren_decl_plan(
                p_acc_id       => l_acc_id,
                p_ename        => pc_entrp.get_entrp_name(p_entrp_id),
                p_email        => pc_users.get_email_from_user_id(p_user_id),
                p_user_id      => p_user_id,
                p_entrp_id     => p_entrp_id,
                p_ben_plan_id  => null,
                p_ben_pln_name => 'FORM_5500',
                p_ren_dec_flg  => 'R',
                p_acc_num      => l_acc_num
            );

        end if;

    -- Added by Jaggi for Ticket #11086
        pc_employer_enroll_compliance.update_acct_pref(p_batch_number, p_entrp_id);
        select
            nvl(broker_id, 0)
        into l_broker_id
        from
            table ( pc_broker.get_broker_info_from_acc_id(l_acc_id) );

        if l_broker_id > 0 then
            l_authorize_req_id := pc_broker.get_broker_authorize_req_id(l_broker_id, l_acc_id);
            pc_broker.create_broker_authorize(
                p_broker_id        => l_broker_id,
                p_acc_id           => l_acc_id,
                p_broker_user_id   => null,
                p_authorize_req_id => l_authorize_req_id,
                p_user_id          => p_user_id,
                x_error_status     => l_return_status,
                x_error_message    => l_error_message
            );

        end if;
    -- code ends here by Joshi.
        begin
            update online_form_5500_staging
            set
                status = 'C',
                modified_date = sysdate,    -- added by swamy for ticket#11119
                modified_by = p_user_id     -- added by swamy for ticket#11119
            where
                    p_entrp_id = p_entrp_id
                and batch_number = p_batch_number;

        end;

        x_error_status := 'S';
    exception
        when process_form_5500_err then
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES IN exception part ', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
            rollback;
        when others then
            x_error_message := 'In PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES  when others : ' || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.PROCESS_FORM_5500_MAIN_TABLES : ', x_error_message);
            x_error_status := 'E';
            x_error_message := sqlerrm;
            rollback;
    end process_form_5500_main_tables;
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

 -- Below Type added by rprabu function FORM_5500 Revamp  ticket 7015
    function get_form_5500_plan_staging (
        p_batch_number         in number,
        p_entrp_id             in number,
        p_enrollment_detail_id in number
    ) return tbl_form_5500_plan_staging
        pipelined
    is
        rec             online_form_5500_plan_staging%rowtype;
        l_enrollment_id number(10);
    begin
        for i in (
            select
                *
            from
                online_form_5500_plan_staging
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and enrollment_detail_id = nvl(p_enrollment_detail_id, enrollment_detail_id)
        ) loop
            rec.enrollment_detail_id := i.enrollment_detail_id;
            rec.enrollment_id := i.enrollment_id;
            rec.plan_name := i.plan_name;
            rec.batch_number := p_batch_number;
            rec.entrp_id := p_entrp_id;
            rec.plan_number := i.plan_number;
            rec.effective_plan_date := i.effective_plan_date;
            rec.plan_start_date := i.plan_start_date;
            rec.plan_end_date := i.plan_end_date;
            rec.plan_type := i.plan_type;
            rec.active_participants := i.active_participants;
            rec.recv_benefits := i.recv_benefits;
            rec.future_benefits := i.future_benefits;
            rec.total_no_ee := i.total_no_ee;
            rec.is_coll_plan := i.is_coll_plan;
            rec.no_of_schedule_a_doc := i.no_of_schedule_a_doc;
            rec.sponsor_name := i.sponsor_name;
            rec.sponsor_contact_name := i.sponsor_contact_name;
            rec.sponsor_email := i.sponsor_email;
            rec.sponsor_tel_num := i.sponsor_tel_num;
            rec.sponsor_business_code := i.sponsor_business_code;
            rec.sponsor_ein := i.sponsor_ein;
            rec.admin_name_sameas_sponsor_flag := i.admin_name_sameas_sponsor_flag;
            rec.admin_name := i.admin_name;
            rec.admin_contact_name := i.admin_contact_name;
            rec.admin_email := i.admin_email;
            rec.admin_tel_num := i.admin_tel_num;
            rec.admin_business_code := i.admin_business_code;
            rec.admin_ein_sameas_sponsor_flag := i.admin_ein_sameas_sponsor_flag;
            rec.admin_ein := i.admin_ein;
            rec.admin_addr := i.admin_addr;
            rec.admin_city := i.admin_city;
            rec.admin_zip := i.admin_zip;
            rec.admin_state := i.admin_state;
            rec.pre_sponsor_name_ein_flag := i.pre_sponsor_name_ein_flag;
            rec.previous_sponsor_name := i.previous_sponsor_name;
            rec.previous_sponsor_ein := i.previous_sponsor_ein;
            rec.erisa_wrap_flag := i.erisa_wrap_flag;
            rec.collective_plan_flag := i.collective_plan_flag;
            rec.plan_fund_code := i.plan_fund_code;
            rec.plan_benefit_code := i.plan_benefit_code;
            rec.tot_price := i.tot_price;
            rec.short_plan_year_flag := i.short_plan_year_flag;
            rec.extention_flag := i.extention_flag;
            rec.dfvc_program_flag := i.dfvc_program_flag;
            rec.other_feature_code := i.other_feature_code;
            rec.last_employer_name := i.last_employer_name;
            rec.last_plan_name := i.last_plan_name;
            rec.last_ein := i.last_ein;
            rec.last_plan_number := i.last_plan_number;
            rec.erisa_wrap_plan_flag := i.erisa_wrap_plan_flag;
            rec.l_day_active_participants := i.l_day_active_participants;
	----		Rec.Retired_emp_enroll_L_day   			   := I.Retired_emp_enroll_L_day ;
            rec.enrolled_empl_1st_day_pln_yr := i.enrolled_empl_1st_day_pln_yr;
            rec.next_yr_short_plan_year_flag := i.next_yr_short_plan_year_flag;
            rec.next_yr_plan_start_date := i.next_yr_plan_start_date;
            rec.next_yr_plan_end_date := i.next_yr_plan_end_date;
            rec.send_doc_later_flag := i.send_doc_later_flag;
            rec.page_validity := i.page_validity;
            rec.ben_plan_flag := i.ben_plan_flag; --8132
            pipe row ( rec );
        end loop;
    end get_form_5500_plan_staging;
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Below  function rate Plans  added by rprabu function FORM_5500 Revamp  ticket 7015
--Function GET_Rate_Plans_Form_5500

    function get_benefit_plans_form_5500 (
        p_batch_number       in number,
        p_entrp_id           in number,
        p_enrollment_line_id in number,
        p_lookup_name        in varchar2
    ) return get_benefit_plan_row_t
        pipelined
    is
        rec             get_benefit_plan_row;
        x_error_message varchar2(300);
        x_error_status  varchar2(10);
    begin
        for rate_plans in (
            select
                listagg(b.rate_plan_id, ':') within group(
                order by
                    rate_plan_id
                ) rate_plan_id,
                listagg(b.rate_plan_detail_id, ':') within group(
                order by
                    rate_plan_detail_id
                ) rate_plan_detail_id,
                listagg(b.line_list_price, ':') within group(
                order by
                    rate_plan_detail_id
                ) line_list_price
            from
                ar_quote_headers_staging a,
                ar_quote_lines_staging   b
            where
                    a.quote_header_id = b.quote_header_id
                and account_type = 'FORM_5500'
                and a.entrp_id = p_entrp_id
                and a.enrollment_detail_id = p_enrollment_line_id
                and a.batch_number = p_batch_number
        ) loop
            rec.rate_plan_ids := rate_plans.rate_plan_id;
            rec.rate_plan_detail_ids := rate_plans.rate_plan_detail_id;
            rec.list_prices := rate_plans.line_list_price;
        end loop;

        for x in (
            select
                listagg(a.notice_type, ':') within group(
                order by
                    a.notice_type
                ) notice_type,
                listagg(b.description, ':') within group(
                order by
                    b.description
                ) description
            from
                plan_notices_stage a,
                lookups            b
            where
                    b.lookup_name = nvl(b.lookup_name, p_lookup_name)
                and a.batch_number = p_batch_number
                and a.notice_type (+) = b.lookup_code
                and a.entrp_id = p_entrp_id
                and entity_id = p_enrollment_line_id
                and entity_type = 'FORM_5500'
            order by
                a.notice_type -- Ordr By Is Necessary For Php People To Correctly Mapp The Flg_No_Notice AND Flg_Addition
        ) loop
      -- 5500 means null value, I am passing 5500 whie inserting into plan_notices_stage if the flag flg_no_notice is "N"
            rec.notice_type := x.notice_type;
            rec.description := x.description;
        end loop;
    ------------------------------
    ------Populate Benefit code details...
        for i in (
            select
                listagg(a.benefit_code_id, ':') within group(
                order by
                    a.benefit_code_id
                ) benefit_code_id,
                listagg(a.benefit_code_name, ':') within group(
                order by
                    a.benefit_code_id
                ) benefit_code_name,
                listagg(a.benefit_code_name
                        || '-'
                        || a.fully_insured_flag, ':') within group(
                order by
                    a.benefit_code_id
                ) fully_insured_flag,
                listagg(a.benefit_code_name
                        || '-'
                        || a.self_insured_flag, ':') within group(
                order by
                    a.benefit_code_id
                ) self_insured_flag,
                listagg(a.description, ':') within group(
                order by
                    a.benefit_code_id
                ) description,
                listagg(a.description, ':') within group(
                order by
                    a.benefit_code_id
                ) meaning,
                listagg(a.eligibility, ':') within group(
                order by
                    a.benefit_code_id
                ) eligibility,
                listagg(a.er_cont_pref, ':') within group(
                order by
                    a.benefit_code_id
                ) er_cont_pref,
                listagg(a.ee_cont_pref, ':') within group(
                order by
                    a.benefit_code_id
                ) ee_cont_pref,
                listagg(a.er_ee_contrib_lng, ':') within group(
                order by
                    a.benefit_code_id
                ) er_ee_contrib_lng,
                listagg(a.refer_to_doc, ':') within group(
                order by
                    a.benefit_code_id
                ) refer_to_doc
            from
                benefit_codes_stage a,
                lookups             b
            where
                    benefit_code_name = lookup_code
                and a.entity_id = p_enrollment_line_id
                and a.batch_number = p_batch_number
                and a.entrp_id = p_entrp_id
        ) loop
            rec.benefit_code_id := i.benefit_code_id;
            rec.benefit_code_name := i.benefit_code_name;
            rec.fully_insured_flag := i.fully_insured_flag;
            rec.self_insured_flag := i.self_insured_flag;
            rec.meaning := nvl(i.description, i.meaning);
            rec.eligibility := i.eligibility;
            rec.er_cont_pref := i.er_cont_pref;
            rec.ee_cont_pref := i.ee_cont_pref;
            rec.er_ee_contrib_lng := i.er_ee_contrib_lng;
            rec.refer_to_doc := i.refer_to_doc;
        end loop;
    -----------------------------------------------------
        pipe row ( rec );
    exception
        when others then
            x_error_message := 'In Upsert_form_5500_Plan_staging when others : ' || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.GET_Benefit_plans_Form_5500 : ', sqlerrm);
    end get_benefit_plans_form_5500;
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*Ticket#7792 .FORM_5500  Renewal*/
    procedure populate_renewal_data (
        p_batch_number   in number,
        p_entrp_id       in number,
        p_user_id        in number,
        p_page_validity  in varchar2,    -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        p_bank_authorize in varchar2,    -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        p_account_type   in varchar2    -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
    ) is

        l_enrollment_id         number;
        x_enrollment_id         number;
        l_renewed_plan_id       number;
        l_plan_type             varchar2(100);
        l_cnt_contact           number;
        l_cnt_ga                number;
        l_ga_lic                number;
        l_acc_id                number;
        l_acc_num               varchar2(20);
        x_error_status          varchar2(10);
        x_error_message         varchar2(1000);
        l_rec_count             number;
        x_enrollment_detail_id  number;
        l_prev_enrollment_id    number;
        l_prev_ben_plan_id      number := null; --------- 8132
        l_entity_type           varchar2(50);   --Added by swmay for ticket#10747
        l_broker_id             number;         -- Added by swmay for ticket#10747
        l_user_bank_acct_stg_id number;  -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        x_user_bank_acct_stg_id number;  -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        x_bank_status           varchar2(50);
    begin
        l_enrollment_id := 0;
        begin
            select
                acc_id,
                acc_num
            into
                l_acc_id,
                l_acc_num
            from
                account
            where
                entrp_id = p_entrp_id;

        exception
            when no_data_found then
                l_acc_id := 0;
        end;

    ---------------------------------------- Renew record already exists?    ----------------------------------------------------------------------------------
        if l_acc_id > 0 then
            begin
                select
                    nvl(
                        max(enrollment_id),
                        0
                    )
                into l_enrollment_id
                from
                    online_form_5500_staging
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number
                    and status = 'I' --------- rprabu 03/07/2020
                    and source = 'RENEWAL';

            exception
                when no_data_found then
                    pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...l_Enrollment_Id ', l_enrollment_id);
                    l_enrollment_id := 0;
            end;

            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...l_Enrollment_Id ', l_enrollment_id);
            if l_enrollment_id = 0 then
                begin
                    select
                        nvl(
                            max(enrollment_id),
                            0
                        )
                    into l_prev_enrollment_id
                    from
                        online_form_5500_staging
                    where
                        entrp_id = p_entrp_id;

                exception
                    when no_data_found then
                        l_prev_enrollment_id := 0;
                end;

                l_enrollment_id := form_5500_staging_seq.nextval;
                insert into online_form_5500_staging (
                    enrollment_id,
                    entrp_id,
                    batch_number,
                    acc_num,
                    creation_date,
                    created_by,
                    modified_date,
                    modified_by,
                    acct_usage,
                    credit_payment_monthly_pre,
                    payment_method,
                    send_invoice,
                    pay_acct_fees,
                    grand_total_price,
                    company_contact_entity,
                    company_contact_email,
                    plan_admin_individual_name,
                    emp_plan_sponsor_ind_name,
                    disp_annual_report_ind_name,
                    disp_annual_report_phone_no,
                    form_5500_sub_option_flag,
                    company_contact_others,
                    source
                )
                    (
                        select
                            l_enrollment_id,
                            p_entrp_id,
                            p_batch_number,
                            l_acc_num,
                            sysdate,
                            p_user_id,
                            null,
                            null,
                            acct_usage,
                            credit_payment_monthly_pre,
                            payment_method,
                            null send_invoice,
                            pay_acct_fees,
                            grand_total_price,
                            company_contact_entity,
                            company_contact_email,
                            plan_admin_individual_name,
                            emp_plan_sponsor_ind_name,
                            disp_annual_report_ind_name,
                            disp_annual_report_phone_no,
                            form_5500_sub_option_flag,
                            company_contact_others,
                            'RENEWAL'
                        from
                            online_form_5500_staging a,
                            enterprise               b,
                            account                  c
                        where
                                c.entrp_id = p_entrp_id --31482
                            and b.en_code = 1
                            and a.entrp_id (+) = c.entrp_id    --- existing records whic dont have entry in Staging table.
                            and b.entrp_id = c.entrp_id
                            and a.enrollment_id (+) = l_prev_enrollment_id
                    );

                pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...After Insertion l_Enrollment_Id ', l_enrollment_id
                );

           -- Added by swmay for ticket#10747
                pc_broker.get_broker_id(p_user_id, l_entity_type, l_broker_id);
        -- DO not prepopulate Bank data for Broker user
                if nvl(l_entity_type, '*') <> 'BROKER' then   -- In cond. Added by swmay for ticket#10747
              -- UPDATE bank details.
                    for x in (
                        select
                            *
                        from
                            user_bank_acct
                        where
                            bank_acct_id = (
                                select
                                    max(bank_acct_id)
                                from
                                    user_bank_acct
                                where
                                        acc_id = l_acc_id
                                    and status = 'A'
                            )
                    ) loop
                    /*UPDATE Online_Form_5500_Staging
                       set  Bank_Name         =   X.Bank_Name
                           ,Routing_Number   =  X.bank_Routing_num
                           ,Bank_Acc_Num       =  X.Bank_Acct_Num
                           ,Bank_Acc_Type       =  X.Bank_Acct_Type
                    where enrollment_id    =   l_Enrollment_Id
                        AND  batch_number   =   p_batch_number ;*/

                   -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
                        pc_employer_enroll.upsert_bank_info(
                            p_user_bank_acct_stg_id => l_user_bank_acct_stg_id,
                            p_entrp_id              => p_entrp_id,
                            p_batch_number          => p_batch_number,
                            p_account_type          => p_account_type,
                            p_acct_usage            => x.bank_account_usage,
                            p_display_name          => x.bank_name,
                            p_bank_acct_type        => x.bank_acct_type,
                            p_bank_routing_num      => x.bank_routing_num,
                            p_bank_acct_num         => x.bank_acct_num,
                            p_bank_name             => x.bank_name,
                            p_user_id               => p_user_id,
                            p_validity              => nvl(p_page_validity, 'V'),
                            p_bank_authorize        => p_bank_authorize,
                            p_giac_response         => x.giac_response,   -- Added by Swamy for Ticket#12527 
                            p_giac_verify           => x.giac_verify,   -- Added by Swamy for Ticket#12527 
                            p_giac_authenticate     => x.giac_authenticate,   -- Added by Swamy for Ticket#12527 
                            p_bank_acct_verified    => x.bank_acct_verified,   -- Added by Swamy for Ticket#12527 
                            p_business_name         => x.business_name,   -- Added by Swamy for Ticket#12527 
                            p_annual_optional_remit => null,   -- Added by Swamy for Ticket#12527 
                            p_existing_bank_flag    => 'Y',     -- Added by Swamy for Ticket#12527
                            p_bank_acct_id          => x.bank_acct_id,
                            x_user_bank_acct_stg_id => x_user_bank_acct_stg_id,
                            x_bank_status           => x_bank_status,    -- Added by Swamy for Ticket#12534 
                            x_error_status          => x_error_status,
                            x_error_message         => x_error_message
                        );
                    end loop;
                end if;

                pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...no renewal data ', l_enrollment_id);
                pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...insertion ', sqlerrm);
            else
    -----------Recently added need to UPDATE further fields  -------------------------
                for q in (
                    select
                        acct_usage,
                        credit_payment_monthly_pre,
                        payment_method,
                        send_invoice,
                        pay_acct_fees,
                        grand_total_price,
                        company_contact_entity,
                        company_contact_email,
                        plan_admin_individual_name,
                        emp_plan_sponsor_ind_name,
                        disp_annual_report_ind_name,
                        disp_annual_report_phone_no,
                        form_5500_sub_option_flag,
                        company_contact_others
                    from
                        online_form_5500_staging
                    where
                            entrp_id = p_entrp_id
                        and source = 'ENROLLMENT'
                ) loop
                    update online_form_5500_staging
                    set
                        acct_usage = q.acct_usage,
                        credit_payment_monthly_pre = q.credit_payment_monthly_pre,
                        payment_method = q.payment_method,
                        send_invoice = q.send_invoice,
                        pay_acct_fees = q.pay_acct_fees,
                    ---    Grand_Total_Price                         = Q.Grand_Total_Price ,
                        company_contact_entity = q.company_contact_entity,
                        company_contact_email = q.company_contact_email,
                        plan_admin_individual_name = q.plan_admin_individual_name,
                        emp_plan_sponsor_ind_name = q.emp_plan_sponsor_ind_name,
                        disp_annual_report_ind_name = q.disp_annual_report_ind_name,
                        disp_annual_report_phone_no = q.disp_annual_report_phone_no,
                        form_5500_sub_option_flag = q.form_5500_sub_option_flag,
                        company_contact_others = q.company_contact_others
                    where
                            entrp_id = p_entrp_id
                        and batch_number = p_batch_number;

                    pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...After UPDATE P_batch_number ', p_batch_number
                    );
                end loop;
            end if;

      ----------------Create plan staging records  from last ben_plan_enrollment_setup table -------------------------------
            for z in (
                select
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
                    wrap_opt_flg,
                    erissa_erap_doc_type
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = l_acc_id
                    and status in ( 'A', 'P' )         -----       A and  P is added Issue in Mulltiple sub plans reported Shavee 20/03/2020
                    and nvl(renewal_flag, 'N') <> 'Y'
                    and trunc(sysdate) between trunc(plan_end_date + 30) and trunc(add_months(plan_end_date, 12))
            )   -- Replace 7 with 12 by Jaggi for Ticket#11036
             loop
                l_rec_count := 0;
                pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...l_rec_count(before inserting stage) ', l_rec_count
                );
			  ------ Find previos active record to fetch the previous details....7856
                begin
                    select
                        max(ben_plan_id)
                    into l_prev_ben_plan_id
                    from
                        ben_plan_enrollment_setup
                    where
                            ben_plan_number = z.ben_plan_number
                        and status = 'A'
                        and acc_id = l_acc_id
                        and ben_plan_id <= z.ben_plan_id;

                exception
                    when no_data_found then
                        l_prev_ben_plan_id := null;
                end;

                begin
                    select
                        nvl(
                            count(*),
                            0
                        )
                    into l_rec_count
                    from
                        online_form_5500_plan_staging
                    where
                            entrp_id = p_entrp_id
                        and batch_number = p_batch_number
                        and ben_plan_id = z.ben_plan_id;

                exception
                    when no_data_found then
                        l_rec_count := 0;
                end;

                pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...after SELECT  statment ', l_rec_count);
                pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...p_batch_number ', p_batch_number);
                pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...z.ben_plan_id ', z.ben_plan_id);
                pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...l_prev_ben_plan_id ', l_prev_ben_plan_id);
                if l_rec_count = 0 then
                    begin
                        select
                            form_5500_plan_staging_seq.nextval
                        into x_enrollment_detail_id
                        from
                            dual;

                    end;
                    pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...x_enrollment_detail_id ', x_enrollment_detail_id
                    );
                    insert into online_form_5500_plan_staging (
                        enrollment_detail_id,
                        entrp_id,
                        ben_plan_id_next,  --- 8132
                        ben_plan_id_main,    -----8132
                        ben_plan_flag, -- 8132
                        acc_num, -------8132
                        batch_number,
                        ben_plan_id,
                        plan_name,
                        plan_number,
                        plan_type,
                        active_participants,
                        recv_benefits,
                        future_benefits,
                        total_no_ee,
                        is_coll_plan,
                        sponsor_name,
                        sponsor_contact_name,
                        sponsor_email,
                        sponsor_tel_num,
                        sponsor_business_code,
                        sponsor_ein,
                        admin_name_sameas_sponsor_flag,
                        admin_name,
                        admin_contact_name,
                        admin_email,
                        admin_tel_num,
                        admin_business_code,
                        admin_ein_sameas_sponsor_flag,
                        admin_ein,
                        admin_addr,
                        admin_city,
                        admin_zip,
                        admin_state,
                        pre_sponsor_name_ein_flag,
                        previous_sponsor_name,
                        previous_sponsor_ein,
                        erisa_wrap_flag,
                        collective_plan_flag,
                        tot_price,
                        page_validity,
                        creation_date,
                        created_by,
                        modified_date,
                        modified_by,
                        enrollment_id,
                        plan_fund_code,
                        plan_benefit_code,
                        effective_plan_date,
                        plan_start_date,
                        plan_end_date,
                        no_of_schedule_a_doc,
                        short_plan_year_flag,
                        extention_flag,
                        dfvc_program_flag,
                        other_feature_code,
                        last_employer_name,
                        last_plan_name,
                        last_ein,
                        last_plan_number,
                        erisa_wrap_plan_flag,
                        l_day_active_participants,
                        enrolled_empl_1st_day_pln_yr,
                        next_yr_short_plan_year_flag,
                        next_yr_plan_start_date,
                        next_yr_plan_end_date,
                        send_doc_later_flag
                    )
                        select
                            x_enrollment_detail_id, ---    form_5500_plan_staging_seq.nextval,
                            p_entrp_id,
                            ben_plan_id_next, --- 8132
                            a.ben_plan_id_main,  ---8132
                            'Y',---8132
                            l_acc_num, ---8132
                            p_batch_number,
                            z.ben_plan_id,
                            nvl(z.ben_plan_name, plan_name),
                            nvl(z.ben_plan_number, plan_number),
                            'FORM_5500_RENEW',
                            get_census_number(p_entrp_id, 'ACTIVE_PARTICIPANT')          active_participants,
                            get_census_number(p_entrp_id, 'RETIRED_SEP_BEN')             recv_benefits,
                            get_census_number(p_entrp_id, 'RETIRED_SEP_FUT_BEN')         future_benefits,
                            get_census_number(p_entrp_id, 'NO_OF_ELIGIBLE')              total_no_ee,
                            nvl(z.is_collective_plan, is_coll_plan),
                            sponsor_name,
                            sponsor_contact_name,
                            sponsor_email,
                            sponsor_tel_num,
                            sponsor_business_code,
                            sponsor_ein,
                            admin_name_sameas_sponsor_flag,
                            admin_name,
                            admin_contact_name,
                            admin_email,
                            admin_tel_num,
                            admin_business_code,
                            admin_ein_sameas_sponsor_flag,
                            admin_ein,
                            admin_addr,
                            admin_city,
                            admin_zip,
                            admin_state,
                            pre_sponsor_name_ein_flag,
                            previous_sponsor_name,
                            previous_sponsor_ein,
                            erisa_wrap_flag,
                            collective_plan_flag,
                            tot_price,
                            'I',
                            sysdate,
                            p_user_id,
                            null,
                            null,
                            l_enrollment_id,
                            nvl(z.plan_funding_code, plan_fund_code),
                            b.plan_benefit_code,
                             --to_char( Z.effective_date  ,'mm/dd/yyyy') ,  --8132
                            to_char(z.original_eff_date, 'mm/dd/yyyy'),    -- Added by Swamy for Ticket#11722
                            to_char(z.plan_start_date, 'mm/dd/yyyy'),  ---8132
                            to_char(z.plan_end_date, 'mm/dd/yyyy'),  ------ 8132
                            no_of_schedule_a_doc,
                            short_plan_year_flag,
                            extention_flag,
                            dfvc_program_flag,
                            other_feature_code,
                            last_employer_name,
                            last_plan_name,
                            last_ein,
                            last_plan_number,
                            erisa_wrap_plan_flag,
                            get_census_number(p_entrp_id, 'LAST_DAY_ACTIVE_PARTICIPANT') l_day_active_participants,
                            get_census_number(p_entrp_id, 'ENRD_EMP_1ST_DAY_NXT_PLN_YR') enrolled_empl_1st_day_pln_yr,
                            null, ----Next_Yr_Short_Plan_Year_Flag ,
                            to_char(z.plan_end_date + 1, 'mm/dd/yyyy'), --- Ticket #8039 rprabu  17/08/2019  8132
                            null, ----Next_Yr_Plan_End_Date ,
                               -----    to_char(add_months(b.plan_end_date+1, 12) ,'mm/dd/yyyy') , --- Ticket #8039 rprabu  17/08/2019
                            send_doc_later_flag
                        from
                            online_form_5500_plan_staging a,
                            ben_plan_enrollment_setup     b
                        where
                                b.entrp_id = p_entrp_id
                            and a.ben_plan_id (+) = b.ben_plan_id --- For Old Form_5500 Records
                            and b.ben_plan_id = nvl(l_prev_ben_plan_id, z.ben_plan_id)
                            and not exists (
                                select
                                    1
                                from
                                    plan_notices p
                                where
                                        p.entrp_id = p_entrp_id
                                    and b.ben_plan_id = p.entity_id
                                    and p.notice_type = 'FINAL_REPORT'
                            );   -- Added by Jaggi for Ticket#8080;

                    pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...l_prev_ben_plan_id ( after stage Insert) '
                    , l_prev_ben_plan_id);

            --------- UPDATE The Plan Admin Details From Main Tables...
                    for l_ctr in (
                        select
                            en_code,
                            entrp_code,
                            name,
                            contact_email,
                            contact_phone,
                            irs_business_code,
                            entrp_contact,
                            address,
                            city,
                            state,
                            zip
                        from
                            enterprise          a,
                            entrp_relationships b
                        where
                                a.entrp_id = b.entrp_id
                            and relationship_type = 'PLAN_ADMIN_ER'
                            and a.entrp_id = p_entrp_id
                    ) loop
                        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...UPDATE The Plan Admin Details From Main Tables. p_entrp_id ( after stage Insert) '
                        , p_entrp_id);
                        update online_form_5500_plan_staging
                        set
                            admin_ein = nvl(l_ctr.entrp_code, admin_ein),
                            admin_name = nvl(l_ctr.name, admin_name),
                            admin_email = nvl(l_ctr.contact_email, admin_email),
                            sponsor_tel_num = nvl(l_ctr.contact_phone, sponsor_tel_num),
                            admin_business_code = nvl(l_ctr.irs_business_code, admin_business_code),
                            admin_contact_name = nvl(l_ctr.entrp_contact, admin_contact_name),
                            admin_addr = nvl(l_ctr.address, admin_addr),
                            admin_city = nvl(l_ctr.city, admin_city),
                            admin_state = nvl(l_ctr.state, admin_state),
                            admin_zip = nvl(l_ctr.zip, admin_zip)
                        where
                                entrp_id = p_entrp_id
                            and ben_plan_id = z.ben_plan_id;

                    end loop;

              --------- UPDATE The Plan SPONCERS Details From Main Tables...
                    for l_ctr in (
                        select
                            en_code,
                            entrp_code,
                            name,
                            entrp_contact,
                            contact_email,
                            contact_phone,
                            entrp_email,
                            entrp_phones,
                            irs_business_code
                        from
                            enterprise          a,
                            entrp_relationships b
                        where
                                a.entrp_id = b.entrp_id
                            and relationship_type = 'PLAN_SPONSOR_ER'
                            and a.entrp_id = p_entrp_id
                    ) loop
                        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...UPDATE The Plan sponcers Details From Main Tables. p_entrp_id ( after stage Insert) '
                        , p_entrp_id);

                --------- UPDATE The Plan Spancer Details From Main Tables...
                        update online_form_5500_plan_staging
                        set
                            sponsor_ein = nvl(l_ctr.entrp_code, sponsor_ein),
                            sponsor_name = nvl(l_ctr.name, sponsor_name),
                            sponsor_email = nvl(l_ctr.contact_email, sponsor_email),
                            sponsor_tel_num = nvl(l_ctr.contact_phone, sponsor_tel_num),
                            sponsor_business_code = nvl(l_ctr.irs_business_code, sponsor_business_code),
                            sponsor_contact_name = nvl(l_ctr.entrp_contact, sponsor_contact_name)
                        where
                                entrp_id = p_entrp_id
                            and ben_plan_id = z.ben_plan_id;

                    end loop;

                    for y in (
                        select
                            quote_header_id_seq.nextval new_header_id,
                            quote_header_id             old_header_id,
                            payment_method,
                            total_quote_price,
                            l_renewed_plan_id,
                            p_user_id,
                            sysdate
                        from
                            ar_quote_headers
                        where
                                entrp_id = p_entrp_id
                            and ben_plan_id = nvl(l_prev_ben_plan_id, z.ben_plan_id)
                    ) ----8135
                     loop
                    /**Pricing Information **/
                        insert into ar_quote_headers_staging (
                            quote_header_id,
                            entrp_id,
                            payment_method,
                            total_quote_price,
                            ben_plan_id,
                            batch_number,
                            account_type,
                            enrollment_detail_id,
                            created_by,
                            creation_date
                        ) values ( y.new_header_id,
                                   p_entrp_id,
                                   y.payment_method,
                                   y.total_quote_price,
                                   null,
                                   p_batch_number,
                                   'FORM_5500',
                                   x_enrollment_detail_id,
                                   p_user_id,
                                   sysdate );

                        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...UPDATE The Plan sponcers Details From Main Tables. Y.New_header_id, ( after stage Insert) '
                        , y.new_header_id);
                        insert into ar_quote_lines_staging (
                            quote_line_id,
                            quote_header_id,
                            rate_plan_id,
                            rate_plan_detail_id,
                            line_list_price,
                            batch_number,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date
                        )
                            (
                                select
                                    compliance_quote_lines_seq.nextval,
                                    y.new_header_id,
                                    rate_plan_id,
                                    rate_plan_detail_id,
                                    line_list_price,
                                    p_batch_number,
                                    p_user_id,
                                    sysdate,
                                    p_user_id,
                                    sysdate
                                from
                                    ar_quote_lines
                                where
                                    quote_header_id = y.old_header_id
                            );

                        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...UPDATE The Plan sponcers Details From Main Tables. Y.old_header_id, ( after stage Insert) '
                        , y.old_header_id
                                                                                                                                                                                            || 'l_prev_ben_plan_id :='
                                                                                                                                                                                            || l_prev_ben_plan_id
                                                                                                                                                                                            )
                                                                                                                                                                                            ;

                   /*
                    FOR rec IN (SELECT  Notice_Type,Created_By
                                 FROM PLAN_NOTICES p
                                WHERE p.Entrp_Id  = P_Entrp_Id
                                  AND p.Entity_Type = 'BEN_PLAN_ENROLLMENT_SETUP'
                                  and not exists (select 1 from ONLINE_FORM_5500_PLAN_STAGING b where b.ben_plan_id = p.entity_id and p.notice_type = 'FINAL_REPORT' and b.entrp_id = p.entrp_id)   -- Added by Jaggi for Ticket#8080
                                  )
                    LOOP
                        INSERT INTO Plan_Notices_Stage
                          ( Plan_Notice_Id, batch_number, Entrp_id,    Entity_Id,
                            Entity_Type,  Notice_Type ,  Creation_Date,Created_By )
                          VALUES
                          ( Plan_Notice_Seq.Nextval, P_batch_number,p_entrp_id,
                            x_Enrollment_detail_id,'FORM_5500' ,rec.Notice_Type ,  Sysdate, rec.Created_By  );
							       pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...UPDATE The Plan sponcers Details From Main Tables. Y.old_header_id, ( after PLAN_NOTICES Insert) ', Y.old_header_id  );

                    END LOOP;
                   */
                        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data x_enrollment_detail_id :=', x_enrollment_detail_id
                        );
                     -- Commented above and added below by Swamy for Ticket#8080
                        for rec in (
                            select
                                r.enrollment_detail_id,
                                p.notice_type,
                                p.created_by
                            from
                                plan_notices                  p,
                                online_form_5500_plan_staging r
                            where
                                    p.entrp_id = p_entrp_id
                                and p.entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                                and r.ben_plan_id = nvl(p.ben_plan_id_pending, r.ben_plan_id)
                                and p.notice_type <> 'FINAL_REPORT'
                                and r.entrp_id = p.entrp_id
                                and r.batch_number = p_batch_number
                                and r.plan_type = 'FORM_5500_RENEW'
                                and r.enrollment_detail_id = x_enrollment_detail_id
                        ) loop
                            insert into plan_notices_stage (
                                plan_notice_id,
                                batch_number,
                                entrp_id,
                                entity_id,
                                entity_type,
                                notice_type,
                                creation_date,
                                created_by
                            ) values ( plan_notice_seq.nextval,
                                       p_batch_number,
                                       p_entrp_id,
                                       x_enrollment_detail_id,
                                       'FORM_5500',
                                       rec.notice_type,
                                       sysdate,
                                       rec.created_by );

                            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...UPDATE The Plan sponcers Details From Main Tables. Y.old_header_id, ( after PLAN_NOTICES Insert) '
                            , y.old_header_id);
                        end loop;

                  ------------plan_notices------
                        insert into benefit_codes_stage (
                            benefit_code_id,
                            benefit_code_name,
                            entrp_id,
                            entity_id,
                            entity_type,
                            description,
                            batch_number,
                            fully_insured_flag,
                            self_insured_flag,
                            creation_date,
                            created_by
                        )
                            (
                                select
                                    benefit_code_seq.nextval,
                                    benefit_code_name,
                                    p_entrp_id,
                                    x_enrollment_detail_id,
                                    'FORM_5500_PLAN_SETUP',
                                    description,
                                    p_batch_number,
                                    fully_insured_flag,
                                    self_insured_flag,
                                    sysdate,
                                    p_user_id
                                from
                                    benefit_codes
                                where
                                    entity_id = nvl(l_prev_ben_plan_id, z.ben_plan_id)
                            );

                        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...insert BENEFIT_CODES_STAGE from previous plan l_prev_ben_plan_id, ( after PLAN_NOTICES Insert) '
                        , l_prev_ben_plan_id);
                    end loop;

                end if;  --- l_rec_count
            end loop;

      --------------------------------------------------------------------------
      /** benefit Codes **/
      ---    pc_log.log_error('In Populate renewal..AR Quote','Benefit Codes');
      /* Create Contacts Broker data */
 /*     BEGIN
        SELECT  broker_id
        INTO l_cnt_contact
        FROM emp_overview_v
        WHERE entrp_id = p_entrp_id;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      END;

      --For contacts which did not get craeted thru online enrollment
      IF l_cnt_contact <> 0 THEN
        INSERT
        INTO CONTACT_LEADS
				( Contact_Id ,
				First_Name ,
				Entity_Id ,
				Entity_Type ,
				Ref_Entity_Type ,
				Email ,
				Contact_Type,
				User_Id,
				Phone_Num,
				Contact_Fax,
				Account_Type,
				Lic_Number,
                prefetched_flg
          )
        SELECT   CONTACT_SEQ.NEXTVAL ,
                      First_Name||Last_Name ,
                      Pc_Entrp.Get_Tax_Id(P_Entrp_Id) ,
                      'ENTERPRISE' ,
                      'BEN_PLAN_RENEWALS' ,
                      broker_email ,
                      'BROKER' ,
                       P_User_Id ,
                        Broker_Phone ,
                        Null ,
                        'FORM_5500' ,
                      Broker_Lic,
                      'Y'
        FROM TABLE(Pc_Broker.Get_Broker_Info(L_Cnt_Contact));
      END IF;
  pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...insert broker   L_Cnt_Contact :  ',  L_Cnt_Contact  );

      BEGIN
        -- GA Contact
        SELECT  COUNT(*)
        INTO l_cnt_ga
        FROM CONTACT
        WHERE entity_id     = Pc_Entrp.get_tax_id(p_entrp_id)
        AND entity_type     = 'ENTERPRISE'
        AND contact_type     = 'ENTERPRISE'
        AND account_type    = 'FORM_5500'
        AND contact_id NOT IN
          (SELECT  contact_id FROM CONTACT_LEADS WHERE account_type = 'FORM_5500'
          );
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      END;

  pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...insert GA Contact   L_Cnt_Contact :  ',  p_entrp_id  );

      --If we old conatcts for old ER's which are not in contact leads, we are doing an entry in leads table
      IF l_cnt_ga <> 0 THEN

        BEGIN
          SELECT  GA_LIC INTO l_GA_LIC
          FROM TABLE(Pc_Broker.Get_GA_Info(p_entrp_id));
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                 NULL;
        END;

  pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...insert GA Contact   L_Cnt_Contact :  ',  L_Cnt_Contact  );

         INSERT INTO CONTACT_LEADS
                    ( Contact_Id ,
                      First_Name ,
                      Entity_Id ,
                      Entity_Type ,
                      Ref_Entity_Type ,
                      Email ,
                      Contact_Type,
                      User_Id,
                      Phone_Num,
                      Contact_Fax,
                      Account_Type,
                      Lic_Number ,
                      prefetched_flg)
        SELECT  CONTACT_SEQ.NEXTVAL ,
                     	first_name ||last_name ,pc_entrp.get_tax_id(p_entrp_id) ,
                    'ENTERPRISE' ,
                    'BEN_PLAN_RENEWALS'  --Helps distinguish between recorsd already present AND onez that are newly craeted during renewals
                    ,email ,
                  	 'GA',
                     p_user_id,
                     phone,
                      NULL ,
                      'FORM_5500',
                    	L_Ga_Lic,
                        'Y'
         FROM  Table(Pc_Contact.Get_Contact_Info(Pc_Entrp.Get_Tax_Id(P_Entrp_Id),'GA'));

      END IF;

*/

       -- Commented above code and Added Below code by Swamy
        -- Added by Swamy for Ticket#9221 on 22/06/2020
        -- There is no provision to add Primary contact during Renewal through Online, but the system checks for atleast one primary contact exists in contact_leads
        -- Table, so inserting only Primary contacts.
            insert into contact_leads (
                contact_id,
                first_name,
                entity_id,
                entity_type,
                ref_entity_type,
                email,
                contact_type,
                user_id,
                phone_num,
                contact_fax,
                account_type,
                prefetched_flg
            )
                select
                    contact_id,
                    first_name || last_name,
                    entity_id,
                    entity_type,
                    entity_type,
                    email,
                    contact_type,
                    user_id,
                    phone,
                    fax,
                    account_type,
                    'Y'
                from
                    contact
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and contact_type = 'PRIMARY'
                    and account_type = 'FORM_5500'
                    and contact_id not in (
                        select
                            contact_id
                        from
                            contact_leads
                        where
                                entity_id = pc_entrp.get_tax_id(p_entrp_id)
                            and account_type = 'FORM_5500'
                            and contact_type = 'PRIMARY'
                    );

        --Added below by Swamy for Ticket#9239
            delete from contact_leads
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and entity_type = 'ENTERPRISE'
                and contact_type in ( 'GA', 'BROKER' )
                and account_type = 'FORM_5500';

            pc_web_er_renewal.upsert_contact_leads(
                p_entrp_id      => p_entrp_id,
                p_user_id       => p_user_id,
                p_ben_plan_id   => l_prev_ben_plan_id,
                p_account_type  => 'FORM_5500',
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data ...insert GA Contact   L_Cnt_Contact :  ', p_entrp_id);
    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.populate_renewal_data Exception : ', sqlerrm);
            rollback;
    end populate_renewal_data;
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
---    /*Ticket#7015.FORM_5500 reconstruction */   New function Done by RPRABU 05/12/2018
    function get_form_5500_inv_bank_info (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_enrollment_id in number,
        p_account_type  in varchar2
    ) return tbl_online_form_5500_staging
        pipelined
    is
        rec             typ_tbl_online_form_5500_staging;--Online_Form_5500_Staging%Rowtype;
        x_error_message varchar2(300);
        x_error_status  varchar2(20);
    begin
        for i in (
            select
                *
            from
                online_form_5500_staging
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and enrollment_id = nvl(p_enrollment_id, enrollment_id)
        ) loop
            rec.entrp_id := i.entrp_id;
            rec.batch_number := i.batch_number;
            rec.enrollment_id := i.enrollment_id;
    --  Rec.Bank_Name                    := I.Bank_Name ;
    --  Rec.Routing_Number               := I.Routing_Number ;
    --  Rec.Bank_Acc_Num                 := I.Bank_Acc_Num;
    --  Rec.Bank_Acc_Type                := I.Bank_Acc_Type;
   --   Rec.Acct_Usage                   := I.Acct_Usage ;
            rec.credit_payment_monthly_pre := i.credit_payment_monthly_pre;
            rec.payment_method := i.payment_method;
            rec.acct_payment_fees := i.acct_payment_fees;
            rec.grand_total_price := i.grand_total_price;
            rec.send_invoice := i.send_invoice;
            rec.pay_acct_fees := i.pay_acct_fees;
            rec.salesrep_id := i.salesrep_id;
            rec.salesrep_flag := i.salesrep_flag;
     -- Rec.Bank_Authorize               := I.Bank_Authorize ;       -- Added by Jaggi ##9602
      -- Added by Swamy for Ticket#12662
            for bank_stage in (
                select
                    bank_name,
                    bank_routing_num,
                    bank_acct_num,
                    bank_acct_type,
                    acct_usage,
                    business_name,
                    giac_verify,
                    giac_authenticate,
                    giac_response,
                    user_bank_acct_stg_id,
                    bank_status,
                    bank_authorize
                from
                    user_bank_acct_staging
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number
            ) loop
                rec.bank_name := bank_stage.bank_name;
                rec.routing_number := bank_stage.bank_routing_num;
                rec.bank_acc_num := bank_stage.bank_acct_num;
                rec.bank_acc_type := bank_stage.bank_acct_type;
                rec.acct_usage := bank_stage.acct_usage;
                rec.business_name := bank_stage.business_name;
                rec.giac_verify := bank_stage.giac_verify;
                rec.giac_authenticate := bank_stage.giac_authenticate;
                rec.giac_response := bank_stage.giac_response;
                rec.bank_acct_stg_id := bank_stage.user_bank_acct_stg_id;
                rec.bank_status := bank_stage.bank_status;
                rec.bank_authorize := bank_stage.bank_authorize;
            end loop;

            pipe row ( rec );
        end loop;
    exception
        when others then
            x_error_message := 'In Upsert_form_5500_Plan_staging when others : ' || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.Get_FORM_5500_INV_BANK_INFO ', sqlerrm);
    end get_form_5500_inv_bank_info;
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    procedure update_form_5500_inv_bank_info (
        p_batch_number               in varchar2,
        p_entrp_id                   in number,
        p_salesrep_flag              in varchar2,                  -- Ticket #6882
        p_salesrep_id                in number,
        p_invoice_flag               in varchar2,
        p_credit_payment_monthly_pre in varchar2,
        p_payment_method             in varchar2,
        p_acct_payment_fees          in varchar2,                 -- added by rprabu 30/07/2019
        p_page_validity              in varchar2,
        p_source                     in varchar2 default null,    -- Added by Swamy for Ticket#9324 on 16/07/2020
        p_user_id                    in number,           -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        x_error_status               out varchar2,
        x_error_message              out varchar2
    ) is

        l_salesrep_flag         varchar2(1);
        l_salesrep_id           number;
        l_page_validity         varchar2(1);
        l_acct_type             varchar2(20);
        l_entity_type           varchar2(100);
        l_broker_id             number;
        x_user_bank_acct_stg_id number;
        l_account_type          varchar2(100);
        l_bank_status           varchar2(100);
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_INVOICE_BANK_INFO', 'In Proc');
     -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        pc_broker.get_broker_id(
            p_user_id     => p_user_id,
            p_entity_type => l_entity_type,
            p_broker_id   => l_broker_id
        );

        l_entity_type := nvl(l_entity_type, 'EMPLOYER');
        l_account_type := pc_account.get_account_type_from_entrp_id(p_entrp_id);
        if p_salesrep_flag = 'Y' then
            l_salesrep_id := p_salesrep_id;
        elsif p_salesrep_flag = 'N'
        or p_salesrep_flag is null then
            l_salesrep_id := null;
        end if;

        pc_employer_enroll.upsert_page_validity(
            p_batch_number  => p_batch_number,
            p_entrp_id      => p_entrp_id,
            p_account_type  => 'FORM_5500',
            p_page_no       => '2',
            p_block_name    => 'INVOICING_PAYMENT',
            p_validity      => p_page_validity, -- 'I',
            p_user_id       => null,
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );

        begin
            update online_form_5500_staging
            set
                salesrep_id = l_salesrep_id,
                salesrep_flag = p_salesrep_flag,
                send_invoice = p_invoice_flag,
                credit_payment_monthly_pre = p_credit_payment_monthly_pre,
                payment_method = p_payment_method,
                acct_payment_fees = p_acct_payment_fees
             --Bank_Authorize             = P_Bank_Authorize
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id;

      --- p_invoice_flag is send invoice option 19/09/2018
            update contact_leads
            set
                send_invoice = p_invoice_flag
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and account_type = 'FORM_5500';

        exception
            when no_data_found then
                null;
        end;

        if p_page_validity = 'V' then
            pc_employer_enroll.validate_contact(null, p_entrp_id, p_batch_number, 'FORM_5500', p_source);   -- Added by Swamy for Ticket#9324 on 16/07/2020
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_INVOICE_BANK_INFO call validate_contact ', p_invoice_flag);
        end if;

    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_FORM_5500_INV_BANK_INFO', 'Error ' || sqlerrm);
    end update_form_5500_inv_bank_info;

---    /*Ticket#7015.FORM_5500 reconstruction */    New function Done by RPRABU 05/12/2018
/*  Procedure Update_Form_5500_Inv_Bank_Info(
      P_Batch_Number                In VARCHAR2 ,
      P_Entrp_Id                    In Number,
      P_Salesrep_Flag               In VARCHAR2,                  -- Ticket #6882
      P_Salesrep_Id                 In Number,
      P_Invoice_Flag                In VARCHAR2,
      P_Credit_Payment_Monthly_Pre  In VARCHAR2,
      P_Bank_Name                   In VARCHAR2,
      P_Account_Type                In VARCHAR2,
      P_Routing_Num                 In VARCHAR2,
      P_Account_Num                 In VARCHAR2,
      P_Acct_Usage                  In VARCHAR2,
      P_Payment_Method              In VARCHAR2,
      p_Acct_Payment_Fees           IN VARCHAR2,                 -- added by rprabu 30/07/2019
	  P_Page_Validity               In VARCHAR2,
	  p_source                      IN VARCHAR2 DEFAULT NULL,    -- Added by Swamy for Ticket#9324 on 16/07/2020
      P_Bank_Authorize              IN VARCHAR2,                 -- Added by Jaggi ##9602
	  p_user_id                     In Number,           -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
      p_giac_response               IN VARCHAR2,   -- Added by Swamy for Ticket#12527 
      p_giac_verify                 IN VARCHAR2,   -- Added by Swamy for Ticket#12527 
      p_giac_authenticate           IN VARCHAR2,   -- Added by Swamy for Ticket#12527 
      p_bank_acct_verified          IN VARCHAR2,   -- Added by Swamy for Ticket#12527 
      p_business_name               IN VARCHAR2,   -- Added by Swamy for Ticket#12527 
      p_existing_bank_flag          IN VARCHAR2,   -- Added by Swamy for Ticket#12527
      p_Bank_acct_stg_Id            IN NUMBER,     -- Added by Swamy for Ticket#12527
      p_bank_acct_id                IN NUMBER,     -- Added by Swamy for Ticket#12527
      x_bank_status                 Out VARCHAR2,  -- Added by Swamy for Ticket#12527 
      x_bank_status_message         Out VARCHAR2,  -- Added by Swamy for Ticket#12527 
      X_Error_Status                Out VARCHAR2,
      X_Error_Message               Out VARCHAR2 )
  IS
    L_Salesrep_flag         VARCHAR2(1);
    L_salesrep_id           NUMBER;
    l_page_validity         VARCHAR2(1);
    l_acct_type             VARCHAR2(20);
    l_entity_type           VARCHAR2(100);
    l_broker_id             NUMBER;
	l_User_Bank_acct_stg_Id NUMBER := p_Bank_acct_stg_Id;   -- Added by Swamy for Ticket#12527
    X_User_Bank_acct_stg_Id NUMBER;
    l_account_type          VARCHAR2(100);
    l_bank_status           VARCHAR2(20);
  BEGIN
    pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_INVOICE_BANK_INFO','In Proc');
     -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
    pc_broker.get_broker_id(p_user_id    => p_user_id ,
                        p_entity_type => l_entity_type,
						p_broker_id  => l_broker_id);

    l_entity_type := NVL(l_entity_type,'EMPLOYER');
    l_account_type := pc_account.get_account_type_from_entrp_id(P_Entrp_Id);

    IF P_Salesrep_flag    = 'Y' THEN
      L_salesrep_id      := p_salesrep_id;
    Elsif P_Salesrep_flag = 'N' OR P_Salesrep_flag IS NULL THEN
      L_salesrep_id      := NULL;
    END IF;
    Pc_Employer_Enroll.Upsert_Page_Validity(P_Batch_Number 		=> P_Batch_Number,
											P_Entrp_Id 		    => P_Entrp_Id,
											P_Account_Type 		=> 'FORM_5500',
											P_Page_No		    => '2',
											P_Block_Name	    => 'INVOICING_PAYMENT',
											P_Validity		    => p_page_validity, -- 'I',
											P_User_Id		    => NULL,
											X_Error_Status	    => X_Error_Status,
											X_Error_Message		=> X_Error_Message ) ;
    BEGIN
      UPDATE Online_Form_5500_Staging
         SET salesrep_id                = L_salesrep_id,
             Salesrep_flag              = P_Salesrep_flag,
             Send_invoice               = p_invoice_flag,
             credit_payment_monthly_pre = p_credit_payment_monthly_pre,
             bank_name                  = p_bank_name,
             routing_number             = p_routing_num,
             bank_acc_num               = p_account_num ,
             bank_acc_type              = p_account_type,
             acct_usage                 = p_acct_usage,
             payment_method             = p_payment_method,
             Acct_Payment_Fees          = p_Acct_Payment_Fees,
             Bank_Authorize             = P_Bank_Authorize
       WHERE batch_number               = p_batch_number
         AND entrp_id                   = p_entrp_id;

     -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
    IF l_entity_type IN ('BROKER','EMPLOYER')  THEN
         -- Commented by Swamy for Ticket#12527
        /*FOR j IN (SELECT User_Bank_acct_stg_Id
                    FROM User_Bank_acct_Staging
                   WHERE batch_number = p_batch_number
                     AND entrp_id = p_entrp_id
                     AND nvl(renewed_by,'EMPLOYER') = l_entity_type) LOOP
              l_User_Bank_acct_stg_Id := j.User_Bank_acct_stg_Id;
        END LOOP;
		*/

/*       Pc_Log.Log_Error('pc_employer_enroll.set_payment',' calling pc_employer_enroll.Upsert_Bank_Info ');
       pc_employer_enroll.Upsert_Bank_Info(
          P_User_Bank_acct_stg_Id => l_User_Bank_acct_stg_Id,
          P_Entrp_Id              => P_Entrp_Id,
          P_Batch_Number          => P_Batch_Number,
          P_Account_Type          => l_account_type,
          P_Acct_usage            => p_acct_usage,
          P_Display_Name          => p_bank_name,
          P_Bank_Acct_Type        => p_account_type,
          P_Bank_Routing_Num      => p_routing_num,
          P_Bank_Acct_Num         => p_routing_num,
          P_Bank_Name             => p_bank_name,
          p_user_id               => p_user_id,
          P_validity              => NVL(p_page_validity,'V'),
          P_Bank_Authorize        => P_Bank_Authorize,
          p_giac_response         => p_giac_response,   -- Added by Swamy for Ticket#12527 
          p_giac_verify           => p_giac_verify,   -- Added by Swamy for Ticket#12527 
          p_giac_authenticate     => p_giac_authenticate,   -- Added by Swamy for Ticket#12527 
          p_bank_acct_verified    => p_bank_acct_verified,   -- Added by Swamy for Ticket#12527 
          p_business_name         => p_business_name,   -- Added by Swamy for Ticket#12527 
          p_annual_optional_remit => NULL,   -- Added by Swamy for Ticket#12534 
          p_existing_bank_flag    => p_existing_bank_flag, --'N',     -- Added by Swamy for Ticket#12527
          p_bank_acct_id          => p_bank_acct_id,       -- Added by Swamy for Ticket#12527
          X_User_Bank_acct_stg_Id => X_User_Bank_acct_stg_Id,
          x_bank_status           => l_bank_status,    -- Added by Swamy for Ticket#12534 
          X_ERROR_STATUS          => X_ERROR_STATUS,
          X_ERROR_MESSAGE         => X_ERROR_MESSAGE);

          IF NVL(x_error_status,'*') = 'E' THEN
            l_page_validity := 'I';
            x_bank_status := l_bank_status;              -- Added by Swamy for Ticket#12527       
            x_bank_status_message := X_ERROR_MESSAGE;    -- Added by Swamy for Ticket#12527 
          ELSE
            l_page_validity := NVL(p_page_validity,'V');
            x_bank_status := l_bank_status;              -- Added by Swamy for Ticket#12527       
            x_bank_status_message := X_ERROR_MESSAGE;    -- Added by Swamy for Ticket#12527 
         END IF;

       Pc_Log.Log_Error('pc_employer_enroll.set_payment',' calling pc_employer_enroll.upsert_page_validity '||' l_page_validity :='||l_page_validity);
          pc_employer_enroll.upsert_page_validity
                             (p_batch_number => p_batch_number,
                              p_entrp_id     => p_entrp_id,
                              p_account_type => 'FORM_5500',
                              p_page_no      => '3',
                              p_block_name   => 'INVOICING_PAYMENT',
                              p_validity     => l_page_validity,
                              p_user_id      => p_user_id,
                              x_error_status => x_error_status,
                              x_error_message => x_error_message ) ;
    END IF;
     -- End of Ticket#10993(Dev Ticket#10747)

      --- p_invoice_flag is send invoice option 19/09/2018
      UPDATE CONTACT_LEADS
         SET SEND_INVOICE = p_invoice_flag
       WHERE entity_id  = PC_ENTRP.GET_TAX_ID(p_entrp_id)
         AND Account_Type = 'FORM_5500';
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    END;

    IF p_page_validity ='V' THEN
      PC_EMPLOYER_ENROLL.validate_contact(NULL,P_Entrp_Id,P_Batch_Number, 'FORM_5500',p_source);   -- Added by Swamy for Ticket#9324 on 16/07/2020
      pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_INVOICE_BANK_INFO call validate_contact ',p_invoice_flag);
    END IF;
    --- End If;
  EXCEPTION
  WHEN OTHERS THEN
    x_error_message := SQLCODE || ' ' || SQLERRM;
    x_error_status      := 'E';
    pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_FORM_5500_INV_BANK_INFO','Error '||SQLERRM);
   END UPDATE_FORM_5500_INV_BANK_INFO;
*/
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function get_census_number (
        p_entrp_id    number,
        p_census_code varchar2
    ) return number is
        l_census_numbers number(5);
        x_error_message  varchar2(300);
        x_error_status   varchar2(20);
    begin
        begin
            select
                census_numbers
            into l_census_numbers
            from
                enterprise_census
            where
                    census_code = p_census_code
                and entity_id = p_entrp_id
                and rownum < 2;

        exception
            when no_data_found then
                l_census_numbers := 0;
        end;

        return l_census_numbers;
    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL.Get_Census_number ', 'Error ' || sqlerrm);
    end get_census_number;

----------7998 done by swamy on 29/08/2019
    function get_rate_codes return get_rate_type_row_t
        pipelined
        deterministic
    is
        l_record get_rate_type_row;
    begin
        for x in (
            select
                a.rate_plan_id,
                b.rate_plan_detail_id                        as param_id,
                a.rate_plan_name                             as param,
                b.coverage_type                              code,
                b.description,
                ltrim(to_char(b.rate_plan_cost, '99999.99')) as fee
            from
                rate_plans       a,
                rate_plan_detail b
            where
                    a.rate_plan_id = b.rate_plan_id
                and a.rate_plan_name = 'FORM_5500_STANDARD_FEES'
                and a.account_type = 'FORM_5500'
                and upper(b.coverage_type) not in ( 'HEALTH_FRM_WI_ERISSA' )   -- Added by Swamy for Ticket#12009 25012024
                and nvl(b.effective_end_date, sysdate) >= sysdate
        ) loop
            l_record.rate_plan_id := x.rate_plan_id;
            l_record.param_id := x.param_id;
            l_record.param := x.param;
            l_record.code := x.code;
            l_record.description := x.description;
            l_record.fee := x.fee;
            if upper(x.code) = 'HEALTH_FRM' then
                l_record.order_id := '2';
            elsif upper(x.code) = 'HEALTH_FRM_WO_ERISSA' then
                l_record.order_id := '3';
	  -- ELSIF UPPER(X.Code) = 'HEALTH_FRM_WI_ERISSA' THEN   -- Commented by Swamy for Ticket#12009 25012024
	   --   L_Record.Order_Id := '1';
            elsif upper(x.code) = 'PLAN_FORM' then
                l_record.order_id := '4';
            elsif upper(x.code) = 'HRA_ACCOUNT_FORM' then
                l_record.order_id := '5';
            elsif upper(x.code) = 'EXT_OF_FILE' then
                l_record.order_id := '6';
            elsif upper(x.code) = 'INSUFF_FILLING' then
                l_record.order_id := '7';
            elsif upper(x.code) = 'AMEND_FORM550_BY_STERLING' then -- Added by Jaggi #11571
                l_record.order_id := '8';
            elsif upper(x.code) = 'AMEND_FORM550_NOT_BY_STERLING' then -- Added by Jaggi #11571
                l_record.order_id := '9';
            elsif upper(x.code) = 'FINAL_REPORT' then
                l_record.order_id := '10';
            end if;

            pipe row ( l_record );
        end loop;
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm;
            pipe row ( l_record );
    end get_rate_codes;
      ----------7998 END done by swamy on 29/08/2019
-- Added by Joshi for 8471. To get the COBRA fee infor
    function get_cobra_fee (
        p_no_of_eligible number,
        p_fee_schedule   varchar2
    ) return cobra_fee_record_t
        pipelined
        deterministic
    is
        l_record cobra_fee_row_t;
    begin
        for x in (
            select
                a.rate_plan_id,
                rate_plan_detail_id                        as param_id,
                rate_plan_name                             as param,
                coverage_type,
                minimum_range,   --- 3933 rprabu 02/07/2019
                maximum_range,   --- 3933 rprabu 02/07/2019
                minimum_range
                || '-'
                || maximum_range                           as range,
                ltrim(to_char(rate_plan_cost, '99999.99')) as fee,
                1                                          sequence_no
            from
                rate_plans       a,
                rate_plan_detail b
            where
                    a.rate_plan_id = b.rate_plan_id
                and a.rate_plan_name = 'COBRA_STANDARD_FEES'
                and account_type = 'COBRA'
                and coverage_type = 'MAIN_COBRA_SERVICE'
                and rate_code = decode(p_fee_schedule, 'A', '30', 'M', '182')
                and nvl(p_no_of_eligible, 0) between b.minimum_range and nvl(b.maximum_range, 100000)
            union
            select
                a.rate_plan_id,
                rate_plan_detail_id                        as param_id,
                rate_plan_name                             as param,
                coverage_type,
                minimum_range,   --- 3933 rprabu 02/07/2019
                maximum_range,   --- 3933 rprabu 02/07/2019
                minimum_range
                || '-'
                || maximum_range                           as range,
                ltrim(to_char(rate_plan_cost, '99999.99')) as fee,
                2                                          sequence_no
            from
                rate_plans       a,
                rate_plan_detail b
            where
                    a.rate_plan_id = b.rate_plan_id
                and a.rate_plan_name = 'COBRA_STANDARD_FEES'
                and account_type = 'COBRA'
                and coverage_type = 'OPEN_ENROLLMENT_SUITE'
                and nvl(p_no_of_eligible, 0) between b.minimum_range and nvl(b.maximum_range, 100000)
            union
            select
                a.rate_plan_id,
                rate_plan_detail_id                        as param_id,
                rate_plan_name                             as param,
                coverage_type,
                minimum_range,   --- 3933 rprabu 02/07/2019
                maximum_range,   --- 3933 rprabu 02/07/2019
                minimum_range
                || '-'
                || maximum_range                           as range,
                ltrim(to_char(rate_plan_cost, '99999.99')) as fee,
                3                                          sequence_no
            from
                rate_plans       a,
                rate_plan_detail b
            where
                    a.rate_plan_id = b.rate_plan_id
                and a.rate_plan_name = 'COBRA_STANDARD_FEES'
                and account_type = 'COBRA'
                and coverage_type = 'OPTIONAL_COBRA_SERVICE_CN'
                and nvl(p_no_of_eligible, 0) between b.minimum_range and nvl(b.maximum_range, 100000)
            union
            select
                a.rate_plan_id,
                rate_plan_detail_id                        as param_id,
                rate_plan_name                             as param,
                coverage_type,
                minimum_range,   --- 3933 rprabu 02/07/2019
                maximum_range,   --- 3933 rprabu 02/07/2019
                minimum_range
                || '-'
                || maximum_range                           as range,
                ltrim(to_char(rate_plan_cost, '99999.99')) as fee,
                4                                          sequence_no
            from
                rate_plans       a,
                rate_plan_detail b
            where
                    a.rate_plan_id = b.rate_plan_id
                and a.rate_plan_name = 'COBRA_STANDARD_FEES'
                and account_type = 'COBRA'
                and coverage_type = 'OPTIONAL_COBRA_SERVICE_SC'
            order by
                sequence_no
        ) loop
            l_record.rate_plan_id := x.rate_plan_id;
            l_record.rate_plan_detail_id := x.param_id;
            l_record.rate_plan_name := x.param;
            l_record.coverage_type := x.param;
            l_record.min_range := x.minimum_range;   --- 3933 rprabu 02/07/2019
            l_record.max_range := x.maximum_range;   --- 3933 rprabu 02/07/2019
            l_record.range := x.range;
            l_record.fee := x.fee;
            l_record.coverage_type := x.coverage_type;
            pipe row ( l_record );
        end loop;
    end get_cobra_fee;
   -----------------Ticket#9392	 rprabu 29/09/2020
    procedure upsert_cobra_staging_comp_info (
        p_entrp_id      in number,
        p_batch_number  in number,
        p_eff_date      in varchar2,
        p_page_validity in varchar2,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
        l_count number := 0;
    begin
        pc_log.log_error('UPSERT_COBRA_STAGING_COMP_INFO', ' ..Validity' || p_page_validity);
        update online_compliance_staging
        set
            effective_date = p_eff_date
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;
   --- added by rprabu for validations based on   page_validity table 9392 ticket implemention
        pc_employer_enroll.upsert_page_validity(
            p_batch_number  => p_batch_number,
            p_entrp_id      => p_entrp_id,
            p_account_type  => 'COBRA',
            p_page_no       => '1',
            p_block_name    => 'COMPANY_INFORMATION',  -- 8014 rprabu 12/08/2019
            p_validity      => p_page_validity,
            p_user_id       => p_user_id,
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );

    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_COBRA_STAGING_COMP_INFO', sqlerrm);
    end upsert_cobra_staging_comp_info;

    procedure upsert_cobra_staging (
        p_entrp_id            in number,
        p_batch_number        in number,
        p_tot_ees             in number,
        p_eff_date            in varchar2,
        p_rate_plan_id        in varchar2_tbl,
        p_rate_plan_detail_id in varchar2_tbl,
        p_rate_plan_name      in varchar2_tbl,
        p_list_price          in varchar2_tbl,
        p_tot_price           in number default null,
        p_user_id             in number,
        p_page_validity       in varchar2,
        p_billing_frequency   in varchar2,         -- 02/19/2020 Jagadeesh #8471
        p_carrier_notify      in varchar2,         -- 02/19/2020 Jagadeesh #8471
        x_error_status        out varchar2,
        x_error_message       out varchar2
    ) is

        l_header_id      number;
        l_count          number;
        v_no_of_eligible varchar2(100);   -- Added by Swamy for Ticket#7606
        l_page_validity  varchar2(10);          --9392 rprabu  12/10/2020
        l_carrier_info   number := 0;  ---------rprabu 03/12/2020  Ticket #9442
        l_source         varchar2(10);  -- Added by Swamy for Ticket#11364
    begin
        pc_log.log_error('COBRAStaging', 'Loop..Validity'
                                         || p_page_validity
                                         || ' P_BATCH_NUMBER :='
                                         || p_batch_number);
    -- Added max(upper(source)) by Swamy for Ticket#11364
        select
            count(*),
            max(upper(source))
        into
            l_count,
            l_source
        from
            online_compliance_staging
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

    -- Start Added by Swamy for Ticket#7606
    /*
    FOR i IN 1..p_rate_plan_id.COUNT
      LOOP
        IF p_rate_plan_detail_id(i) IS NOT NULL THEN
           FOR J IN (SELECT maximum_range
                                    FROM rate_plan_detail
                                   WHERE rate_plan_id = p_rate_plan_id(i)
                                     AND rate_plan_detail_id = p_rate_plan_detail_id(i)
                                     AND coverage_type ='MAIN_COBRA_SERVICE') LOOP
             v_No_OF_Eligible := j.maximum_range;
           END LOOP;
        END IF;
      END LOOP;
       -- End of Addition by Swamy for Ticket#7606 */

    /* Header Record */
        pc_log.log_error('COBRAStaging', 'Loop' || l_count);
        if l_count = 0 then
      /* new rec */
            insert into online_compliance_staging (
                record_id,
                entrp_id,
         -- NO_OFF_EES ,
                no_of_eligible,       -- Added by Swamy for Ticket#7606
                effective_date,
                batch_number,
                carrier_notify_flag,  -- ADDED BY Jagadeesh
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                inactive_plan_flag   -- Added by Joshi for 10430
            ) values ( compliance_staging_seq.nextval,
                       p_entrp_id,
         -- p_tot_ees,
                       p_tot_ees,    -- Added by Swamy for Ticket#7606
                       p_eff_date,
                       p_batch_number,
                       p_carrier_notify,     -- ADDED BY Jagadeesh
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate,
                       nvl(
                           pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
                           'N'
                       ) );

            pc_log.log_error('COBRAStaging', 'After Insert..1');
    --- added by rprabu for validations based on   page_validity table 9392 ticket implemention
            if p_eff_date is not null then  ----Trunc(sysdate)   <   to_Date(p_eff_date, 'mm/dd/yyyy')   Then Ticket# 9549 rprabu
                l_page_validity := 'V';
            else
                l_page_validity := 'I';
            end if;
     -- For Cobra Renewal COMPANY_INFORMATION is not used.
            if l_source <> 'RENEWAL' then  -- Added for Prod Ticket#11612 by Swamy
                pc_employer_enroll.upsert_page_validity(
                    p_batch_number  => p_batch_number,
                    p_entrp_id      => p_entrp_id,
                    p_account_type  => 'COBRA',
                    p_page_no       => '1',
                    p_block_name    => 'COMPANY_INFORMATION',
                    p_validity      => l_page_validity,
                    p_user_id       => p_user_id,
                    x_error_status  => x_error_status,
                    x_error_message => x_error_message
                );
            end if;

      /* Plan Options */
            insert into ar_quote_headers_staging (
                quote_header_id,
                total_quote_price,
                entrp_id,
                batch_number,
                billing_frequency,            -- added by Jagadeesh #8471
                account_type,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date
            ) values ( compliance_quote_seq.nextval,
                       p_tot_price,
                       p_entrp_id,
                       p_batch_number,
                       p_billing_frequency,          -- added by Jagadeesh #8471
                       'COBRA',
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate ) returning quote_header_id into l_header_id;

            pc_log.log_error('COBRAStaging', 'After Insert');
            for i in 1..p_rate_plan_id.count loop
                pc_log.log_error('COBRAStaging loop ',
                                 'After Insert p_rate_plan_id(i) :='
                                 || p_rate_plan_id(i)
                                 || 'p_rate_plan_detail_id(i) :='
                                 || p_rate_plan_detail_id(i)
                                 || 'p_rate_plan_name(i) :='
                                 || p_rate_plan_name(i)
                                 || 'p_list_price(i) :='
                                 || p_list_price(i));

                if p_rate_plan_detail_id(i) is not null then
                    insert into ar_quote_lines_staging (
                        quote_line_id,
                        quote_header_id,
                        rate_plan_id,
                        rate_plan_detail_id,
                        rate_plan_name,
                        line_list_price,
                        batch_number,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date
                    ) values ( compliance_quote_lines_seq.nextval,
                               l_header_id,
                               p_rate_plan_id(i),
                               p_rate_plan_detail_id(i),
                               p_rate_plan_name(i),
                               p_list_price(i),
                               p_batch_number,
                               p_user_id,
                               sysdate,
                               p_user_id,
                               sysdate );

                end if;

            end loop;

        else
      /* Update Record */
            pc_log.log_error('COBRAStaging', 'Update' || p_batch_number);
            pc_log.log_error('COBRAStaging', 'Update' || p_entrp_id);
      -- 02/19/2020 -- ADDED BY Jagadeesh
            if p_carrier_notify = 'N' then
                update compliance_plan_staging
                set
                    carrier_contact_name = null,
                    carrier_contact_email = null,
                    carrier_phone_no = null,
                    carrier_addr = null,
                    policy_number = null,
                    carrier_name = null
                where
                        batch_number = p_batch_number
                    and entity_id = p_entrp_id;

            end if;

            update online_compliance_staging
            set
                carrier_notify_flag = p_carrier_notify,   -- ADDED BY Jagadeesh
                no_of_eligible = p_tot_ees,   -- Added by Swamy for Ticket#7606
                effective_date = p_eff_date
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number;

           /* Plan Options */
      -- Added for Prod Ticket#11612 by Swamy
            delete from ar_quote_headers_staging
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id;

            pc_log.log_error('COBRAStaging loop ', 'After update p_entrp_id) :='
                                                   || p_entrp_id
                                                   || 'p_tot_price :='
                                                   || p_tot_price
                                                   || 'p_billing_frequency :='
                                                   || p_billing_frequency);

            insert into ar_quote_headers_staging (
                quote_header_id,
                total_quote_price,
                entrp_id,
                batch_number,
                billing_frequency,            -- added by Jagadeesh #8471
                account_type,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date
            ) values ( compliance_quote_seq.nextval,
                       p_tot_price,
                       p_entrp_id,
                       p_batch_number,
                       p_billing_frequency,          -- added by Jagadeesh #8471
                       'COBRA',
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate ) returning quote_header_id into l_header_id;

    /*   Begin
      SELECT quote_header_id
      INTO l_header_id
      FROM AR_QUOTE_HEADERS_STAGING
      WHERE batch_number = p_batch_number
      AND entrp_id       = p_entrp_id;
	 EXCEPTION   WHEN OTHERS THEN
    pc_log.log_error('PC_EMPLOYER_ENROLL.Upsert_cobra_staging',SQLERRM);
      ENd;
    */
     -- Swamy --> For Renewal Company Information Module is not there so blocking it for Renewal
            if l_source not in ( 'RENEWAL' ) then   -- If cond added by Swamy for Ticket#11364
        --- added by rprabu for validations based on   page_validity table 9392 ticket implemention
                if p_eff_date is not null then  ----Trunc(sysdate)   <   to_Date(p_eff_date, 'mm/dd/yyyy')   Then Ticket# 9549 rprabu
                    l_page_validity := 'V';
                else
                    l_page_validity := 'I';
                end if;
             --- added by rprabu for validations based on   page_validity table 9392 ticket implemention
                pc_employer_enroll.upsert_page_validity(
                    p_batch_number  => p_batch_number,
                    p_entrp_id      => p_entrp_id,
                    p_account_type  => 'COBRA',
                    p_page_no       => '1',
                    p_block_name    => 'COMPANY_INFORMATION',  -- 8014 rprabu 12/08/2019
                    p_validity      => l_page_validity,
                    p_user_id       => p_user_id,
                    x_error_status  => x_error_status,
                    x_error_message => x_error_message
                );

            end if;  -- Added by Swamy for Ticket#11364

            delete from ar_quote_lines_staging
            where
                batch_number = p_batch_number;

            for i in 1..p_rate_plan_id.count loop
                pc_log.log_error('COBRAStaging loop ',
                                 'After update  p_rate_plan_id(i) :='
                                 || p_rate_plan_id(i)
                                 || 'p_rate_plan_detail_id(i) :='
                                 || p_rate_plan_detail_id(i)
                                 || 'p_rate_plan_name(i) :='
                                 || p_rate_plan_name(i)
                                 || 'p_list_price(i) :='
                                 || p_list_price(i));

                if p_rate_plan_detail_id(i) is not null then
                    insert into ar_quote_lines_staging (
                        quote_line_id,
                        quote_header_id,
                        rate_plan_id,
                        rate_plan_detail_id,
                        rate_plan_name,
                        line_list_price,
                        batch_number,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date
                    ) values ( compliance_quote_lines_seq.nextval,
                               l_header_id,
                               p_rate_plan_id(i),
                               p_rate_plan_detail_id(i),
                               p_rate_plan_name(i),
                               p_list_price(i),
                               p_batch_number,
                               p_user_id,
                               sysdate,
                               p_user_id,
                               sysdate );

                end if;

            end loop;
      /* Rate Plan detail loop */
            update ar_quote_headers_staging
            set
                total_quote_price = p_tot_price,
                billing_frequency = p_billing_frequency        -- added by Jagadeesh #8471
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number;

        end if;
    /* Insert update loop */
    --Validating pages
    --- 8471 Jagadeesh
        for y in (
            select
                count(*) cnt
            from
                compliance_plan_staging
            where
                    batch_number = p_batch_number
                and carrier_name is not null
        ) loop
            if
                y.cnt = 0
                and p_carrier_notify = 'Y'
            then
                update compliance_plan_staging
                set
                    page_validity = 'I'
                where
                    batch_number = p_batch_number;

            end if;
        end loop;
    ----
        ------rprabu 03/12/2020  Ticket #9442
        begin
            select
                count(batch_number)
            into l_carrier_info
            from
                compliance_plan_staging
            where
                    batch_number = p_batch_number
                and carrier_name is null;

            if
                p_carrier_notify = 'Y'
                and l_carrier_info > 0
            then
                update online_compliance_staging
                set
                    page2 = 'I'
                where
                        batch_number = p_batch_number
                    and entrp_id = p_entrp_id;
                        -- added by jaggi Ticket #9442 on 06/10/2021
                pc_employer_enroll.upsert_page_validity(
                    p_batch_number  => p_batch_number,
                    p_entrp_id      => p_entrp_id,
                    p_account_type  => 'COBRA',
                    p_page_no       => 2,
                    p_block_name    => 'BENEFIT_PLAN_INFORMATION',
                    p_validity      => 'I',
                    p_user_id       => p_user_id,
                    x_error_status  => x_error_status,
                    x_error_message => x_error_message
                );

            end if;

        end;       ------ END rprabu 03/12/2020  Ticket #9442
    ----
        update online_compliance_staging
        set
            page1_company = p_page_validity,
            page1_plan = p_page_validity,
            fees_payment_flag =
                case
                    when lower(fees_payment_flag) = 'check'
                         and p_billing_frequency = 'M' then
                        null
                    else
                        fees_payment_flag
                end,  -- ##8471 Jagadeesh
            page3_payment =
                case
                    when lower(fees_payment_flag) = 'check'
                         and p_billing_frequency = 'M' then
                        'I'
                end  -- ##8471 Jagadeesh
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;
	 --- added by rprabu for validations based on   page_validity table 9392 ticket implemention
        pc_employer_enroll.upsert_page_validity(
            p_batch_number  => p_batch_number,
            p_entrp_id      => p_entrp_id,
            p_account_type  => 'COBRA',
            p_page_no       => 1,
            p_block_name    => 'PLAN_OPTIONS',  -- 8014 rprabu 12/08/2019
            p_validity      => p_page_validity,
            p_user_id       => p_user_id,
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );

    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.Upsert_cobra_staging', sqlerrm);
    end upsert_cobra_staging;

-- Below function is added by swamy to get the details of the benefit plan Information for Ticket#5469.
    function get_cobra_plan (
        p_plan_id in number
    ) return ret_re_cobra_plan_t
        pipelined
        deterministic
    is

        cursor cur_get_cobra_plan is
        select
            insurance_company_name,
            plan_name,
            plan_type,
            governing_state,
            plan_start_date,
            plan_end_date,
            self_funded_flag,
            conversion_flag,
            bill_cobra_premium_flag,
            coverage_terminate,
            age_rated_flag,
            ee_premium,
            ee_spouse_premium,
            ee_child_premium,
            ee_children_premium,
            ee_family_premium,
            spouse_premium,
            child_premium,
            spouse_child_premium,
            carrier_name,
            carrier_contact_name,
            carrier_contact_email,
            carrier_phone_no,
            carrier_addr,
            plan_number,
            policy_number,
            description,
            cobra_fed_flag      -- Swamy 05022024 #12000
        from
            compliance_plan_staging
        where
            plan_id = p_plan_id;

        l_record er_cobra_plan_t;
    begin
        for x in cur_get_cobra_plan loop
            l_record.insurance_company_name := x.insurance_company_name;
            l_record.plan_name := x.plan_name;
            l_record.plan_type := x.plan_type;
            l_record.governing_state := x.governing_state;
            l_record.plan_start_date := x.plan_start_date;
            l_record.plan_end_date := x.plan_end_date;
            l_record.self_funded_flag := x.self_funded_flag;
            l_record.conversion_flag := x.conversion_flag;
            l_record.bill_cobra_premium_flag := x.bill_cobra_premium_flag;
            l_record.coverage_terminate := x.coverage_terminate;
            l_record.age_rated_flag := x.age_rated_flag;
            l_record.ee_premium := x.ee_premium;
            l_record.ee_spouse_premium := x.ee_spouse_premium;
            l_record.ee_child_premium := x.ee_child_premium;
            l_record.ee_children_premium := x.ee_children_premium;
            l_record.ee_family_premium := x.ee_family_premium;
            l_record.spouse_premium := x.spouse_premium;
            l_record.child_premium := x.child_premium;
            l_record.spouse_child_premium := x.spouse_child_premium;
            l_record.carrier_name := x.carrier_name;
            l_record.carrier_contact_name := x.carrier_contact_name;
            l_record.carrier_contact_email := x.carrier_contact_email;
            l_record.carrier_phone_no := x.carrier_phone_no;
            l_record.carrier_addr := x.carrier_addr;
            l_record.plan_number := x.plan_number;
            l_record.policy_number := x.policy_number;
            l_record.description := x.description;
            l_record.cobra_fed_flag := x.cobra_fed_flag;   -- Swamy 05022024 #12000
            pipe row ( l_record );
        end loop;
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm;
            pipe row ( l_record );
    end get_cobra_plan;
    --Added by Jagadeesh on 02/24 #8471
    procedure create_compliance_plan (
        p_entrp_id                in number,
        p_plan_name               in varchar2,
        p_insurance_company_name  in varchar2,
        p_governing_state         in varchar2,
        p_plan_start_date         in varchar2,
        p_plan_end_date           in varchar2,
        p_plan_type               in varchar2,
        p_description             in varchar2,
        p_self_funded_flag        in varchar2,
        p_conversion_flag         in varchar2,
        p_bill_cobra_premium_flag in varchar2,
        p_coverage_terminate      in varchar2,
        p_age_rated_flag          in varchar2,
        p_carrier_contact_name    in varchar2,
        p_policy_number           in varchar2,
        p_plan_number             in varchar2,
        p_carrier_name            in varchar2, -- added by Joshi for 8471
        p_carrier_contact_email   in varchar2,
        p_carrier_phone_no        in varchar2,
        p_carrier_addr            in varchar2,
        p_ee_premium              in varchar2,
        p_ee_spouse_premium       in varchar2,
        p_ee_child_premium        in varchar2,
        p_ee_children_premium     in varchar2,
        p_ee_family_premium       in varchar2,
        p_spouse_premium          in varchar2,
        p_child_premium           in varchar2,
        p_spouse_child_premium    in varchar2,
        p_user_id                 in number,
        p_page_validity           in varchar2,
        p_batch_number            in number,
        p_plan_id                 in number default null,
        p_renewed_ben_plan_id     in number,   -- Added by Swamy for Ticket#10431(Renewal Resubmit)
        p_cobra_fed_flag          in varchar2,   -- Swamy 05022024 #12000
        x_er_ben_plan_id          out number,
        x_error_status            out varchar2,
        x_error_message           out varchar2
    ) is
        l_count         number;
        l_page_validity varchar2(1) := 'V';    -- Added by swamy for ticket#6070
    begin
        pc_log.log_error('create_compliance_plan', 'Loop' || p_plan_id);
        if p_plan_id is null then
      /* Insert */
            pc_log.log_error('create_compliance_plan..Count', l_count);
            insert into compliance_plan_staging (
                plan_id,
                entity_id,
                plan_name,
                plan_type,
                plan_number,
                policy_number,
                insurance_company_name,
                governing_state,
                plan_start_date,
                plan_end_date,
                self_funded_flag,
                conversion_flag,
                bill_cobra_premium_flag,
                coverage_terminate,
                age_rated_flag,
                carrier_name,
                carrier_contact_name,
                carrier_contact_email,
                carrier_phone_no,
                carrier_addr,
                ee_premium,
                ee_spouse_premium,
                ee_child_premium,
                ee_children_premium,
                ee_family_premium,
                spouse_premium,
                child_premium,
                spouse_child_premium,
                description,
                batch_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                page_validity,       -- Added by swamy for ticket#6070
                cobra_fed_flag        -- Swamy 05022024 #12000
            ) values ( compliance_plan_seq.nextval,
                       p_entrp_id,
                       p_plan_name,
                       p_plan_type,
                       p_plan_number,
                       p_policy_number,
                       p_insurance_company_name,
                       p_governing_state,
                       p_plan_start_date,
                       p_plan_end_date,
                       p_self_funded_flag,
                       p_conversion_flag,
                       p_bill_cobra_premium_flag,
                       p_coverage_terminate,
                       p_age_rated_flag,
                       p_carrier_name,
                       p_carrier_contact_name,
                       p_carrier_contact_email,
                       p_carrier_phone_no,
                       p_carrier_addr,
                       p_ee_premium,
                       p_ee_spouse_premium,
                       p_ee_child_premium,
                       p_ee_children_premium,
                       p_ee_family_premium,
                       p_spouse_premium,
                       p_child_premium,
                       p_spouse_child_premium,
                       p_description,
                       p_batch_number,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_page_validity,    -- Added by swamy for ticket#6070
                       p_cobra_fed_flag      -- Swamy 05022024 #12000  
                        ) returning plan_id into x_er_ben_plan_id;

        else
      /* Update */
            pc_log.log_error('create_compliance_plan..Update', p_plan_start_date);
            update compliance_plan_staging
            set
                plan_name = p_plan_name,
                plan_number = p_plan_number,
                policy_number = p_policy_number,
                plan_type = p_plan_type,
                insurance_company_name = p_insurance_company_name,
                governing_state = p_governing_state,
                plan_start_date = p_plan_start_date,
                plan_end_date = p_plan_end_date,
        -- PLAN_START_DATE   =    to_date(p_plan_start_date,'dd/mm/rrrr')  ,
        --PLAN_END_DATE  =     to_date(p_plan_end_date,'dd/mm/rrrr') ,
                self_funded_flag = p_self_funded_flag,
                conversion_flag = p_conversion_flag,
                bill_cobra_premium_flag = p_bill_cobra_premium_flag,
                coverage_terminate = p_coverage_terminate,
                age_rated_flag = p_age_rated_flag,
                carrier_contact_name = p_carrier_contact_name,
                carrier_contact_email = p_carrier_contact_email,
                carrier_phone_no = p_carrier_phone_no,
                carrier_addr = p_carrier_addr,
                ee_premium = p_ee_premium,
                ee_spouse_premium = p_ee_spouse_premium,
                ee_child_premium = p_ee_child_premium,
                ee_children_premium = p_ee_children_premium,
                ee_family_premium = p_ee_family_premium,
                spouse_premium = p_spouse_premium,
                child_premium = p_child_premium,
                last_updated_by = p_user_id,
                last_update_date = sysdate,
                spouse_child_premium = p_spouse_child_premium,
                description = p_description,
                page_validity = p_page_validity,   -- Added by Swamy for Ticket#6070
                renewed_ben_plan_id = p_renewed_ben_plan_id,  -- Added by Swamy for Ticket#10431(Renewal Resubmit)
                carrier_name = p_carrier_name,   -- 8471 Joshi
                cobra_fed_flag = p_cobra_fed_flag  -- Swamy 05022024 #12000  
            where
                    batch_number = p_batch_number
                and entity_id = p_entrp_id
                and plan_id = p_plan_id;

            x_er_ben_plan_id := p_plan_id;
        end if;

    -- Below code added by Swamy for Ticket#6070
    -- Check if any record is Invalid for that employer and batch number,
    -- If yes then mark the page2 as I(Invalid), else default it as V(Valid)
        for j in (
            select
                page_validity
            from
                compliance_plan_staging
            where
                    batch_number = p_batch_number
                and entity_id = p_entrp_id
                and page_validity = 'I'
        ) loop
            l_page_validity := j.page_validity;
        end loop;

    /* Insert/Update loop */
    --Validating page# 2
        update online_compliance_staging
        set
            page2 = l_page_validity,    -- Replaced p_page_validity with L_Page_Validity by swamy for Ticket#6070,
            page1_plan = 'V',      ---Ticket #9429   rprabu 02/12/2020
            last_update_date = sysdate,  -- added by swamy
            last_updated_by = p_user_id -- added by swamy
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;
  --- added by rprabu for validations based on   page_validity table 9392 ticket implemention
        pc_employer_enroll.upsert_page_validity(
            p_batch_number  => p_batch_number,
            p_entrp_id      => p_entrp_id,
            p_account_type  => 'COBRA',
            p_page_no       => 2,
            p_block_name    => 'BENEFIT_PLAN_INFORMATION',  -- 8014 rprabu 12/08/2019
            p_validity      => l_page_validity,
            p_user_id       => p_user_id,
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );

    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL.create_compliance_plan', sqlerrm);
    end create_compliance_plan;

  --Added by Jagadeesh on 02/24 #8471
    procedure create_cobra_plan (
        p_entrp_id       in number,
        p_batch_number   in number,
        p_user_id        in number,
        x_er_ben_plan_id out number,
        x_error_status   out varchar2,
        x_error_message  out varchar2
    ) is

        l_er_ben_plan_id       number;
        l_error_status         varchar2(100) := 'S';
        l_error_message        varchar2(1000);
        l_acc_id               number;
        x_quote_header_id      number;
        l_exist                number := 0;
        l_header_exist         number := 0;
        l_acc_num              varchar2(100);
        l_bank_id              number;
        l_date                 date;
        l_carrier_notify_flag  varchar2(1);
        l_entity_type          varchar2(50);   ----9141 rprabu 05/08/2020
        l_entity_id            number;        ----9141 rprabu 05/08/2020
        l_enrolle_type         varchar2(50);   ----9141 rprabu 05/08/2020
        l_enrolled_by          number;        ----9141 rprabu 05/08/2020
        l_ga_broker_flg        varchar2(50);   ----9141 rprabu 05/08/2020
        l_sign_type            account.sign_type%type;  -- Added by swamy for Ticket#9617
        erreur exception;      ----9141 rprabu 05/08/2020
        l_plan_name            varchar2(100);  -- added by jaggi 10430
        l_resubmit_flag        varchar2(1);
        l_ben_plan_id          number;
        l_inactive_plan_exist  varchar2(1);
        l_no                   number := 0;
        l_broker_id            number;
        l_authorize_req_id     number;
        l_renewed_by           varchar2(30);
        l_source               varchar2(30);
        l_account_status       number;
        type rates_rec is record (
                coverage_level varchar2(100),
                rate           number
        );
        type rates_tbl is
            table of rates_rec index by binary_integer;
        l_rates_tbl            rates_tbl;
        l_cnt                  number := 0;
        l_eff_date             date;
        l_acct_usage           varchar2(100);
        l_bank_count           number;
        l_return_status        varchar2(10);
        l_sales_team_member_id number;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan', 'In Proc');
        pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan', p_entrp_id);
        for x in (
            select
                *
            from
                online_compliance_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            select
                acc_id,
                acc_num,
                enrolled_by,
                nvl(enrolle_type, 'EMPLOYER'),
                sign_type,
                nvl(resubmit_flag, 'N') resubmit_flag --sign_type added by swamy for Ticket#9617 ----9141 rprabu 05/08/2020
            into
                l_acc_id,
                l_acc_num,
                l_enrolled_by,
                l_enrolle_type,
                l_sign_type,
                l_resubmit_flag ---9141 rprabu 05/08/2020
            from
                account
            where
                entrp_id = p_entrp_id;

            l_inactive_plan_exist := nvl(
                pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
                'N'
            );
            l_source := x.source;

--     -- Jaggi Added by #11265
--     UPDATE account
--        SET salesrep_id = x.salesrep_id
--      WHERE entrp_id = p_entrp_id;
     -- added by Jaggi #11629
            if x.salesrep_id is not null then
                pc_sales_team.upsert_sales_team_member(
                    p_entity_type           => 'SALES_REP',
                    p_entity_id             => x.salesrep_id,
                    p_mem_role              => 'PRIMARY',
                    p_entrp_id              => p_entrp_id,
                    p_start_date            => trunc(sysdate),
                    p_end_date              => null,
                    p_status                => 'A',
                    p_user_id               => p_user_id,
                    p_pay_commission        => null,
                    p_note                  => null,
                    p_no_of_days            => null,
                    px_sales_team_member_id => l_sales_team_member_id,
                    x_return_status         => l_return_status,
                    x_error_message         => x_error_message
                );
            end if;

     -- Added by Jaggi #11086
            if l_source is null then
                pc_account.upsert_acc_pref(
                    p_entrp_id               => p_entrp_id,
                    p_acc_id                 => l_acc_id,
                    p_claim_pay_method       => null,
                    p_auto_pay               => null,
                    p_plan_doc_only          => null,
                    p_status                 => 'A',
                    p_allow_eob              => 'Y',
                    p_user_id                => p_user_id,
                    p_pin_mailer             => 'N',
                    p_teamster_group         => 'N',
                    p_allow_exp_enroll       => 'Y',
                    p_maint_fee_paid         => null,
                    p_allow_online_renewal   => 'Y',
                    p_allow_election_changes => 'N',
                    p_plan_action_flg        => 'N',
                    p_submit_election_change => 'Y',
                    p_edi_flag               => 'N',
                    p_vendor_id              => null,
                    p_reference_flag         => null,
                    p_allow_payroll_edi      => null,
                    p_fees_paid_by           => null
                );
            end if;

    -- Added by Jaggi #11365
            if pc_account.get_broker_id(l_acc_id) = 0 then
                for j in (
                    select
                        broker_id
                    from
                        online_users ou,
                        broker       b
                    where
                            user_id = p_user_id
                        and user_type = 'B'
                        and upper(tax_id) = upper(broker_lic)
                ) loop
                    update account
                    set
                        broker_id = j.broker_id
                    where
                        entrp_id = p_entrp_id;

                end loop;
            end if;

      /*For Multiple medical plans we create one entry in ben_plan setup table */

            l_carrier_notify_flag := x.carrier_notify_flag; -- Jagadeesh #8471

      -- Added below insert statement by Swamy for Ticket#7606
            if nvl(x.no_off_ees, 0) <> 0 then
                insert into enterprise_census (
                    entity_id,
                    entity_type,
                    census_code,
                    census_numbers,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    ben_plan_id
                ) values ( p_entrp_id,
                           'ENTERPRISE',
                           'NO_OF_EMPLOYEES',
                           x.no_off_ees,
                           sysdate,
                           p_user_id,
                           sysdate,
                           p_user_id,
                           null );

            end if;

            if nvl(x.no_of_eligible, 0) <> 0 then
                insert into enterprise_census (
                    entity_id,
                    entity_type,
                    census_code,
                    census_numbers,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    ben_plan_id
                ) values ( p_entrp_id,
                           'ENTERPRISE',
                           'NO_OF_ELIGIBLE',
                           x.no_of_eligible,
                           sysdate,
                           p_user_id,
                           sysdate,
                           p_user_id,
                           null );
           -- Jagadeesh. update no of eligible employees
                update enterprise
                set
                    no_of_eligible = x.no_of_eligible
                where
                    entrp_id = p_entrp_id;

            end if;
      -- End of Addition by Swamy for Ticket#7606

            l_date := to_date ( x.effective_date, 'mm/dd/yyyy' );

     -- Added by Joshi for 10430
     -- existing cobra plans and ben plan  should be deleted in case of resubmission

            if l_resubmit_flag = 'Y' then

       -- Added by Joshi for 10430. need to delete existing contacts and reinsert as in case of resubmit
       -- user might update existing  contacts.
                for c in (
                    select
                        contact_id
                    from
                        contact_leads
                    where
                            entity_id = pc_entrp.get_tax_id(p_entrp_id)
                        and account_type = 'COBRA'
                        and ref_entity_type = 'ONLINE_ENROLLMENT'
                ) loop
                    delete from contact
                    where
                            entity_id = pc_entrp.get_tax_id(p_entrp_id)
                        and contact_id = c.contact_id;

                    delete from contact_role
                    where
                        contact_id = c.contact_id;

                end loop;

                update user_bank_acct
                set
                    status = 'I'
                where
                        acc_id = l_acc_id
                    and bank_account_usage = 'INVOICE';

                update user_bank_acct
                set
                    status = 'I'
                where
                        acc_id = l_acc_id
                    and bank_account_usage = 'COBRA_DISBURSE';  -- added by Jaggi #11262
                delete from ar_quote_headers
                where
                    entrp_id = p_entrp_id; -- added by Jaggi 05/16/2023

       /*   commented and added below by Joshi for #12339. Ben plan deletion issue 
       BEGIN
           SELECT ben_plan_id INTO l_ben_plan_id
             FROM ben_plan_enrollment_Setup
            WHERE acc_id = l_acc_id ;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_ben_plan_id := NULL ;
         END ;
       IF l_ben_plan_id  is NOT NULL THEN
            DELETE FROM COBRA_PLAN_SETUP
            WHERE BEN_PLAN_ID = l_ben_plan_id ;

            DELETE FROM BEN_PLAN_ENROLLMENT_SETUP
            WHERE ACC_ID =  l_acc_id  AND ENTRP_ID = P_entrp_id AND ben_plan_id = l_ben_plan_id;
        END IF;    */

                for b in (
                    select distinct
                        bp.ben_plan_id
                    from
                        ben_plan_enrollment_setup bp,
                        online_compliance_staging os,
                        compliance_plan_staging   ops
                    where
                            os.batch_number = p_batch_number
                        and os.entrp_id = p_entrp_id
                        and os.batch_number = ops.batch_number
                        and os.entrp_id = bp.entrp_id
                        and ops.ben_plan_id = bp.ben_plan_id
                ) loop
                    delete from cobra_plan_setup
                    where
                        ben_plan_id = b.ben_plan_id;

                    delete from ben_plan_enrollment_setup
                    where
                            entrp_id = p_entrp_id
                        and ben_plan_id = b.ben_plan_id;

                end loop;

            end if;

            pc_log.log_error('create_cobra_plan ', 'before update_PLAN_INFO call '
                                                   || 'l_er_ben_plan_id '
                                                   || l_er_ben_plan_id);
            l_eff_date := to_date ( x.effective_date, 'MM/DD/YYYY' ); --------Take Over date raised by client rprabu  09/05/2022 cp Project

            pc_employer_enroll.update_plan_info(
                p_entrp_id        => p_entrp_id,
                p_fiscal_end_date => null,
                p_plan_type       => 'COBRA',
                p_eff_date        => x.effective_date,
                p_org_eff_date    => null,
                p_plan_start_date => x.effective_date,
                p_plan_end_date   => to_char(add_months(l_date, 12) - 1,
                                           'mm/dd/rrrr'),
                p_takeover        => null,
                p_user_id         => p_user_id,
                p_plan_name       => l_plan_name    -- added jaggi #10430
                ,
                x_er_ben_plan_id  => l_er_ben_plan_id,
                x_error_status    => l_error_status,
                x_error_message   => l_error_message
            );

	-- Added by Joshi for 10430. taken from down.

            if l_error_status = 'S' then
                update compliance_plan_staging
                set
                    ben_plan_id = l_er_ben_plan_id
                where
                        entity_id = p_entrp_id
                    and batch_number = p_batch_number;

            end if;

     /*Create Bank Info */
      -- Added by Joshi UPPER for ticket 9035
 /*     IF UPPER(X.FEES_PAYMENT_FLAG) = 'ACH'  AND X.BANK_NAME IS NOT NULL THEN

        IF l_Enrolle_Type = 'BROKER' THEN   -- If Cond. for Broker Added by Swamy for Ticket#9719
            IF nvl(X.acct_payment_fees,'EMPLOYER') = 'EMPLOYER'  THEN   -- 9412 rprabu 31/08/2020
                L_Entity_Id    := l_acc_Id;
                L_Entity_Type  := 'ACCOUNT';
            ELSIF X.acct_payment_fees = 'BROKER' Then
                L_Entity_Id    := l_Enrolled_By;
                L_Entity_Type  := l_Enrolle_Type;
            END IF;
        ELSIF l_Enrolle_Type = 'GA' THEN
            IF nvl(X.acct_payment_fees,'EMPLOYER')    in  ( 'EMPLOYER', 'BROKER') THEN -- 9412 rprabu 31/08/2020
                L_Entity_Id    := l_acc_Id;
                L_Entity_Type  := 'ACCOUNT';
            ELSIF X.ACCT_PAYMENT_FEES IN ('GA'  )   THEN
                L_Entity_Id    := l_Enrolled_By;
                L_Entity_Type  := l_Enrolle_Type;
            END IF;
        ELSE -- For employer, bank account should go as employer irrespecive of who pays.
            L_Entity_Id    := l_acc_Id;
            L_Entity_Type  := 'ACCOUNT';
        END IF;

        pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan L_Entity_Id  31/08',L_Entity_Id);
        pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan L_Entity_Type 31/08',L_Entity_Type);

        -- Added by Swamy for Ticket#9387 on 21/08/2020
        l_ga_broker_flg := pc_user_bank_acct.check_bank_acct(p_entity_id  => L_Entity_Id
                                                              ,p_entity_type    => L_Entity_Type
                                                              ,p_bank_acct_type => X.Bank_Acc_Type
                                                              ,p_routing_number => X.Routing_Number
                                                              ,p_bank_acct_num  => X.Bank_Acc_Num
                                                              ,p_bank_name      => X.Bank_Name
                                                              ,p_bank_account_usage => 'INVOICE'); -- Joshi 10431

        pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_ga_broker_flg 31/08',l_ga_broker_flg);

        IF l_ga_broker_flg = 'N' THEN ------------9141 rprabu 11/08/2020
            -------9141 rprabu 05/08/2020
            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan',p_entrp_id);

            Pc_User_Bank_Acct.Insert_Bank_Account(P_Entity_Id => L_Entity_Id ,        P_Entity_Type => L_Entity_Type,
                          P_Display_Name => X.Bank_Name ,         P_Bank_Acct_Type => X.Bank_Acc_Type ,
                          P_Bank_Routing_Num => X.Routing_Number,   P_Bank_Acct_Num => X.Bank_Acc_Num ,
                          P_Bank_Name => X.Bank_Name ,      P_Bank_Account_Usage => 'INVOICE' ,
                          P_User_Id => P_User_Id ,   X_Bank_Acct_Id => L_Bank_Id ,
                          X_Return_Status => L_Error_Status ,   X_Error_Message => L_Error_Message );

            IF NVL(X_Error_Status,'S') = 'E' THEN
              Raise Erreur;
            END IF;
        END IF;
        ---PC_EMPLOYER_ENROLL.insert_user_bank_acct(p_acc_num => l_acc_num ,p_display_name => X.bank_name ,p_bank_acct_type => X.BANK_ACC_TYPE ,p_bank_routing_num => X.ROUTING_NUMBER ,p_bank_acct_num => X.BANK_ACC_NUM ,p_bank_name => X.bank_name ,p_user_id => p_user_id ,p_acct_usage => 'INVOICE' ,x_bank_acct_id => l_bank_id ,x_return_status => l_error_status ,x_error_message => l_error_message );
      END IF;
 */
      /*Create Bank Info ends here */
    -- Added by Jaggi #11262  /*Create Bank Info */
    -- Add bank details
     /*  FOR bank_rec IN  (SELECT bank_name
                               ,routing_number
                               ,bank_acc_num
                               ,bank_acc_type
                               ,optional_bank_name
                               ,optional_routing_number
                               ,optional_bank_acc_num
                               ,optional_bank_acc_type
                               ,Optional_Fee_Paid_By
                               ,remit_bank_name
                               ,remit_routing_number
                               ,remit_bank_acc_num
                               ,remit_bank_acc_type
                           FROM online_compliance_staging
                          WHERE batch_number = p_batch_number
                            AND entrp_id     = p_entrp_id )*/

      -- Added by Swamy for Ticket#12534 
       /*FOR bank_rec IN  (SELECT bank_name
                               ,bank_routing_num
                               ,bank_acct_num
                               ,bank_acct_type
                               ,optional_remit_flag 
                           FROM User_Bank_acct_Staging
                          WHERE batch_number = p_batch_number
                            AND entrp_id     = p_entrp_id )
        LOOP
            l_acct_usage :=  'INVOICE' ;
            l_bank_count := 0 ;
            l_bank_id := NULL;

        -- Annual bank details
        IF NVL(bank_rec.optional_remit_flag,'*') = '*' AND bank_rec.bank_name IS NOT NULL THEN  -- Added by Swamy for Ticket#12534 
            IF UPPER(X.acct_payment_fees)= 'EMPLOYER'  THEN
                l_entity_id := l_acc_id;
                l_entity_type := 'ACCOUNT';
            ELSIF UPPER(X.acct_payment_fees) = 'BROKER'  THEN
                l_entity_id := pc_account.get_broker_id(l_acc_id);
                l_entity_type := 'BROKER';
            ELSIF UPPER( X.acct_payment_fees) = 'GA'  THEN
                l_entity_id := pc_account.get_ga_id(l_acc_id);
                l_entity_type := 'GA';
            END IF;

            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_entity_id: ',l_entity_id);
            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_entity_type',l_entity_type);
            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_acct_usage l',l_acct_usage);

            l_bank_id := pc_user_bank_acct.get_bank_acct_id( p_entity_id   => l_entity_id
                          ,p_entity_type        => l_entity_type
                          ,p_bank_acct_num     => bank_rec.bank_acct_num
                          ,p_bank_name         => bank_rec.bank_name
                          ,p_bank_routing_num  => bank_rec.bank_routing_num
                          ,p_bank_Account_usage => l_acct_usage
                          ,p_bank_acct_type     => bank_rec.bank_acct_type
                          );

            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_count l',l_bank_count);

              IF NVL(l_bank_id,0) = 0 THEN
                  -- fee bank details
                  pc_user_bank_acct.insert_bank_account(
                                     p_entity_id          => l_entity_id
                                    ,p_entity_type        => l_entity_type
                                    ,p_display_name       => bank_rec.bank_name
                                    ,p_bank_acct_type     => bank_rec.bank_acct_type
                                    ,p_bank_routing_num   => bank_rec.bank_routing_num
                                    ,p_bank_acct_num      => bank_rec.bank_acct_num
                                    ,p_bank_name          => bank_rec.bank_name
                                    ,p_bank_account_usage => NVL(l_acct_usage,'INVOICE')
                                    ,p_user_id            => p_user_id
                                    ,x_bank_acct_id       => l_bank_id
                                    ,x_return_status      => l_return_status
                                    ,x_error_message      => l_error_message);

                pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_id l',l_bank_id);

               END IF;
              UPDATE online_compliance_staging
                 SET bank_acct_id = NVL(l_bank_id, bank_acct_id)
               WHERE batch_number = p_batch_number
                 AND entrp_id     = p_entrp_id;
             END IF;
        -- optional bank details
        IF NVL(bank_rec.optional_remit_flag,'*') = 'O' AND bank_rec.bank_name IS NOT NULL THEN
                l_entity_id    := null ;
                l_entity_type  := null;
                l_acct_usage :=  'INVOICE' ;

                IF UPPER(x.optional_Fee_Paid_By)= 'EMPLOYER'  THEN    -- Added by Swamy for Ticket#12534 
                    l_entity_id := l_acc_id;
                    l_entity_type := 'ACCOUNT';
                ELSIF UPPER(x.optional_Fee_Paid_By) = 'BROKER'  THEN   -- Added by Swamy for Ticket#12534 
                    l_entity_id := pc_account.get_broker_id(l_acc_id);
                    l_entity_type := 'BROKER';
                ELSIF UPPER( x.optional_Fee_Paid_By) = 'GA'  THEN    -- Added by Swamy for Ticket#12534 
                    l_entity_id := pc_account.get_ga_id(l_acc_id);
                    l_entity_type := 'GA';
                END IF;
               -- check if used had entered existing bank account details.
            l_bank_id := pc_user_bank_acct.get_bank_acct_id( p_entity_id   => l_entity_id
                          ,p_entity_type        => l_entity_type
                          ,p_bank_acct_num     => bank_rec.bank_acct_num
                          ,p_bank_name         => bank_rec.bank_name
                          ,p_bank_routing_num  => bank_rec.bank_routing_num
                          ,p_bank_Account_usage => l_acct_usage
                          ,p_bank_acct_type     => bank_rec.bank_acct_type
                          );
               pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan optional l_bank_count  l',l_bank_count);

              IF NVL(l_bank_id,0) = 0 THEN
               pc_user_bank_acct.insert_bank_account(
                                 p_entity_id          => l_entity_id
                                ,p_entity_type        => l_entity_type
                                ,p_display_name       => bank_rec.bank_name
                                ,p_bank_acct_type     => bank_rec.bank_acct_type
                                ,p_bank_routing_num   => bank_rec.bank_routing_num
                                ,p_bank_acct_num      => bank_rec.Bank_Acct_Num
                                ,p_bank_name          => bank_rec.bank_name
                                ,p_bank_account_usage => NVL(l_acct_usage,'INVOICE')
                                ,p_user_id            => p_user_id
                                ,x_bank_acct_id       => l_bank_id
                                ,x_return_status      => l_return_status
                                ,x_error_message      => l_error_message);

               pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_id l',l_bank_id);
                END IF ;
              pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_id l',l_bank_id);
              pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_error_message l',l_error_message);

              UPDATE online_compliance_staging
                 SET optional_fee_bank_acct_id = NVL(l_bank_id, optional_fee_bank_acct_id)
               WHERE batch_number = p_batch_number
                 AND entrp_id     = p_entrp_id;
            END IF;
        -- Remit bank details
        IF NVL(bank_rec.optional_remit_flag,'*') = 'R' AND bank_rec.bank_name IS NOT NULL THEN  -- Added by Swamy for Ticket#12534 

                l_acct_usage  := 'COBRA_DISBURSE' ;
                l_entity_id   := l_acc_id;
                l_entity_type := 'ACCOUNT';

                -- check if used had entered existing bank account details.
            l_bank_id := pc_user_bank_acct.get_bank_acct_id( p_entity_id   => l_entity_id
                          ,p_entity_type        => l_entity_type
                          ,p_bank_acct_num     => bank_rec.bank_acct_num
                          ,p_bank_name         => bank_rec.bank_name
                          ,p_bank_routing_num  => bank_rec.bank_routing_num
                          ,p_bank_Account_usage => l_acct_usage
                          ,p_bank_acct_type     => bank_rec.bank_acct_type
                          );

                pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan optional l_bank_count  l',l_bank_count);

              IF NVL(l_bank_id,0) = 0 THEN
                pc_user_bank_acct.insert_bank_account(
                                  p_entity_id          => l_entity_id
                                 ,p_entity_type        => l_entity_type
                                 ,p_display_name       => bank_rec.bank_name
                                 ,p_bank_acct_type     => bank_rec.bank_acct_type
                                 ,p_bank_routing_num   => bank_rec.bank_routing_num
                                 ,p_bank_acct_num      => bank_rec.Bank_Acct_Num
                                 ,p_bank_name          => bank_rec.bank_name
                                 ,p_bank_account_usage => NVL(l_acct_usage,'COBRA_DISBURSE')
                                 ,p_user_id            => p_user_id
                                 ,x_bank_acct_id       => l_bank_id
                                 ,x_return_status      => l_return_status
                                 ,x_error_message      => l_error_message);
            END IF;
         END IF;

    END LOOP;*/

       -- Added by Swamy for Ticket#12534 
            pc_employer_enroll_compliance.insert_enroll_renew_bank_accounts(
                p_entrp_id               => p_entrp_id,
                p_acc_id                 => l_acc_id,
                p_batch_number           => p_batch_number,
                p_acct_payment_fees      => x.acct_payment_fees,
                p_fees_payment_flag      => x.fees_payment_flag,
                p_optional_fee_paid_by   => x.optional_fee_paid_by,
                p_opt_fee_payment_method => x.optional_fee_payment_method,
                p_user_id                => p_user_id,
                p_source                 => 'E',
                p_account_status         => l_account_status,
                x_error_status           => x_error_status,
                x_error_message          => x_error_message
            );

            for y in (
                select
                    *
                from
                    compliance_plan_staging
                where
                        entity_id = p_entrp_id
                    and batch_number = p_batch_number
            ) loop
                insert into cobra_plan_setup (
                    cobra_plan_id,
                    plan_name,
                    insurance_company_name,
                    governing_state,
                    plan_start_date,
                    plan_end_date,
                    plan_type,
                    description,
                    self_funded_flag,
                    conversion_flag,
                    bill_cobra_premium_flag,
                    coverage_terminate,
                    age_rated_flag,
                    entity_id,
                    carrier_contact_name,
                    policy_number,
                    plan_number,
                    carrier_contact_email,
                    carrier_phone_no,
                    carrier_addr,
                    ee_premium,
                    ee_spouse_premium,
                    ee_child_premium,
                    ee_children_premium,
                    ee_family_premium,
                    spouse_premium,
                    chil_premium,
                    spouse_child_premium,
                    salesrep_flag,
                    salesrep_id,
                    ben_plan_id,
                    created_by,
                    creation_date,
                    cobra_fed_flag                  -- Swamy 05022024 #12000
                ) values ( cobra_plan_seq.nextval,
                           y.plan_name,
                           y.insurance_company_name,
                           y.governing_state,
                           to_date(y.plan_start_date, 'mm/dd/yyyy'),/*Ticket#7135 */
                           to_date(y.plan_end_date, 'mm/dd/yyyy'),
                           y.plan_type,
                           y.description,
                           y.self_funded_flag,
                           y.conversion_flag,
                           y.bill_cobra_premium_flag,
                           y.coverage_terminate,
                           y.age_rated_flag,
                           p_entrp_id,
                           y.carrier_contact_name,
                           y.policy_number,
                           y.plan_number,
                           y.carrier_contact_email,
                           y.carrier_phone_no,
                           y.carrier_addr,
                           y.ee_premium,
                           y.ee_spouse_premium,
                           y.ee_child_premium,
                           y.ee_children_premium,
                           y.ee_family_premium,
                           y.spouse_premium,
                           y.child_premium,
                           y.spouse_child_premium,
                           x.salesrep_flag,
                           x.salesrep_id,
                           l_er_ben_plan_id,
                           p_user_id,
                           sysdate,
                           y.cobra_fed_flag                  -- Swamy 05022024 #12000
                            ) returning cobra_plan_id into x_er_ben_plan_id;
	------------  COBRA project changes done by 20/01/2022

                for z in (
                    select
                        *
                    from
                        compliance_plan_staging s
                    where
                            entity_id = p_entrp_id
                        and batch_number = p_batch_number
                        and plan_id in (
                            select
                                max(plan_id)
                            from
                                compliance_plan_staging s1
                            where
                                    s1.entity_id = s.entity_id
                                and s1.batch_number = s.batch_number
                                and s1.plan_type = s.plan_type
                                and s1.plan_name = s.plan_name
                        )
                        and not exists (
                            select
                                *
                            from
                                newcobra.cobra_plans cp
                            where
                                    cp.clientplanqbid = s.plan_id
                                and cp.entrp_id = s.entity_id
                        )
                ) loop
                    insert into newcobra.cobra_plans (
                        cobra_plan_id,
                        entrp_id,
                        plan_name,
                        plan_type,
                        plan_number,
                        policy_number,
                        carrier_name,
                        governing_state,
                        plan_start_date,
                        plan_end_date,
                        self_funded_flag,
                        conversion_flag,
                        bill_cobra_premium_flag,
                        coverage_terminate,
                        carrier_contact_name,
                        carrier_contact_email,
                        carrier_phone_no,
                        carrier_addr,
                        waitingperiod,
                        fsarenewalmonth,
                        description,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        ben_plan_id,
                        plan_effective_date,
                        online_cobra_election,
                        bundled_flag,
                        plan_bundle_id,
                        division_id,
                        agedeterminedby,
                        status,
                        months_of_cobra,
                        days_to_elect,
                        first_preimum_election_day,
                        preimum_election_day,
                        clientplanqbid,
                        clientid
                    ) values ( cobra_plan_id_seq.nextval,
                               z.entity_id,  ---   Create or replace public SYNONYM COBRA_PLAN_ID_SEQ for newcobra.COBRA_PLAN_ID_SEQ;
                               z.plan_name,
                               case
                                   when z.plan_type = 'MED' then
                                       'MEDICAL'
                                   when z.plan_type = 'DET' then
                                       'DENTAL'
                                   when z.plan_type = 'VIS' then
                                       'VISION'
                                   else
                                       'OTHER'
                               end,
                               z.plan_number,
                               z.policy_number,
                               nvl(z.carrier_name, z.insurance_company_name),       -------Insurance_Company_Name,
                               z.governing_state,
                               to_date(z.plan_start_date, 'mm/dd/yyyy'),
                               to_date(z.plan_end_date, 'mm/dd/yyyy'),
                               z.self_funded_flag,
                               z.conversion_flag,
                               z.bill_cobra_premium_flag,
                               case
                                   when z.coverage_terminate = 'END_OF_MONTH' then
                                       'EOM'
                                   else
                                       'EVENT'
                               end,
                               z.carrier_contact_name,
                               z.carrier_contact_email,
                               z.carrier_phone_no,
                               z.carrier_addr,
                               null,
                               null,
                               null,
                               0,
                               sysdate,
                               0,
                               sysdate,
                               z.ben_plan_id,
                               to_date(z.plan_start_date, 'mm/dd/yyyy'),
                               'Y',
                               null,
                               null,
                               null,  ----division_id ,
                               null,
                               'A',
                               18,
                               60,
                               null,
                               null,
                               z.plan_id,
                               null );

                    insert into newcobra.cobra_plan_rates (
                        cobra_plan_rate_id,
                        rate_type,
                        cobra_plan_id,
                        effective_date,
                        billing_date,
                        renewal_date,
                        end_date,
                        qb_premium_admin_fee,
                        qb_disability_fee,
                        clientplanqbid,
                        clientid
                    )
                        select
                            cobra_plan_rate_id_seq.nextval,
                            case
                                when nvl(z.ee_premium, 0) + nvl(z.ee_spouse_premium, 0) + nvl(z.ee_child_premium, 0) + nvl(z.ee_children_premium
                                , 0) + nvl(z.spouse_premium, 0) + nvl(z.child_premium, 0) + nvl(z.spouse_child_premium, 0) > 0 then
                                    'COMPOSITE'
                                else
                                    'NORATE'
                            end rate_type,
                            cp.cobra_plan_id,
                            cp.plan_start_date,
                            cp.plan_start_date,
                            null,
                            cp.plan_end_date,
                            2,
                            50,
                            clientplanqbid,
                            null
                        from
                            newcobra.cobra_plans cp
                        where
                                entrp_id = z.entity_id
                            and clientplanqbid = z.plan_id;

                    l_cnt := 0;
                    l_rates_tbl.delete;
                    if z.ee_premium > 0 then
                        l_cnt := l_cnt + 1;
                        l_rates_tbl(l_cnt).coverage_level := 'EE';   ---- issue raised by Sonia 'QB'  replaced by EE fixed on 11/07/2022 rprabu COBRA project
                        l_rates_tbl(l_cnt).rate := z.ee_premium;
                    end if;

                    if z.ee_spouse_premium > 0 then
                        l_cnt := l_cnt + 1;
                        l_rates_tbl(l_cnt).coverage_level := 'EE+SPOUSE';
                        l_rates_tbl(l_cnt).rate := z.ee_spouse_premium;
                    end if;

                    if z.ee_child_premium > 0 then
                        l_cnt := l_cnt + 1;
                        l_rates_tbl(l_cnt).coverage_level := 'EE+CHILD';
                        l_rates_tbl(l_cnt).rate := z.ee_child_premium;
                    end if;

                    if z.ee_children_premium > 0 then
                        l_cnt := l_cnt + 1;
                        l_rates_tbl(l_cnt).coverage_level := 'EE+CHILDREN';
                        l_rates_tbl(l_cnt).rate := z.ee_children_premium;
                    end if;

                    if z.ee_family_premium > 0 then
                        l_cnt := l_cnt + 1;
                        l_rates_tbl(l_cnt).coverage_level := 'EE+FAMILY';
                        l_rates_tbl(l_cnt).rate := z.ee_family_premium;
                    end if;

                    if z.spouse_premium > 0 then
                        l_cnt := l_cnt + 1;
                        l_rates_tbl(l_cnt).coverage_level := 'SPOUSEONLY';
                        l_rates_tbl(l_cnt).rate := z.spouse_premium;
                    end if;

                    if z.child_premium > 0 then
                        l_cnt := l_cnt + 1;
                        l_rates_tbl(l_cnt).coverage_level := 'CHILDONLY';
                        l_rates_tbl(l_cnt).rate := z.child_premium;
                    end if;

                    if z.spouse_child_premium > 0 then
                        l_cnt := l_cnt + 1;
                        l_rates_tbl(l_cnt).coverage_level := 'SPOUSE+CHILD';
                        l_rates_tbl(l_cnt).rate := z.spouse_child_premium;
                    end if;

                    forall k in 1..l_rates_tbl.count
                        insert into cobra_plan_rate_detail (
                            cobra_plan_rate_detail_id,
                            cobra_plan_rate_id,
                            coverage_level,
                            rate,
                            status,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date,
                            rate_type,
                            clientplanqbrateid,
                            clientid,
                            cobra_plan_id
                        )
                            select
                                cobra_plan_rate_detail_id_seq.nextval,
                                r.cobra_plan_rate_id,
                                l_rates_tbl(k).coverage_level,
                                l_rates_tbl(k).rate,
                                'A',
                                0,
                                sysdate,
                                0,
                                sysdate,
                                r.rate_type,
                                z.plan_id,
                                null,
                                cp.cobra_plan_id
                            from
                                cobra_plans      cp,
                                cobra_plan_rates r
                            where
                                    cp.entrp_id = z.entity_id
                                and cp.clientplanqbid = z.plan_id
                                and cp.cobra_plan_id = r.cobra_plan_id;

                end loop;

                pc_log.log_error('In Proc', 'AFter Insert..ER ID..' || x_er_ben_plan_id);
                pc_log.log_error('In Proc', 'PLAN ID..' || y.plan_id);
                pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan', 'In Proc3');

     --Insert all the Plan documents in File attachments table
                insert into file_attachments (
                    attachment_id,
                    document_name,
                    document_type,
                    attachment,
                    entity_name,
                    entity_id,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    document_purpose
                )
                    (
                        select
                            attachment_id,
                            document_name,
                            document_type,
                            attachment,
                            entity_name,
                            x_er_ben_plan_id,
				  /* COBRA Plan ID */
                            creation_date,
                            created_by,
                            last_update_date,
                            last_updated_by,
                            decode(document_purpose, 'COBRA Plan Document', 'COBRA_PLAN_DOC', document_purpose)   --- rprabu 22/01/2024 
                        from
                            file_attachments_staging fs
                        where
                                plan_id = y.plan_id
                            and batch_number = p_batch_number
                            and not exists (
                                select
                                    *
                                from
                                    file_attachments
                                where
                                    fs.attachment_id = file_attachments.attachment_id
                            ) -- added by jaggi#10431
                    );

        --Inserting Plan Options and optional COBRA services
                pc_log.log_error('In Proc', 'Insertig Fees and Services Price ID' || l_er_ben_plan_id);
        --For a particular ER only one entry goes into AR_QUOTE_HEADERS
                begin
                    select
                        count(*)
                    into l_header_exist
                    from
                        ar_quote_headers
                    where
                        entrp_id = p_entrp_id;

                exception
                    when no_data_found then
                        l_header_exist := 0;
                end;

                for i in (
                    select
                        *
                    from
                        ar_quote_headers_staging
                    where
                            entrp_id = p_entrp_id /*Ticket#3773*/
                        and batch_number = p_batch_number /*Ticket#3773*/
                ) loop
     --     IF l_header_exist = 0 THEN  -- commented and added below by Joshi for 12283. in case of inactive plan enrollment, there will be records in the ar_quote_header table. 
                    if ( l_header_exist = 0
                    or (
                        nvl(l_inactive_plan_exist, 'N') = 'I'
                        and l_header_exist >= 0
                    ) ) then
                        pc_log.log_error('PC_WEB_COMPLIANCE', 'INSRT_AR_QUOTE_HEADERS');
                        pc_log.log_error('PC_WEB_COMPLIANCE', 'INSRT_AR_QUOTE_HEADERS');
                        pc_web_compliance.insrt_ar_quote_headers(
                            p_quote_name                => null,
                            p_quote_number              => null,
                            p_total_quote_price         => i.total_quote_price, ---Total Annual Fees
                            p_quote_date                => to_char(sysdate, 'mm/dd/rrrr'),
                            p_payment_method            => x.fees_payment_flag,  -- replaced I.PAYMENT_METHOD with X.FEES_PAYMENT_FLAG by Swamy for Ticket#11129
                            p_entrp_id                  => p_entrp_id,
                            p_bank_acct_id              => 0,
                            p_ben_plan_id               => l_er_ben_plan_id,
                            p_user_id                   => p_user_id,
                            p_quote_source              => 'ONLINE',
                            p_product                   => 'COBRA',
                            p_billing_frequency         => i.billing_frequency,
                            p_optional_payment_method   => x.optional_fee_payment_method,             -- Added by Jaggi #11262
                            p_optional_fee_bank_acct_id => x.optional_fee_bank_acct_id,               -- Added by Jaggi #11262
                            x_quote_header_id           => x_quote_header_id,
                            x_return_status             => l_error_status,
                            x_error_message             => l_error_message
                        );

                        pc_log.log_error('PC_WEB_COMPLIANCE', x_error_message);
                        for ii in (
                            select
                                *
                            from
                                ar_quote_lines_staging
                            where
                                quote_header_id = i.quote_header_id
                        ) loop
                            pc_web_compliance.insrt_ar_quote_lines(
                                p_quote_header_id     => x_quote_header_id, -- I.QUOTE_HEADER_ID(commented and added by Joshi for 8864),
                                p_rate_plan_id        => ii.rate_plan_id,
                                p_rate_plan_detail_id => ii.rate_plan_detail_id,
                                p_line_list_price     => ii.line_list_price,
                                p_notes               => 'COBRA ONLINE ENROLLMENT',
                                p_user_id             => p_user_id,
                                x_return_status       => l_error_status,
                                x_error_message       => l_error_message
                            );

            -- Added by Jaggi #12672
                            if ii.rate_plan_name in ( 'OPTIONAL_COBRA_SERVICE_CN', 'OPTIONAL_COBRA_SERVICE_SC', 'OPEN_ENROLLMENT_SUITE'
                            ) then
                                insert into cobra_services_detail (
                                    acc_id,
                                    ben_plan_id,
                                    service_type,
                                    effective_date,
                                    service_selected,
                                    created_by,
                                    creation_date,
                                    last_updated_by,
                                    last_updated_date
                                ) values ( l_acc_id,
                                           l_er_ben_plan_id,
                                           ii.rate_plan_name,
                                           l_date,
                                           'Y',
                                           p_user_id,
                                           sysdate,
                                           p_user_id,
                                           sysdate );

                            end if;

                        end loop;
            /* Quote Lines Loop */
                    end if;--AR Quote HEaders
                end loop;
        /* Quote headers loop */
            end loop;
      /* Plan Loop */
        end loop;
    /* Master Record */
        pc_log.log_error('In Proc', 'Before Contact');
    /* Update Contact Info */
    --Added contact Type and User ID for Online Portal

      -- Added by Joshi for 10430. need to delete existing contacts and reinsert as in case of resubmit
     -- user might update existing  contacts.
        if l_resubmit_flag = 'Y' then
            delete from contact
            where
                contact_id in (
                    select
                        contact_id
                    from
                        contact_leads
                    where
                            entity_id = pc_entrp.get_tax_id(p_entrp_id)
                        and account_type = 'COBRA'
                );

        end if;

        insert into contact (
            contact_id,
            first_name,
            last_name,
            entity_id,
            entity_type,
            email,
            status,
            start_date,
            last_updated_by,
            created_by,
            last_update_date,
            creation_date,
            can_contact,
            contact_type,
            user_id,
            phone,
            fax,
            title,
            account_type
        )
            select
                contact_id,
                substr(first_name,
                       0,
                       instr(first_name, ' ', 1, 1) - 1),
                substr(first_name,
                       instr(first_name, ' ', 1, 1) + 1,
                       length(first_name) - instr(first_name, ' ', 1, 1) + 1),
                entity_id,
                'ENTERPRISE',
                email,
                'A',
                sysdate,
                p_user_id,
                p_user_id,
                sysdate,
                sysdate,
                'Y',
                contact_type,
                null,
                phone_num,
                contact_fax,
                job_title,
                'COBRA'
            from
                contact_leads a
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and not exists (
                    select
                        1
                    from
                        contact b
                    where
                        a.contact_id = b.contact_id
                )     -------- 7783 rprabu 31/10/2019
                and account_type = 'COBRA';

        pc_log.log_error('In Proc', 'Before Contact..Rowinsert' || sql%rowcount);
    /** For all contacts added define contact roles etc */
    --Ticket#6555
        for xx in (
            select
                *
            from
                contact_leads a
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and not exists (
                    select
                        1
                    from
                        contact_role b
                    where
                        a.contact_id = b.contact_id
                )     -------- 7783 rprabu 31/10/2019
                and account_type = 'COBRA'
        ) loop
            insert into contact_role e (
                contact_role_id,
                contact_id,
                role_type,
                account_type,
                effective_date,
                created_by,
                last_updated_by
            ) values ( contact_role_seq.nextval,
                       xx.contact_id,
                       xx.account_type,
                       xx.account_type,
                       sysdate,
                       p_user_id,
                       p_user_id );
      --Especially for compliance we need to have both account type and role type defined
            insert into contact_role e (
                contact_role_id,
                contact_id,
                role_type,
                account_type,
                effective_date,
                created_by,
                last_updated_by
            ) values ( contact_role_seq.nextval,
                       xx.contact_id,
                       xx.contact_type,
                       xx.account_type,
                       sysdate,
                       p_user_id,
                       p_user_id );
      --For all products we want Fee Invoice option also checked
            if xx.contact_type = 'PRIMARY'
            or xx.send_invoice = 1 then
                insert into contact_role e (
                    contact_role_id,
                    contact_id,
                    role_type,
                    account_type,
                    effective_date,
                    created_by,
                    last_updated_by
                ) values ( contact_role_seq.nextval,
                           xx.contact_id,
                           'FEE_BILLING',
                           xx.account_type,
                           sysdate,
                           p_user_id,
                           p_user_id );

            end if;

        end loop;

        pc_log.log_error('In Proc', 'After Contact..insert');

    -- code taken from above loop and brought here
    -- tikcet 9006 Joshi on 04/22/2020
        if l_carrier_notify_flag = 'Y' then     -- added by Jagadeesh ##8471

            insert into file_attachments (
                attachment_id,
                document_name,
                document_type,
                attachment,
                entity_name,
                entity_id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                document_purpose
            )
                (
                    select
                        file_attachments_seq.nextval,-- #8471 Jagadeesh
                        document_name,
                        document_type,
                        attachment,
                        'ACCOUNT',
                        l_acc_id,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        document_purpose
                    from
                        file_attachments_staging
                    where
                            batch_number = p_batch_number
                        and document_purpose like 'TPA%'
                        and plan_id is null
                );

        end if;

     --Added by Jagadeesh on 02/24 #8471
        if l_carrier_notify_flag = 'Y' then
            insert into carrier_notification (
                entrp_id,
                entity_id,
                entity_type,
                plan_number,
                policy_number,
                cariier_name,
                carrier_contact_name,
                carrier_contact_email,
                carrier_phone_no,
                carrier_addr,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            )
                select
                    p_entrp_id,
                    l_er_ben_plan_id,
                    'BEN_PLAN_ENROLLMENT_SETUP',
                    plan_number,
                    policy_number,
                    carrier_name,
                    carrier_contact_name,
                    carrier_contact_email,
                    carrier_phone_no,
                    carrier_addr,
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id
                from
                    compliance_plan_staging
                where
                        batch_number = p_batch_number
                    and entity_id = p_entrp_id;

        end if;

    --Once Plan setup complete update teh complete flag as 1
    -- IF l_error_status = 'S' THEN

 ---9392 rprabu 07/10/2020
        if l_enrolle_type = 'GA' then
            ---9392 rprabu 07/10/2020
            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_account_type  => 'COBRA',
                p_page_no       => '4',
                p_block_name    => 'AUTH_SIGN',
                p_validity      => 'V',
                p_user_id       => null,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

            ---9392 rprabu 07/10/2020
            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_account_type  => 'COBRA',
                p_page_no       => '4',
                p_block_name    => 'AGREEMENT',
                p_validity      => 'V',
                p_user_id       => null,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

        end if;

     -- Added by Joshi for 10430
        if l_inactive_plan_exist = 'I' then
            pc_employer_enroll_compliance.update_inactive_account(l_acc_id, p_user_id);
        else
            update account
            set
                complete_flag = 1,
                account_status = nvl(l_account_status, 3),   -- Added by Swamy for Ticket#12534
                start_date = l_eff_date,  --- Take Over date issued rasied by client 09/05/2022 cp Project
                enrolled_date =
                    case
                        when enrolled_date is null then
                            sysdate
                        else
                            enrolled_date
                    end,--
                submit_by = p_user_id,
                resubmit_flag = 'N'    -- Code moved from PHP, after final submit to Here Added by Swamy for Ticket#12534
            where
                acc_id = l_acc_id;

        end if;

    -- END IF;

      -- Added by Jaggi for Ticket #11086

        pc_employer_enroll_compliance.update_acct_pref(p_batch_number, p_entrp_id);
        select
            broker_id
        into l_broker_id
        from
            table ( pc_broker.get_broker_info_from_acc_id(l_acc_id) );

        if l_broker_id > 0 then
            l_authorize_req_id := pc_broker.get_broker_authorize_req_id(l_broker_id, l_acc_id);
            pc_broker.create_broker_authorize(
                p_broker_id        => l_broker_id,
                p_acc_id           => l_acc_id,
                p_broker_user_id   => null,
                p_authorize_req_id => l_authorize_req_id,
                p_user_id          => p_user_id,
                x_error_status     => l_error_status,
                x_error_message    => l_error_message
            );

        end if;
        -- code ends here by Joshi.

        x_error_status := l_error_status;
        x_error_message := l_error_message;
        x_er_ben_plan_id := l_er_ben_plan_id;
    exception
        when erreur then
            rollback;
            x_error_status := 'E';
            x_error_message := x_error_message
                               || sqlcode
                               || ' '
                               || sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan', 'Error '
                                                                     || x_error_message
                                                                     || ' := '
                                                                     || sqlerrm);
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
            rollback;
    end create_cobra_plan;

  -- Added by Swamy for Ticket#8684 on 19/05/2020
    procedure upsert_erisa_staging (
        p_entrp_id       in number,
        p_batch_number   in number,
        p_state_of_org   in varchar2,
        p_yr_end_date    in varchar2,
        p_entity_type    in varchar2,
        p_name           in varchar2,
        p_affl_flag      in varchar2,
        p_cntrl_grp_flag in varchar2,
        p_aff_name       in varchar2_tbl,
        p_cntrl_grp      in varchar2_tbl,
        p_user_id        in number,
        p_page_validity  in varchar2,
        p_source         in varchar2,
        p_city           in varchar2,
        p_zip            in varchar2,
        p_address        in varchar2,
        x_error_status   out varchar2,
        x_error_message  out varchar2
    ) is

        l_header_id   number;
        l_count       number;
        l_source      varchar2(100);
        v_name        enterprise.name%type;
        v_address     enterprise.address%type;
        v_city        enterprise.city%type;
        v_state       enterprise.state%type;
        v_zip         enterprise.zip%type;
        v_entity_type online_compliance_staging.type_of_entity%type;
        v_acc_id      account.acc_id%type;
    begin
        pc_log.log_error('PC_WEB_ER_RENEWAL.UPSERT_Erisa_STAGING', 'p_entrp_id :='
                                                                   || p_entrp_id
                                                                   || 'p_batch_number :='
                                                                   || p_batch_number
                                                                   || ' p_yr_end_date :='
                                                                   || p_yr_end_date);

        for j in (
            select
                count(*) cnt
            from
                online_compliance_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            l_count := j.cnt;
        end loop;

        for k in (
            select
                source
            from
                online_compliance_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            l_source := k.source;
        end loop;

    /* Header Record */
        if l_count = 0 then
      /* new rec */
            v_acc_id := pc_entrp.get_acc_id(p_entrp_id);
            for j in (
                select
                    entrp_id,
                    name,
                    address,
                    city,
                    state,
                    zip
                from
                    myemploy
                where
                    acc_id = v_acc_id
            ) loop
                v_name := j.name;
                v_address := j.address;
                v_city := j.city;
                v_state := j.state;
                v_zip := j.zip;
            end loop;

            for k in (
                select
                    entity_type
                from
                    enterprise
                where
                    entrp_id = p_entrp_id
            ) loop
                v_entity_type := k.entity_type;
            end loop;   -- Added by Swamy for Ticket#9181

            insert into online_compliance_staging (
                record_id,
                entrp_id,
                state_of_org,
                fiscal_yr_end,
                type_of_entity,
                entity_name_desc,
                affliated_flag,
                cntrl_grp_flag,
                batch_number,
                source,
                city,
                zip,
                address,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date
            ) values ( compliance_staging_seq.nextval,
                       p_entrp_id,
                       nvl(p_state_of_org, v_state),
                       null  --p_yr_end_date Commented and added Null by Jaggi for Ticket#10743 on 18/01/2022
                       ,
                       nvl(p_entity_type, v_entity_type),
                       p_name,
                       p_affl_flag,
                       p_cntrl_grp_flag,
                       p_batch_number,
                       p_source,
                       nvl(p_city, v_city),
                       nvl(p_zip, v_zip),
                       nvl(p_address, v_address),
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate );

            pc_log.log_error('POP Staging', 'After Insert..');
        else
      /* Update Record */
            pc_log.log_error('POP Staging', 'Update' || p_entrp_id);
            update online_compliance_staging
            set
                state_of_org = p_state_of_org,
                fiscal_yr_end = p_yr_end_date,
                type_of_entity = p_entity_type,
                entity_name_desc = p_name,
                affliated_flag = p_affl_flag,
                cntrl_grp_flag = p_cntrl_grp_flag,
                zip = p_zip,
                city = p_city,
                address = p_address,
                last_updated_by = p_user_id,
                last_update_date = sysdate
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number;

        end if;
    /* Insert update loop */
    /* Affliated Employers */
        if l_source = 'RENEWAL' then
            delete from enterprise_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
                and entity_type = 'BEN_PLAN_RENEWALS';

            for i in 1..p_aff_name.count loop
                if p_aff_name(i) is not null then
                    insert into enterprise_staging (
                        entrp_stg_id,
                        entrp_id,
                        en_code,
                        name,
                        batch_number,
                        entity_type,
                        created_by,
                        creation_date
                    ) values ( entrp_staging_seq.nextval,
                               p_entrp_id,
                               10 -- Affliated ER
                               ,
                               p_aff_name(i),
                               p_batch_number,
                               'BEN_PLAN_RENEWALS',
                               p_user_id,
                               sysdate );

                end if;
            end loop;
      /**Control grp **/
            for i in 1..p_cntrl_grp.count loop
                if p_cntrl_grp(i) is not null then
                    insert into enterprise_staging (
                        entrp_stg_id,
                        entrp_id,
                        en_code,
                        name,
                        batch_number,
                        entity_type,
                        created_by,
                        creation_date
                    ) values ( entrp_staging_seq.nextval,
                               p_entrp_id,
                               11 -- Controlled Grp
                               ,
                               p_cntrl_grp(i),
                               p_batch_number,
                               'BEN_PLAN_RENEWALS',
                               p_user_id,
                               sysdate );

                end if; -- Added by Swamy wrt Ticket#6559
            end loop;

        else
      /*Enrollment loop */
            delete from enterprise_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
                and entity_type = 'ONLINE_ENROLLMENT';

            for i in 1..p_aff_name.count loop
                if nvl(
                    p_aff_name(i),
                    '*'
                ) <> '*' then
                    insert into enterprise_staging (
                        entrp_stg_id,
                        entrp_id,
                        en_code,
                        name,
                        batch_number,
                        entity_type,
                        created_by,
                        creation_date
                    ) values ( entrp_staging_seq.nextval,
                               p_entrp_id,
                               10 -- Affliated ER
                               ,
                               p_aff_name(i),
                               p_batch_number,
                               'ONLINE_ENROLLMENT',
                               p_user_id,
                               sysdate );

                end if;
            end loop;
      /**Control Group **/
            for i in 1..p_cntrl_grp.count loop
                if nvl(
                    p_cntrl_grp(i),
                    '*'
                ) <> '*' then
                    insert into enterprise_staging (
                        entrp_stg_id,
                        entrp_id,
                        en_code,
                        name,
                        batch_number,
                        entity_type,
                        created_by,
                        creation_date
                    ) values ( entrp_staging_seq.nextval,
                               p_entrp_id,
                               11-- Controlled Grp
                               ,
                               p_cntrl_grp(i),
                               p_batch_number,
                               'ONLINE_ENROLLMENT',
                               p_user_id,
                               sysdate );

                end if;
            end loop;

        end if;
    /*renewal enrollment If */
        x_error_status := 'S';
    exception
        when others then
            x_error_status := 'E';
            pc_log.log_error('PC_WEB_ER_RENEWAL.UPSERT_Erisa_STAGING', sqlerrm);
    end upsert_erisa_staging;

--As per Pier 9095 Added by Jagadeesh On 05/19/2020
    function get_compliance_renewal_data (
        p_batch_number number,
        p_entrp_id     number
    ) return compliance_renewal_data_t
        pipelined
        deterministic
    is
        l_compliance_renewal_data compliance_renewal_data_row_t;
        v_plan_end_date           date;
    begin
        for x in (
            select
                state_of_org,
                fiscal_yr_end,
                type_of_entity,
                company_tax,
                decode(company_tax, 'C', 'C Corporation', 'P', 'Partnership') company_tax_desc  -- Added by Swamy for Ticket#12711
                     --,Decode(COMPANY_TAX,'C',Decode(PLAN_TYPE,'COMP_POP','Company','Corporation'),'P','Partnership') COMPANY_TAX_DESC --added by jaggi #10577
                ,
                entity_name_desc,
                affliated_flag,
                cntrl_grp_flag,
                plan_id,
                plan_type,
                takeover_flag,
                plan_number,
                plan_name,
                plan_start_date,
                plan_end_date,
                short_plan_yr_flag,
                flg_plan_name,
                flg_pre_adop_pln,
                ga_flag,
                ga_id,
                org_eff_date,
                effective_date,
                eff_date_sterling,
                a.no_of_eligible,
                a.no_off_ees,
                b.erissa_erap_doc_type,
                (
                    select distinct
                        total_quote_price
                    from
                        ar_quote_headers_staging
                    where
                            entrp_id = a.entrp_id
                        and batch_number = p_batch_number
                )                                                             total_cost,
                plan_doc_ndt_flag,
                a.last_update_date,
                a.address,
                a.city,
                a.zip,
                a.state_main_office      -- Added by Swamy for Ticket#11037
                ,
                a.state_govern_law        -- Added by Swamy for Ticket#11037
                ,
                a.affliated_diff_ein       -- Added by Swamy for Ticket#11037
                ,
                a.type_entity_other         -- Added by Swamy for Ticket#11037
                ,
                b.short_plan_yr_end_date  -- Added by Joshi for 12135.
            from
                online_compliance_staging a,
                compliance_plan_staging   b
            where
                    a.batch_number = b.batch_number
                and a.batch_number = p_batch_number
                and a.entrp_id = p_entrp_id
        ) loop
            l_compliance_renewal_data.state_of_org := x.state_of_org;
            l_compliance_renewal_data.fiscal_yr_end := x.fiscal_yr_end;
            l_compliance_renewal_data.type_of_entity := x.type_of_entity;
            l_compliance_renewal_data.company_tax := x.company_tax;
            l_compliance_renewal_data.company_tax_desc := x.company_tax_desc;
            l_compliance_renewal_data.entity_name_desc := x.entity_name_desc;
            l_compliance_renewal_data.affliated_flag := x.affliated_flag;
            l_compliance_renewal_data.cntrl_grp_flag := x.cntrl_grp_flag;
            l_compliance_renewal_data.plan_id := x.plan_id;
            l_compliance_renewal_data.plan_type := x.plan_type;
            l_compliance_renewal_data.takeover_flag := x.takeover_flag;
            l_compliance_renewal_data.plan_number := x.plan_number;
            l_compliance_renewal_data.plan_name := x.plan_name;              -- Added by Jaggi #9905
            l_compliance_renewal_data.short_plan_yr_flag := x.short_plan_yr_flag;
            l_compliance_renewal_data.flg_plan_name := x.flg_plan_name;
            l_compliance_renewal_data.flg_pre_adop_pln := x.flg_pre_adop_pln;
            l_compliance_renewal_data.ga_flag := x.ga_flag;
            l_compliance_renewal_data.ga_id := x.ga_id;
            l_compliance_renewal_data.org_eff_date := x.org_eff_date;
            l_compliance_renewal_data.effective_date := x.effective_date;
            l_compliance_renewal_data.eff_date_sterling := x.eff_date_sterling;
            l_compliance_renewal_data.no_of_eligible := x.no_of_eligible;
            l_compliance_renewal_data.no_off_ees := x.no_off_ees;
            l_compliance_renewal_data.erissa_erap_doc_type := x.erissa_erap_doc_type;
            l_compliance_renewal_data.total_cost := x.total_cost;
            l_compliance_renewal_data.plan_doc_ndt_flag := x.plan_doc_ndt_flag;
            l_compliance_renewal_data.address := x.address;
            l_compliance_renewal_data.city := x.city;
            l_compliance_renewal_data.zip := x.zip;
            l_compliance_renewal_data.state_main_office := x.state_main_office;    -- Added by Swamy for Ticket#11037
            l_compliance_renewal_data.state_govern_law := x.state_govern_law;     -- Added by Swamy for Ticket#11037
            l_compliance_renewal_data.affliated_diff_ein := x.affliated_diff_ein;    -- Added by Swamy for Ticket#11037
            l_compliance_renewal_data.type_entity_other := x.type_entity_other;      -- Added by Swamy for Ticket#11037
            l_compliance_renewal_data.short_plan_yr_end_date := x.short_plan_yr_end_date;  -- Added by Joshi for 12135.

            if x.plan_type = 'ERISA_WRAP' then
                l_compliance_renewal_data.plan_start_date := x.plan_start_date;
                l_compliance_renewal_data.plan_end_date := x.plan_end_date;
            else
                l_compliance_renewal_data.plan_start_date := x.plan_start_date;
                l_compliance_renewal_data.plan_end_date := x.plan_end_date;

           /*
             FOR Y IN (SELECT MAX(PLAN_END_DATE) PLAN_END_DATE --, MAX(B.CREATION_DATE) CREATION_DATE
                      FROM  BEN_PLAN_ENROLLMENT_SETUP B, ACCOUNT A
                     WHERE  A. ACC_ID = B.ACC_ID
                       AND  A.ENTRP_ID IS NOT NULL
                       AND  A.ENTRP_ID = P_ENTRP_ID  )
          LOOP
              v_plan_end_date := Y.PLAN_END_DATE;
              --IF TO_DATE(X.PLAN_END_DATE,'mm/dd/yyyy') >= v_plan_end_date  THEN
                 L_COMPLIANCE_RENEWAL_DATA.PLAN_START_DATE :=  X.PLAN_START_DATE;
                 L_COMPLIANCE_RENEWAL_DATA.PLAN_END_DATE   :=  X.PLAN_END_DATE;
            --ELSE
                L_COMPLIANCE_RENEWAL_DATA.PLAN_START_DATE  := TO_CHAR( v_plan_end_date+1, 'mm/dd/yyyy');
                L_COMPLIANCE_RENEWAL_DATA.PLAN_END_DATE    := TO_CHAR( Add_months(v_plan_end_date+1,12)-1, 'mm/dd/yyyy');
            END IF;

          END LOOP;
          */
            end if;

            pipe row ( l_compliance_renewal_data );
        end loop;
    end get_compliance_renewal_data;

 --Added by Swamy on 25/06/20 #9242
 -- The Page_validity table is not used because it is at the global level,so we are using online_FORM_5500_plan_staging to update for Plan level as form5500 has multiple plans
 -- if the user uploads documents with same name, need to validate the duplicate file name and highlight the particular plan.
 -- So this procedure is to update page_validity column at the plan level using online_FORM_5500_plan_staging table.
    procedure update_plan_staging (
        p_entrp_id             in number,
        p_batch_number         in number,
        p_enrollment_detail_id in number,
        p_page_validity        in varchar2,
        x_error_status         out varchar2,
        x_error_message        out varchar2
    ) is
    begin
        x_error_status := 'S';
        update online_form_5500_plan_staging
        set
            page_validity = p_page_validity
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number
            and enrollment_detail_id = p_enrollment_detail_id;

    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.update_plan_staging', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
            rollback;
    end update_plan_staging;

 --Added by rprabu  on 05/08/20 #9141
    procedure update_app_signed_by_staging (
        p_entrp_id      in number,
        p_batch_number  in number,
        p_account_type  in varchar2,
        p_sign_type     in varchar2, -----who is signing
        p_contact_name  in varchar2,
        p_email         in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
        l_account_status    number(2);
        l_acct_payment_fees varchar2(100);
    begin
        x_error_status := 'S';
        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.update_app_signed_by_staging', 'p_account_type' || p_account_type);
        for i in (
            select
                acc_id,
                enrolle_type,
                enrolled_by
            from
                account
            where
                entrp_id = p_entrp_id
        ) loop
            if p_account_type in ( 'COBRA', 'POP', 'ERISA_WRAP' ) then
                select
                    acct_payment_fees
                into l_acct_payment_fees
                from
                    online_compliance_staging
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number;

                update online_compliance_staging
                set
                    contact_name = decode(p_sign_type, 'EMPLOYER', p_contact_name, null),
                    email = decode(p_sign_type, 'EMPLOYER', p_email, null),
                    signed_by = decode(p_sign_type, 'EMPLOYER', i.acc_id, i.enrolled_by),
                    sign_type = p_sign_type
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number;

            end if;

            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.update_app_signed_by_staging', 'i.enrolle_type'
                                                                                           || i.enrolle_type
                                                                                           || ' L_Acct_payment_fees :='
                                                                                           || l_acct_payment_fees
                                                                                           || ' P_Sign_Type :='
                                                                                           || p_sign_type);
       -- If cond. for Broker added by Swamy for Ticket#9617
            if i.enrolle_type = 'BROKER' then   -- Broker added by Swamy for Ticket#9617
                if
                    l_acct_payment_fees = 'BROKER'
                    and p_sign_type = 'BROKER'
                then
                    l_account_status := 10;                     -- Pending Broker Submit
                    pc_employer_enroll.upsert_page_validity(
                        p_batch_number  => p_batch_number,
                        p_entrp_id      => p_entrp_id,
                        p_account_type  => p_account_type,
                        p_page_no       => 4,
                        p_block_name    => 'AUTH_SIGN',
                        p_validity      => 'V',
                        p_user_id       => null,
                        x_error_status  => x_error_status,
                        x_error_message => x_error_message
                    );

                elsif
                    l_acct_payment_fees = 'BROKER'
                    and p_sign_type = 'EMPLOYER'
                then
                    l_account_status := 6;                      --Pending Signature
                elsif (
                    l_acct_payment_fees in ( 'EMPLOYER', 'BROKER' )
                    and p_sign_type = 'EMPLOYER'
                ) then
                    l_account_status := 8;                      --Pending payment and Signature
                    pc_employer_enroll.upsert_page_validity(
                        p_batch_number  => p_batch_number,
                        p_entrp_id      => p_entrp_id,
                        p_account_type  => p_account_type,
                        p_page_no       => '3',
                        p_block_name    => 'INVOICING_PAYMENT',
                        p_validity      => 'I',
                        p_user_id       => null,
                        x_error_status  => x_error_status,
                        x_error_message => x_error_message
                    );
        -- Added by Swamy for Ticket#11604 05/05/2023
        -- POP Added by Jaggi for Ticket#11616 05/18/2023
                elsif
                    p_account_type in ( 'COBRA', 'POP', 'ERISA_WRAP' )
                    and l_acct_payment_fees = 'GA'
                    and p_sign_type = 'EMPLOYER'
                then  --ERISA_WRAP Added Swamy 07022024 #12012
                    l_account_status := 6;    --Pending Signature
                elsif
                    p_account_type in ( 'COBRA', 'POP' )
                    and l_acct_payment_fees = 'GA'
                    and p_sign_type = 'BROKER'
                then
                    l_account_status := 3;    -- Pending Activation
                end if;
            else
                if
                    l_acct_payment_fees in ( 'GA' )
                    and p_sign_type in ( 'GA' )
                then
                    l_account_status := 9;                     ---------Pending GA Submit
                    pc_employer_enroll.upsert_page_validity(
                        p_batch_number  => p_batch_number,
                        p_entrp_id      => p_entrp_id,
                        p_account_type  => p_account_type,
                        p_page_no       => 4,
                        p_block_name    => 'AUTH_SIGN',
                        p_validity      => 'V',
                        p_user_id       => null,
                        x_error_status  => x_error_status,
                        x_error_message => x_error_message
                    );

                elsif
                    l_acct_payment_fees in ( 'GA' )
                    and p_sign_type = 'EMPLOYER'
                then
                    l_account_status := 6;                      ----------Pending Signature
                elsif
                    l_acct_payment_fees in ( 'EMPLOYER', 'GA' )
                    and p_sign_type = 'EMPLOYER'
                then
                    l_account_status := 8;                      ---------Pending payment and Signature
			-----------9392 13/10/2020 p_account_type
                    pc_employer_enroll.upsert_page_validity(
                        p_batch_number  => p_batch_number,
                        p_entrp_id      => p_entrp_id,
                        p_account_type  => p_account_type,
                        p_page_no       => '3',
                        p_block_name    => 'INVOICING_PAYMENT',
                        p_validity      => 'I',
                        p_user_id       => null,
                        x_error_status  => x_error_status,
                        x_error_message => x_error_message
                    );
        -- Added by Swamy for Ticket#11604 05/05/2023
        -- POP Added by Jaggi for Ticket#11616 05/18/2023
                elsif
                    p_account_type in ( 'COBRA', 'POP', 'ERISA_WRAP' )
                    and l_acct_payment_fees = 'BROKER'
                    and p_sign_type = 'EMPLOYER'
                then  --ERISA_WRAP Added Swamy 07022024 #12012
                    l_account_status := 6;      --Pending Signature
                elsif
                    p_account_type in ( 'COBRA', 'POP' )
                    and l_acct_payment_fees = 'BROKER'
                    and p_sign_type = 'GA'
                then
                    l_account_status := 3;      -- Pending Activation
                end if;
            end if;

            update account
            set
                signed_by = decode(p_sign_type, 'EMPLOYER', i.acc_id, i.enrolled_by),
                ga_id = decode(i.enrolle_type, 'BROKER', null, i.enrolled_by),  -- Decode for Broker added by Swamy for Ticket#9617
                sign_type = p_sign_type,
                account_status = nvl(l_account_status, account_status)
            where
                entrp_id = p_entrp_id;

        end loop;

    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.update_app_signed_by_staging', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
            rollback;
    end update_app_signed_by_staging;

----------9141  done by rprabu  on 13/08/2020
    function get_employer_details (
        p_entrp_id     in number,
        p_account_type in varchar2,
        p_source       in varchar2                -- Added by Swamy for Tiecket#11364(Broker)
    ) return employer_details_rec_t
        pipelined
        deterministic
    is
        l_record employer_details_rec;
    begin
        for x in (
            select
                acc_id,
                a.acc_num,
                account_status,
                c.description,
                enrolle_type,
                enrolled_by,
                signed_by,
                sign_type,
                a.renewed_by,
                a.signature_account_status,
                a.renewal_sign_type,
                a.renewal_signed_by,
                a.renewed_by_id,
                a.renewed_by_user_id,
                a.renewed_date,
                a.submit_by   --- Added a.renewed_by,a.Signature_account_staus by Swamy for Ticket#11364(Broker)
                ,
                a.account_type,
                a.entrp_id  -- Added by Swamy for Ticket#12776
            from
                account    a,
                enterprise b,
                lookups    c
            where
                    to_char(a.account_status) = ( c.lookup_code )
                and lookup_name = 'ACCOUNT_STATUS'
                and a.entrp_id = b.entrp_id
                and a.account_type = p_account_type
                and a.entrp_id = p_entrp_id
        ) loop
            l_record.acc_id := x.acc_id;
            l_record.acc_num := x.acc_num;
            l_record.account_status := x.account_status;
            l_record.acccount_description := x.description;
            l_record.enrolle_type := x.enrolle_type;
            l_record.enrolled_by := x.enrolled_by;
            l_record.signed_by := x.signed_by;
            l_record.sign_type := x.sign_type;
            l_record.renewed_by := x.renewed_by;                 -- Added by Swamy for Ticket#11364(Broker)
            l_record.signature_account_status := x.signature_account_status;   -- Added by Swamy for Ticket#11364(Broker)
            l_record.renewed_by_id := x.renewed_by_id;              -- Added by Swamy for Ticket#11364(Broker)
            l_record.renewal_signed_by := x.renewal_signed_by;              -- Added by Swamy for Ticket#11364(Broker)
            l_record.renewal_sign_type := x.renewal_sign_type;          -- Added by Swamy for Ticket#11364(Broker)
            l_record.renewed_by_user_id := x.renewed_by_user_id;         -- Added by Swamy for Tiecket#11364(Broker)
            l_record.submit_by := x.submit_by;                  -- Added by Swamy for Ticket#11636
            l_record.renewal_flag := 'N';                          -- Added by Swamy for Ticket#11636
            if trunc(sysdate) < add_business_days(5, x.renewed_date) then         -- Added by Swamy for Ticket#11636
                l_record.renewal_flag := 'Y';
            end if;

            l_record.inactive_plan_flag := nvl(
                pc_employer_enroll_compliance.get_resubmit_inactive_flag(x.entrp_id),
                'N'
            );  -- Added by Swamy for Ticket#12776
            l_record.account_type := x.account_type;     -- Added by Swamy for Ticket#12776
            pipe row ( l_record );
        end loop;
    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.Get_employer_details', sqlerrm);
    end get_employer_details;

        ----------9141  done by rprabu  on 13/08/2020
    function get_client_details (
        p_entity_id   in number,
        p_entity_type in varchar2    -- Added by jaggi for Ticket#10848 on 05/09/2022
        ,
        p_acct_status in varchar2
    )   -- Added by Swamy for Ticket#9862 on 03/06/2021
     return client_details_rec_t
        pipelined
        deterministic
    is
        l_record client_details_rec;
    begin
        for x in (
            select
                acc_status,
                description,
                no_of_employers
            from
                (
                    select
                        account_status acc_status,
                        count(*)       no_of_employers
                    from
                        account
                    where
                            p_entity_id = decode(p_acct_status,
                                                 'A',
                                                 decode(p_entity_type, 'G', ga_id, 'B', broker_id),
                                                 'P',
                                                 enrolled_by)  -- Added by Swamy for Ticket#9862 on 03/06/2021
                        and entrp_id is not null
                    group by
                        account_status
                )       a,
                lookups b
            where
                    lookup_name = 'ACCOUNT_STATUS'
                and acc_status = lookup_code
        ) loop
            l_record.account_status := x.acc_status;
            l_record.account_descrtiption := x.description;
            l_record.no_of_clients := x.no_of_employers;
            pipe row ( l_record );
        end loop;
    end get_client_details;

----------Ticket# 9396 of  GA development ticket 9141  done by rprabu  on 13/08/2020
    function get_ein_details (
        p_ein          in varchar2,
        p_account_type in varchar2
    ) return ein_details_rec_t
        pipelined
        deterministic
    is
        l_record enterprise%rowtype;
    begin
        for ein_rec in (
            select
                a.address,
                a.name,
                a.city,
                a.state,
                a.zip,
                a.entrp_contact,
                a.entrp_phones,
                a.entrp_fax,
                a.industry_type,
                a.card_allowed
            from
                enterprise a,
                account    b
            where
                    a.entrp_code = p_ein
                and a.entrp_id = b.entrp_id
                and b.account_type = nvl(p_account_type, b.account_type)
            order by
                a.entrp_id
        ) loop
            l_record.address := ein_rec.address;
            l_record.name := ein_rec.name;
            l_record.city := ein_rec.city;
            l_record.state := ein_rec.state;
            l_record.zip := ein_rec.zip;
            l_record.entrp_contact := ein_rec.entrp_contact;
            l_record.entrp_phones := ein_rec.entrp_phones;
            l_record.entrp_fax := ein_rec.entrp_fax;
            l_record.industry_type := ein_rec.industry_type;
            l_record.card_allowed := ein_rec.card_allowed;
            pipe row ( l_record );
        end loop;
    end get_ein_details;

--- added by Joshi on 10/12/2020  for Ticket#9392
    procedure insert_comp_staging (
        p_batch_number in number,
        p_entrp_id     in number,
        p_account_type in varchar2,
        p_user_id      in number
    ) is
        l_count integer;
    begin
        select
            count(*)
        into l_count
        from
            online_compliance_staging
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

        if l_count = 0 then
            insert into online_compliance_staging (
                record_id,
                entrp_id,
                batch_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date
            ) values ( compliance_staging_seq.nextval,
                       p_entrp_id,
                       p_batch_number,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate );

        end if;

   -- Insert into ar_quoter_header_staging table
        select
            count(*)
        into l_count
        from
            ar_quote_headers_staging
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

        if l_count = 0 then
            insert into ar_quote_headers_staging (
                quote_header_id,
                total_quote_price,
                entrp_id,
                batch_number,
                billing_frequency,
                account_type,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date
            ) values ( compliance_quote_seq.nextval,
                       0,
                       p_entrp_id,
                       p_batch_number,
                       null,
                       p_account_type,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate );

        end if;

        select
            count(*)
        into l_count
        from
            compliance_plan_staging
        where
                entity_id = p_entrp_id
            and batch_number = p_batch_number;

        if l_count = 0 then
            insert into compliance_plan_staging (
                plan_id,
                entity_id,
                batch_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                page_validity
            ) values ( compliance_plan_seq.nextval,
                       p_entrp_id,
                       p_batch_number,
                       p_user_id,
                       sysdate,
                       p_batch_number,
                       sysdate,
                       'I' );

        end if;

    end insert_comp_staging;

 -- Added by #10430
    function is_inactive_plan_exists (
        p_ein in varchar2
    ) return varchar2 is
        l_inactive_plan_fsahra_exist varchar2(1) := 'N';
        l_inactive_plan_comp_exist   varchar2(1) := 'N';
    begin
        for x in (
            select
                b.acc_id,
                b.plan_type,
                max(b.plan_end_date) plan_end_date
            from
                enterprise                e,
                ben_plan_enrollment_setup b,
                account                   a
            where
                    e.entrp_id = b.entrp_id
                and replace(entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                 --AND ROWNUM = 1
                and a.account_type in ( 'FSA', 'HRA' )
                and plan_type not in ( 'TRN', 'PKG', 'UA1' )
                and a.account_status <> '4'
            group by
                b.acc_id,
                b.plan_type
            union
            select
                b.acc_id,
                'TRN',
                max(b.end_date) plan_end_date
            from
                enterprise        e,
                ben_plan_renewals b,
                account           a
            where
                    e.entrp_id = a.entrp_id
                and a.acc_id = b.acc_id
                and replace(entrp_code, '-') = replace(p_ein, '-')
                and a.account_type in ( 'FSA', 'HRA' )
                and plan_type in ( 'TRN', 'PKG', 'UA1' )
                and a.account_status <> '4'
            group by
                b.acc_id
        ) loop
            if trunc(sysdate) - x.plan_end_date <= 365 then
                l_inactive_plan_fsahra_exist := 'N';
                exit;
            end if;

            l_inactive_plan_fsahra_exist := 'Y';
        end loop;

        pc_log.log_error('IS_INACTIVE_PLAN_EXISTS l_inactive_plan_fsahra_Exist: ', l_inactive_plan_fsahra_exist);
        for x in (
            select
                b.acc_id,
                null,
                max(b.plan_end_date) plan_end_date
            from
                enterprise                e,
                ben_plan_enrollment_setup b,
                account                   a
            where
                    e.entrp_id = b.entrp_id
                and replace(entrp_code, '-') = replace(p_ein, '-')
                and a.entrp_id = b.entrp_id
                 --AND ROWNUM = 1
                and a.account_type not in ( 'SBS', 'CMP', 'RB', 'ACA', 'HSA',
                                            'FSA', 'HRA' )
                and a.account_status <> '4'
            group by
                b.acc_id
        ) loop
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.IS_INACTIVE_PLAN_EXISTS difference:  ',
                             abs(sysdate - x.plan_end_date));
            if pc_account.get_account_type(x.acc_id) = 'FORM_5500' then
        -- For FORM5500 resubmit option is changed from 365 to 730 days as per Ticket#11131
                if trunc(sysdate) - x.plan_end_date >= 730 then
                    l_inactive_plan_comp_exist := 'Y';
                    exit;
                end if;

            elsif
                x.plan_end_date < sysdate
                and abs(sysdate - x.plan_end_date) > 365
            then
                l_inactive_plan_comp_exist := 'Y';
                exit;
            end if;

            l_inactive_plan_comp_exist := 'N';
        end loop;

        pc_log.log_error('IS_INACTIVE_PLAN_EXISTS l_inactive_plan_comp_Exist: ', l_inactive_plan_comp_exist);
        if l_inactive_plan_comp_exist = 'Y'
        or l_inactive_plan_fsahra_exist = 'Y' then
            return 'Y';
        else
            return 'N';
        end if;

    exception
        when others then
            return 'N';
    end is_inactive_plan_exists;

-- added by jaggi
    function get_er_inactive_plans (
        p_ein in varchar2
    ) return accounts_t
        pipelined
        deterministic
    is
        l_record  accounts_row_t;
        p_user_id number;
    begin
        for x in (
            select
                e.entrp_code,
                a.acc_id,
                acc_num,
                account_type,
                a.entrp_id,
                max(plan_start_date) start_date,
                max(plan_end_date)   plan_end_date  -- Added by swamy for Ticket#9384
            from
                account                   a,
                ben_plan_enrollment_setup b,
                enterprise                e
            where
                    a.acc_id = b.acc_id
                and a.entrp_id = b.entrp_id
                and a.entrp_id = e.entrp_id
                and replace(e.entrp_code, '-') = replace(p_ein, '-')
                and plan_type not in ( 'TRN', 'PKG', 'UA1' )
                and a.account_status <> '4'
                and a.account_type <> 'HSA'
            group by
                e.entrp_code,
                a.acc_id,
                acc_num,
                account_type,
                a.entrp_id
            having
                sysdate - max(plan_end_date) > 365
        ) loop
            l_record.entrp_code := x.entrp_code;
            l_record.acc_id := x.acc_id;
            l_record.acc_num := x.acc_num;
            l_record.account_type := x.account_type;
            l_record.entrp_id := x.entrp_id;
            l_record.start_date := x.start_date;
            l_record.plan_end_date := x.plan_end_date;
            pipe row ( l_record );
        end loop;
    end get_er_inactive_plans;

    function get_resubmit_inactive_flag (
        p_entrp_id number
    ) return varchar2 is
        ls_return_flag varchar2(1) := 'N';
        l_ben_plan_cnt number;
    begin
        for x in (
            select
                'R' return_flag
            from
                account    a,
                enterprise e
            where
                    a.entrp_id = e.entrp_id
                and a.entrp_id = p_entrp_id
                and nvl(a.resubmit_flag, 'N') = 'Y'
        )
                        --AND TRUNC(SYSDATE) - TRUNC(A.ENROLLED_DATE) < 30
                       -- AND A.ACCOUNT_STATUS = 3 )
         loop
            ls_return_flag := x.return_flag;
            return ls_return_flag;
        end loop;

        select
            count(*)
        into l_ben_plan_cnt
        from
            ben_plan_enrollment_setup
        where
            entrp_id = p_entrp_id;

        if l_ben_plan_cnt = 0 then
            return 'N';
        end if;
        for x in (
            select
                b.acc_id,
                b.plan_type,
                max(b.plan_end_date) plan_end_date
            from
                enterprise                e,
                ben_plan_enrollment_setup b,
                account                   a
            where
                    e.entrp_id = b.entrp_id
                and a.entrp_id = p_entrp_id
                and a.entrp_id = b.entrp_id
                 --AND ROWNUM = 1
                and a.account_type in ( 'FSA', 'HRA' )
                and plan_type not in ( 'TRN', 'PKG', 'UA1' )
                and a.account_status <> '4'
            group by
                b.acc_id,
                b.plan_type
            union
            select
                b.acc_id,
                'TRN',
                max(b.end_date) plan_end_date
            from
                ben_plan_renewals b,
                account           a
            where
                    a.acc_id = b.acc_id
                and a.entrp_id = p_entrp_id
                and a.account_type in ( 'FSA', 'HRA' )
                and b.plan_type in ( 'TRN', 'PKG', 'UA1' )
                and a.account_status <> '4'
            group by
                b.acc_id
            union
            select
                b.acc_id,
                null,
                max(b.plan_end_date) plan_end_date
            from
                enterprise                e,
                ben_plan_enrollment_setup b,
                account                   a
            where
                    e.entrp_id = b.entrp_id
                and a.entrp_id = p_entrp_id
                and a.entrp_id = b.entrp_id
                 --AND ROWNUM = 1
                and a.account_type not in ( 'SBS', 'CMP', 'RB', 'ACA', 'HSA',
                                            'FSA', 'HRA' )
                and a.account_status <> '4'
            group by
                b.acc_id
        ) loop
            if pc_account.get_account_type_from_entrp_id(p_entrp_id) = 'FORM_5500' then
            -- For FORM5500 resubmit option is changed from 365 to 730 days as per Ticket#11131
                if trunc(sysdate) - x.plan_end_date <= 730 then
                    ls_return_flag := 'N';
                else
                    ls_return_flag := 'I';
                end if;

            else
                if trunc(sysdate) - x.plan_end_date <= 365 then
                    ls_return_flag := 'N';
                else
                    ls_return_flag := 'I';       -- Added by Joshi #11250
                end if;
            end if;
        end loop;

        return ls_return_flag;
    end get_resubmit_inactive_flag;

-- Added by Joshi for 10430
    procedure update_inactive_account (
        p_acc_id  number,
        p_user_id number
    ) is
    begin
        for x in (
            select
                acc_id
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            update account
            set
                complete_flag = 1,
                account_status = decode(account_status, 11, 11, 3), -- Added Decode 11, by swamy for Ticket#12309
                id_verified = null,
                last_updated_by = p_user_id,
                last_update_date = sysdate,
                verified_date = null,
                verified_by = null,
                verified_by_sales = null,      -- added by Sam #11716  
                verified_sales_date = null,      -- added by Sam #11716       
                id_verified_sales = null,       -- added by Sam #11716  
                resubmit_flag = 'N'    -- Code moved from PHP, after final submit to Here Added by Swamy for Ticket#12534
            where
                acc_id = x.acc_id;

        end loop;
    end update_inactive_account;

-- Added by Joshi for 10430

    function get_inactive_not_enrolled_plans (
        p_acc_id number
    ) return plan_type_rec_t
        pipelined
        deterministic
    is
        l_record plan_type_rec;
    begin
        for x in (
            select
                lookup_code,
                description
            from
                table ( pc_employer_enroll.get_fsa_plan_type )
            where
                lookup_code not in ( 'TRN', 'PKG', 'UA1' )
                and lookup_code not in (
                    select
                        plan_type
                    from
                        account                   a, ben_plan_enrollment_setup b
                    where
                            a.acc_id = b.acc_id
                        and a.acc_id = p_acc_id
                        and plan_type not in ( 'TRN', 'PKG', 'UA1' )
                        and a.account_type in ( 'FSA', 'HRA' )
                    group by
                        plan_type
                    having
                        sysdate - max(plan_end_date) < 365
                )
            union
            select
                lookup_code,
                description
            from
                table ( pc_employer_enroll.get_fsa_plan_type ) l
            where
                l.lookup_code in ( 'TRN', 'PKG', 'UA1' )
                and not exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = p_acc_id
                        and plan_type = l.lookup_code
                )
        ) loop
            l_record.lookup_code := x.lookup_code;
            l_record.description := x.description;
            pipe row ( l_record );
        end loop;
    end get_inactive_not_enrolled_plans;

-- Added by Jaggi for 10742
    function get_amendment_plans (
        p_tax_id in varchar2
    ) return get_amendment_plans_rec_t
        pipelined
        deterministic
    is
        l_record get_amendment_plans_rec;
        l_cnt    number;
    begin
        for x in (
            select
                a.account_type,
                a.acc_id,
                meaning
            from
                account    a,
                enterprise e,
                lookups    l
            where
                    a.entrp_id = e.entrp_id
                and l.lookup_code = a.account_type
                and lookup_name = 'AMENDMENT_FEE'
                and e.entrp_code = p_tax_id
                and account_status = 1
        ) loop
            l_record.account_type := x.account_type;
            l_record.acc_id := x.acc_id;
            l_record.fee := x.meaning;
            if x.account_type = 'POP' then
                select
                    count(*)
                into l_cnt
                from
                    ben_plan_enrollment_setup b
                where
                        b.acc_id = x.acc_id
                    and b.status = 'A'
                    and upper(b.plan_type) like 'COMP_POP%'
                    and trunc(b.plan_end_date) > trunc(sysdate);

                if l_cnt = 0 then
                    l_record.account_type := null;
                end if;
            end if;

            if l_record.account_type is not null then
                pipe row ( l_record );
            end if;
        end loop;
    end get_amendment_plans;

-- Added by Swamy for Ticket#10747
-- The bank details should not prefect the data during 2nd time renewal for Broker user.
-- The data is prefetched from staging table, during 2nd time renewal the same data is prefetched from staging table.In order to avaiod 2nd time prefetching the bank details, making the bank details as null for Broker user.
    procedure update_broker_bank_stage (
        p_entrp_id     in number,
        p_batch_number in number,
        p_user_id      in number
    ) is
        l_last_update_date date;
        l_entity_type      varchar2(50);
        l_broker_id        number;
    begin
        pc_broker.get_broker_id(p_user_id, l_entity_type, l_broker_id);
        pc_log.log_error('PC_EMPLOYER_ENROLL_compliance.update_broker_bank_stage..ID', 'In p_user_id' || p_user_id);
        if nvl(l_entity_type, '*') = 'BROKER' then
            for j in (
                select
                    last_update_date
                from
                    online_compliance_staging
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number
            ) loop
                l_last_update_date := j.last_update_date;
            end loop;

            l_last_update_date := trunc(nvl(l_last_update_date, sysdate));
            if ( ( trunc(sysdate) - l_last_update_date ) > pc_web_er_renewal.g_prior_days ) then
                update online_compliance_staging
                set
                    bank_acc_type = null,
                    routing_number = null,
                    bank_acc_num = null,
                    bank_name = null
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number
                    and source = 'RENEWAL';

            end if;

        end if;

    end update_broker_bank_stage;

-- Added by Jaggi for Ticket  11086
    function get_acc_preference_staging (
        p_batch_number in number,
        p_entrp_id     in number,
        p_source       in varchar2
    ) return tbl_account_pref_staging_t
        pipelined
    is

        l_record          tbl_account_pref_staging_row;
        l_sql             varchar2(4000);
        l_column_list     varchar2(4000);
        l_sql_cur         l_cursor;
        l_staging_cnt     number;
        l_pref_cnt        number;
        l_comp_plan_exits varchar2(1) default 'N';
    begin
        for x in (
            select
                acc_id,
                account_type
            from
                account
            where
                entrp_id = p_entrp_id
        ) loop
            pc_log.log_error('Get_Acc_Preference_Staging', 'x.acc_id: '
                                                           || x.acc_id
                                                           || 'x.account_type: '
                                                           || x.account_type);

    -- added by Jaggi #11086
            if x.account_type = 'POP' then
                for j in (
                    select
                        *
                    from
                        compliance_plan_staging s
                    where
                            entity_id = p_entrp_id
                        and batch_number = p_batch_number
                        and plan_type like '%COMP%'
                ) loop
                    l_comp_plan_exits := 'Y';
                end loop;

            end if;

    -- get the column list
            if
                x.account_type = 'POP'
                and l_comp_plan_exits = 'N'
            then
                select
                    listagg(permission_type, ', ') within group(
                    order by
                        product_type
                    ) permission_list
                into l_column_list
                from
                    broker_authorize_product_map
                where
                        product_type = x.account_type
                    and permission_type not in ( 'ALLOW_BROKER_PLAN_AMEND' );

            else
                select
                    listagg(permission_type, ', ') within group(
                    order by
                        product_type
                    ) permission_list
                into l_column_list
                from
                    broker_authorize_product_map
                where
                    product_type = x.account_type;

            end if;

            for y in (
                select
                    count(*) cnt
                from
                    account_pref_staging
                where
                        batch_number = p_batch_number
                    and entrp_id = p_entrp_id
                    and nvl(source, 'ENROLLMENT') = p_source
            ) loop
                l_staging_cnt := y.cnt;
            end loop;

            for j in (
                select
                    count(*) cnt
                from
                    account_preference
                where
                    entrp_id = p_entrp_id
            ) loop
                l_pref_cnt := j.cnt;
            end loop;

            pc_log.log_error('P_Batch_Number', 'l_column_list: ' || l_column_list);
            pc_log.log_error('P_Batch_Number', 'l_staging_cnt: ' || l_staging_cnt);
            pc_log.log_error('P_Batch_Number', 'l_pref_cnt: ' || l_pref_cnt);
            if l_column_list is not null then
                if l_staging_cnt > 0 then
                    l_sql := 'select Distinct a.Entrp_Id,c.account_type , a.authorize_options, bp.description,  a.is_authorized,bp.nav_code
                from ( select Entrp_Id,source,batch_number, authorize_options, is_authorized from account_pref_staging
                       unpivot INCLUDE  NULLS (is_authorized FOR authorize_options IN ( '
                             || l_column_list
                             || ' )))  a ,broker_authorize_product_map bp , account c
                where a.Entrp_Id = c.Entrp_Id and a.Entrp_Id = '
                             || p_entrp_id
                             || ' and a.authorize_options = bp.permission_type
                   and a.batch_number = '
                             || p_batch_number
                             || '
                   and NVL(a.source,''ENROLLMENT'') = '''
                             || p_source
                             || '''
                   and bp.product_type = '''
                             || x.account_type
                             || '''';

                    pc_log.log_error('Get_Acc_Preference_Staging', 'l_sql : ' || l_sql);
                end if;

                if
                    l_pref_cnt > 0
                    and l_staging_cnt = 0
                then
                    l_sql := 'select Distinct a.acc_id,c.account_type , a.authorize_options, bp.description,  a.is_authorized,bp.nav_code
                from ( select acc_id, authorize_options, is_authorized from account_preference
                       unpivot INCLUDE  NULLS (is_authorized FOR authorize_options IN ( '
                             || l_column_list
                             || ' )))  a ,broker_authorize_product_map bp , account c
                where a.acc_id = c.acc_id and a.acc_id = '
                             || x.acc_id
                             || ' and a.authorize_options = bp.permission_type
                   and bp.product_type = '''
                             || x.account_type
                             || '''';

                    pc_log.log_error('Get_Acc_Preference_Staging', 'l_sql : ' || l_sql);
                end if;

                if
                    l_pref_cnt = 0
                    and l_staging_cnt = 0
                then
                    if
                        x.account_type = 'POP'
                        and l_comp_plan_exits = 'N'
                    then
                        l_sql := 'select Distinct '
                                 || p_entrp_id
                                 || ', product_type account_type , PERMISSION_TYPE authorize_options, bp.description,  Null as is_authorized,bp.nav_code
                         from broker_authorize_product_map bp
                        where bp.product_type = '''
                                 || x.account_type
                                 || '''
                          and permission_type NOT IN (''ALLOW_BROKER_PLAN_AMEND'')';
                    else
                        l_sql := 'select Distinct '
                                 || p_entrp_id
                                 || ', product_type account_type , PERMISSION_TYPE authorize_options, bp.description,  Null as is_authorized,bp.nav_code
                        from broker_authorize_product_map bp
                       where  bp.product_type = '''
                                 || x.account_type
                                 || '''';
                    end if;

                    pc_log.log_error('Get_Acc_Preference_Staging', 'l_sql : ' || l_sql);
                end if;

                open l_sql_cur for l_sql;

                loop
                    fetch l_sql_cur into l_record;
                    exit when l_sql_cur%notfound;
                    pipe row ( l_record );
                end loop;

                close l_sql_cur;
            end if;

        end loop;
    end get_acc_preference_staging;

    procedure upsert_acc_pref_staging (
        p_batch_number     in number,
        p_entrp_id         in number,
        p_authorize_option pc_broker.varchar2_tbl,
        p_is_authorized    pc_broker.varchar2_tbl,
        p_user_id          in number,
        p_source           in varchar2,
        x_error_status     out varchar2,
        x_error_message    out varchar2
    ) is

        l_sql            varchar2(4000);
        l_where          varchar2(1000);    -- Increased the value by Swamy for Ticket#12534 
        l_update_sql     varchar2(1000);
        l_update_by_sql  varchar2(1000);
        l_sql_set_column varchar2(1000);
        l_sql_set_values varchar2(1000);
    begin
        x_error_status := 'S';
        for x in (
            select
                count(*) cnt
            from
                account_pref_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            if x.cnt > 0 then
                l_sql := 'update account_pref_staging set last_update_date = sysdate,source = '''
                         || p_source
                         || ''', last_updated_by = '
                         || p_user_id
                         || ',';
                for i in 1..p_authorize_option.count loop
                    pc_log.log_error('UPDATE_BROKER_AUTH',
                                     'p_authorize_option(i):'
                                     || p_authorize_option(i)
                                     || 'p_is_authorized(i):'
                                     || p_is_authorized(i));

                    if i = 1 then
                        l_sql_set_column := p_authorize_option(i)
                                            || '='
                                            || ''''
                                            || p_is_authorized(i)
                                            || '''';

                    else
                        l_sql_set_column := l_sql_set_column
                                            || ','
                                            || p_authorize_option(i)
                                            || '='
                                            || ''''
                                            || p_is_authorized(i)
                                            || '''';
                    end if;

                    l_where := ' where batch_number = '
                               || p_batch_number
                               || ' and entrp_id = '
                               || p_entrp_id;
                    l_update_sql := l_sql
                                    || l_sql_set_column
                                    || l_where;
                end loop;

                pc_log.log_error('UPDATE_BROKER_AUTH', 'l_update_sql : ' || l_update_sql);
                if l_update_sql is not null then
                    execute immediate l_update_sql;
                end if;
            else
                for i in 1..p_authorize_option.count loop
                    pc_log.log_error('UPDATE_BROKER_AUTH',
                                     'p_authorize_option(i):'
                                     || p_authorize_option(i)
                                     || 'p_is_authorized(i):'
                                     || p_is_authorized(i));

                    if i = 1 then
                        l_sql_set_column := p_authorize_option(i);
                        l_sql_set_values := ''''
                                            || p_is_authorized(i)
                                            || '''';
                    else
                        l_sql_set_column := l_sql_set_column
                                            || ','
                                            || p_authorize_option(i);
                        l_sql_set_values := l_sql_set_values
                                            || ','
                                            || ''''
                                            || p_is_authorized(i)
                                            || '''';

                    end if;

                    l_where := ' where batch_number = '
                               || p_batch_number
                               || ' and entrp_id'
                               || p_entrp_id;
                    l_update_sql := l_sql
                                    || l_sql_set_column
                                    || l_where;
                end loop;

                if l_sql_set_column is not null then
                    l_sql_set_column := '('
                                        || l_sql_set_column
                                        || ', batch_number,entrp_id, created_by, creation_date,source'
                                        || ')';
                    l_sql_set_values := '('
                                        || l_sql_set_values
                                        || ','
                                        || p_batch_number
                                        || ','
                                        || p_entrp_id
                                        || ','
                                        || p_user_id
                                        || ','
                                        || 'sysdate'
                                        || ','
                                        || ''''
                                        || p_source
                                        || ''''
                                        || ')';

                    l_sql := 'insert into account_pref_staging'
                             || l_sql_set_column
                             || ' values '
                             || l_sql_set_values;
                end if;

                pc_log.log_error('UPDATE_BROKER_AUTH', 'l_sql_set_column' || l_sql_set_column);
                pc_log.log_error('UPDATE_BROKER_AUTH', 'l_sql_set_values' || l_sql_set_values);
                pc_log.log_error('UPDATE_BROKER_AUTH', 'l_sql' || l_sql);
                if l_sql is not null then
                    execute immediate l_sql;
                end if;
            end if;
        end loop;

    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('UPDATE_BROKER_AUTH', 'others' || dbms_utility.format_error_backtrace);
            raise;
            rollback;
    end upsert_acc_pref_staging;

    procedure update_acct_pref (
        p_batch_number in number,
        p_entrp_id     in number
    ) is
    begin
        for x in (
            select
                *
            from
                account_pref_staging
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
        ) loop
            update account_preference
            set
                allow_broker_plan_amend = x.allow_broker_plan_amend,
                allow_bro_upd_pln_doc = x.allow_bro_upd_pln_doc,
                allow_broker_renewal = x.allow_broker_renewal,
                allow_broker_enroll_rpts = x.allow_broker_enroll_rpts,
                allow_broker_enroll = x.allow_broker_enroll,
                allow_broker_invoice = x.allow_broker_invoice,
                allow_broker_enroll_ee = x.allow_broker_enroll_ee,
                allow_broker_ee = x.allow_broker_ee
            where
                entrp_id = p_entrp_id;

        end loop;
    end update_acct_pref;

-- Added by Jaggi #11364
    procedure update_online_compliance_staging (
        p_batch_number                in number,
        p_entrp_id                    in number,
        p_acct_fee_paid_by            in varchar2,
        p_acct_fee_payment_method     in varchar2,
        p_optional_fee_paid_by        in varchar2,
        p_optional_fee_payment_method in varchar2
    ) is
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.update_online_compliance_staging', 'Error '
                                                                                           || p_batch_number
                                                                                           || ' := '
                                                                                           || p_batch_number);
        for x in (
            select
                *
            from
                online_compliance_staging
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            update online_compliance_staging
            set
                fees_payment_flag = p_acct_fee_paid_by,
                acct_payment_fees = p_acct_fee_payment_method,
                optional_fee_payment_method = p_acct_fee_payment_method,
                optional_fee_bank_acct_id = p_optional_fee_paid_by
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number;

        end loop;

    end update_online_compliance_staging;

-- Added by Swamy for Ticket#11364
    procedure cobra_renewal_final_submit (
        p_entrp_id      in number,
        p_acc_id        in number,
        p_batch_number  in number,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is

        l_acct_usage                  varchar2(100);
        l_bank_count                  number;
        l_entity_id                   number;
        l_entity_type                 varchar2(100);
        l_bank_id                     number;
        l_header_exist                number;
        l_fees_payment_flag           varchar2(100);
        l_carrier_notify_flag         varchar2(100);
        l_optional_fee_payment_method varchar2(100);
        l_optional_fee_bank_acct_id   number;
        x_quote_header_id             number;
        x_batch_number                number;
        l_authorize_req_id            number;
        l_authorize_option            pc_online_enrollment.varchar2_tbl;
        l_options                     pc_online_enrollment.varchar2_tbl;
        l_is_authorized               pc_online_enrollment.varchar2_tbl;
        l_nav_code                    pc_online_enrollment.varchar2_tbl;
        l_counter                     number := 0;
        l_tax                         varchar2(20);
        l_account_type                varchar2(20);
        x_renewed_plan_id             number;
        l_bank_acct_id                number;
        err exception;
        erreur exception;
        l_enrolle_type                varchar2(50);
        l_inactive_plan_exist         varchar2(1);
        l_acc_id                      number;
        l_eff_date                    date;
        l_broker_id                   number;
        l_error_status                varchar2(100) := 'S';   -- Added by Swamy for Ticket#11368
        l_error_message               varchar2(1000);         -- Added by Swamy for Ticket#11368
        v_resubmit_flag               varchar2(1000);         -- Added by Swamy for Ticket#11636
        l_renewed_plan_id             number;      -- Added by Swamy for Ticket#11636
        l_plan_id                     number;      -- Added by Swamy for Ticket#11636
        l_user_type                   varchar2(20);         -- Added by Swamy for Ticket#11636
        l_ga_id                       number;    -- Added by Swamy for Ticket#11636
        l_renewed_by_id               number;    -- Added by Swamy for Ticket#11636
        l_plan_start_date             date;      -- Added by Swamy for Ticket#11636
        l_prev_plan_start_date        date;      -- Added by Swamy for Ticket#11636
        l_account_status              number;
        l_opt_eff_start_date          date;      -- Added by Jaggi #12672																   

    begin
        l_authorize_option := l_options;
        l_is_authorized := l_options;
        l_nav_code := l_options;
        l_authorize_req_id := null;

 -- Added by Swamy for Ticket#11636
        for k in (
            select
                decode(user_type, 'B', 'BROKER', 'G', 'GA',
                       'EMPLOYER') user_type
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            l_user_type := k.user_type;
        end loop;

        for ocs in (
            select
                bank_name,
                no_of_eligible,
                routing_number,
                bank_acc_num,
                bank_acc_type,
                optional_bank_name,
                optional_routing_number,
                optional_bank_acc_num,
                optional_bank_acc_type,
                optional_fee_paid_by,
                remit_bank_name,
                remit_routing_number,
                remit_bank_acc_num,
                remit_bank_acc_type,
                acct_payment_fees,
                carrier_notify_flag,
                fees_payment_flag,
                optional_fee_payment_method,
                optional_fee_bank_acct_id,
                upper(source) source,
                renewed_plan_id    -- Added by Swamy for Ticket#11636
            from
                online_compliance_staging
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and source = 'RENEWAL'
        ) loop
            l_tax := pc_entrp.get_tax_id(p_entrp_id);
            l_account_type := pc_account.get_account_type(p_acc_id);
            x_renewed_plan_id := null;
            l_bank_acct_id := null;
            l_optional_fee_bank_acct_id := null;

      -- Added by Swamy for Ticket#11368
            select
                acc_id,
                nvl(enrolle_type, 'EMPLOYER'),
                ga_id,
                broker_id
            into
                l_acc_id,
                l_enrolle_type,
                l_ga_id,
                l_broker_id
            from
                account
            where
                entrp_id = p_entrp_id;

            for auth_id in (
                select
                    authorize_req_id
                from
                    table ( pc_broker.get_broker_authorise_info(l_tax) )
                where
                    account_type = l_account_type
            ) loop
                l_authorize_req_id := auth_id.authorize_req_id;
            end loop;

            l_counter := 0;
            for auth_opt in (
                select
                    is_authorized,
                    nav_code,
                    authorize_option
                from
                    table ( pc_employer_enroll_compliance.get_acc_preference_staging(
                        p_batch_number => p_batch_number,
                        p_entrp_id     => p_entrp_id,
                        p_source       => ocs.source
                    ) )
            ) loop
                l_counter := l_counter + 1;
                if l_is_authorized.count = 0 then
                    l_is_authorized(l_counter) := auth_opt.is_authorized;
                    l_nav_code(l_counter) := auth_opt.authorize_option;
                    l_authorize_option(l_counter) := auth_opt.authorize_option;
                else
                    l_is_authorized(l_counter) := auth_opt.is_authorized;
                    l_nav_code(l_counter) := auth_opt.authorize_option;
                    l_authorize_option(l_counter) := auth_opt.authorize_option;
                end if;

            end loop;

         -- Start Added by Swamy for Ticket#11636
            v_resubmit_flag := pc_account.get_renewal_resubmit_flag(p_entrp_id);
            if
                nvl(ocs.renewed_plan_id, 0) = 0
                and nvl(v_resubmit_flag, 'N') = 'Y'
            then
                for j in (
                    select
                        max(plan_start_date) plan_start_date
                    from
                        ben_plan_enrollment_setup
                    where
                        acc_id = p_acc_id
                ) loop
                    l_plan_start_date := j.plan_start_date;
                end loop;

                for j in (
                    select
                        max(plan_start_date) plan_start_date
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = p_acc_id
                        and plan_start_date < l_plan_start_date
                ) loop
                    l_prev_plan_start_date := j.plan_start_date;
                end loop;

                for k in (
                    select
                        ben_plan_id
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = p_acc_id
                        and plan_start_date = l_prev_plan_start_date
                ) loop
                    l_renewed_plan_id := k.ben_plan_id;
                end loop;

                ocs.renewed_plan_id := l_renewed_plan_id;
            end if;

            pc_log.log_error('cobra_renewal_final_submit', 'v_resubmit_flag : '
                                                           || v_resubmit_flag
                                                           || 'ocs.renewed_plan_id :='
                                                           || ocs.renewed_plan_id
                                                           || 'p_batch_number :='
                                                           || p_batch_number);

            if nvl(v_resubmit_flag, 'N') = 'Y' then   -- Added by Swamy for Ticket#11636
                pc_web_compliance.delete_resubmit_data(
                    p_acc_id              => p_acc_id,
                    p_entrp_id            => p_entrp_id,
                    p_batch_number        => p_batch_number,
                    p_renewed_ben_plan_id => ocs.renewed_plan_id,
                    p_ben_plan_id         => null,
                    p_account_type        => 'COBRA',
                    p_eligibility_id      => null
                );

                update ben_plan_renewals
                set
                    optional_fee_paid_by = ocs.optional_fee_paid_by,
                    pay_acct_fees = ocs.acct_payment_fees
                where
                        renewed_plan_id = ocs.renewed_plan_id
                    and acc_id = p_acc_id;

            end if;

            pc_log.log_error('UPDATE_BROKER_AUTH', 'ocs.acct_payment_fees : '
                                                   || ocs.acct_payment_fees
                                                   || ' ocs.optional_fee_paid_by :='
                                                   || ocs.optional_fee_paid_by
                                                   || ' ocs.no_of_eligible :='
                                                   || ocs.no_of_eligible);

-- 11368 Joshi. (for alone implementing all this 6-7 days).

-- If account.renewed_by = 'BROKER' OR 'GA' and if ( ocs.acct_payment_fees = 'EMPLOYER' OR UPPER(ocs.optional_Fee_Paid_By)= 'EMPLOYER'  AND paymenth_method = 'ACH'
-- then dont call any of the below procedure.
-- update account set renewal_status = 'Pending ACH ER' and exit the procedure. notification should be sent to EMPLOYER.
-- your data is available in only staging table.
-- when employer logs in . get the lastet batch_number and then you need populate details in the applications. (employer cannot change xcept ACH details)
-- Employer will enter ACH details and then submit.
-- in this case this entire procedure should be run.

            pc_web_compliance.update_er_account_cobra(
                p_acc_id                => p_acc_id,
                p_new_plan_year         => null,
                p_user_id               => p_user_id,
                p_pay_acct_fees         => ocs.acct_payment_fees,
                p_optional_fee_paid_by  => ocs.optional_fee_paid_by,
                p_no_of_eligible        => ocs.no_of_eligible,
                p_authorize_req_id      => l_authorize_req_id,
                p_policy_number         => l_options,
                p_plan_number           => l_options,
                p_carrier_name          => l_options,
                p_carrier_contact_name  => l_options,
                p_carrier_contact_email => l_options,
                p_carrier_phone_no      => l_options,
                p_authorize_option      => l_authorize_option,
                p_is_authorized         => l_is_authorized,
                p_nav_code              => l_nav_code,
                p_staging_batch_number  => p_batch_number,
                p_source                => ocs.source,
                x_batch_number          => x_batch_number,
                x_renewed_plan_id       => x_renewed_plan_id,
                x_return_status         => x_error_status,
                x_error_message         => x_error_message
            );

            if nvl(x_error_status, 'S') = 'E' then
                x_error_message := ( x_error_message
                                     || 'ERROR in cobra_renewal_final_submit after calling update_er_account_cobra' );
                raise erreur;
            end if;

         /*
            l_acct_usage := 'INVOICE';
            l_bank_count := 0;

        -- Annual bank details
        IF ocs.bank_name IS NOT NULL THEN
            IF UPPER(ocs.acct_payment_fees)= 'EMPLOYER'  THEN
                l_entity_id := p_acc_id;
                l_entity_type := 'ACCOUNT';
            ELSIF UPPER(ocs.acct_payment_fees) = 'BROKER'  THEN
                l_entity_id := pc_account.get_broker_id(p_acc_id);
                l_entity_type := 'BROKER';
            ELSIF UPPER( ocs.acct_payment_fees) = 'GA'  THEN
                l_entity_id := pc_account.get_ga_id(p_acc_id);
                l_entity_type := 'GA';
            END IF;

            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_entity_id: ',l_entity_id);
            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_entity_type',l_entity_type);
            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_acct_usage l',l_acct_usage);

             SELECT COUNT(*) INTO l_bank_count
               FROM bank_Accounts
              WHERE bank_routing_num = ocs.routing_number
                AND bank_acct_num    = ocs.bank_acc_num
                AND bank_name        = ocs.bank_name
                AND status           = 'A'
                AND bank_account_usage = l_acct_usage
                AND entity_id        = l_entity_id
                AND entity_type      = l_entity_type ;

            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_count l',l_bank_count);

              IF l_bank_count = 0 THEN
                  -- fee bank details
                  pc_user_bank_acct.insert_bank_account(
                                     p_entity_id          => l_entity_id
                                    ,p_entity_type        => l_entity_type
                                    ,p_display_name       => ocs.bank_name
                                    ,p_bank_acct_type     => ocs.bank_acc_type
                                    ,p_bank_routing_num   => ocs.routing_number
                                    ,p_bank_acct_num      => ocs.bank_acc_num
                                    ,p_bank_name          => ocs.bank_name
                                    ,p_bank_account_usage => NVL(l_acct_usage,'INVOICE')
                                    ,p_user_id            => p_user_id
                                    ,x_bank_acct_id       => l_bank_id
                                    ,x_return_status      => x_error_status
                                    ,x_error_message      => x_error_message);

                               IF NVL(x_error_status,'S') = 'E' THEN
                                  x_error_message := (x_error_message || 'ERROR in cobra_renewal_final_submit after calling insert_bank_account');
                                  RAISE ERREUR;
                               END IF;

                 ELSE
                    FOR   B IN ( SELECT bank_acct_id
                                   FROM bank_Accounts
                                  WHERE bank_routing_num = ocs.routing_number
                                    AND bank_acct_num    = ocs.bank_acc_num
                                    AND bank_name        = ocs.bank_name
                                    AND status           = 'A'
                                    AND bank_account_usage = l_acct_usage
                                    AND entity_id        = l_entity_id
                                    AND entity_type      = l_entity_type
                                )
                    LOOP
                            l_bank_id := b.bank_Acct_id ;
                    END LOOP;
                    pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_id l',l_bank_id);
                END IF;
                l_bank_acct_id   := l_bank_id;
        END IF;

        -- optional bank details
        IF ocs.optional_bank_name IS NOT NULL THEN
                l_entity_id    := NULL;
                l_entity_type  := NULL;
                l_acct_usage   := 'INVOICE' ;
                l_bank_count   := 0;
                l_bank_id      := NULL;

                IF UPPER(ocs.optional_Fee_Paid_By)= 'EMPLOYER'  THEN
                    l_entity_id := p_acc_id;
                    l_entity_type := 'ACCOUNT';
                ELSIF UPPER(ocs.optional_Fee_Paid_By) = 'BROKER'  THEN
                    l_entity_id := pc_account.get_broker_id(p_acc_id);
                    l_entity_type := 'BROKER';
                ELSIF UPPER( ocs.optional_Fee_Paid_By) = 'GA'  THEN
                    l_entity_id := pc_account.get_ga_id(p_acc_id);
                    l_entity_type := 'GA';
                END IF;

               -- check if used had entered existing bank account details.
               SELECT COUNT(*) INTO l_bank_count
                 FROM bank_Accounts
                WHERE bank_routing_num = ocs.optional_routing_number
                  AND bank_acct_num    = ocs.optional_bank_acc_num
                  AND bank_name        = ocs.optional_bank_name
                  AND status           = 'A'
                  AND bank_account_usage = l_acct_usage
                  AND entity_id        = l_entity_id
                  AND entity_type      = l_entity_type ;

               pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan optional l_bank_count  l',l_bank_count);

              IF l_bank_count = 0 THEN
                 pc_user_bank_acct.insert_bank_account(
                                 p_entity_id          => l_entity_id
                                ,p_entity_type        => l_entity_type
                                ,p_display_name       => ocs.optional_bank_name
                                ,p_bank_acct_type     => ocs.optional_bank_acc_type
                                ,p_bank_routing_num   => ocs.optional_routing_number
                                ,p_bank_acct_num      => ocs.optional_Bank_Acc_Num
                                ,p_bank_name          => ocs.optional_bank_name
                                ,p_bank_account_usage => NVL(l_acct_usage,'INVOICE')
                                ,p_user_id            => p_user_id
                                ,x_bank_acct_id       => l_bank_id
                                ,x_return_status      => x_error_status
                                ,x_error_message      => x_error_message);

                               IF NVL(x_error_status,'S') = 'E' THEN
                                  x_error_message := (x_error_message || 'ERROR in cobra_renewal_final_submit after calling insert_bank_account for optional bank ');
                                  RAISE ERREUR;
                               END IF;
               pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_id l',l_bank_id);
              ELSE
                    FOR B IN (SELECT bank_Acct_id
                                FROM bank_Accounts
                               WHERE bank_routing_num = ocs.optional_routing_number
                                 AND bank_acct_num    = ocs.optional_bank_acc_num
                                 AND bank_name        = ocs.optional_bank_name
                                 AND status           = 'A'
                                 AND entity_id        = l_entity_id
                                 AND entity_type      = l_entity_type )
                    LOOP
                            l_bank_id := b.bank_Acct_id ;
                    END LOOP;
              END IF ;
              l_optional_fee_bank_acct_id   := l_bank_id;
              pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_id l',l_bank_id);
              pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan x_error_message l',x_error_message);
        END IF;

        -- Remit bank details
        IF ocs.Remit_bank_name IS NOT NULL THEN

                l_acct_usage  := 'COBRA_DISBURSE' ;
                l_entity_id   := p_acc_id;
                l_entity_type := 'ACCOUNT';
                l_bank_count  := 0;
                l_bank_id     := NULL;

               -- check if used had entered existing bank account details.
               SELECT COUNT(*) INTO l_bank_count
                 FROM bank_Accounts
                WHERE bank_routing_num = ocs.remit_routing_number
                  AND bank_acct_num    = ocs.remit_bank_acc_num
                  AND bank_name        = ocs.remit_bank_name
                  AND status           = 'A'
                  AND bank_account_usage = l_acct_usage
                  AND entity_id        = l_entity_id
                  AND entity_type      = l_entity_type ;

               pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan optional l_bank_count  l',l_bank_count);

              IF l_bank_count = 0 THEN
                pc_user_bank_acct.insert_bank_account(
                                  p_entity_id          => l_entity_id
                                 ,p_entity_type        => l_entity_type
                                 ,p_display_name       => ocs.Remit_bank_name
                                 ,p_bank_acct_type     => ocs.Remit_bank_acc_type
                                 ,p_bank_routing_num   => ocs.Remit_routing_number
                                 ,p_bank_acct_num      => ocs.Remit_Bank_Acc_Num
                                 ,p_bank_name          => ocs.Remit_bank_name
                                 ,p_bank_account_usage => NVL(l_acct_usage,'COBRA_DISBURSE')
                                 ,p_user_id            => p_user_id
                                 ,x_bank_acct_id       => l_bank_id
                                 ,x_return_status      => x_error_status
                                 ,x_error_message      => x_error_message);

                               IF NVL(x_error_status,'S') = 'E' THEN
                                  x_error_message := (x_error_message || 'ERROR in cobra_renewal_final_submit after calling insert_bank_account for Remitance bank ');
                                  RAISE ERREUR;
                               END IF;
             END IF;
         END IF;*/

       -- Added by Swamy for Ticket#12534 
            pc_employer_enroll_compliance.insert_enroll_renew_bank_accounts(
                p_entrp_id               => p_entrp_id,
                p_acc_id                 => l_acc_id,
                p_batch_number           => p_batch_number,
                p_acct_payment_fees      => ocs.acct_payment_fees,
                p_fees_payment_flag      => ocs.fees_payment_flag,
                p_optional_fee_paid_by   => ocs.optional_fee_paid_by,
                p_opt_fee_payment_method => ocs.optional_fee_payment_method,
                p_user_id                => p_user_id,
                p_source                 => 'R',
                p_account_status         => l_account_status,
                x_error_status           => x_error_status,
                x_error_message          => x_error_message
            );

            l_fees_payment_flag := ocs.fees_payment_flag;
            l_carrier_notify_flag := ocs.carrier_notify_flag;
            l_optional_fee_payment_method := ocs.optional_fee_payment_method;
        end loop;

        pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan optional x_renewed_plan_id  l.1', x_renewed_plan_id
                                                                                                 || 'v_resubmit_flag :='
                                                                                                 || v_resubmit_flag);
        update online_compliance_staging
        set --optional_fee_bank_acct_id = NVL(l_optional_fee_bank_acct_id, optional_fee_bank_acct_id)  -- Commented by Swamy for Ticket#12534 
          --, bank_acct_id = NVL(l_bank_acct_id,optional_fee_bank_acct_id)   -- Commented by Swamy for Ticket#12534 
            renewed_plan_id = decode(v_resubmit_flag, 'N', x_renewed_plan_id, renewed_plan_id)   -- Added by swamy for ticket#11636
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

        if l_carrier_notify_flag = 'Y' then
     --Insert all the Plan documents in File attachments table
            insert into file_attachments (
                attachment_id,
                document_name,
                document_type,
                attachment,
                entity_name,
                entity_id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                document_purpose,
                batch_number    -- Added by swamy for ticket#11636
            )
                (
                    select
                        file_attachments_seq.nextval,
                        document_name,
                        document_type,
                        attachment,
                        'ACCOUNT',
                        p_acc_id,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        document_purpose,
                        p_batch_number   -- Added by swamy for ticket#11636
                    from
                        file_attachments_staging
                    where
                            batch_number = p_batch_number
                        and document_purpose like 'TPA%'
                        and plan_id is null
                );

        end if;

        for i in (
            select
                *
            from
                ar_quote_headers_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            pc_log.log_error('PC_WEB_COMPLIANCE', 'INSRT_AR_QUOTE_HEADERS x_renewed_plan_id :=' || x_renewed_plan_id);
            pc_web_compliance.insrt_ar_quote_headers(
                p_quote_name                => null,
                p_quote_number              => null,
                p_total_quote_price         => i.total_quote_price,
                p_quote_date                => to_char(sysdate, 'mm/dd/rrrr'),
                p_payment_method            => l_fees_payment_flag,
                p_entrp_id                  => p_entrp_id,
                p_bank_acct_id              => 0,
                p_ben_plan_id               => x_renewed_plan_id,
                p_user_id                   => p_user_id,
                p_quote_source              => 'ONLINE',
                p_product                   => 'COBRA',
                p_billing_frequency         => i.billing_frequency,
                p_optional_payment_method   => l_optional_fee_payment_method,
                p_optional_fee_bank_acct_id => l_optional_fee_bank_acct_id,
                x_quote_header_id           => x_quote_header_id,
                x_return_status             => x_error_status,
                x_error_message             => x_error_message
            );

            if nvl(x_error_status, 'S') = 'E' then
                x_error_message := ( x_error_message
                                     || 'ERROR in cobra_renewal_final_submit after calling insrt_ar_quote_headers ' );
                raise erreur;
            end if;

            pc_log.log_error('PC_WEB_COMPLIANCE', x_error_message);
            pc_log.log_error('create_cobra_plan ', 'status3'
                                                   || 'x_error_status '
                                                   || x_error_status);
            for aqls in (
                select
                    rate_plan_id,
                    rate_plan_detail_id,
                    line_list_price,
                    rate_plan_name -- added by Jaggi #12672
                from
                    ar_quote_lines_staging
                where
                    quote_header_id = i.quote_header_id
            ) loop
                pc_web_compliance.insrt_ar_quote_lines(
                    p_quote_header_id     => x_quote_header_id,
                    p_rate_plan_id        => aqls.rate_plan_id,
                    p_rate_plan_detail_id => aqls.rate_plan_detail_id,
                    p_line_list_price     => aqls.line_list_price,
                    p_notes               => 'COBRA ONLINE ENROLLMENT',
                    p_user_id             => p_user_id,
                    x_return_status       => x_error_status,
                    x_error_message       => x_error_message
                );

                if nvl(x_error_status, 'S') = 'E' then
                    x_error_message := ( x_error_message
                                         || 'ERROR in cobra_renewal_final_submit after calling insrt_ar_quote_lines ' );
                    raise erreur;
                end if;

              -- Added by Jaggi #12672
              -- Added by Jaggi #12672
                for j in (
                    select
                        plan_start_date
                    from
                        ben_plan_enrollment_setup
                    where
                        ben_plan_id = x_renewed_plan_id
                ) loop
                    l_opt_eff_start_date := j.plan_start_date;
                end loop;

                if aqls.rate_plan_name in ( 'OPTIONAL_COBRA_SERVICE_CN', 'OPTIONAL_COBRA_SERVICE_SC', 'OPEN_ENROLLMENT_SUITE' ) then
                    insert into cobra_services_detail (
                        acc_id,
                        ben_plan_id,
                        service_type,
                        effective_date,
                        service_selected,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_updated_date
                    ) values ( l_acc_id,
                               x_renewed_plan_id,
                               aqls.rate_plan_name,
                               l_opt_eff_start_date,
                               'Y',
                               p_user_id,
                               sysdate,
                               p_user_id,
                               sysdate );

                end if;

                pc_log.log_error('create_cobra_plan ', 'status4'
                                                       || 'x_error_status '
                                                       || x_error_status);
            end loop;

        end loop;

        insert into contact (
            contact_id,
            first_name,
            last_name,
            entity_id,
            entity_type,
            email,
            status,
            start_date,
            last_updated_by,
            created_by,
            last_update_date,
            creation_date,
            can_contact,
            contact_type,
            user_id,
            phone,
            fax,
            title,
            account_type
        )
            select distinct
                contact_id,  -- added by swamy for ticket#11636
                substr(first_name,
                       0,
                       instr(first_name, ' ', 1, 1) - 1),
                substr(first_name,
                       instr(first_name, ' ', 1, 1) + 1,
                       length(first_name) - instr(first_name, ' ', 1, 1) + 1),
                entity_id,
                'ENTERPRISE',
                email,
                'A',
                sysdate,
                p_user_id,
                p_user_id,
                sysdate,
                sysdate,
                'Y',
                contact_type,
                null,
                phone_num,
                contact_fax,
                job_title,
                'COBRA'
            from
                contact_leads a
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and not exists (
                    select
                        1
                    from
                        contact b
                    where
                        a.contact_id = b.contact_id
                )
                and account_type = 'COBRA'
                and ref_entity_type = 'BEN_PLAN_RENEWALS';

        pc_log.log_error('In Proc', 'Before Contact..Rowinsert' || sql%rowcount);
    /** For all contacts added define contact roles etc */
    --Ticket#6555
        for xx in (
            select
                *
            from
                contact_leads a
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and not exists (
                    select
                        1
                    from
                        contact_role b
                    where
                        a.contact_id = b.contact_id
                )     -------- 7783 rprabu 31/10/2019
                and account_type = 'COBRA'
        ) loop
            insert into contact_role e (
                contact_role_id,
                contact_id,
                role_type,
                account_type,
                effective_date,
                created_by,
                last_updated_by,
                ref_contact_id   -- added by swamy for ticket#11636
            ) values ( contact_role_seq.nextval,
                       xx.contact_id,
                       xx.account_type,
                       xx.account_type,
                       sysdate,
                       p_user_id,
                       p_user_id,
                       xx.entity_id   -- added by swamy for ticket#11636
                        );
      --Especially for compliance we need to have both account type and role type defined
            insert into contact_role e (
                contact_role_id,
                contact_id,
                role_type,
                account_type,
                effective_date,
                created_by,
                last_updated_by,
                ref_contact_id   -- added by swamy for ticket#11636
            ) values ( contact_role_seq.nextval,
                       xx.contact_id,
                       xx.contact_type,
                       xx.account_type,
                       sysdate,
                       p_user_id,
                       p_user_id,
                       xx.entity_id   -- added by swamy for ticket#11636
                        );
      --For all products we want Fee Invoice option also checked
            if xx.contact_type = 'PRIMARY'
            or xx.send_invoice = 1 then
                insert into contact_role e (
                    contact_role_id,
                    contact_id,
                    role_type,
                    account_type,
                    effective_date,
                    created_by,
                    last_updated_by,
                    ref_contact_id   -- added by swamy for ticket#11636
                ) values ( contact_role_seq.nextval,
                           xx.contact_id,
                           'FEE_BILLING',
                           xx.account_type,
                           sysdate,
                           p_user_id,
                           p_user_id,
                           xx.entity_id   -- added by swamy for ticket#11636
                            );

            end if;

        end loop;

        for i in (
            select
                first_name,
                email,
                user_id,
                entity_type,
                ref_entity_type,
                lic_number
            from
                contact_leads a
            where
                    account_type = l_account_type
                and not exists (
                    select
                        1
                    from
                        contact b
                    where
                        a.contact_id = b.contact_id
                )
                and entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and contact_flg = 'Y'     -- Only save the details of the contact who's value is selected during online renewal. Staging table contains data for both selected and non selected contacts.
                and nvl(lic_number, '*') <> '*'
        ) --Cur_Contacts
         loop
            pc_broker.insert_sales_team_leads(
                p_first_name      => null,
                p_last_name       => null,
                p_license         => i.lic_number,
                p_agency_name     => i.first_name,
                p_tax_id          => null,
                p_gender          => null,
                p_address         => null,
                p_city            => null,
                p_state           => null,
                p_zip             => null,
                p_phone1          => null,
                p_phone2          => null,
                p_email           => i.email,
                p_entrp_id        => p_entrp_id,
                p_ref_entity_id   => x_renewed_plan_id,
                p_ref_entity_type => i.ref_entity_type,
                p_lead_source     => 'RENEWAL',
                p_entity_type     => i.entity_type
            );
        end loop;

        -- Added by Swamy for Ticket#11368
/*        If l_Enrolle_Type = 'GA' Then
             Pc_Employer_Enroll.upsert_page_validity
			   (p_batch_number => p_batch_number,
				p_entrp_id => p_entrp_id,
				p_Account_Type => 'COBRA',
				p_page_no => '4',
				p_block_name => 'AUTH_SIGN',
				p_validity => 'V',
				p_user_id => NULL,
				x_error_status => x_error_status,
				x_error_message => x_error_message ) ;

             Pc_Employer_Enroll.upsert_page_validity
			   (p_batch_number => p_batch_number,
				p_entrp_id => p_entrp_id,
				p_Account_Type => 'COBRA'  ,
				p_page_no => '4',
				p_block_name => 'AGREEMENT',
				p_validity => 'V',
				p_user_id => NULL,
				x_error_status => x_error_status,
				x_error_message => x_error_message ) ;
           End If;
           pc_employer_enroll_compliance.update_acct_pref(p_batch_number , p_entrp_id);
*/

        if nvl(v_resubmit_flag, 'N') = 'N' then   -- Added by Swamy for Ticket#11636
            select
                broker_id
            into l_broker_id
            from
                table ( pc_broker.get_broker_info_from_acc_id(l_acc_id) );

            if l_broker_id > 0 then
                l_authorize_req_id := pc_broker.get_broker_authorize_req_id(l_broker_id, l_acc_id);
                pc_broker.create_broker_authorize(
                    p_broker_id        => l_broker_id,
                    p_acc_id           => l_acc_id,
                    p_broker_user_id   => null,
                    p_authorize_req_id => l_authorize_req_id,
                    p_user_id          => p_user_id,
                    x_error_status     => l_error_status,
                    x_error_message    => l_error_message
                );

            end if;

        end if;

        if l_user_type = 'BROKER' then
            l_renewed_by_id := l_broker_id;
        elsif l_user_type = 'GA' then
            l_renewed_by_id := l_ga_id;
        else
            l_renewed_by_id := l_acc_id;
        end if;

        update online_compliance_staging
        set
            submit_status = 'COMPLETED',
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
                entrp_id = p_entrp_id
            and source = 'RENEWAL'
            and batch_number = p_batch_number;

        if nvl(v_resubmit_flag, 'N') = 'N' then   -- Added by Swamy for Ticket#11636
            update account
            set
                signature_account_status = null,
                renewed_date = decode(v_resubmit_flag, 'N', sysdate, renewed_date)   -- Added by swamy for ticket#11636
              --  ,renewed_by = l_user_type -- Added by Swamy for Ticket#11636
                ,
                submit_by = p_user_id    -- Added by Swamy for Ticket#11636
               -- ,renewed_by_id = l_renewed_by_id  -- Added by Swamy for Ticket#11636
            where
                entrp_id = p_entrp_id;

        else
            update account
            set
                renewed_by = l_user_type,
                submit_by = p_user_id,
                renewed_by_id = l_renewed_by_id,
                renewed_by_user_id = p_user_id
            where
                entrp_id = p_entrp_id;

        end if;

        x_error_status := l_error_status;
        x_error_message := l_error_message;
    exception
        when erreur then
            rollback;
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.cobra_renewal_final_submit IN exception ERREUR ', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
        when others then
            rollback;
            x_error_message := 'In cobra_renewal_final_submit when others : ' || sqlerrm;   -- Swamy 11636
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLAINCE.cobra_renewal_final_submit', sqlerrm || dbms_utility.format_error_backtrace
            );
    end cobra_renewal_final_submit;

-- Added by Swamy for Ticket#11364(broker)
    procedure renewal_app_signed_by_staging (
        p_entrp_id        in number,
        p_batch_number    in number,
        p_account_type    in varchar2,
        p_sign_type       in varchar2, -----who is signing
        p_contact_name    in varchar2,
        p_email           in varchar2,
        p_renewed_by      in varchar2,
        p_renewed_user_id in number,
        x_error_status    out varchar2,
        x_error_message   out varchar2
    ) is

        l_signature_account_status number;
        l_acct_payment_fees        varchar2(100);
        l_monthly_fees_paid_by     varchar2(100);
        l_renewed_by_id            number;
        l_acc_id                   number;
        l_broker_id                number;
        l_ga_id                    number;
        l_bank_name                bank_accounts.bank_name%type;
        l_routing_number           varchar2(9);
        l_bank_acc_num             bank_accounts.bank_acct_num%type;
        l_bank_acc_type            bank_accounts.bank_acct_type%type;
        l_remit_bank_name          bank_accounts.bank_name%type;
        l_remit_routing_number     varchar2(9);
        l_remit_bank_acc_num       bank_accounts.bank_acct_num%type;
        l_remit_bank_acc_type      bank_accounts.bank_acct_type%type;
    begin
        x_error_status := 'S';
        for acc in (
            select
                acc_id,
                broker_id,
                ga_id
            from
                account
            where
                entrp_id = p_entrp_id
        ) loop
            l_acc_id := acc.acc_id;
            l_broker_id := acc.broker_id;
            l_ga_id := acc.ga_id;
        end loop;

        if p_renewed_by = 'BROKER' then
            l_renewed_by_id := l_broker_id;
        elsif p_renewed_by = 'GA' then
            l_renewed_by_id := l_ga_id;
        else
            l_renewed_by_id := l_acc_id;
        end if;

        if p_account_type in ( 'COBRA', 'POP', 'ERISA_WRAP' ) then
            for j in (
                select
                    acct_payment_fees
                from
                    online_compliance_staging
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number
            ) loop
                l_acct_payment_fees := j.acct_payment_fees;
            end loop;

            update online_compliance_staging
            set
                contact_name = decode(p_sign_type, 'EMPLOYER', p_contact_name, null),
                email = decode(p_sign_type, 'EMPLOYER', p_email, null)
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number;

        end if;

        if p_account_type in ( 'FSA', 'HRA' ) then
            for j in (
                select
                    decode(
                        upper(pay_acct_fees),
                        'GENERAL AGENT',
                        'GA',
                        upper(pay_acct_fees)
                    ) pay_acct_fees,
                    decode(
                        upper(monthly_fees_paid_by),
                        'GENERAL AGENT',
                        'GA',
                        upper(monthly_fees_paid_by)
                    ) monthly_fees_paid_by
                from
                    online_fsa_hra_staging
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number
                    and source = 'RENEWAL'
            ) loop
                l_acct_payment_fees := j.pay_acct_fees;
                l_monthly_fees_paid_by := j.monthly_fees_paid_by;
            end loop;

            update online_fsa_hra_staging
            set
                contact_name = decode(p_sign_type, 'EMPLOYER', p_contact_name, null),
                email = decode(p_sign_type, 'EMPLOYER', p_email, null),
                signed_by = decode(p_sign_type, 'EMPLOYER', l_acc_id, 'BROKER', l_broker_id,
                                   'GA', l_ga_id),
                sign_type = p_sign_type
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number;

        end if;

        if p_renewed_by = 'BROKER' then   -- Broker added by Swamy for Ticket#9617
            if p_account_type in ( 'COBRA', 'ERISA_WRAP' ) then       -- Added by Jaggi #11533
                if
                    l_acct_payment_fees = 'BROKER'
                    and p_sign_type = 'EMPLOYER'
                then
                    l_signature_account_status := 6;    --Pending Signature
                elsif
                    l_acct_payment_fees = 'EMPLOYER'
                    and p_sign_type = 'EMPLOYER'
                then
                    l_signature_account_status := 8;    --Pending payment and Signature
                    pc_employer_enroll.upsert_page_validity(
                        p_batch_number  => p_batch_number,
                        p_entrp_id      => p_entrp_id,
                        p_account_type  => p_account_type,
                        p_page_no       => '3',
                        p_block_name    => 'INVOICING_PAYMENT',
                        p_validity      => 'I',
                        p_user_id       => null,
                        x_error_status  => x_error_status,
                        x_error_message => x_error_message
                    );
            -- Added by Swamy for Ticket#11604 05/05/2023
                elsif
                    p_account_type in ( 'COBRA', 'ERISA_WRAP' )
                    and l_acct_payment_fees = 'GA'
                    and p_sign_type = 'EMPLOYER'
                then       -- Added by Jaggi #11533
                    l_signature_account_status := 6;
                elsif
                    p_account_type in ( 'COBRA', 'ERISA_WRAP' )
                    and l_acct_payment_fees = 'GA'
                    and p_sign_type = 'BROKER'
                then         -- Added by Jaggi #11533
                    l_signature_account_status := null;
                end if;

            elsif p_account_type in ( 'FSA', 'HRA' ) then
            /*IF L_Acct_payment_fees IN ('BROKER','GA') AND P_Sign_Type  = 'EMPLOYER' AND NVL(l_monthly_fees_paid_by,'*') IN ('BROKER','EMPLOYER') THEN    -- Added EMPLOYER Swamy #11616 15022024
               L_Signature_account_status :=  6  ;    --Pending Signature*/
                if
                    l_monthly_fees_paid_by = 'EMPLOYER'
                    and p_sign_type = 'EMPLOYER'
                    and l_acct_payment_fees in ( 'EMPLOYER', 'BROKER', 'GA' )
                then    -- Added EMPLOYER Swamy #11616 15022024
                    l_signature_account_status := 8;
                elsif
                    l_acct_payment_fees = 'EMPLOYER'
                    and p_sign_type = 'EMPLOYER'
                    and l_monthly_fees_paid_by in ( 'EMPLOYER', 'BROKER', 'GA' )
                then  -- GA Added Swamy #11616 15022024
                    l_signature_account_status := 8;    --Pending payment and Signature
                    pc_employer_enroll.upsert_page_validity(
                        p_batch_number  => p_batch_number,
                        p_entrp_id      => p_entrp_id,
                        p_account_type  => p_account_type,
                        p_page_no       => '3',
                        p_block_name    => 'INVOICING_PAYMENT',
                        p_validity      => 'I',
                        p_user_id       => null,
                        x_error_status  => x_error_status,
                        x_error_message => x_error_message
                    );

                end if;
            end if;
        else
            if p_account_type in ( 'COBRA', 'ERISA_WRAP' ) then       -- Added by Jaggi #11533
                if
                    l_acct_payment_fees = 'GA'
                    and p_sign_type = 'EMPLOYER'
                then
                    l_signature_account_status := 6;    --Pending Signature
                elsif
                    l_acct_payment_fees = 'EMPLOYER'
                    and p_sign_type = 'EMPLOYER'
                then
                    l_signature_account_status := 8;    --Pending payment and Signature
                    pc_employer_enroll.upsert_page_validity(
                        p_batch_number  => p_batch_number,
                        p_entrp_id      => p_entrp_id,
                        p_account_type  => p_account_type,
                        p_page_no       => '3',
                        p_block_name    => 'INVOICING_PAYMENT',
                        p_validity      => 'I',
                        p_user_id       => null,
                        x_error_status  => x_error_status,
                        x_error_message => x_error_message
                    );
            -- Added by Swamy for Ticket#11604 05/05/2023
                elsif
                    p_account_type in ( 'COBRA', 'ERISA_WRAP' )
                    and l_acct_payment_fees = 'BROKER'
                    and p_sign_type = 'EMPLOYER'
                then   -- Added by Jaggi #11533
                    l_signature_account_status := 6;
                elsif
                    p_account_type in ( 'COBRA', 'ERISA_WRAP' )
                    and l_acct_payment_fees = 'BROKER'
                    and p_sign_type = 'GA'
                then         -- Added by Jaggi #11533
                    l_signature_account_status := null;
                end if;

            elsif p_account_type in ( 'FSA', 'HRA' ) then
            /*IF L_Acct_payment_fees IN ('GA','BROKER') AND P_Sign_Type  = 'EMPLOYER' AND NVL(l_monthly_fees_paid_by,'*') IN ('GA','EMPLOYER') THEN   -- Added EMPLOYER Swamy #11616 15022024
               L_Signature_account_status :=  6  ;    --Pending Signature
               */
                if
                    l_monthly_fees_paid_by = 'EMPLOYER'
                    and p_sign_type = 'EMPLOYER'
                    and l_acct_payment_fees in ( 'EMPLOYER', 'BROKER', 'GA' )
                then    -- Added EMPLOYER Swamy #11616 15022024
                    l_signature_account_status := 8;
                elsif
                    l_acct_payment_fees = 'EMPLOYER'
                    and p_sign_type = 'EMPLOYER'
                    and l_monthly_fees_paid_by in ( 'EMPLOYER', 'GA', 'BROKER' )
                then -- Added BROKER Swamy #11616 15022024
                    l_signature_account_status := 8;    --Pending payment and Signature
                    pc_employer_enroll.upsert_page_validity(
                        p_batch_number  => p_batch_number,
                        p_entrp_id      => p_entrp_id,
                        p_account_type  => p_account_type,
                        p_page_no       => '3',
                        p_block_name    => 'INVOICING_PAYMENT',
                        p_validity      => 'I',
                        p_user_id       => null,
                        x_error_status  => x_error_status,
                        x_error_message => x_error_message
                    );

                end if;
            end if;
        end if;

    -- Added by Swamy for Ticket#11527
    -- Employer bank account details should be prefetched when the broker has selected Pending payment and Signature during renewal
        if
            l_signature_account_status in ( 8, 6 )
            and l_acct_payment_fees = 'EMPLOYER'
        then
            for b in (
                select
                    bank_routing_num,
                    bank_acct_num,
                    bank_name,
                    bank_acct_type
                from
                    bank_accounts
                where
                        status = 'A'
                    and bank_account_usage = 'INVOICE'
                    and entity_id = l_acc_id
                    and entity_type = 'ACCOUNT'
            ) loop
                l_bank_name := b.bank_name;
                l_routing_number := b.bank_routing_num;
                l_bank_acc_num := b.bank_acct_num;
                l_bank_acc_type := b.bank_acct_type;
            end loop;

            for rb in (
                select
                    bank_routing_num,
                    bank_acct_num,
                    bank_name,
                    bank_acct_type
                from
                    bank_accounts
                where
                        status = 'A'
                    and bank_account_usage = 'COBRA_DISBURSE'
                    and entity_id = l_acc_id
                    and entity_type = 'ACCOUNT'
            ) loop
                l_remit_bank_name := rb.bank_name;
                l_remit_routing_number := rb.bank_routing_num;
                l_remit_bank_acc_num := rb.bank_acct_num;
                l_remit_bank_acc_type := rb.bank_acct_type;
            end loop;

          -- In PHP many places the fees_payment_flag is used as Ach instead of ACH
            update online_compliance_staging
            set
                bank_name = l_bank_name,
                routing_number = l_routing_number,
                bank_acc_type = l_bank_acc_type,
                bank_acc_num = l_bank_acc_num,
                fees_payment_flag = 'Ach',
                remit_bank_name = l_remit_bank_name,
                remit_routing_number = l_remit_routing_number,
                remit_bank_acc_type = l_remit_bank_acc_type,
                remit_bank_acc_num = l_remit_bank_acc_num
            where
                    source = 'RENEWAL'
                and entrp_id = p_entrp_id
                and batch_number = p_batch_number;

        end if;
    -- End of Addition for Ticket#11527

        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.Renewal_app_signed_by_staging P_Sign_Type', p_sign_type
                                                                                                    || 'l_Acc_id :='
                                                                                                    || l_acc_id
                                                                                                    || 'l_renewed_by_id :='
                                                                                                    || l_renewed_by_id
                                                                                                    || 'p_renewed_by :='
                                                                                                    || p_renewed_by
                                                                                                    || 'p_renewed_user_id :='
                                                                                                    || p_renewed_user_id
                                                                                                    || 'L_Signature_account_status :='
                                                                                                    || l_signature_account_status);

        update account
        set
            renewal_signed_by = decode(p_sign_type, 'EMPLOYER', l_acc_id, l_renewed_by_id),
            renewal_sign_type = p_sign_type,
            renewed_by = p_renewed_by,
            renewed_by_id = l_renewed_by_id,
            renewed_by_user_id = p_renewed_user_id,
            signature_account_status = l_signature_account_status,
            renewed_date = sysdate
        where
            entrp_id = p_entrp_id;

    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.Renewal_app_signed_by_staging', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
            rollback;
    end renewal_app_signed_by_staging;

-- Added by Jaggi #11596
    procedure upsert_employer_user_staging_online (
        p_email                        in varchar2,
        p_ein_number                   in varchar2,
        p_management_account_user_name in varchar2,
        p_management_account_password  in varchar2,
        p_password_question            in varchar2,
        p_password_answer              in varchar2,
        p_enrollment_id                in number,
        x_enrollment_id                out number,
        x_error_message                out varchar2,
        x_return_status                out varchar2
    ) is
        l_enrollment_id number;
    begin
        x_return_status := 'S';
        if p_enrollment_id is null then
        -- delete the existing data IF user tries to re-singup
            delete from employer_online_enrollment
            where
                ein_number = p_ein_number;

            delete from employer_online_product_staging
            where
                ein = p_ein_number;

            pc_employer_enroll.create_employer_staging(
                p_name                         => null,
                p_ein_number                   => p_ein_number,
                p_address                      => null,
                p_city                         => null,
                p_state                        => null,
                p_zip                          => null,
                p_contact_name                 => null,
                p_phone                        => null,
                p_email                        => p_email,
                p_card_allowed                 => null,
                p_management_account_user_name => p_management_account_user_name,
                p_management_account_password  => p_management_account_password,
                p_password_question            => p_password_question,
                p_password_answer              => p_password_answer,
                p_account_type                 => null,
                p_fax_id                       => null,
                p_batch_number                 => null,
                p_office_phone_no              => null,
                p_salesrep_flag                => null,
                p_salesrep_name                => null,
                x_enrollment_id                => x_enrollment_id,
                x_error_message                => x_error_message,
                x_return_status                => x_return_status
            );

        else
            update employer_online_enrollment
            set
                email = p_email,
                ein_number = p_ein_number,
                management_account_user_name = p_management_account_user_name,
                management_account_password = p_management_account_password,
                password_question = p_password_question,
                password_answer = p_password_answer,
                last_update_date = sysdate,
                last_updated_by = 421
            where
                enrollment_id = p_enrollment_id;

            x_enrollment_id := p_enrollment_id;
        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.Upsert_EMPLOYER_USER_STAGING_ONLINE', 'x_enrollment_id ' || x_enrollment_id);
    exception
        when others then
            x_return_status := 'E';
            x_error_message := x_error_message
                               || ' '
                               || sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.Upsert_EMPLOYER_USER_STAGING_ONLINE', 'error in when others ' || sqlerrm)
            ;
    end upsert_employer_user_staging_online;

-- Added by Jaggi #11596
    procedure upsert_emp_company_staging (
        p_name            in varchar2,
        p_address         in varchar2,
        p_city            in varchar2,
        p_state           in varchar2,
        p_zip             in varchar2,
        p_phone           in varchar2,
        p_fax_id          in varchar2,
        p_office_phone_no in varchar2,
        p_enrollment_id   in out number,
        x_error_message   out varchar2,
        x_return_status   out varchar2
    ) is
        l_return_status varchar2(30) := 'S';
    begin
        update employer_online_enrollment
        set
            name = p_name,
            address = p_address,
            city = p_city,
            state = p_state,
            zip = p_zip,
            phone = p_phone,
            fax_no = p_fax_id,
            office_phone_number = p_office_phone_no,
            last_update_date = sysdate,
            last_updated_by = 421
        where
            enrollment_id = p_enrollment_id;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := x_error_message
                               || ' '
                               || sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.upsert_emp_company_staging', 'error in when others ' || sqlerrm);
    end upsert_emp_company_staging;

-- Added by Jaggi #11596
    procedure upsert_emp_product_staging (
        p_enrollment_id in varchar2,
        p_ein_number    in varchar2,
        p_account_type  in varchar2_tbl,
        p_salesrep_flag in varchar2,
        p_salesrep_name in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
        l_batch_number  number;
        l_salesrep_name varchar2(100);
    begin
        x_return_status := 'S';
        pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.upsert_emp_company_staging', 'p_account_type' || p_account_type.count);

    -- case of changing the prodcuts on the summary page - clear the existing data and re-insert
        delete from employer_online_product_staging
        where
            ein = p_ein_number;

        if p_salesrep_flag = 'Y' then
            l_salesrep_name := p_salesrep_name;
        elsif p_salesrep_flag = 'N'
        or p_salesrep_flag is null then
            l_salesrep_name := null;
        end if;

        update employer_online_enrollment
        set
            salesrep_name = l_salesrep_name,
            salesrep_flag = p_salesrep_flag,
            last_update_date = sysdate,
            last_updated_by = 421
        where
            enrollment_id = p_enrollment_id;

--        PC_EMPLOYER_ENROLL.generate_batch_number(PC_ENTRP.get_entrp_id_from_ein_act(p_ein_number,p_account_type(NULL)),p_account_type(NULL),NULL,l_batch_number);
        select
            batch_num_seq.nextval
        into l_batch_number
        from
            dual;

        if p_account_type.count is not null then
            for i in 1..p_account_type.count loop
                pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.upsert_emp_company_staging', 'l_batch_number' || l_batch_number);
                pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.upsert_emp_company_staging',
                                 'p_account_type' || p_account_type(i));
                insert into employer_online_product_staging (
                    enrollment_id,
                    batch_number,
                    ein,
                    account_type,
                    plan_code,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( p_enrollment_id,
                           l_batch_number,
                           p_ein_number,
                           p_account_type(i),
                           case
                               when p_account_type(i) = 'ERISA_WRAP' then
                                   516
                               when p_account_type(i) = 'FSA'        then
                                   513
                               when p_account_type(i) = 'HRA'        then
                                   507
                               when p_account_type(i) = 'COBRA'      then
                                   514
                               when p_account_type(i) = 'FORM_5500'  then
                                   515
                               when p_account_type(i) = 'POP'        then
                                   511
                               when p_account_type(i) = 'LSA'        then
                                   525
                               else
                                   1
                           end,
                           sysdate,
                           0,
                           sysdate,
                           0 );

            end loop;
        end if;

    -- Added by Joshi for 11668. update the employer_online_enrollment table with batch number as HSA/LSA
   -- product enrollment refer this.
        update employer_online_enrollment
        set
            batch_number = l_batch_number
        where
            enrollment_id = p_enrollment_id;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end upsert_emp_product_staging;

-- Added by Jaggi #11596
    function get_er_online_enrollment_details (
        p_enrollment_id in number
    ) return get_er_online_enrollment_details_row_t
        pipelined
        deterministic
    is
        l_record get_er_online_enrollment_details_row;
    begin
        for x in (
            select
                name,
                ein_number,
                address,
                city,
                state,
                zip,
                contact_name,
                phone,
                email,
                management_account_user_name,
                enrollment_account_user_name,
                management_account_password,
                enrollment_account_password,
                password_question,
                password_answer,
                entrp_id,
                acc_num,
                fax_no,
                salesrep_id,
                salesrep_flag,
                office_phone_number,
                salesrep_name,
                enrollment_id
            from
                employer_online_enrollment
            where
                enrollment_id = p_enrollment_id
        ) loop
            l_record.enrollment_id := x.enrollment_id;
            l_record.name := x.name;
            l_record.ein_number := x.ein_number;
            l_record.address := x.address;
            l_record.city := x.city;
            l_record.state := x.state;
            l_record.zip := x.zip;
            l_record.contact_name := x.contact_name;
            l_record.phone := x.phone;
            l_record.email := x.email;
            l_record.username := x.management_account_user_name;
            l_record.enrollment_account_user_name := x.enrollment_account_user_name;
            l_record.password := x.management_account_password;
            l_record.enrollment_account_password := x.enrollment_account_password;
            l_record.pass_question := x.password_question;
            l_record.pass_answer := x.password_answer;
            l_record.entrp_id := x.entrp_id;
            l_record.acc_num := x.acc_num;
            l_record.fax_no := x.fax_no;
            l_record.salesrep_id := x.salesrep_id;
            l_record.salesrep_flag := x.salesrep_flag;
            l_record.office_phone_number := x.office_phone_number;
            l_record.salesrep_name := x.salesrep_name;
            pipe row ( l_record );
        end loop;
    end get_er_online_enrollment_details;

  -- Added by Jaggi #11596
    function get_er_online_product_details (
        p_enrollment_id in number
    ) return get_er_online_product_details_row_t
        pipelined
        deterministic
    is
        l_record get_er_online_product_details_row;
    begin
        for x in (
            select
                account_type
            from
                employer_online_product_staging
            where
                enrollment_id = p_enrollment_id
        ) loop
            l_record.account_type := x.account_type;
            pipe row ( l_record );
        end loop;
    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.Get_Er_Online_Product_Details', sqlerrm);
    end get_er_online_product_details;

 -- Added by Jaggi #11596
    procedure process_employer_online (
        p_enrollment_id in number,
        p_enrolle_type  in varchar2 default 'E',
        p_referral_url  in varchar2,
        p_referral_code in varchar2,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        l_sqlerrm       varchar2(3200);
        l_acc_id        number;
        l_action        varchar2(255);
        l_setup_error exception;
        l_create_error exception;
        l_return_status varchar2(30) := 'S';
        l_error_message varchar2(3200);
        l_acc_num       varchar2(30);
        l_entrp_id      number;
        l_user_id       number;
        l_exist         varchar2(2) := 'N';
        l_create        varchar2(10) := 'N';
        l_account_type  varchar2(10);
        l_batch_number  number;
        l_ein_number    varchar2(10);
    begin
        x_return_status := 'S';
        for x in (
            select
                name,
                ein_number,
                address,
                city,
                state,
                zip,
                contact_name,
                phone,
                email,
                management_account_user_name,
                enrollment_account_user_name,
                management_account_password,
                enrollment_account_password,
                password_question,
                password_answer,
                p.entrp_id     entrp_id,
                p.acc_num      acc_num,
                fax_no,
                salesrep_id,
                salesrep_flag,
                office_phone_number,
                salesrep_name,
                p.account_type account_type,
                fee_plan_type,
                debit_card_allowed,
                p.plan_code    plan_code,
                industry_type
            from
                employer_online_enrollment      e,
                employer_online_product_staging p
            where
                    e.enrollment_id = p.enrollment_id
                and e.enrollment_id = p_enrollment_id
        ) loop
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.PROCESS_EMPLOYER_ONLINE', l_action);
            l_entrp_id := null;
            l_ein_number := x.ein_number;
            begin
        -- Stacked Account Logic : Vanitha 01/25/2017
                for xx in (
                    select
                        'FSA'
                    from
                        dual
                    where
                        x.account_type in ( 'FSA', 'HRA' )
                    union
                    select
                        'HRA'
                    from
                        dual
                    where
                        x.account_type in ( 'FSA', 'HRA' )
                    union
                    select
                        x.account_type
                    from
                        dual
                ) loop
                    if l_entrp_id is null then
                        l_entrp_id := pc_entrp.get_entrp_id_from_ein_act(x.ein_number, x.account_type);
                    end if;
                end loop;

                if
                    x.account_type in ( 'FSA', 'HRA' )
                    and pc_account.is_stacked_account(l_entrp_id) = 'Y'
                then
                    update account
                    set
                        account_type = 'FSA'
                    where
                            account_type = 'HRA'
                        and entrp_id = l_entrp_id;

                end if;
        -- end of stacked account logic

                if l_entrp_id is not null then
                    l_action := 'Employer Exist ';
                    pc_employer_enroll.update_employer(
                        p_entrp_id            => l_entrp_id,
                        p_name                => x.name,
                        p_ein_number          => x.ein_number,
                        p_address             => x.address,
                        p_city                => x.city,
                        p_state               => x.state,
                        p_zip                 => x.zip,
                        p_contact_name        => x.contact_name,
                        p_phone               => x.phone,
                        p_email               => x.email,
                        p_user_id             => p_user_id,
                        p_fax_id              => x.fax_no,
                        p_office_phone_number => x.office_phone_number,
                        x_error_message       => x_error_message,
                        x_return_status       => x_return_status
                    );

                else
                    l_action := 'Creating Employer ';
                    pc_entrp.insert_enterprise(
                        p_name                => x.name,
                        p_ein_number          => x.ein_number,
                        p_address             => x.address,
                        p_city                => x.city,
                        p_state               => x.state,
                        p_zip                 => x.zip,
                        p_contact_name        => x.contact_name,
                        p_phone               => x.phone,
                        p_email               => x.email,
                        p_fee_plan_type       => x.fee_plan_type,
                        p_card_allowed        => x.debit_card_allowed,
                        p_office_phone_number => x.office_phone_number,
                        x_entrp_id            => l_entrp_id,
                        p_industry_type       => x.industry_type,
                        p_fax_id              => x.fax_no,
                        x_error_status        => l_return_status,
                        x_error_message       => l_error_message
                    );

                    if l_return_status <> 'S' then
                        raise l_create_error;
                    end if;
                    pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.PROCESS_EMPLOYER_ONLINE', 'l_entrp_id ' || l_entrp_id);
                    l_action := 'Creating Account';
                    pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.PROCESS_EMPLOYER_ONLINE', l_action);
                    insert into account (
                        acc_id,
                        entrp_id,
                        acc_num,
                        plan_code,
                        start_date,
                        note,
                        fee_setup,
                        fee_maint,
                        reg_date,
                        pay_code,
                        pay_period,
                        account_status,
                        complete_flag,
                        account_type,
                        enrollment_source,
                        broker_id,
                        referral_url,
                        referral_code,
--			  Enrolled_By,
                        enrolle_type,
                        created_by,
                        last_updated_by
                    ) values ( acc_seq.nextval,
                               l_entrp_id,
                               'G'
                               ||
                               case
                                   when x.account_type = 'HSA'
                                        and x.plan_code in ( 1, 2, 3 ) then
                                           substr(
                                               pc_account.generate_acc_num(x.plan_code,
                                                                           upper(x.state)),
                                               2
                                           )
                                   else
                                       pc_account.generate_acc_num(x.plan_code, null)
                               end,
                               x.plan_code,
                               sysdate,
                               'Online Enrollment',
                               case
                                   when x.account_type = 'HSA' then
                                       pc_plan.fsetup_online(0)
                                   else
                                       0
                               end,
                               case
                                   when x.account_type = 'HSA' then
                                       pc_plan.fmonth(x.plan_code) --- This plan code has to be hard coded
                                   else
                                       0
                               end,
                               sysdate,
                               x.fee_plan_type,
                               null ---x.er_contribution_frequency
                               ,
                               decode(p_enrolle_type, 'EMPLOYER', 3, 'GA', 9,
                                      'BROKER', 10),
                               decode(x.account_type, 'LSA', 1, 0),
                               x.account_type,
                               'ONLINE',
                               0,
                               p_referral_url,
                               p_referral_code,
--		      P_Enrolled_By,
                               p_enrolle_type,
                               p_user_id,
                               p_user_id ) returning acc_id into l_acc_id;

                    select
                        acc_num
                    into l_acc_num
                    from
                        account
                    where
                        acc_id = l_acc_id;

                    update employer_online_product_staging
                    set
                        entrp_id = l_entrp_id,
                        acc_num = l_acc_num
                    where
                            enrollment_id = p_enrollment_id
                        and account_type = x.account_type;

           -- Added by Joshi for 11668.
--             IF X.ACCOUNT_TYPE = 'HSA' THEN
                    update employer_online_enrollment
                    set
                        entrp_id = l_entrp_id,
                        acc_num = l_acc_num -- added by Jaggi #11706 on 08/23/2023
                    where
                        enrollment_id = p_enrollment_id;
--             END IF;

                end if;

            exception
                when l_create_error then
                    x_error_message := l_action
                                       || ' '
                                       || x_error_message;
                    x_return_status := 'E';
                    update employer_online_enrollment
                    set
                        error_message = x_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = p_enrollment_id;

                when others then
                    x_error_message := l_action
                                       || ' '
                                       || sqlerrm;
                    x_return_status := 'E';
                    update employer_online_enrollment
                    set
                        error_message = x_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = p_enrollment_id;
        --  RAISE;
                    pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.PROCESS_EMPLOYER_ONLINE', 'error in when others ' || sqlerrm);
                    dbms_output.put_line('error message ' || sqlerrm);
            end;
    /* Create Online Users entry */
            if p_enrolle_type = 'EMPLOYER' then
                update account
                set
                    enrolled_by = l_acc_id,
                    enrolle_type = p_enrolle_type
                where
                    acc_id = l_acc_id;

                l_action := 'Creating Management Account';
                pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.PROCESS_EMPLOYER_ONLINE', l_action);
                begin
                    if pc_employer_enroll_compliance.is_inactive_plan_exists(l_ein_number) = 'Y' then
                        select
                            'Y',
                            user_id
                        into
                            l_create,
                            l_user_id
                        from
                            online_users
                        where
                                replace(tax_id, '-') = replace(l_ein_number, '-')
                            and emp_reg_type = 2
                            and user_status not in ( 'I', 'D' )
                            and exists (
                                select
                                    '1'
                                from
                                    account    a,
                                    enterprise e
                                where
                                        e.entrp_code = l_ein_number
                                    and a.account_status not in ( '1', '2', '5' )
                                    and a.entrp_id = e.entrp_id
                            );

                    else
                        select
                            'Y',
                            user_id
                        into
                            l_create,
                            l_user_id
                        from
                            online_users
                        where
                                replace(tax_id, '-') = replace(l_ein_number, '-')
                            and user_status not in ( 'I', 'D' )
                            and exists (
                                select
                                    '1'
                                from
                                    account    a,
                                    enterprise e
                                where
                                        e.entrp_code = l_ein_number
                                    and a.account_status not in ( '1', '2', '5' )
                                    and a.entrp_id = e.entrp_id
                            );

                    end if;
                exception
                    when no_data_found then
                        l_create := 'N';
                end;

                if l_create = 'N' then --only if user not created
                    for k in (
                        select
                            acc_num
                        from
                            employer_online_enrollment
                        where
                            replace(ein_number, '-') = replace(l_ein_number, '-')
                    ) loop
                        l_acc_num := k.acc_num;
                        exit;
                    end loop;

                    pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.PROCESS_EMPLOYER_ONLINE-Acc#', l_acc_num);
                    pc_users.insert_users(
                        p_user_name     => x.management_account_user_name,
                        p_password      => x.management_account_password,
                        p_user_type     => 'E',
                        p_emp_reg_type  => 2 -- check if this is for management
                        ,
                        p_find_key      => l_acc_num,
                        p_email         => x.email,
                        p_pw_question   => x.password_question,
                        p_pw_answer     => x.password_answer,
                        p_tax_id        => x.ein_number,
                        x_user_id       => l_user_id,
                        x_return_status => l_return_status,
                        x_error_message => x_error_message
                    );

                end if;

            end if;

            if l_user_id is not null then
                update account
                set
                    created_by = l_user_id,
                    last_updated_by = l_user_id
                where
                    acc_id = l_acc_id;

            end if;

            if l_return_status <> 'S' then
                x_return_status := 'E';
            end if;
        end loop;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := x_error_message
                               || ' '
                               || sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL_COMPLIANCE.PROCESS_EMPLOYER_ONLINE', 'error in when others ' || sqlerrm);
    end process_employer_online;

-- Added by Joshi for 12526        
    function get_plan_validity (
        p_batch_number number,
        p_entrp_id     number
    ) return varchar2 is
        ls_return varchar2(1) := 'V';
    begin
        for x in (
            select
                'I' plan_validity
            from
                compliance_plan_staging
            where
                    entity_id = p_entrp_id
                and batch_number = p_batch_number
                and page_validity = 'I'
        ) loop
            ls_return := x.plan_validity;
        end loop;

        return ls_return;
    end get_plan_validity;

-- Added by Swamy for Ticket#12534 
-- Procedure to insert the bank details to staging table
    procedure set_payment_cobra (
        p_entrp_id                in number,
        p_acc_id                  in number,
        p_batch_number            in number,
        p_bank_name               in varchar2,
        p_bank_acc_type           in varchar2,
        p_routing_number          in varchar2,
        p_bank_acc_num            in varchar2,
        p_bank_acct_usage         in varchar2,
        p_user_id                 in number,
        p_page_validity           in varchar2,
        p_bank_authorize          in varchar2,
        p_giac_response           in varchar2,
        p_giac_verify             in varchar2,
        p_giac_authenticate       in varchar2,
        p_bank_acct_verified      in varchar2,
        p_business_name           in varchar2,
        p_annual_optional_remit   in varchar2,
        p_fees_remitance_flag     in varchar2
                         --  ,p_pay_optional_fees_by        IN    VARCHAR2
                         --  ,p_optional_fee_payment_method IN    VARCHAR2
        ,
        p_optional_bank_authorize in varchar2,
        p_remit_bank_authorize    in varchar2,
        p_bank_acct_stg_id        in number,
        p_existing_bank_flag      in varchar2     -- Added by Swamy for Ticket#12534
        ,
        p_bank_acct_id            in number     -- Added by Swamy for Ticket#12534(12624)
        ,
        x_bank_status             out varchar2,
        x_error_status            out varchar2,
        x_error_message           out varchar2
    ) is

        l_bank_name               varchar2(100);
        l_entity_type             varchar2(100);
        l_broker_id               number;
        l_acct_type               varchar2(100);
--l_User_Bank_acct_stg_Id    NUMBER;
        l_page_validity           varchar2(100);
        l_opt_fee_bank_created_by varchar2(100);
        l_ann_fee_bank_created_by varchar2(100);
        x_user_bank_acct_stg_id   number;
        l_optional_bank_id        number;
        l_remit_bank_id           number;
        l_bank_id                 number;
--x_bank_status              VARCHAR2(100);    -- Added by Swamy for Ticket#12534 
        l_error_message           varchar2(1000); -- Added by Swamy for Ticket#12534 
        l_error_status            varchar2(100);
        l_bank_status             varchar2(100);
    begin
        pc_log.log_error('pc_employer_enroll.set_payment_cobra begin p_entrp_id', ' p_entrp_id '
                                                                                  || p_entrp_id
                                                                                  || 'p_user_id :='
                                                                                  || p_user_id
                                                                                  || 'p_batch_number :='
                                                                                  || p_batch_number
                                                                                  || 'p_giac_response :='
                                                                                  || p_giac_response
                                                                                  || 'p_giac_verify :='
                                                                                  || p_giac_verify
                                                                                  || 'p_giac_authenticate :='
                                                                                  || p_giac_authenticate);

        pc_broker.get_broker_id(
            p_user_id     => p_user_id,
            p_entity_type => l_entity_type,
            p_broker_id   => l_broker_id
        );

        l_entity_type := nvl(l_entity_type, 'EMPLOYER');
        l_acct_type := pc_account.get_account_type(p_acc_id);
        pc_log.log_error('pc_employer_enroll.set_payment_cobra begin l_entity_type', ' l_entity_type '
                                                                                     || l_entity_type
                                                                                     || 'l_acct_type :='
                                                                                     || l_acct_type
                                                                                     || 'p_bank_Acct_stg_id :='
                                                                                     || p_bank_acct_stg_id
                                                                                     || ' p_Acc_id :='
                                                                                     || p_acc_id);

	--l_User_Bank_acct_stg_Id := p_bank_Acct_stg_id;
        if l_acct_type = 'COBRA' then
      /* FOR j IN (SELECT  User_Bank_acct_stg_Id,bank_name
                    FROM User_Bank_acct_Staging
                   WHERE batch_number = p_batch_number
                     AND entrp_id = p_entrp_id
					 AND NVL(optional_remit_flag,'N') = NVL(p_annual_optional_remit,'N')
                     AND nvl(renewed_by,'EMPLOYER') = l_entity_type) loop --10747new
              l_User_Bank_acct_stg_Id := j.User_Bank_acct_stg_Id;
              l_bank_name             := j.bank_name;
        END LOOP;*/

            pc_log.log_error('pc_employer_enroll.set_payment', ' calling pc_employer_enroll.Upsert_Bank_Info ');
            pc_employer_enroll.upsert_bank_info(
                p_user_bank_acct_stg_id => p_bank_acct_stg_id,
                p_entrp_id              => p_entrp_id,
                p_batch_number          => p_batch_number,
                p_account_type          => l_acct_type,
                p_acct_usage            => p_bank_acct_usage,
                p_display_name          => p_bank_name,
                p_bank_acct_type        => p_bank_acc_type,
                p_bank_routing_num      => p_routing_number,
                p_bank_acct_num         => p_bank_acc_num,
                p_bank_name             => p_bank_name,
                p_user_id               => p_user_id,
                p_validity              => nvl(p_page_validity, 'V'),
                p_bank_authorize        => p_bank_authorize,
                p_giac_response         => p_giac_response,
                p_giac_verify           => p_giac_verify,
                p_giac_authenticate     => p_giac_authenticate,
                p_bank_acct_verified    => p_bank_acct_verified,
                p_business_name         => p_business_name,
                p_annual_optional_remit => p_annual_optional_remit,
                p_existing_bank_flag    => p_existing_bank_flag     -- Added by Swamy for Ticket#12534
                ,
                p_bank_acct_id          => p_bank_acct_id,
                x_user_bank_acct_stg_id => x_user_bank_acct_stg_id,
                x_bank_status           => l_bank_status,
                x_error_status          => x_error_status,
                x_error_message         => x_error_message
            );

            pc_log.log_error('pc_employer_enroll.set_payment', ' calling pc_employer_enroll.Upsert_Bank_Info X_ERROR_STATUS :='
                                                               || x_error_status
                                                               || ' X_ERROR_MESSAGE :='
                                                               || x_error_message
                                                               || 'x_bank_status :='
                                                               || x_bank_status);

            if nvl(x_error_status, '*') = 'E'
            or l_bank_status in ( 'P', 'R' ) then
                l_page_validity := 'I';
                l_error_status := x_error_status;
                l_error_message := x_error_message;
            elsif nvl(x_error_status, '*') = 'S' then
                l_page_validity := nvl(p_page_validity, 'V');
                l_error_status := x_error_status;
                l_error_message := x_error_message;
            else
                l_page_validity := nvl(p_page_validity, 'V');
            end if;

            pc_log.log_error('pc_employer_enroll.set_payment', ' calling pc_employer_enroll.upsert_page_validity '
                                                               || ' l_page_validity :='
                                                               || l_page_validity);
            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_account_type  => l_acct_type,
                p_page_no       => '3',
                p_block_name    => 'INVOICING_PAYMENT',
                p_validity      => l_page_validity,
                p_user_id       => p_user_id,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );
    -- 'O' Optional bank details
    -- 'A' Annual bank details
    -- 'R' Remmitance bank details 
            if nvl(p_annual_optional_remit, 'N') = 'O' then
                l_optional_bank_id := x_user_bank_acct_stg_id;
       -- When both payee is same ie either BROKER/EMPLOYER, then from php the p_optional_fee_payment_method is passed as NULL, due to this invoice is affeceted as the bank acc num is not stored in online_compliance_staging
       /*IF X_User_Bank_acct_stg_Id IS NOT NULL AND NVL(p_optional_fee_payment_method,'*') = '*' THEN
          l_opt_fee_payment_method := 'ACH';
       END IF;*/
                if nvl(p_bank_name, '*') <> nvl(l_bank_name, '*') then
                    l_opt_fee_bank_created_by := pc_users.get_user_type(p_user_id);
                end if;

            elsif nvl(p_annual_optional_remit, 'N') = 'R' then
                l_remit_bank_id := x_user_bank_acct_stg_id;
            else
                l_bank_id := x_user_bank_acct_stg_id;
                if nvl(p_bank_name, '*') <> nvl(l_bank_name, '*') then
                    l_ann_fee_bank_created_by := pc_users.get_user_type(p_user_id);
                end if;

            end if;

            update online_compliance_staging
            set 
      --optional_fee_paid_by        = p_pay_optional_fees_by 
     -- optional_fee_payment_method  = l_opt_fee_payment_method --p_optional_fee_payment_method 
                optional_bank_authorize = p_optional_bank_authorize,
                remit_bank_authorize = p_remit_bank_authorize,
                bank_authorize = p_bank_authorize,
                annual_fee_bank_created_by = nvl(l_ann_fee_bank_created_by, annual_fee_bank_created_by),
                optional_fee_bank_created_by = nvl(l_opt_fee_bank_created_by, optional_fee_bank_created_by)
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number;

        end if;

        x_error_message := l_error_message;
        x_error_status := l_error_status;
        x_bank_status := l_bank_status;
    exception
        when others then
            x_error_status := 'U';
            x_error_message := sqlerrm(sqlcode);
            pc_log.log_error('pc_employer_enroll.set_payment_cobra', sqlerrm || dbms_utility.format_error_backtrace);
    end set_payment_cobra;

-- Added by Swamy for Ticket#12534 
    procedure upsert_compliance_staging_info (
        p_entrp_id                    in number,
        p_batch_number                in number,
        p_source                      in varchar2,
        p_fees_payment_flag           in varchar2,
        p_salesrep_flag               in varchar2,
        p_salesrep_id                 in number,
        p_cp_invoice_flag             in varchar2,
        p_fees_remitance_flag         in varchar2,
        p_acct_payment_fees           in varchar2,
        p_pay_optional_fees_by        in varchar2,
        p_optional_fee_payment_method in varchar2
                                       -- ,p_optional_fee_bank_acct_id   IN    NUMBER
                                      --  ,P_optional_Bank_Authorize     IN    VARCHAR2
                                      --  ,P_Remit_Bank_Authorize        IN    VARCHAR2
                                      --  ,P_Bank_Authorize              IN    VARCHAR2
                                       -- ,p_bank_acct_id                IN    NUMBER
        ,
        p_page_validity               in varchar2,
        p_user_id                     in number,
        x_error_status                out varchar2,
        x_error_message               out varchar2
    ) is

        l_count              number;
        l_acct_type          varchar2(100);
        l_enrolle_type       varchar2(100);
        l_bank_name          varchar2(100);
        l_optional_bank_name varchar2(100);
        l_source             varchar2(100);
        v_page3_payment      varchar2(100);
        l_cnt                number;
        setup_error exception;
    begin
        pc_log.log_error('pc_employer_enroll.upsert_compliance_staging_info p_acct_payment_fees ', p_acct_payment_fees
                                                                                                   || ' p_entrp_id :='
                                                                                                   || p_entrp_id
                                                                                                   || ' p_batch_number :='
                                                                                                   || p_batch_number
                                                                                                   || ' P_source :='
                                                                                                   || p_source);

        for bank in (
            select
                bank_name,
                optional_bank_name,
                source  -- Added by swamy for Ticket#11364
            from
                online_compliance_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            l_bank_name := bank.bank_name;
            l_optional_bank_name := bank.optional_bank_name;
            l_source := bank.source;
        end loop;

        if nvl(l_source, '*') = '*' then
            x_error_message := ' No previous Bank details data for Compliance Plan';
      --raise setup_error ;
        end if;
        for acc in (
            select
                account_type,
                nvl(enrolle_type, 'EMPLOYER') enrolle_type
            from
                account
            where
                entrp_id = p_entrp_id
        ) loop
            l_acct_type := acc.account_type;
            l_enrolle_type := acc.enrolle_type;
        end loop;

        if l_source not in ( 'RENEWAL' ) then   -- Added by swamy for Ticket#11364
        -- brought from top to here by swamy for ticket#11364
            for plan in (
                select
                    count(*) cnt
                from
                    compliance_plan_staging
                where
                        entity_id = p_entrp_id
                    and batch_number = p_batch_number
            ) loop
                l_count := plan.cnt;
            end loop;

            if l_count = 0 then
                x_error_message := ' No previous data for Compliance Plan';
                raise setup_error;
            end if;
        end if;

        v_page3_payment := p_page_validity;
        if p_cp_invoice_flag = 1 then
            for con_led in (
                select
                    count(*) cnt
                from
                    contact_leads
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and contact_type in ( 'BROKER', 'GA' )
            ) loop
                l_cnt := con_led.cnt;
            end loop;

            if nvl(l_cnt, 0) = 0 then -- If only broker or GA is not there then we shud invalidate it
                v_page3_payment := 'I';
            end if;
        end if;                                     --Send Invoice Flag

        update online_compliance_staging
        set
            fees_payment_flag = p_fees_payment_flag,
            salesrep_flag = p_salesrep_flag,
            salesrep_id = p_salesrep_id,
            send_invoice = p_cp_invoice_flag,
            remittance_flag = p_fees_remitance_flag,
            acct_payment_fees = p_acct_payment_fees,
            optional_fee_paid_by = p_pay_optional_fees_by,
            optional_fee_payment_method = p_optional_fee_payment_method,
     -- optional_fee_bank_acct_id   = p_optional_fee_bank_acct_id,
     -- optional_Bank_Authorize     = P_optional_Bank_Authorize,
     -- Remit_Bank_Authorize        = P_Remit_Bank_Authorize,
     -- Bank_Authorize              = P_Bank_Authorize
     -- annual_fee_bank_created_by  = CASE WHEN NVL(p_bank_name,'*') <> NVL(l_bank_name,'*') THEN pc_users.get_user_type(p_user_id) ELSE annual_fee_bank_created_by END,
     -- optional_fee_bank_created_by= CASE WHEN NVL(p_optional_bank_name,'*') <> NVL(l_optional_bank_name,'*') THEN pc_users.get_user_type(p_user_id) ELSE optional_fee_bank_created_by END,
     -- bank_acct_id                = p_bank_acct_id -- Added by Joshi for 9141
            page3_payment = v_page3_payment
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

        update contact_leads
        set
            send_invoice = p_cp_invoice_flag
        where
                entity_id = pc_entrp.get_tax_id(p_entrp_id)
            and account_type = l_acct_type; -- Replaced 'COBRA' with l_acct_type by swamy  Ticket#6294

    exception
        when setup_error then
            x_error_status := 'E';
            pc_log.log_error('pc_employer_enroll.upsert_compliance_staging_info', x_error_message);
        when others then
            x_error_status := 'U';
            x_error_message := sqlerrm(sqlcode);
            pc_log.log_error('pc_employer_enroll.upsert_compliance_staging_info', sqlerrm);
    end upsert_compliance_staging_info;

-- Added by Swamy for Ticket#12534 
    procedure insert_enroll_renew_bank_accounts (
        p_entrp_id               in number,
        p_acc_id                 in number,
        p_batch_number           in number,
        p_acct_payment_fees      in varchar2,
        p_fees_payment_flag      in varchar2,
        p_optional_fee_paid_by   in varchar2,
        p_opt_fee_payment_method in varchar2,
        p_user_id                in number,
        p_source                 in varchar2,
        p_account_status         out number,
        x_error_status           out varchar2,
        x_error_message          out varchar2
    ) is

        l_acct_usage                varchar2(100);
        l_bank_count                number;
        l_bank_id                   number;
        l_bank_acct_id              number;
        l_optional_fee_bank_acct_id number;
        l_entity_id                 number;
        l_entity_type               varchar2(100);
        l_account_status            varchar2(100) := 'N';
        l_optional_bank_acc_num     varchar2(200);
        l_bank_acc_num              varchar2(200);
        l_bank_status               varchar2(200);
        erreur exception;
    begin

 -- Added by Swamy for Ticket#12534 
        for bank_rec in (
            select
                user_bank_acct_stg_id,
                bank_name,
                bank_routing_num,
                bank_acct_num,
                bank_acct_type,
                annual_optional_remit,
                bank_status,
                giac_response,
                giac_verify,
                giac_authenticate,
                business_name,
                bank_acct_verified,
                created_by
            from
                user_bank_acct_staging
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
        ) loop
            l_acct_usage := 'INVOICE';
            l_bank_count := 0;
            l_bank_id := null;
            l_entity_type := null;
            l_entity_id := null;

        -- Annual bank details
            if
                nvl(bank_rec.annual_optional_remit, 'N') = 'A'
                and upper(p_fees_payment_flag) = 'ACH'
                and bank_rec.bank_name is not null
            then
                if upper(p_acct_payment_fees) = 'EMPLOYER' then
                    l_entity_id := p_acc_id;
                    l_entity_type := 'ACCOUNT';
                elsif upper(p_acct_payment_fees) = 'BROKER' then
                    l_entity_id := pc_account.get_broker_id(p_acc_id);
                    l_entity_type := 'BROKER';
                elsif upper(p_acct_payment_fees) = 'GA' then
                    l_entity_id := pc_account.get_ga_id(p_acc_id);
                    l_entity_type := 'GA';
                end if;
            elsif
                nvl(bank_rec.annual_optional_remit, 'N') = 'O'
                and upper(p_opt_fee_payment_method) = 'ACH'
                and bank_rec.bank_name is not null
            then
                if upper(p_optional_fee_paid_by) = 'EMPLOYER' then
                    l_entity_id := p_acc_id;
                    l_entity_type := 'ACCOUNT';
                elsif upper(p_optional_fee_paid_by) = 'BROKER' then
                    l_entity_id := pc_account.get_broker_id(p_acc_id);
                    l_entity_type := 'BROKER';
                elsif upper(p_optional_fee_paid_by) = 'GA' then
                    l_entity_id := pc_account.get_ga_id(p_acc_id);
                    l_entity_type := 'GA';
                end if;
            elsif
                nvl(bank_rec.annual_optional_remit, 'N') = 'R'
                and bank_rec.bank_name is not null
            then
                l_acct_usage := 'COBRA_DISBURSE';
                l_entity_id := p_acc_id;
                l_entity_type := 'ACCOUNT';
            end if;

            pc_log.log_error('PC_EMPLOYER_ENROLL.Insert_Enroll_renew_bank_accounts l_entity_id: ', l_entity_id
                                                                                                   || 'l_entity_type'
                                                                                                   || l_entity_type
                                                                                                   || 'l_acct_usage l'
                                                                                                   || l_acct_usage
                                                                                                   || ' p_opt_fee_payment_method :='
                                                                                                   || p_opt_fee_payment_method);

            if nvl(l_entity_id, -1) <> -1 then
                l_bank_id := pc_user_bank_acct.get_bank_acct_id(
                    p_entity_id          => l_entity_id,
                    p_entity_type        => l_entity_type,
                    p_bank_acct_num      => bank_rec.bank_acct_num,
                    p_bank_name          => bank_rec.bank_name,
                    p_bank_routing_num   => bank_rec.bank_routing_num,
                    p_bank_account_usage => l_acct_usage,
                    p_bank_acct_type     => bank_rec.bank_acct_type
                );

                pc_log.log_error('PC_EMPLOYER_ENROLL.Insert_Enroll_renew_bank_accounts l_bank_id l', l_bank_id);
                if nvl(l_bank_id, 0) = 0 then
                     -- fee bank details
                    pc_user_bank_acct.giact_insert_bank_account(
                        p_entity_id             => l_entity_id,
                        p_entity_type           => l_entity_type,
                        p_display_name          => bank_rec.bank_name,
                        p_bank_acct_type        => bank_rec.bank_acct_type,
                        p_bank_routing_num      => bank_rec.bank_routing_num,
                        p_bank_acct_num         => bank_rec.bank_acct_num,
                        p_bank_name             => bank_rec.bank_name,
                        p_bank_account_usage    => nvl(l_acct_usage, 'INVOICE'),
                        p_user_id               => bank_rec.created_by,
                        p_bank_status           => bank_rec.bank_status,
                        p_giac_verify           => bank_rec.giac_verify,
                        p_giac_authenticate     => bank_rec.giac_authenticate,
                        p_giac_response         => bank_rec.giac_response,
                        p_business_name         => bank_rec.business_name,
                        p_bank_acct_verified    => bank_rec.bank_acct_verified,
                        p_existing_bank_account => 'N',
                        x_bank_status           => l_bank_status,
                        x_bank_acct_id          => l_bank_id,
                        x_return_status         => x_error_status,
                        x_error_message         => x_error_message
                    );

                    if nvl(x_error_status, 'S') = 'E' then
                        x_error_message := ( x_error_message
                                             || 'ERROR in cobra_renewal_final_submit after calling insert_bank_account' );
                        raise erreur;
                    end if;

                    if nvl(bank_rec.annual_optional_remit, 'N') = 'A' then
                        l_bank_acct_id := l_bank_id;
                        l_bank_acc_num := bank_rec.bank_acct_num;
                    elsif nvl(bank_rec.annual_optional_remit, 'N') = 'O' then
                        l_optional_fee_bank_acct_id := l_bank_id;
                        l_optional_bank_acc_num := bank_rec.bank_acct_num;
                    end if;

                    pc_log.log_error('PC_EMPLOYER_ENROLL.Insert_Enroll_renew_bank_accounts l_bank_acc_num **1 ', l_bank_acc_num
                                                                                                                 || ' l_optional_bank_acc_num :='
                                                                                                                 || l_optional_bank_acc_num
                                                                                                                 || 'l_bank_acct_id :='
                                                                                                                 || l_bank_acct_id
                                                                                                                 || ' l_optional_fee_bank_acct_id :='
                                                                                                                 || l_optional_fee_bank_acct_id
                                                                                                                 || ' bank_rec.annual_optional_remit :='
                                                                                                                 || bank_rec.annual_optional_remit
                                                                                                                 );
                    -- For Enrollment, if any bank is in Pending documentation or Pending review then the account status should be Pending bank verification
                    if
                        nvl(bank_rec.bank_status, '*') in ( 'P', 'W' )
                        and p_source = 'E'
                    then
                        p_account_status := 11;
                    end if;

                    pc_log.log_error('PC_EMPLOYER_ENROLL.Insert_Enroll_renew_bank_accounts bank_rec.bank_status **1.1 ', bank_rec.bank_status
                                                                                                                         || ' p_source :='
                                                                                                                         || p_source
                                                                                                                         || ' p_account_status :='
                                                                                                                         || p_account_status
                                                                                                                         );

                else
                    if nvl(bank_rec.annual_optional_remit, 'N') = 'A' then
                        l_bank_acct_id := l_bank_id;
                        l_bank_acc_num := pc_user_bank_acct.get_bank_acct_num(l_bank_id);
                    elsif nvl(bank_rec.annual_optional_remit, 'N') = 'O' then
                        l_optional_fee_bank_acct_id := l_bank_id;
                        l_optional_bank_acc_num := pc_user_bank_acct.get_bank_acct_num(l_bank_id);
                    end if;

                    pc_log.log_error('PC_EMPLOYER_ENROLL.Insert_Enroll_renew_bank_accounts l_bank_acc_num **2', l_bank_acc_num
                                                                                                                || ' l_optional_bank_acc_num :='
                                                                                                                || l_optional_bank_acc_num
                                                                                                                || 'l_bank_acct_id :='
                                                                                                                || l_bank_acct_id
                                                                                                                || ' l_optional_fee_bank_acct_id :='
                                                                                                                || l_optional_fee_bank_acct_id
                                                                                                                || ' bank_rec.annual_optional_remit :='
                                                                                                                || bank_rec.annual_optional_remit
                                                                                                                );

                     -- FOr Broker/GA if the exisitng bank does not have business name, and if during enrollment and renewal
                     -- user has given business name, then the business name should be updated.
                    if l_entity_type in ( 'BROKER', 'GA' ) then
                        for k in (
                            select
                                business_name
                            from
                                bank_accounts
                            where
                                    bank_acct_id = l_bank_id
                                and entity_id = l_entity_id
                                and entity_type = l_entity_type
                        ) loop
                            if nvl(k.business_name, '*') <> nvl(bank_rec.business_name, '*') then
                                update bank_accounts
                                set
                                    business_name = bank_rec.business_name
                                where
                                        bank_acct_id = l_bank_id
                                    and entity_id = l_entity_id
                                    and entity_type = l_entity_type;

                            end if;
                        end loop;
                    end if;

                end if;

                pc_file_upload.giact_insert_file_attachments(
                    p_user_bank_stg_id => bank_rec.user_bank_acct_stg_id,
                    p_attachment_id    => null,
                    p_entity_id        => l_bank_id,
                    p_entity_name      => 'GIACT_BANK_INFO',
                    p_document_purpose => 'GIACT_DOC',
                    p_batch_number     => p_batch_number,
                    p_source           => p_source,
                    x_error_status     => x_error_status,
                    x_error_message    => x_error_message
                );

                update user_bank_acct_staging
                set
                    bank_acct_id = l_bank_id
                where
                        user_bank_acct_stg_id = bank_rec.user_bank_acct_stg_id
                    and batch_number = p_batch_number
                    and entrp_id = p_entrp_id;

            end if;

        end loop;

        update online_compliance_staging
        set
            bank_acct_id = nvl(l_bank_acct_id, bank_acct_id),
            optional_fee_bank_acct_id = nvl(l_optional_fee_bank_acct_id, optional_fee_bank_acct_id),
            bank_acc_num = l_bank_acc_num,
            optional_bank_acc_num = l_optional_bank_acc_num
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

        x_error_status := 'S';
    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end insert_enroll_renew_bank_accounts;

-- Added by Swamy for Ticket#12534 
    function get_cobra_giact_bank_details (
        p_entrp_id     in number,
        p_batch_number in number
    ) return sys_refcursor is

        thecursor                    sys_refcursor;
        l_annual_bank_name           varchar2(100);
        l_annual_routing_number      varchar2(100);
        l_annual_bank_acc_num        varchar2(100);
        l_annual_bank_acc_type       varchar2(100);
        l_annual_created_by          varchar2(100);
        l_optional_bank_name         varchar2(100);
        l_optional_routing_number    varchar2(100);
        l_optional_bank_acc_num      varchar2(100);
        l_optional_bank_acc_type     varchar2(100);
        l_optional_created_by        varchar2(100);
        l_remit_bank_name            varchar2(100);
        l_remit_routing_number       varchar2(100);
        l_remit_bank_acc_num         varchar2(100);
        l_remit_bank_acct_type       varchar2(100);
        l_remit_created_by           varchar2(100);
        l_annual_bank_status         varchar2(100);
        l_optional_bank_status       varchar2(100);
        l_remit_bank_status          varchar2(100);
        l_annual_acct_stg_id         number;
        l_optional_acct_stg_id       number;
        l_remit_acct_stg_id          number;
        l_annual_business_name       varchar2(1000);
        l_optional_business_name     varchar2(1000);
        l_annual_giac_verify         varchar2(100);
        l_annual_giac_authenticate   varchar2(100);
        l_annual_giac_response       varchar2(100);
        l_optional_giac_verify       varchar2(100);
        l_optional_giac_authenticate varchar2(100);
        l_optional_giac_response     varchar2(100);
        l_remit_giac_verify          varchar2(100);
        l_remit_giac_authenticate    varchar2(100);
        l_remit_giac_response        varchar2(100);
        l_annual_bank_acct_id        number;
        l_optional_bank_acct_id      number;
        l_remit_bank_acct_id         number;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.Get_Cobra_giact_Bank_Details p_entrp_id  l', p_entrp_id
                                                                                          || ' p_batch_number :='
                                                                                          || p_batch_number);
        for bank_stg in (
            select
                user_bank_acct_stg_id,
                bank_name,
                bank_routing_num,
                bank_acct_num,
                bank_acct_type,
                created_by,
                annual_optional_remit,
                bank_status,
                business_name,
                giac_verify,
                giac_authenticate,
                giac_response,
                bank_acct_id
            from
                user_bank_acct_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            if nvl(bank_stg.annual_optional_remit, 'N') = 'A' then
                l_annual_bank_name := bank_stg.bank_name;
                l_annual_routing_number := bank_stg.bank_routing_num;
                l_annual_bank_acc_num := bank_stg.bank_acct_num;
                l_annual_bank_acc_type := bank_stg.bank_acct_type;
                l_annual_created_by := bank_stg.created_by;
                l_annual_bank_status := bank_stg.bank_status;
                l_annual_acct_stg_id := bank_stg.user_bank_acct_stg_id;
                l_annual_business_name := bank_stg.business_name;
                l_annual_giac_verify := bank_stg.giac_verify;
                l_annual_giac_authenticate := bank_stg.giac_authenticate;
                l_annual_giac_response := bank_stg.giac_response;
                l_annual_bank_acct_id := bank_stg.bank_acct_id;
            elsif nvl(bank_stg.annual_optional_remit, 'N') = 'O' then
                l_optional_bank_name := bank_stg.bank_name;
                l_optional_routing_number := bank_stg.bank_routing_num;
                l_optional_bank_acc_num := bank_stg.bank_acct_num;
                l_optional_bank_acc_type := bank_stg.bank_acct_type;
                l_optional_created_by := bank_stg.created_by;
                l_optional_bank_status := bank_stg.bank_status;
                l_optional_acct_stg_id := bank_stg.user_bank_acct_stg_id;
                l_optional_business_name := bank_stg.business_name;
                l_optional_giac_verify := bank_stg.giac_verify;
                l_optional_giac_authenticate := bank_stg.giac_authenticate;
                l_optional_giac_response := bank_stg.giac_response;
                l_optional_bank_acct_id := bank_stg.bank_acct_id;
            elsif nvl(bank_stg.annual_optional_remit, 'N') = 'R' then
                l_remit_bank_name := bank_stg.bank_name;
                l_remit_routing_number := bank_stg.bank_routing_num;
                l_remit_bank_acc_num := bank_stg.bank_acct_num;
                l_remit_bank_acct_type := bank_stg.bank_acct_type;
                l_remit_created_by := bank_stg.created_by;
                l_remit_bank_status := bank_stg.bank_status;
                l_remit_acct_stg_id := bank_stg.user_bank_acct_stg_id;
                l_remit_giac_verify := bank_stg.giac_verify;
                l_remit_giac_authenticate := bank_stg.giac_authenticate;
                l_remit_giac_response := bank_stg.giac_response;
                l_remit_bank_acct_id := bank_stg.bank_acct_id;
            end if;
        end loop;

        open thecursor for select
                                                (
                                                    json_object(
                                                        key 'ACC_NUM' value b.acc_num,
                                                        key 'REMITTANCE_FLAG' value a.remittance_flag,
                                                        key 'FEES_PAYMENT_FLAG' value a.fees_payment_flag,
                                                        key 'SALESREP_ID' value a.salesrep_id,
                                                        key 'SALESREP_FLAG' value a.salesrep_flag,
                                                                key 'SEND_INVOICE' value a.send_invoice,
                                                        key 'ACCT_PAYMENT_FEES' value a.acct_payment_fees,
                                                        key 'OPTIONAL_FEE_PAID_BY' value a.optional_fee_paid_by,
                                                        key 'OPTIONAL_FEE_PAYMENT_METHOD' value a.optional_fee_payment_method,
                                                        key 'REMITTANCE_FLAG' value a.remittance_flag,
                                                                key 'BANK_AUTHORIZE' value a.bank_authorize,
                                                        key 'OPTIONAL_BANK_AUTHORIZE' value a.optional_bank_authorize,
                                                        key 'REMIT_BANK_AUTHORIZE' value a.bank_authorize,
                                                        key 'BANK_NAME' value l_annual_bank_name,
                                                        key 'ROUTING_NUMBER' value l_annual_routing_number,
                                                                key 'BANK_ACC_NUM' value l_annual_bank_acc_num,
                                                        key 'BANK_ACC_TYPE' value l_annual_bank_acc_type,
                                                        key 'ANNUAL_FEE_BANK_CREATED_BY' value l_annual_created_by,
                                                        key 'BANK_ACCT_ID' value null,
                                                        key 'ANNUAL_BANK_STATUS' value l_annual_bank_status,
                                                                key 'ANNUAL_BANK_ACCT_STG_ID' value l_annual_acct_stg_id,
                                                        key 'ANNUAL_BUSINESS_NAME' value l_annual_business_name,
                                                        key 'OPTIONAL_BANK_NAME' value l_optional_bank_name,
                                                        key 'OPTIONAL_ROUTING_NUMBER' value l_optional_routing_number,
                                                        key 'OPTIONAL_BANK_ACC_NUM' value l_optional_bank_acc_num,
                                                                key 'OPTIONAL_BANK_ACC_TYPE' value l_optional_bank_acc_type,
                                                        key 'OPTIONAL_FEE_BANK_CREATED_BY' value l_optional_created_by,
                                                        key 'OPTIONAL_FEE_BANK_ACCT_ID' value null,
                                                        key 'OPTIONAL_BANK_STATUS' value l_optional_bank_status,
                                                        key 'OPTIONAL_BANK_ACCT_STG_ID' value l_optional_acct_stg_id,
                                                                key 'OPTIONAL_BUSINESS_NAME' value l_optional_business_name,
                                                        key 'REMIT_BANK_NAME' value l_remit_bank_name,
                                                        key 'REMIT_ROUTING_NUMBER' value l_remit_routing_number,
                                                        key 'REMIT_BANK_ACC_NUM' value l_remit_bank_acc_num,
                                                        key 'REMIT_BANK_ACC_TYPE' value l_remit_bank_acct_type,
                                                                key 'REMIT_FEE_BANK_ACCT_ID' value null,
                                                        key 'REMIT_BANK_STATUS' value l_remit_bank_status,
                                                        key 'REMIT_BANK_ACCT_STG_ID' value l_remit_acct_stg_id,
                                                        key 'GIAC_VERIFY' value l_annual_giac_verify,
                                                        key 'GIAC_AUTHENTICATE' value l_annual_giac_authenticate,
                                                                key 'GIAC_RESPONSE' value l_annual_giac_response,
                                                        key 'OPTIONAL_GIAC_VERIFY' value l_optional_giac_verify,
                                                        key 'OPTIONAL_GIAC_AUTHENTICATE' value l_optional_giac_authenticate,
                                                        key 'OPTIONAL_GIAC_RESPONSE' value l_optional_giac_response,
                                                        key 'REMIT_GIAC_VERIFY' value l_remit_giac_verify,
                                                                key 'REMIT_GIAC_AUTHENTICATE' value l_remit_giac_authenticate,
                                                        key 'REMIT_GIAC_RESPONSE' value l_remit_giac_response,
                                                        key 'ANNUAL_BANK_ACCT_ID' value l_annual_bank_acct_id,
                                                        key 'OPTIONAL_BANK_ACCT_ID' value l_optional_bank_acct_id,
                                                        key 'REMIT_BANK_ACCT_ID' value l_remit_bank_acct_id      -- Added by Swamy for Ticket#12534(12624)
                                                    )
                                                ) cobra_bank_details
                                            from
                                                online_compliance_staging a,
                                                account                   b
                          where
                                  a.entrp_id = b.entrp_id
                              and a.entrp_id = p_entrp_id
                              and a.batch_number = p_batch_number;

        return thecursor;
    exception
        when others then
            pc_log.log_error('pc_employer_enroll.Get_Cobra_giact_Bank_Details', sqlerrm || dbms_utility.format_error_backtrace);
    end get_cobra_giact_bank_details;

-- Added by Swamy for Ticket#12534    
    procedure upsert_optional_remit_details (
        p_entrp_id                    in number,
        p_batch_number                in number,
        p_pay_optional_fees_by        in varchar2,
        p_optional_fee_payment_method in varchar2,
        p_optional_bank_authorize     in varchar2,
        p_remit_bank_authorize        in varchar2,
        p_bank_authorize              in varchar2,
        p_bank_acct_id                in number,
        x_error_status                out varchar2,
        x_error_message               out varchar2
    ) is
    begin
        x_error_status := 'S';
        update online_compliance_staging
        set
            optional_fee_paid_by = p_pay_optional_fees_by,
            optional_fee_payment_method = p_optional_fee_payment_method,
            optional_bank_authorize = p_optional_bank_authorize,
            remit_bank_authorize = p_remit_bank_authorize,
            bank_authorize = p_bank_authorize
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

    exception
        when others then
            x_error_status := 'U';
            x_error_message := sqlerrm(sqlcode);
            pc_log.log_error('pc_employer_enroll.Upsert_optional_remit_details', sqlerrm || dbms_utility.format_error_backtrace);
    end upsert_optional_remit_details;

--Added by Joshi for 12621
    procedure er_add_remitt_bank_notify_request (
        p_acc_id      number,
        p_entity_type varchar2,
        p_entity_id   in number,
        p_user_id     number
    ) is
    begin
        insert into er_add_remitt_bank_notification (
            er_remitt_bank_notif_id,
            acc_id,
            entity_type,
            entity_id,
            process_status,
            creation_date,
            created_by
        ) values ( er_remitt_bank_notif_id_seq.nextval,
                   p_acc_id,
                   p_entity_type,
                   p_entity_id,
                   'N',
                   sysdate,
                   p_user_id );

    end;

    procedure insert_staging_bank_giact (
        p_bank_json             in varchar2,
        p_batch_number          in varchar2,
        p_entrp_id              in number,
        p_user_id               in number,
        p_user_bank_acct_stg_id out number,
        p_bank_status           out varchar2,
        p_bank_message          out varchar2,
        x_return_status         out varchar2,
        x_error_message         out varchar2
    ) is

  -- Variables for GIACT API call
        l_request_xml           clob;
        l_response              clob;
        l_json_api_response     clob;
        l_response_code         varchar2(10);
        l_response_xml          xmltype;
        l_json_data             clob := p_bank_json;
        l_return_status         varchar2(1);
        l_bank_status           varchar2(10);
        x_bank_status           varchar2(10);
        x_bank_acct_id          number;
        l_error_message         varchar2(2000);
        x_duplicate_bank_exists varchar2(200);
        x_bank_details_exists   varchar2(200);
        x_active_bank_exists    varchar2(200);
        l_giact_verify          varchar2(200);
        l_giact_authenticate    varchar2(200);
        l_giact_response        varchar2(200);
        l_sqlcode               varchar2(200);
        l_bank_account_type     varchar2(200);
        l_bank_acct_usage       varchar2(200);
        l_entity_id             number;
        l_entity_type           varchar2(200);
        l_user_bank_acct_stg_id number;
        lc_bank_acct_id         number;
        l_request_id            number;
        l_api_error_message     varchar2(2000);
        l_json_response         clob;
        duplicate_error exception;
        bank_details_exists_error exception;
        erreur exception;
        setup_error exception;
    begin
  -- Parse the JSON data using SQL and insert into the temporary table
        for x in (
            select
                bank_data.*
            from
                    json_table ( l_json_data, '$[*]'
                        columns (
                            entity_id varchar2 ( 100 ) path '$.entity_id',
                            entity_type varchar2 ( 100 ) path '$.entity_type',
                            bank_routing_number varchar2 ( 100 ) path '$.bank_routing_number',
                            bank_acct_num varchar2 ( 100 ) path '$.bank_acct_num',
                            bank_acct_id varchar2 ( 100 ) path '$.bank_acct_id',
                            bank_name varchar2 ( 100 ) path '$.bank_name',
                            display_name varchar2 ( 100 ) path '$.display_name',
                            bank_account_type varchar2 ( 100 ) path '$.bank_account_type',
                            bank_account_usage varchar2 ( 100 ) path '$.bank_account_usage',
                            acc_id varchar2 ( 100 ) path '$.acc_id',
                            acc_num varchar2 ( 100 ) path '$.acc_num',
                            business_name varchar2 ( 100 ) path '$.business_name',
                            first_name varchar2 ( 100 ) path '$.first_name',
                            last_name varchar2 ( 100 ) path '$.last_name',
                            entrp_id varchar2 ( 100 ) path '$.entrp_id',
                            ssn varchar2 ( 100 ) path '$.ssn',
                            user_id varchar2 ( 100 ) path '$.user_id',
                            pay_invoice_online varchar2 ( 10 ) path '$.pay_invoice_online',
                            source varchar2 ( 100 ) path '$.source',
                            user_bank_acct_stg_id varchar2 ( 100 ) path '$.user_bank_acct_stg_id',
                            annual_optional_remit varchar2 ( 100 ) path '$.annual_optional_remit',
                            product_type varchar2 ( 100 ) path '$.product_type',
                            acct_payment_fees varchar2 ( 100 ) path '$.acct_payment_fees',
                            bank_agreement varchar2 ( 100 ) path '$.bank_agreement',
                            bank_json varchar2 ( 4000 ) format json path '$'
                        )
                    )
                bank_data
        ) loop
            pc_giact_validations.insert_website_api_requests(
                p_entity_id      => x.entity_id,
                p_entity_type    => x.entity_type,
                p_request_body   => p_bank_json,
                p_response_body  => null,
                p_batch_number   => p_batch_number,
                p_user_id        => p_user_id,
                p_processed_flag => 'N',
                x_request_id     => l_request_id,
                x_return_status  => l_return_status,
                x_error_message  => l_error_message
            );

            pc_log.log_error('pc_giact_validations.insert_staging_bank_giact **1.1  ', 'l_return_status '
                                                                                       || l_return_status
                                                                                       || ' l_request_id :='
                                                                                       || l_request_id
                                                                                       || ' l_error_message :='
                                                                                       || l_error_message
                                                                                       || ' x.user_bank_acct_stg_id :='
                                                                                       || x.user_bank_acct_stg_id);

            l_bank_status := null;
            l_bank_acct_usage := null;
            l_entity_id := x.entity_id;
            pc_log.log_error('pc_giact_validations.insert_staging_bank_giact calling pc_user_bank_acct.validate_giac_bank_details  ',
            'x.acc_id ' || x.acc_id); 

   /* -- commented for ticket#12768(12527)
       DELETE FROM user_bank_acct_staging 
      WHERE user_bank_acct_stg_id = x.user_bank_acct_stg_id;

   -- for enrollment and renewal the validation should not show
   pc_user_bank_acct.bank_Staging_validations
        (p_batch_number   => p_batch_number
        ,p_entrp_id       => p_entrp_id
        ,p_user_id        => p_user_id
		,p_acct_usage     => x.bank_account_usage
        ,x_return_status  => l_return_status 
        ,x_error_message  => l_error_message
        );
pc_log.log_error('pc_giact_validations.insert_staging_bank_giact **1 ','l_return_status '||l_return_status); 
        IF NVL(l_return_status,'N') <> 'S' THEN
          RAISE erreur;
        END IF;
        */
            pc_log.log_error('pc_giact_validations.insert_staging_bank_giact **2 ', 'l_return_status ' || l_return_status); 
    -- Validate the bank details, check for duplicates and other necessary checkings
            pc_user_bank_acct.validate_giac_bank_details(
                p_bank_routing_num      => x.bank_routing_number,
                p_bank_acct_num         => x.bank_acct_num,
                p_bank_acct_id          => x.bank_acct_id,
                p_bank_name             => x.bank_name,
                p_bank_account_type     => x.bank_account_type,
                p_acc_id                => x.acc_id,
                p_entrp_id              => x.entrp_id,
                p_ssn                   => x.ssn,
                p_entity_type           => x.entity_type,
                p_user_id               => x.user_id,
                p_account_usage         => x.bank_account_usage,
                p_pay_invoice_online    => x.pay_invoice_online,
                p_source                => x.source,
                p_duplicate_bank_exists => x_duplicate_bank_exists,
                p_bank_details_exists   => x_bank_details_exists,
                p_active_bank_exists    => x_active_bank_exists,
                x_error_message         => l_error_message,
                x_return_status         => l_return_status
            );

            pc_log.log_error('pc_giact_validations.insert_staging_bank_giact **1 pc_user_bank_acct.validate_giac_bank_details  ', 'l_return_status '
                                                                                                                                || l_return_status
                                                                                                                                || ' x_duplicate_bank_exists :='
                                                                                                                                || x_duplicate_bank_exists
                                                                                                                                || ' x_bank_details_exists :='
                                                                                                                                || x_bank_details_exists
                                                                                                                                || ' x_active_bank_exists :='
                                                                                                                                || x_active_bank_exists
                                                                                                                                );

            if nvl(l_return_status, 'N') <> 'S' then
                raise erreur;
            end if;
            if nvl(x_duplicate_bank_exists, 'N') = 'Y' then
                raise duplicate_error;
            end if;
            if nvl(x_bank_details_exists, '*') in ( 'I', 'D', 'W', 'P', 'E',
                                                    'O' ) then
                raise bank_details_exists_error;
            end if;

        -- If there is already a bank account with Active status, then the same bank details should not go to Giact, instead it should
        -- directly insert the data into bank_accounts table
            if x_active_bank_exists = 'Y' then
                for xx in (
                    select
                        *
                    from
                        table ( pc_user_bank_acct.get_existing_bank_giact_details(
                            p_routing_number     => x.bank_routing_number,
                            p_bank_acct_num      => x.bank_acct_num,
                            p_bank_acct_id       => x.bank_acct_id,
                            p_bank_name          => x.bank_name,
                            p_bank_account_type  => x.bank_account_type,
                            p_ssn                => x.ssn,
                            p_entity_id          => x.entity_id,
                            p_entity_type        => x.entity_type,
                            p_bank_account_usage => x.bank_account_usage
                        ) )
                ) loop
                -- Inserting the details into bank_accounts table
                    pc_user_bank_acct.insert_user_bank_acct_staging(
                        p_user_bank_acct_stg_id  => x.user_bank_acct_stg_id,
                        p_entrp_id               => x.entrp_id,
                        p_batch_number           => p_batch_number,
                        p_account_type           => x.product_type,
                        p_acct_usage             => x.bank_account_usage,
                        p_display_name           => x.display_name,
                        p_bank_acct_type         => x.bank_account_type,
                        p_bank_routing_num       => x.bank_routing_number,
                        p_bank_acct_num          => x.bank_acct_num,
                        p_bank_name              => x.bank_name,
                        p_validity               => 'V',
                        p_bank_authorize         => x.bank_agreement,
                        p_user_id                => p_user_id,
                        p_entity_type            => x.entity_type,
                        p_giac_response          => xx.giac_response,
                        p_giac_verify            => xx.giac_verify,
                        p_giac_authenticate      => xx.giac_authenticate,
                        p_bank_acct_verified     => 'N',
                        p_bank_status            => 'A',
                        p_business_name          => x.business_name,
                        p_giac_verified_response => null,
                        p_annual_optional_remit  => x.annual_optional_remit,
                        x_user_bank_acct_stg_id  => l_user_bank_acct_stg_id,
                        x_error_status           => l_return_status,
                        x_error_message          => l_error_message
                    );

                    if nvl(l_return_status, 'N') <> 'S' then
                        raise erreur;
                    end if;
                end loop;

                p_bank_status := 'A';
                p_bank_message := 'Your bank account has been added successfully!';
            else
                pc_log.log_error('pc_giact_validations.process_bank_giact pc_giact_validations.giact_api_request_formation', 'x.entity_id '
                                                                                                                             || x.entity_id
                                                                                                                             || ' x.entity_TYPE :='
                                                                                                                             || x.entity_type
                                                                                                                             ); 
           -- Based on the input bank details form the request which would be sent to giac.
                if x.bank_account_type = 'C' then
                    l_bank_account_type := 'Checking';
                else
                    l_bank_account_type := 'Savings';
                end if;

                pc_giact_validations.giact_api_request_formation(
                    p_entity_id           => x.entity_id,
                    p_entity_type         => x.entity_type,
                    p_acc_num             => x.acc_num,
                    p_bank_routing_number => x.bank_routing_number,
                    p_bank_account_number => x.bank_acct_num,
                    p_bank_account_type   => l_bank_account_type,
                    p_bank_name           => x.bank_name,
                    p_business_name       => x.business_name,
                    p_first_name          => x.first_name,
                    p_last_name           => x.last_name,
                    p_request_xml         => l_request_xml,
                    x_return_status       => l_return_status,
                    x_error_message       => l_error_message
                );

                pc_log.log_error('pc_giact_validations.insert_staging_bank_giact **1 pc_giact_validations.giact_api_request_formation'
                , 'l_RETURN_STATUS '
                                                                                                                                      || l_return_status
                                                                                                                                      || ' x.entity_TYPE :='
                                                                                                                                      || x.entity_type
                                                                                                                                      )
                                                                                                                                      ;

                if nvl(l_return_status, 'N') <> 'S' then
                    raise erreur;
                end if;
            -- Send the details to giact
                pc_giact_api.soap_giact_call(
                    p_batch_number  => p_batch_number,
                    p_entity_id     => x.entity_id,
                    p_request       => l_request_xml,
                    x_response      => l_response,
                    x_return_status => l_return_status,
                    x_error_message => l_error_message
                );

                pc_log.log_error('pc_giact_validations.insert_staging_bank_giact **1 pc_giact_validations.soap_giact_call', 'l_RETURN_STATUS ' || l_return_status
                );
                if nvl(l_return_status, 'N') <> 'S' then
                    raise erreur;
                end if;
            -- If there is a response from giact 
                if l_response is not null then
                -- Convert the xml response from giac to jason format and get the giact values
                    pc_giact_validations.api_response_json_formation(
                        p_xml_response       => l_response,
                        p_giact_verify       => l_giact_verify,
                        p_giact_authenticate => l_giact_authenticate,
                        p_giact_response     => l_giact_response,
                        p_json_response      => l_json_api_response,
                        p_api_error_message  => l_api_error_message,
                        x_return_status      => l_return_status,
                        x_error_message      => l_error_message
                    );

                    pc_log.log_error('pc_giact_validations.insert_staging_bank_giact **1 pc_giact_validations.api_response_json_formation'
                    , 'l_RETURN_STATUS ' || l_return_status);
                    if nvl(l_return_status, 'N') <> 'S' then
                        raise erreur;
                    end if;

                -- log the request sent to giact and response from giact
                    pc_giact_validations.insert_api_request_log(
                        p_entity_id                   => x.entity_id,
                        p_entity_type                 => x.entity_type,
                        p_enroll_renewal_batch_number => p_batch_number,
                        p_request_xml_data            => l_request_xml,
                        p_response_xml_data           => l_response,
                        p_response_json_data          => l_json_api_response,
                        p_user_id                     => p_user_id,
                        p_website_api_request_id      => l_request_id,
                        x_return_status               => l_return_status,
                        x_error_message               => l_error_message
                    );

                    pc_log.log_error('pc_giact_validations.insert_staging_bank_giact **1 pc_giact_validations.insert_api_request_log'
                    , 'l_RETURN_STATUS ' || l_return_status);
                    if nvl(l_return_status, 'N') <> 'S' then
                        raise erreur;
                    end if;
                -- Get the bank status based on the response from giact
                    pc_user_bank_acct.validate_giact_response(
                        p_gverify       => l_giact_verify,
                        p_gauthenticate => l_giact_authenticate,
                        x_giact_verify  => l_response_code,
                        x_bank_status   => l_bank_status,
                        x_return_status => l_return_status,
                        x_error_message => l_error_message
                    );

                    pc_log.log_error('pc_giact_validations.insert_staging_bank_giact **1.1 ', 'l_bank_status :='
                                                                                              || l_bank_status
                                                                                              || ' l_error_message :='
                                                                                              || l_error_message);
                    p_bank_status := l_bank_status;
                    p_bank_message := l_error_message;
                    pc_log.log_error('pc_giact_validations.insert_staging_bank_giact **1.2 pc_giact_validations.validate_giact_response'
                    , 'l_bank_status '
                                                                                                                                        || l_bank_status
                                                                                                                                        || ' l_RETURN_STATUS :='
                                                                                                                                        || l_return_status
                                                                                                                                        || ' l_response_code :='
                                                                                                                                        || l_response_code
                                                                                                                                        )
                                                                                                                                        ;

                    if nvl(l_return_status, 'N') not in ( 'S', 'P', 'W', 'R', 'A' ) then
                        raise erreur;
                    end if;

                    if l_response_code = 'R' then
                        raise setup_error;
                    end if;
                -- Insert the bank details along with giact details into bank_accounts table
                    pc_log.log_error('pc_giact_validations.insert_staging_bank_giact **1.3 pc_giact_validations.validate_giact_response'
                    , 'x.User_Bank_acct_stg_Id ' || x.user_bank_acct_stg_id);
                    pc_user_bank_acct.insert_user_bank_acct_staging(
                        p_user_bank_acct_stg_id  => x.user_bank_acct_stg_id,
                        p_entrp_id               => x.entrp_id,
                        p_batch_number           => p_batch_number,
                        p_account_type           => x.product_type,
                        p_acct_usage             => x.bank_account_usage,
                        p_display_name           => x.display_name,
                        p_bank_acct_type         => x.bank_account_type,
                        p_bank_routing_num       => x.bank_routing_number,
                        p_bank_acct_num          => x.bank_acct_num,
                        p_bank_name              => x.bank_name,
                        p_validity               => 'V',
                        p_bank_authorize         => x.bank_agreement,
                        p_user_id                => p_user_id,
                        p_entity_type            => x.entity_type,
                        p_giac_response          => l_giact_response,
                        p_giac_verify            => l_giact_verify,
                        p_giac_authenticate      => l_giact_authenticate,
                        p_bank_acct_verified     => 'N',
                        p_bank_status            => l_bank_status,
                        p_business_name          => x.business_name,
                        p_giac_verified_response => l_response_code,
                        p_annual_optional_remit  => x.annual_optional_remit,
                        x_user_bank_acct_stg_id  => l_user_bank_acct_stg_id,
                        x_error_status           => l_return_status,
                        x_error_message          => l_error_message
                    );

                    pc_log.log_error('pc_giact_validations.insert_staging_bank_giact **1.4 pc_giact_validations.validate_giact_response'
                    , 'x.User_Bank_acct_stg_Id '
                                                                                                                                        || x.user_bank_acct_stg_id
                                                                                                                                        || ' l_RETURN_STATUS :='
                                                                                                                                        || l_return_status
                                                                                                                                        || ' l_User_Bank_acct_stg_Id :='
                                                                                                                                        || l_user_bank_acct_stg_id
                                                                                                                                        )
                                                                                                                                        ;

                    if nvl(l_return_status, 'N') <> 'S' then
                        raise erreur;
                    end if;
                end if;

            end if;

        end loop;

        p_user_bank_acct_stg_id := l_user_bank_acct_stg_id;
        x_error_message := 'Your bank account has been added successfully!';
        x_return_status := 'S';
    exception
        when erreur then
            x_error_message := l_error_message;
            x_return_status := 'E';
            pc_log.log_error('pc_giact_validations.insert_staging_bank_giact exception erreur ', 'x_error_message ' || x_error_message
            );
        when setup_error then
            x_return_status := 'E';
            pc_log.log_error('pc_giact_validations.insert_staging_bank_giact exception setup_error', x_error_message);
        when duplicate_error then
            x_error_message := l_error_message;
            x_return_status := 'E';
            pc_log.log_error('pc_giact_validations.insert_staging_bank_giact exception duplicate_error ', 'x_error_message ' || x_error_message
            );
        when bank_details_exists_error then
            x_error_message := l_error_message;
            x_return_status := 'E';
            pc_log.log_error('pc_giact_validations.insert_staging_bank_giact exception BANK_DETAILS_EXISTS_error ', 'x_error_message ' || x_error_message
            );
        when others then
            x_error_message := dbms_utility.format_error_backtrace || sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_giact_validations.insert_staging_bank_giact exception others ', 'x_error_message ' || x_error_message
            );
            l_sqlcode := sqlcode;
            pc_giact_validations.insert_giact_api_errors(
                p_batch_number => p_batch_number,
                p_entity_id    => l_entity_id,
                p_sqlcode      => l_sqlcode,
                p_sqlerrm      => x_error_message,
                p_request      => l_request_xml
            );

    end insert_staging_bank_giact;

-- Added by Jaggi #12672 
    procedure upsert_cobra_service (
        p_service_type   in varchar2,
        p_acc_id         in number,
        p_ben_plan_id    in number,
        p_effective_date in date,
        p_user_id        in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    ) is
        l_cnt number default 0;
    begin
        for x in (
            select
                count(*)
            into l_cnt
            from
                cobra_services_detail
            where
                    acc_id = p_acc_id
                and ben_plan_id = p_ben_plan_id
                and service_type = p_service_type
        ) loop
            if l_cnt = 0 then
                insert into cobra_services_detail (
                    acc_id,
                    ben_plan_id,
                    effective_date,
                    service_type,
                    service_selected,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_updated_date
                ) values ( p_acc_id,
                           p_ben_plan_id,
                           p_effective_date,
                           p_service_type,
                           'Y',
                           p_user_id,
                           sysdate,
                           p_user_id,
                           sysdate );

            end if;
        end loop;
    exception
        when others then
            rollback;
            x_error_message := 'In PC_EMPLOYER_ENROLL_COMPLAINCE.Upsert_Cobra_Service when others : ' || sqlerrm;
            x_return_status := 'E';
    end upsert_cobra_service;

    function get_existing_bank_acct_detail (
        p_entity_type varchar2,
        p_entity_id   in number
    ) return bank_info_row_t
        pipelined
        deterministic
    is
        l_record bank_info_record;
        l_tax_id varchar2(20);
    begin
        if p_entity_type = 'ACCOUNT' then
            for x in (
                select
                    entrp_id
                from
                    account
                where
                    acc_id = p_entity_id
            ) loop
                l_tax_id := pc_entrp.get_tax_id(x.entrp_id);
            end loop;

            if l_tax_id is not null then
                for x in (
                    select
                        bank_acct_id,
                        bank_name
                        || '('
                        || ba.masked_bank_acct_num
                        || ')' bank_name
                        --BANK_ACCT_TYPE as BANK_ACC_TYPE, BANK_ROUTING_NUM as ROUTING_NUMBER, BANK_ACCT_NUM as BANK_ACC_NUM, BANK_ACCOUNT_USAGE, GIAC_VERIFY,GIAC_AUTHENTICATE,GIAC_RESPONSE,BUSINESS_NAME
                    from
                        bank_accounts ba,
                        account       acc,
                        enterprise    e
                    where
                            ba.entity_id = acc.acc_id
                        and acc.entrp_id = e.entrp_id
                        and replace(e.entrp_code, '-') = replace(
                            replace(l_tax_id, '-', ''),
                            ' ',
                            ''
                        )
                        and ba.entity_type = p_entity_type
                        and ba.bank_account_usage = 'INVOICE'
                ) loop
                    l_record.bank_acct_id := x.bank_acct_id;
                    l_record.bank_name := x.bank_name;
                    pipe row ( l_record );
                end loop;

            end if;

        end if;
    end get_existing_bank_acct_detail;

--Added by Swamy for Ticket#12675(POP GIACT)
    procedure set_payment (
        p_entrp_id          in number,
        p_batch_number      in number,
        p_salesrep_flag     in online_compliance_staging.salesrep_flag%type,
        p_salesrep_id       in online_compliance_staging.salesrep_id%type,
        p_acct_payment_fees in varchar2,
        p_fees_payment_flag in varchar2,
        p_page_validity     in varchar2,
        p_user_id           in number,               -- 10747new
        x_error_status      out varchar2,
        x_error_message     out varchar2
    ) is

        setup_error exception;
        l_count                 number;
        l_acct_type             varchar2(100);
        l_contact_cnt           number;
        l_cnt                   number;
        l_enrolle_type          varchar2(100);   ------  9392 rprabu 09/10/2020
        l_user_bank_acct_stg_id number;
        l_source                varchar2(50);   -- Added by swamy for Ticket#11364
        l_page_no               varchar2(5);    -- Added by swamy for Ticket#11364
    begin
        x_error_status := 'S';
        x_error_message := 'Success';
        pc_log.log_error('pc_employer_enroll.set_payment', 'P_user_id '
                                                           || p_user_id
                                                           || ' p_salesrep_flag :='
                                                           || p_salesrep_flag
                                                           || ' p_salesrep_id :='
                                                           || p_salesrep_id
                                                           || ' p_acct_payment_fees :='
                                                           || p_acct_payment_fees
                                                           || ' p_fees_payment_flag :='
                                                           || p_fees_payment_flag);

        for j in (
            select
                nvl(source, 'E') source
            from
                online_compliance_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            l_source := j.source;
        end loop;

        if nvl(l_source, '*') = '*' then
            x_error_message := ' No previous Bank details data for Compliance Plan';
            raise setup_error;
        end if;

        for k in (
            select
                account_type
            from
                account
            where
                entrp_id = p_entrp_id
        ) loop
            l_acct_type := k.account_type;
        end loop;

        if l_source not in ( 'RENEWAL' ) then
            for p in (
                select
                    count(*) cnt
                from
                    compliance_plan_staging
                where
                        entity_id = p_entrp_id
                    and batch_number = p_batch_number
            ) loop
                l_count := p.cnt;
            end loop;

            if nvl(l_count, 0) = 0 then
                x_error_message := ' No previous data for Compliance Plan';
                raise setup_error;
            end if;

        end if;

        update online_compliance_staging
        set
            salesrep_flag = p_salesrep_flag,
            salesrep_id = p_salesrep_id,
            acct_payment_fees = p_acct_payment_fees,
            fees_payment_flag = p_fees_payment_flag
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

        pc_log.log_error('pc_employer_enroll.set_payment', 'l_acct_type :=' || l_acct_type);
    -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        if
            l_acct_type = 'COBRA'
            and l_source = 'RENEWAL'
        then
            l_page_no := '2';
        else
            l_page_no := '3';
        end if;

        pc_employer_enroll.upsert_page_validity(
            p_batch_number  => p_batch_number,
            p_entrp_id      => p_entrp_id,
            p_account_type  => l_acct_type,
            p_page_no       => '3',
            p_block_name    => 'INVOICING_PAYMENT',
            p_validity      => nvl(p_page_validity, 'V'),
            p_user_id       => p_user_id,
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );

    exception
        when setup_error then
            x_error_status := 'E';
            pc_log.log_error('set_invoicing_payment', x_error_message);
        when others then
            x_error_status := 'U';
            x_error_message := sqlerrm(sqlcode);
            pc_log.log_error('set_invoicing_payment', sqlerrm);
    end set_payment;

end pc_employer_enroll_compliance;
/


-- sqlcl_snapshot {"hash":"713e99161e94325d477dda80ebea3380222a0c7c","type":"PACKAGE_BODY","name":"PC_EMPLOYER_ENROLL_COMPLIANCE","schemaName":"SAMQA","sxml":""}