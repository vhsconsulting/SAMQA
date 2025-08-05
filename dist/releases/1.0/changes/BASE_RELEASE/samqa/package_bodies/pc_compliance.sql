-- liquibase formatted sql
-- changeset SAMQA:1754373990590 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_compliance.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_compliance.sql:null:321de014430cd76b9bf0d1d17f677f0867c1dc14:create

create or replace package body samqa.pc_compliance as

    procedure insert_benefit_codes (
        p_benefit_code_id    in number,
        p_entity_id          in number,
        p_entity_type        in varchar2,
        p_code_name          in varchar2,
        p_description        in varchar2,
        p_er_contrib         in varchar2 default null  -- Number to varchar2 Added by Swamy Ticket#5518 Develp from session to staging table
        ,
        p_ee_contrib         in varchar2 default null  -- Number to varchar2 Added by Swamy Ticket#5518 Develp from session to staging table
        ,
        p_eligibility        in varchar2 default null,
        p_user_id            in number default null,
        p_er_ee_contrib_lng  in varchar2 default null -- Added by Swamy Ticket#5518 Develp from session to staging table
        ,
        p_refer_to_doc       in varchar2 default null -- Added by Swamy Ticket#5518 Develp from session to staging table
        ,
        p_fully_insured_flag in varchar2 default null -- Added by rprabu Ticket#7792  23/07/2019
        ,
        p_self_insured_flag  in varchar2 default null -- Added by rprabu Ticket#7792   23/07/2019
        ,
        x_benefit_code_id    out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is
        l_benefit_code_count number := 0;
        v_code_name          varchar2(50) := p_code_name;  -- Added by swamy Ticket#5518 Develp from session to staging table
    begin
        pc_log.log_error('INSERT_BENEFIT_CODES:p_entity_id', p_entity_id);
        select
            count(*)
        into l_benefit_code_count
        from
            benefit_codes
        where
                benefit_code_name = p_code_name
            and entity_id = p_entity_id
            and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
            and upper(benefit_code_name) <> 'OTHER';   -- Added by swamy Ticket#5518 Develp from session to staging table

      -- Below If Cond. Added by swamy Ticket#5518 Develp from session to staging table
        if p_code_name = 'OTHER' then
            v_code_name := p_code_name
                           || '('
                           || p_description
                           || ')';
        end if;
      -- End Swamy

        if l_benefit_code_count = 0 then
            x_return_status := 'S';
            insert into benefit_codes (
                benefit_code_id,
                benefit_code_name,
                description,
                entity_id,
                entity_type,
                eligibility,
                er_cont_pref,
                ee_cont_pref,
                er_ee_contrib_lng,
                refer_to_doc,
                fully_insured_flag    -- Added by rprabu Ticket#7792   23/07/2019
                ,
                self_insured_flag      -- Added by rprabu Ticket#7792   23/07/2019
                ,
                creation_date,
                created_by,
                last_updated_by,
                last_update_date
            ) values ( benefit_code_seq.nextval,
                       v_code_name --p_code_name Replaced p_code_name with v_code_name by swamy Ticket#5518 Develp from session to staging table
                       ,
                       p_description,
                       p_entity_id,
                       p_entity_type,
                       p_eligibility,
                       p_er_contrib,
                       p_ee_contrib,
                       p_er_ee_contrib_lng,
                       p_refer_to_doc,
                       p_fully_insured_flag        -- Added by rprabu Ticket#7792   23/07/2019
                       ,
                       p_self_insured_flag         -- Added by rprabu Ticket#7792   23/07/2019
                       ,
                       sysdate,
                       p_user_id,
                       p_user_id,
                       sysdate ) returning benefit_code_id into x_benefit_code_id;

        else
            update benefit_codes
            set
                fully_insured_flag = p_fully_insured_flag,
                self_insured_flag = p_self_insured_flag
            where
                    entity_id = p_entity_id
                and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                and upper(benefit_code_name) = v_code_name;

        end if;

    exception
        when others then
            pc_log.log_error('PC_ERISSA', sqlerrm);
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end insert_benefit_codes;

    procedure insert_5500_report (
        p_ben_plan_id in number,
        p_report_type in varchar2,
        p_user_id     in number
    ) is
        l_count    number := 0;
        l_entrp_id number := null;--Added by Karthe K S on 11/02/2015 for the Pier Ticket 2464

    begin
        select
            count(*)
        into l_count
        from
            plan_notices
        where
                notice_type = p_report_type
            and entity_id = p_ben_plan_id;

        if l_count = 0 then
            insert into plan_notices (
                plan_notice_id,
                entity_id,
                entity_type,
                notice_type,
                creation_date,
                last_update_date,
                created_by,
                last_updated_by
            ) values ( plan_notice_seq.nextval,
                       p_ben_plan_id,
                       'BEN_PLAN_ENROLLMENT_SETUP',
                       p_report_type,
                       sysdate,
                       sysdate,
                       p_user_id,
                       p_user_id );

        end if;

    end insert_5500_report;

    procedure insert_plan_notices (
        p_ben_plan_id in number,
        p_report_type in varchar2,
        p_user_id     in number
    ) is
        l_count number := 0;
    begin
        select
            count(*)
        into l_count
        from
            plan_notices
        where
                notice_type = p_report_type
            and entity_id = p_ben_plan_id;

        if l_count = 0 then
            insert into plan_notices (
                plan_notice_id,
                entity_id,
                entity_type,
                notice_type,
                creation_date,
                last_update_date,
                created_by,
                last_updated_by
            ) values ( plan_notice_seq.nextval,
                       p_ben_plan_id,
                       'BEN_PLAN_ENROLLMENT_SETUP',
                       p_report_type,
                       sysdate,
                       sysdate,
                       p_user_id,
                       p_user_id );

        end if;

    end insert_plan_notices;

    procedure update_eligibility_detail (
        p_benefit_code_id   in number,
        p_er_contrib        in varchar2 default null,
        p_ee_contrib        in varchar2 default null,
        p_eligibility       in varchar2 default null,
        p_user_id           in number default null,
        p_er_ee_contrib_lng in varchar2 default null  -- Added by Swamy Ticket#5518 Develp from session to staging table
        ,
        p_refer_to_doc      in varchar2 default null  -- Added by Swamy Ticket#5518 Develp from session to staging table
        ,
        x_error_message     out varchar2,
        x_return_status     out varchar2
    ) is
    begin
        if p_benefit_code_id is not null then  -- added by swamy
            update benefit_codes
            set
                eligibility = p_eligibility,
                er_cont_pref = p_er_contrib,
                ee_cont_pref = p_ee_contrib,
                er_ee_contrib_lng = p_er_ee_contrib_lng,    -- Added by Swamy Ticket#5518 Develp from session to staging table
                refer_to_doc = p_refer_to_doc,     -- Added by Swamy Ticket#5518 Develp from session to staging table
                last_updated_by = p_user_id,          -- Added by Swamy Ticket#5518 Develp from session to staging table
                last_update_date = sysdate              -- Added by Swamy Ticket#5518 Develp from session to staging table
            where
                benefit_code_id = p_benefit_code_id;

        end if;
  /*Employer online portal.Update return status as Success */
        x_return_status := 'S';
    exception
        when others then
            pc_log.log_error('In ERISSA.Update_eligibility_detail', sqlerrm);
    end update_eligibility_detail;

    procedure create_census_data (
        p_entrp_id      in number,
        p_no_of_ees     in number,
        p_entity_type   in varchar2,
        p_code_name     in varchar2,
        p_user_id       in number default null,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
        l_rec number := 0;
    begin
        pc_log.log_error('PC_ERISSA..Create Census Data', p_entrp_id);
        begin
            select
                count(1)
            into l_rec
            from
                enterprise_census
            where
                    entity_id = p_entrp_id
                and census_code = p_code_name
                and entity_type = p_entity_type;

            if l_rec >= 1 then
                update enterprise_census
                set
                    census_numbers = p_no_of_ees
                where
                        census_code = p_code_name
                    and entity_id = p_entrp_id;

            else --cnt =0
                insert into enterprise_census (
                    entity_id,
                    entity_type,
                    census_code,
                    census_numbers,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( p_entrp_id,
                           p_entity_type,
                           p_code_name,
                           p_no_of_ees,
                           sysdate,
                           null,
                           sysdate,
                           null );

            end if;

        exception
            when no_data_found then
                insert into enterprise_census (
                    entity_id,
                    entity_type,
                    census_code,
                    census_numbers,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( p_entrp_id,
                           p_entity_type,
                           p_code_name,
                           p_no_of_ees,
                           sysdate,
                           null,
                           sysdate,
                           null );

        end;

    exception
        when too_many_rows then
            pc_log.log_error('PC_ERISSA.Create_Census', 'Error creating census record ' || sqlerrm);
            x_return_status := 'E';
        when others then
            null;
    end create_census_data;

    function get_contact_list (
        p_entrp_id in number
    ) return contact_t
        pipelined
        deterministic
    is
        l_record contact_row_t;
    begin
        for x in (
            select distinct
                b.name,
                lower(a.email) to_email,
                b.entrp_id,
                to_char(
                    add_business_days(10, sysdate),
                    'MM/DD/YYYY'
                )              deadline,
                a.first_name   contact_name
            from
                contact      a,
                enterprise   b,
                contact_role c
            where
                    replace(a.entity_id, '-') = replace(b.entrp_code, '-')
                and a.contact_id = c.contact_id
                and c.role_type in ( 'PRIMARY', 'COMPLIANCE', 'NDT' ) --NDT added by preethy for ticket no:6073 on 05/07/2018
                and nvl(a.status, 'A') = 'A'
                and c.effective_end_date is null
                and b.entrp_id = p_entrp_id
                and a.first_name is not null
                and a.last_name is not null
                and a.email is not null
                and a.can_contact = 'Y'
        ) loop
            l_record.entrp_name := x.name;
            if l_record.email_list is null then
                l_record.email_list := x.to_email;
                l_record.contact_name := x.contact_name;
            else
                l_record.email_list := l_record.email_list
                                       || ','
                                       || x.to_email;
            end if;

            l_record.deadline := x.deadline;
        end loop;

        for x in (
            select
                a.email  cc_list,
                'BROKER' entity_type
            from
                contact      a,
                enterprise   b,
                contact_role c
            where
                    a.entity_id = replace(b.entrp_code, '-')
                and nvl(a.status, 'A') = 'A'
                and c.role_type in ( 'BROKER' )
                and a.contact_id = c.contact_id
                and c.effective_end_date is null
                and b.entrp_id = p_entrp_id
                and a.email is not null
                and a.can_contact = 'Y'
            union
            select
                b.email,
                'GA' entity_type
            from
                active_sales_team_member_v a,
                general_agent              b
            where
                    a.emplr_id = p_entrp_id
                and a.ga = b.ga_id
                and a.ga <> 0
                and b.email is not null
          -- changes to remove the Sales Rep email as requested by Lindsey 03/20
         /*  UNION
          SELECT D.EMAIL, 'SALESREP' entity_type
          FROM active_sales_team_member_v A, EMPLOYEE D, SALESREP E
          where A.EMPLR_ID = P_ENTRP_ID
          AND   E.STATUS = 'A'
          AND   D.EMP_ID  = E.EMP_ID AND E.SALESREP_ID =  primary_salerep
          AND   D.EMAIL IS NOT NULL
          */
        ) loop
            if x.entity_type = 'BROKER' then
                if l_record.email_list is null then
                    l_record.email_list := x.cc_list;
                end if;
            end if;

            if l_record.cc_list is null then
                l_record.cc_list := lower(x.cc_list);
            else
                l_record.cc_list := l_record.cc_list
                                    || ','
                                    || lower(x.cc_list);
            end if;

        end loop;

        l_record.cc_list := l_record.cc_list;
        l_record.contact_name := nvl(l_record.contact_name, 'Plan Administrator');
        if user = 'SAMDEV' then
            l_record.email_list := 'IT-team@sterlingadministration.com,vanitha.subramanyam@sterlingadministration.com';
            l_record.cc_list := 'IT-team@sterlingadministration.com,vanitha.subramanyam@sterlingadministration.com';
        end if;

        pipe row ( l_record );
    end get_contact_list;

    function get_compliance_notify return notification_list_t
        pipelined
        deterministic
    is
        l_record_t notification_list_row_t;
    begin
        for x in (
            select distinct
                b.acc_id,
                b.acc_num,
                b.entrp_id,
                a.product_type,
                case
                    when a.product_type = 'HRA'
                         and c.notice_type = '1ST_QTR_NDT' then
                        'HRA_PRELIM_NDT_PASS_EMAIL'
                    when a.product_type = 'HRA'
                         and c.notice_type = 'LAST_QTR_NDT' then
                        'HRA_FINAL_NDT_PASS_EMAIL'
                    when a.product_type = 'FSA'
                         and c.notice_type = '1ST_QTR_NDT' then
                        'FSA_PRELIM_NDT_PASS_EMAIL'
                    when a.product_type = 'FSA'
                         and c.notice_type = 'LAST_QTR_NDT' then
                        'FSA_FINAL_NDT_PASS_EMAIL'
                    when b.account_type = 'POP'
                         and c.notice_type = '1ST_QTR_NDT' then  -- Added by jaggi #11264
                        'POP_PRELIM_NDT_PASS_EMAIL'
                    when b.account_type = 'POP'
                         and c.notice_type = 'LAST_QTR_NDT' then
                        'POP_FINAL_NDT_PASS_EMAIL'
                end                                                                                template_name,
                c.notice_type,
                decode(c.notice_type, '1ST_QTR_NDT', 'P_NDT_CENSUS_RESULT', 'F_NDT_CENSUS_RESULT') result_file,
                d.attachment_id,
                a.ben_plan_id,
                plan_end_date  -- Added by Jaggi #11264
            from
                ben_plan_enrollment_setup a,
                account                   b,
                plan_notices              c,
                file_attachments          d
            where
                    a.acc_id = b.acc_id
                and c.entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                and c.entity_id = a.ben_plan_id
                and c.notice_type in ( '1ST_QTR_NDT', 'LAST_QTR_NDT' )
                and a.status in ( 'A', 'I' )
                and d.entity_id = a.ben_plan_id
                and d.entity_name = 'BEN_PLAN_ENROLLMENT_SETUP'
                and document_purpose = decode(c.notice_type, '1ST_QTR_NDT', 'P_NDT_CENSUS_RESULT', 'F_NDT_CENSUS_RESULT')
                and trunc(d.creation_date) >= trunc(sysdate - 1)
              --     AND TRUNC(D.CREATION_DATE) >= '01-JAN-2020'
                --  AND TRUNC(D.CREATION_DATE) BETWEEN '01-NOV-2016' AND '19-dec-2016'
                and test_result = 'PASS'
                and c.result_sent_on is null
        ) loop
            l_record_t.acc_num := x.acc_num;
            l_record_t.entrp_id := x.entrp_id;
            l_record_t.acc_id := x.acc_id;
            l_record_t.result_notice := x.result_file;
            l_record_t.product_type := x.acc_num;
            l_record_t.template_name := x.template_name;
            l_record_t.notice_type := x.notice_type;
            l_record_t.attachment_id := x.attachment_id;
            l_record_t.ben_plan_id := x.ben_plan_id;
            l_record_t.plan_end_date := x.plan_end_date;
            for xx in (
                select
                    *
                from
                    table ( pc_compliance.get_contact_list(x.entrp_id) )
            ) loop
                l_record_t.to_list := xx.email_list;
                l_record_t.cc_list := xx.cc_list;
                l_record_t.employer_name := xx.entrp_name;
                l_record_t.contact_name := xx.contact_name;
            end loop;

            pipe row ( l_record_t );
        end loop;
    end get_compliance_notify;

    function get_compliance_followup (
        p_plan_end_from in date,
        p_plan_end_to   in date,
        p_product_type  in varchar2
    ) return compliance_t
        pipelined
        deterministic
    is
        l_record_t compliance_row_t;
    begin
        for x in (
            select
                b.acc_num,
                a.entrp_id,
                pc_entrp.get_entrp_name(a.entrp_id) name,
                to_char(
                    min(a.plan_start_date),
                    'YYYY'
                )                                   plan_start,
                to_char(
                    max(a.plan_end_date),
                    'MM/DD/YYYY'
                )                                   plan_end,
                min(a.plan_start_date)              plan_start_date,
                max(a.plan_end_date)                plan_end_date
            from
                ben_plan_enrollment_setup a,
                account                   b,
                plan_notices              c
            where
                trunc(a.plan_end_date) between p_plan_end_from and p_plan_end_to
                and a.plan_start_date <= sysdate
                -- AND    A.PLAN_END_DATE > SYSDATE
                and a.entrp_id = b.entrp_id
                and product_type = p_product_type
                and nvl(a.non_discm_testing, 'Y') <> 'N'
                and a.ben_plan_id = c.entity_id
                and c.notice_type = 'LAST_QTR_NDT'
                and c.notice_received_on is null
                and c.notice_reminder_on is null
              --   AND    TRUNC(C.NOTICE_REVIEW_SENT)-TRUNC(SYSDATE) = 11
            group by
                b.acc_num,
                a.entrp_id
            order by
                1
        ) loop
            l_record_t.acc_num := x.acc_num;
            l_record_t.entrp_id := x.entrp_id;
            l_record_t.name := x.name;
            l_record_t.plan_start := x.plan_start;
            l_record_t.plan_end := x.plan_end;
            l_record_t.plan_start_date := x.plan_start_date;
            l_record_t.plan_end_date := x.plan_end_date;
            pipe row ( l_record_t );
        end loop;
    end get_compliance_followup;

    procedure export_cms_query_file (
        x_file_name out varchar2
    ) as

        b_lob          blob;
        l_utl_id       utl_file.file_type;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_line_tbl     varchar2_4000_tbl;
        l_line_count   number := 0;
        l_dest_blob    blob;
        l_src_offset   number := 1;
        l_dest_offset  number := 1;
        l_src_osin     number;
        l_dst_osin     number;
        l_rreid        varchar2(255) := '000038675';
        l_source_bfile bfile := bfilename('DEBIT_CARD_DIR',
                                          'CMS_Query_'
                                          || to_char(sysdate, 'mmddyyyyhhmiss')
                                          || '.txt');
    begin
-- followed guidelines from the link
  -- http://www.cms.gov/Medicare/Coordination-of-Benefits-and-Recovery/Mandatory-Insurer-Reporting-For-Group-Health-Plans/Downloads/New-Downloads/MMSEA-Revised-July-14-2014-GHP-User-Guide-Version-4-4.pdf
        l_file_name := 'CMS_Query_'
                       || to_char(sysdate, 'mmddyyyyhhmiss')
                       || '.txt';
        l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
        l_line := 'H0'
                  || l_rreid
                  || 'NGHQ'
                  || to_char(sysdate, 'YYYYMMDD')
                  || lpad(' ', 177, ' ');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select
                a.last_name,
                a.first_name,
                a.birth_date,
                decode(gender, 'M', '1', 'F', '2',
                       '1')                         gender,
                a.ssn,
                b.acc_num,
                a.pers_id,
                pc_entrp.get_entrp_name(a.entrp_id) entrp_name
            from
                person                    a,
                account                   b,
                ben_plan_enrollment_setup c,
                ben_plan_enrollment_setup er
            where
                    a.pers_id = b.pers_id
                and c.acc_id = b.acc_id
                and c.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )
                and c.annual_election >= 5000
                and floor(months_between(sysdate, a.birth_date) / 12) < 79
                and c.status = 'A'
                and c.plan_end_date > sysdate
                and nvl(c.effective_end_date, sysdate) > sysdate
                and c.effective_date > (
                    select
                        max(creation_date)
                    from
                        medicare_pers_record m
                    where
                        m.pers_id = a.pers_id
                )
                and b.account_type in ( 'FSA', 'HRA' )
                and a.ssn is not null
                and er.ben_plan_id = c.ben_plan_id_main
                and nvl(er.is_cms_opted, 'N') = 'N'
                and exists (
                    select
                        *
                    from
                        medicare_pers_record c
                    where
                        c.pers_id = a.pers_id
                )
            union
            select
                a.last_name,
                a.first_name,
                a.birth_date,
                decode(gender, 'M', '1', 'F', '2',
                       '1')                         gender,
                a.ssn,
                b.acc_num,
                a.pers_id,
                pc_entrp.get_entrp_name(a.entrp_id) entrp_name
            from
                person                    a,
                account                   b,
                ben_plan_enrollment_setup c,
                ben_plan_enrollment_setup er
            where
                    a.pers_id = b.pers_id
                and c.acc_id = b.acc_id
                and c.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )
                and c.annual_election >= 5000
                and floor(months_between(sysdate, a.birth_date) / 12) < 79
                and c.status = 'A'
                and c.plan_end_date > sysdate
                and nvl(c.effective_end_date, sysdate) > sysdate
                and c.effective_date > (
                    select
                        max(creation_date)
                    from
                        medicare_pers_record m
                    where
                        m.pers_id = a.pers_id
                )
                and b.account_type in ( 'FSA', 'HRA' )
                and a.ssn is not null
                and er.ben_plan_id = c.ben_plan_id_main
                and nvl(er.is_cms_opted, 'N') = 'N'
                and not exists (
                    select
                        *
                    from
                        medicare_pers_record c
                    where
                        c.pers_id = a.pers_id
                )
            union
            select
                a.last_name,
                a.first_name,
                a.birth_date,
                decode(a.gender, 'M', '1', 'F', '2',
                       '1')                         gender,
                a.ssn,
                b.acc_num,
                a.pers_id,
                pc_entrp.get_entrp_name(d.entrp_id) entrp_name
            from
                person                    a,
                account                   b,
                ben_plan_enrollment_setup c,
                person                    d,
                ben_plan_enrollment_setup er
            where
                    a.pers_main = b.pers_id
                and a.pers_main = d.pers_id
                and c.acc_id = b.acc_id
                and c.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )
                and c.annual_election >= 5000
                and floor(months_between(sysdate, d.birth_date) / 12) < 79
                and c.status = 'A'
                and c.plan_end_date > sysdate
                and nvl(c.effective_end_date, sysdate) > sysdate
                and c.effective_date > (
                    select
                        max(creation_date)
                    from
                        medicare_pers_record m
                    where
                        m.pers_id = a.pers_id
                )
                and b.account_type in ( 'FSA', 'HRA' )
                and a.ssn is not null
                and er.ben_plan_id = c.ben_plan_id_main
                and nvl(er.is_cms_opted, 'N') = 'N'
            union
            select
                a.last_name,
                a.first_name,
                a.birth_date,
                decode(a.gender, 'M', '1', 'F', '2',
                       '1')                         gender,
                a.ssn,
                b.acc_num,
                a.pers_id,
                pc_entrp.get_entrp_name(d.entrp_id) entrp_name
            from
                person                    a,
                account                   b,
                ben_plan_enrollment_setup c,
                person                    d,
                ben_plan_enrollment_setup er
            where
                    a.pers_main = b.pers_id
                and a.pers_main = d.pers_id
                and c.acc_id = b.acc_id
                and c.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )
                and c.annual_election >= 5000
                and floor(months_between(sysdate, d.birth_date) / 12) < 79
                and c.status = 'A'
                and c.plan_end_date > sysdate
                and nvl(c.effective_end_date, sysdate) > sysdate
                and c.effective_date > (
                    select
                        max(creation_date)
                    from
                        medicare_pers_record m
                    where
                        m.pers_id = a.pers_id
                )
                and b.account_type in ( 'FSA', 'HRA' )
                and a.ssn is not null
                and er.ben_plan_id = c.ben_plan_id_main
                and nvl(er.is_cms_opted, 'N') = 'N'
                and not exists (
                    select
                        *
                    from
                        medicare_pers_record c
                    where
                        c.pers_id = a.pers_id
                )
        ) loop
            l_line := lpad(' ', 12, ' ')
                      || rpad(
                substr(
                    upper(x.last_name),
                    1,
                    6
                ),
                6,
                ' '
            )
                      || substr(
                upper(x.first_name),
                1,
                1
            )
                      || nvl(
                to_char(x.birth_date, 'YYYYMMDD'),
                lpad(' ', 8, ' ')
            )
                      || nvl(x.gender, '0')
                      || nvl(
                replace(x.ssn, '-'),
                lpad(' ', 9, ' ')
            )
                      || rpad(x.acc_num, 30, '+')
                      || rpad(x.pers_id, 30, '+')
                      || lpad(' ', 103, ' ')
                      || ':'
                      || x.entrp_name;

            l_line_count := l_line_count + 1;
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := 'T0'
                  || l_rreid
                  || 'NGHQ'
                  || to_char(sysdate, 'YYYYMMDD')
                  || lpad(l_line_count, 9, '0')
                  || lpad(' ', 168, ' ');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        utl_file.fclose(file => l_utl_id);
        if l_line_count > 0 then
            x_file_name := l_file_name;
        end if;
/*
  DBMS_LOB.createtemporary(l_dest_blob,TRUE);
   DBMS_LOB.fileopen(l_source_bfile, dbms_lob.file_readonly);
   l_src_osin := l_src_offset;
  l_dst_osin := l_dest_offset;
   DBMS_LOB.loadblobfromfile( l_dest_blob , l_source_bfile , dbms_lob.lobmaxsize , l_src_offset , l_dest_offset);
  OWA_UTIL.mime_header('application/octet', FALSE);
  HTP.p('Content-length: ' || dbms_lob.getlength(l_dest_blob));
  HTP.p('Content-Disposition: attachment; filename="'||'CMS_Query_'||to_char(sysdate,'mmddyyyyhhmiss')||'.txt'||'"');
  OWA_UTIL.http_header_close;
  WPG_DOCLOAD.download_file(l_dest_blob);*/

    exception
        when others then
            htp.p(sqlerrm
                  || '...'
                  || dbms_utility.format_error_backtrace);
    end export_cms_query_file;

    procedure export_cms_tin_file (
        x_file_name out varchar2
    ) as

        b_lob          blob;
        l_utl_id       utl_file.file_type;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_line_tbl     varchar2_4000_tbl;
        l_line_count   number := 0;
        l_dest_blob    blob;
        l_src_offset   number := 1;
        l_dest_offset  number := 1;
        l_src_osin     number;
        l_dst_osin     number;
        l_rreid        varchar2(255) := '000038675';
        l_source_bfile bfile := bfilename('DEBIT_CARD_DIR',
                                          'CMS_TIN_'
                                          || to_char(sysdate, 'mmddyyyyhhmiss')
                                          || '.txt');
    begin
-- followed guidelines from the link
  -- http://www.cms.gov/Medicare/Coordination-of-Benefits-and-Recovery/Mandatory-Insurer-Reporting-For-Group-Health-Plans/Downloads/New-Downloads/MMSEA-Revised-July-14-2014-GHP-User-Guide-Version-4-4.pdf
        l_file_name := 'CMS_TIN_'
                       || to_char(sysdate, 'mmddyyyyhhmiss')
                       || '.txt';
        l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
        l_line := 'H0'
                  || l_rreid
                  || 'REFR'
                  || to_char(sysdate, 'YYYYMMDD')
                  || lpad(' ', 402, ' ');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select
                rpad(
                    replace(x.entrp_code, '-'),
                    9,
                    ' '
                )  -- TIN
                || rpad(x.name, 32, ' ')                    -- NAME OF ENTITY
                || rpad(x.address, 32, ' ')                 -- Address Line 1.
                || lpad(
                    nvl(x.address2, ' '),
                    32,
                    ' '
                )       -- Address Line 2.
                || rpad(x.city, 15, ' ')                    -- City
                || rpad(x.state, 2, ' ')                    -- State
                || rpad(x.zip, 9, ' ')                      -- Zip
                || 'E' line                               -- TIN indicator
            from
                (
                    select
                        c.*
                    from
                        medicare_pers_record a,
                        person               b,
                        enterprise           c
                    where
                            a.pers_id = b.pers_id
                        and b.entrp_id = c.entrp_id
                ) x
            union
            select
                rpad(
                    replace(x.entrp_code, '-'),
                    9,
                    ' '
                )
                || rpad(x.name, 32, ' ')
                || rpad(x.address, 32, ' ')
                || lpad(
                    nvl(x.address2, ' '),
                    32,
                    ' '
                )
                || rpad(x.city, 15, ' ')
                || rpad(x.state, 2, ' ')
                || rpad(x.zip, 9, ' ')
                || 'I' line -- fixed on 10/26/2017, for the TIN file error received
            from
                enterprise x
            where
                x.entrp_id = 7647
        ) loop
            l_line := x.line;
            l_line_count := l_line_count + 1;
            utl_file.put_line(
                file   => l_utl_id,
                buffer => x.line
            );
        end loop;

        l_line := 'T0'
                  || l_rreid
                  || 'REFR'
                  || to_char(sysdate, 'YYYYMMDD')
                  || lpad(l_line_count, 9, '0')
                  || lpad(' ', 393, ' ');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        utl_file.fclose(file => l_utl_id);
        if l_line_count > 0 then
            x_file_name := l_file_name;
        end if;
  /* DBMS_LOB.createtemporary(l_dest_blob,TRUE);
   DBMS_LOB.fileopen(l_source_bfile, dbms_lob.file_readonly);
   l_src_osin := l_src_offset;
  l_dst_osin := l_dest_offset;
   DBMS_LOB.loadblobfromfile( l_dest_blob , l_source_bfile , dbms_lob.lobmaxsize , l_src_offset , l_dest_offset);
  OWA_UTIL.mime_header('application/octet', FALSE);
  HTP.p('Content-length: ' || dbms_lob.getlength(l_dest_blob));
  HTP.p('Content-Disposition: attachment; filename="'||'CMS_TIN_'||to_char(sysdate,'mmddyyyyhhmiss')||'.txt'||'"');
  OWA_UTIL.http_header_close;
  WPG_DOCLOAD.download_file(l_dest_blob); */
    exception
        when others then
            htp.p(sqlerrm
                  || '...'
                  || dbms_utility.format_error_backtrace);
    end export_cms_tin_file;

    procedure export_cms_msp_file (
        x_file_name out varchar2
    ) as

        b_lob          blob;
        l_utl_id       utl_file.file_type;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_line_tbl     varchar2_4000_tbl;
        l_line_count   number := 0;
        l_dest_blob    blob;
        l_src_offset   number := 1;
        l_dest_offset  number := 1;
        l_src_osin     number;
        l_dst_osin     number;
        l_rreid        varchar2(255) := '000038675';
        l_source_bfile bfile := bfilename('DEBIT_CARD_DIR',
                                          'CMS_MSP_'
                                          || to_char(sysdate, 'mmddyyyyhhmiss')
                                          || '.txt');
    begin
  -- followed guidelines from the link
  -- http://www.cms.gov/Medicare/Coordination-of-Benefits-and-Recovery/Mandatory-Insurer-Reporting-For-Group-Health-Plans/Downloads/New-Downloads/MMSEA-Revised-July-14-2014-GHP-User-Guide-Version-4-4.pdf
        l_file_name := 'CMS_MSP_'
                       || to_char(sysdate, 'mmddyyyyhhmiss')
                       || '.txt';
        l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
        l_line := 'H0'
                  || l_rreid
                  || 'MSPI'
                  || to_char(sysdate, 'YYYYMMDD')
                  || lpad(' ', 402, ' ');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select
                rpad(
                    nvl(a.hic_number, ' '),
                    12,
                    ' '
                )              -- HIC Number (12)
                || rpad(
                    substr(b.last_name, 1, 6),
                    6,
                    ' '
                )           -- Sur name (6)
                || substr(b.first_name, 1, 1)                      -- First name (1)
                || rpad(
                    nvl(
                        to_char(b.birth_date, 'YYYYMMDD'),
                        ' '
                    ),
                    8,
                    ' '
                )              -- Birth Date (8)
                || decode(b.gender, 'M', '1', 'F', '2',
                          '0')          -- Sex (1)
                || rpad(
                    nvl(a.cms_doc_crl_number, ' '),
                    15,
                    ' '
                )             -- DCN (15)
                ||
                case
                    when nvl(a.effective_end_date, sysdate) >= sysdate then
                            '0'
                    else
                        '1'
                end        -- Transaction Type (1)
                || 'R'                                           -- Coverage Type (1)
                || rpad(
                    replace(b.ssn, '-'),
                    9,
                    ' '
                )                -- SSN (9)
                || to_char(a.effective_date, 'YYYYMMDD')          -- Effective Date (8)
                || nvl(
                    to_char(a.effective_end_date, 'YYYYMMDD'),
                    '00000000'
                ) -- Termination Date (8)
                || '01'                                           -- Relationship Code (2)
                || rpad(
                    substr(b.first_name, 1, 9),
                    9,
                    ' '
                )           -- Policy Holder's First Name  (9)
                || rpad(
                    substr(b.last_name, 1, 16),
                    16,
                    ' '
                )         -- Policy Holder's Last Name  (16)
                || rpad(
                    replace(b.ssn, '-'),
                    9,
                    ' '
                )                -- Policy Holder's SSN  (9)
                ||
                case
                        when pc_entrp.count_person(b.entrp_id) < 20              then
                            '0'
                        when pc_entrp.count_person(b.entrp_id) between 20 and 99 then
                            '1'
                        else
                            '2'
                end        -- Employer Size(1)
                || rpad(
                    nvl(
                        to_char(b.entrp_id),
                        ' '
                    ),
                    20,
                    ' '
                )      -- Group Policy Number(1)
                || rpad(b.pers_id, 17, ' ')                         -- Individual Policy Number(1)
                || '1'                                            -- Subscriber Only (1)
                || '1'                                            -- Employee Status (1)
                || rpad(
                    replace(
                        pc_entrp.get_tax_id(b.entrp_id),
                        '-'
                    ),
                    9,
                    ' '
                ) -- TIN (9)
                || '841637046' line                               -- TPA TIN (9)
            from
                medicare_pers_record a,
                person               b
            where
                    a.pers_id = b.pers_id
                and floor(months_between(sysdate, b.birth_date) / 12) < 79
                and b.pers_main is null
                and a.tin_result_code is not null
                and nvl(a.effective_end_date, sysdate) >= sysdate
                and not exists (
                    select
                        *
                    from
                        account                   c,
                        ben_plan_enrollment_setup bp,
                        ben_plan_enrollment_setup er
                    where
                            a.acc_num = c.acc_num
                        and c.acc_id = bp.acc_id
                        and er.is_cms_opted = 'Y'
                        and bp.plan_end_date > a.effective_date
                        and a.acc_num = c.acc_num
                        and c.acc_id = bp.acc_id
                        and bp.ben_plan_id_main = er.ben_plan_id
                )
            union
            select
                rpad(
                    nvl(a.hic_number, ' '),
                    12,
                    ' '
                )                       -- HIC Number (12)
                || rpad(
                    substr(b.last_name, 1, 6),
                    6,
                    ' '
                )             -- Sur name (6)
                || substr(b.first_name, 1, 1)                        -- First name (1)
                || rpad(
                    nvl(
                        to_char(b.birth_date, 'YYYYMMDD'),
                        ' '
                    ),
                    8,
                    ' '
                )                -- Birth Date (8)
                || decode(b.gender, 'M', '1', 'F', '2',
                          '0')           -- Sex (1)
                || rpad(
                    nvl(a.cms_doc_crl_number, ' '),
                    15,
                    ' '
                )               -- DCN (15)
                ||
                case
                    when nvl(a.effective_end_date, sysdate) >= sysdate then
                            '0'
                    else
                        '1'
                end        -- Transaction Type (1)
                || 'R'                                           --- Coverage Type (1)
                || rpad(
                    nvl(
                        replace(b.ssn, '-'),
                        ' '
                    ),
                    9,
                    ' '
                )                  -- SSN (9)
                || to_char(a.effective_date, 'YYYYMMDD')           -- Effective Date (8)
                || nvl(
                    to_char(a.effective_end_date, 'YYYYMMDD'),
                    '00000000'
                ) -- Termination Date (8)
                || lpad(
                    nvl(b.relat_code, '04'),
                    2,
                    '0'
                )              -- Relationship Code (2)
                || rpad(
                    substr(c.first_name, 1, 9),
                    9,
                    ' '
                )            -- Policy Holder's First Name  (9)
                || rpad(
                    substr(c.last_name, 1, 16),
                    16,
                    ' '
                )          -- Policy Holder's Last Name  (16)
                || rpad(
                    nvl(
                        replace(c.ssn, '-'),
                        ' '
                    ),
                    9,
                    ' '
                )                 -- Policy Holder's SSN  (9)
                ||
                case
                        when pc_entrp.count_person(c.entrp_id) < 20              then
                            '0'
                        when pc_entrp.count_person(c.entrp_id) between 20 and 99 then
                            '1'
                        else
                            '2'
                end                      -- Employer Size(1)
                || rpad(
                    nvl(
                        to_char(c.entrp_id),
                        ' '
                    ),
                    20,
                    ' '
                )      -- Group Policy Number(1)
                || rpad(b.pers_id, 17, ' ')                          -- Individual Policy Number(1)
                || '1'                                             -- Subscriber Only (1)
                || '1'                                             -- Employee Status (1)
                || rpad(
                    replace(
                        pc_entrp.get_tax_id(c.entrp_id),
                        '-'
                    ),
                    9,
                    ' '
                ) -- TIN (9)
                || '841637046'                                      -- TPA TIN (9)
            from
                medicare_pers_record a,
                person               b,
                person               c
            where
                    a.pers_id = b.pers_id
                and floor(months_between(sysdate, c.birth_date) / 12) < 79
                and nvl(a.effective_end_date, sysdate) >= sysdate
                and b.pers_main is not null
                and a.tin_result_code is not null
                and b.pers_main = c.pers_id
                and not exists (
                    select
                        *
                    from
                        account                   c,
                        ben_plan_enrollment_setup bp,
                        ben_plan_enrollment_setup er
                    where
                            a.acc_num = c.acc_num
                        and c.acc_id = bp.acc_id
                        and er.is_cms_opted = 'Y'
                        and bp.plan_end_date > a.effective_date
                        and a.acc_num = c.acc_num
                        and c.acc_id = bp.acc_id
                        and bp.ben_plan_id_main = er.ben_plan_id
                )
        ) loop
            l_line := substr(
                rpad(x.line, 424, ' '),
                1,
                424
            );

            l_line_count := l_line_count + 1;
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := 'T0'
                  || l_rreid
                  || 'MSPI'
                  || to_char(sysdate, 'YYYYMMDD')
                  || lpad(l_line_count, 9, '0')
                  || lpad(' ', 393, ' ');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        utl_file.fclose(file => l_utl_id);
        if l_line_count > 0 then
            x_file_name := l_file_name;
        end if;
    exception
        when others then
            htp.p(sqlerrm
                  || '...'
                  || dbms_utility.format_error_backtrace);
    end export_cms_msp_file;

    procedure import_cms_file (
        pv_file_name in varchar2,
        p_user_id    in number
    ) as

        l_file          utl_file.file_type;
        l_buffer        raw(32767);
        l_amount        binary_integer := 32767;
        l_pos           integer := 1;
        l_blob          blob;
        l_blob_len      integer;
        exc_no_file exception;
        l_create_ddl    varchar2(32000);
        lv_dest_file    varchar2(300);
        l_sqlerrm       varchar2(32000);
        l_create_error exception;
        l_batch_number  number;
        l_valid_plan    number(10);
        l_acc_id        number(10);
        x_return_status varchar2(10);
        x_error_message varchar2(2000);
    begin
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

  /* Get the contents of BLOB from wwv_flow_files */
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            l_file := utl_file.fopen('DEBIT_CARD_DIR', pv_file_name, 'w', 32767);
            l_blob_len := dbms_lob.getlength(l_blob); -- gets file length

    -- Open / Creates the destination file.
    -- Read chunks of the BLOB and write them to the file
    -- until complete.
            while l_pos < l_blob_len loop
                dbms_lob.read(l_blob, l_amount, l_pos, l_buffer);
                utl_file.put_raw(l_file, l_buffer, true);
                l_pos := l_pos + l_amount;
            end loop;
    -- Close the file.
            utl_file.fclose(l_file);
    -- Delete file from wwv_flow_files
            delete from wwv_flow_files
            where
                name = pv_file_name;

        exception
            when others then
                null;
        end;

        begin
            execute immediate ' ALTER TABLE CMS_EXTERNAL
		location (DEBIT_CARD_DIR:'''
                              || lv_dest_file
                              || ''')';
        exception
            when others then
                l_sqlerrm := 'Error in Changing location of compliance file' || sqlerrm;
                raise l_create_error;
        end;

    end import_cms_file;

    procedure update_medicare_information is
        l_pers_id number;
    begin
        for x in (
            select
                substr(cms_record, 1, 12)   hic_number,
                substr(cms_record, 102, 14) medicare_ctrl_number,
                replace(
                    substr(cms_record, 117, 30),
                    '+'
                )                           acc_num,
                replace(
                    substr(cms_record, 147, 30),
                    '+'
                )                           pers_id,
                substr(cms_record, 100, 2)  medicare_flag,
                substr(cms_record, 29, 9)   ssn
            from
                cms_external
            where
                trim(substr(cms_record, 1, 12)) is not null
                and substr(cms_record, 100, 2) = '01'
        ) loop
            l_pers_id := null;
            update medicare_pers_record
            set
                hic_number = x.hic_number,
                effective_date = sysdate,
                cms_doc_crl_number = x.medicare_ctrl_number,
                last_update_date = sysdate
            where
                pers_id = x.pers_id
            returning pers_id into l_pers_id;

            if l_pers_id is null then
                insert into medicare_pers_record (
                    pers_id,
                    hic_number,
                    cms_doc_crl_number,
                    effective_date,
                    creation_date,
                    last_update_date,
                    acc_num,
                    ssn
                ) values ( x.pers_id,
                           x.hic_number,
                           x.medicare_ctrl_number,
                           sysdate,
                           sysdate,
                           sysdate,
                           x.acc_num,
                           format_ssn(x.ssn) );

            end if;

        end loop;

        for x in (
            select
                substr(cms_record, 1, 12)   hic_number,
                substr(cms_record, 102, 14) medicare_ctrl_number,
                replace(
                    substr(cms_record, 117, 30),
                    '+'
                )                           acc_num,
                replace(
                    substr(cms_record, 147, 30),
                    '+'
                )                           pers_id,
                substr(cms_record, 100, 2)  medicare_flag
            from
                cms_external
            where
                trim(substr(cms_record, 1, 12)) is not null
                and substr(cms_record, 100, 2) = '51'
        ) loop
            update medicare_pers_record
            set
                effective_end_date = sysdate,
                cms_doc_crl_number = x.medicare_ctrl_number,
                last_update_date = sysdate
            where
                pers_id = x.pers_id;

        end loop;

        update_plan_dates_cms;
    end update_medicare_information;

    procedure update_plan_dates_cms is
    begin
        for x in (
            select
                a.acc_num,
                max(c.effective_date)     effective_date,
                max(c.effective_end_date) effective_end_date
            from
                medicare_pers_record      a,
                account                   b,
                ben_plan_enrollment_setup c
            where
                    a.acc_num = b.acc_num
                and b.acc_id = c.acc_id
                and c.product_type = 'HRA'
                and c.status in ( 'A', 'I' )
            group by
                a.acc_num
        ) loop
            update medicare_pers_record
            set
                effective_date = x.effective_date,
                effective_end_date = x.effective_end_date
            where
                acc_num = x.acc_num;

        end loop;

        update medicare_pers_record a
        set
            entrp_id = (
                select
                    b.entrp_id
                from
                    account c,
                    person  b
                where
                        a.acc_num = c.acc_num
                    and b.pers_id = c.pers_id
            )
        where
            entrp_id is null;

        update medicare_pers_record a
        set
            ein = (
                select
                    replace(entrp_code, '-')
                from
                    enterprise b
                where
                    a.entrp_id = b.entrp_id
            )
        where
            ein is null;

    end;

    procedure update_tin_result is
        l_pers_id    number;
        l_line_count number := 0;
    begin
        for x in (
            select
                substr(cms_record, 559, 2)     tin_result_code,
                trim(substr(cms_record, 1, 9)) ein,
                cms_record                     line
            from
                cms_external
            where
                trim(substr(cms_record, 1, 9)) is not null
        ) loop
            l_pers_id := null;
            l_line_count := l_line_count + 1;
            if
                l_line_count = 1
                and x.line not like 'H0000038675TGRP%'
            then
                raise_application_error('-20001', 'Not a valid TIN response file');
            end if;

            update medicare_pers_record
            set
                tin_result_code = x.tin_result_code
            where
                ein = x.ein;

        end loop;
    exception
        when others then
            raise;
    end update_tin_result;

    procedure update_msp_result is
        l_pers_id    number;
        l_line_count number := 0;
    begin
        for x in (
            select
                trim(substr(cms_record, 5, 9))    hic_number,
                trim(substr(cms_record, 51, 1))   medicare_reason,
                trim(substr(cms_record, 184, 8))  msp_effective_date,
                trim(substr(cms_record, 192, 8))  msp_termination_date,
                trim(substr(cms_record, 381, 17)) pers_id,
                trim(substr(cms_record, 454, 8))  medicare_eff_date,
                trim(substr(cms_record, 462, 8))  medicare_term_date,
                trim(substr(cms_record, 485, 8))  medicare_a_eff_date,
                trim(substr(cms_record, 493, 8))  medicare_a_term_date,
                trim(substr(cms_record, 501, 8))  medicare_b_eff_date,
                trim(substr(cms_record, 509, 8))  medicare_b_term_date,
                trim(substr(cms_record, 517, 8))  date_of_death,
                trim(substr(cms_record, 530, 8))  medicare_c_eff_date,
                trim(substr(cms_record, 538, 8))  medicare_c_term_date,
                trim(substr(cms_record, 551, 8))  medicare_d_eff_date,
                trim(substr(cms_record, 559, 8))  medicare_d_term_date,
                trim(substr(cms_record, 567, 8))  medicare_d_elig_s_date,
                trim(substr(cms_record, 575, 8))  medicare_d_elig_t_date,
                cms_record                        line
            from
                cms_external
        ) loop
            l_line_count := l_line_count + 1;
            if
                l_line_count = 1
                and x.line not like 'H0000038675MSPR%'
            then
                raise_application_error('-20001', 'Not a valid MSP response file');
            end if;

            l_pers_id := null;
            update medicare_pers_record
            set
                msp_effective_date = x.msp_effective_date,
                msp_termination_date = x.msp_termination_date,
                medicare_reason = x.medicare_reason,
                medicare_eff_date = x.medicare_eff_date,
                medicare_term_date = x.medicare_term_date,
                medicare_a_eff_date = x.medicare_a_eff_date,
                medicare_a_term_date = x.medicare_a_term_date,
                medicare_b_eff_date = x.medicare_b_eff_date,
                medicare_b_term_date = x.medicare_b_term_date,
                date_of_death = x.date_of_death,
                medicare_c_eff_date = x.medicare_c_eff_date,
                medicare_c_term_date = x.medicare_c_term_date,
                medicare_d_eff_date = x.medicare_d_eff_date,
                medicare_d_term_date = x.medicare_d_term_date,
                medicare_d_elig_s_date = x.medicare_d_elig_s_date,
                medicare_d_elig_t_date = x.medicare_d_elig_t_date
            where
                pers_id = x.pers_id;

        end loop;
    exception
        when others then
            raise;
    end update_msp_result;

    procedure update_compliance_result_sent (
        p_ben_plan_id in number,
        p_notice_type in varchar2
    ) is
    begin
        pc_log.log_error('update_compliance_result_sent ', 'p_ben_plan_id'
                                                           || p_ben_plan_id
                                                           || 'p_notice_type'
                                                           || p_notice_type);
        update plan_notices
        set
            result_sent_on = sysdate,
            last_update_date = sysdate,
            last_updated_by = 0,
            notice_sent_on = sysdate
        where
                entity_id = p_ben_plan_id
            and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
            and notice_type = p_notice_type;

        pc_log.log_error('update_compliance_result_sent ', 'rowcount ' || sql%rowcount);
        commit;
    end update_compliance_result_sent;

    procedure update_plan_followup (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2,
        p_notice_type     in varchar2,
        p_user_id         in number
    ) is
        l_count number := 0;
    begin
        pc_log.log_error('P_PLAN_START_DATE ', p_plan_start_date);
        pc_log.log_error('P_PLAN_END_DATE ', p_plan_end_date);
        pc_log.log_error('P_PLAN_TYPE ', p_plan_type);
        pc_log.log_error('P_NOTICE_TYPE ', p_notice_type);
        pc_log.log_error('P_ENTRP_ID ', p_entrp_id);
        update plan_notices
        set
            notice_reminder_on = sysdate
        where
            entity_id in (
                select
                    ben_plan_id
                from
                    ben_plan_enrollment_setup
                where
                        plan_start_date = p_plan_start_date
                    and plan_end_date = p_plan_end_date
                    and entrp_id = p_entrp_id
                    and product_type = p_plan_type
            )
            and notice_type = p_notice_type
            and notice_review_sent is not null;

    end update_plan_followup;

    function get_compliance_data (
        p_ndt_pref     in varchar2,
        p_ndt_type     in varchar2,
        p_product_type in varchar2
    ) return compliance_t
        pipelined
        deterministic
    is
        l_record_t compliance_row_t;
    begin
        for x in (
            select
                b.acc_num,
                b.entrp_id,
                to_char(
                    min(a.plan_start_date),
                    'YYYY'
                )                      plan_start,
                to_char(
                    max(a.plan_end_date),
                    'MM/DD/YYYY'
                )                      plan_end,
                min(a.plan_start_date) plan_start_date,
                max(a.plan_end_date)   plan_end_date
            from
                ben_plan_enrollment_setup a,
                account                   b,
                account_preference        c
            where
                    b.acc_id = c.acc_id
                and rownum = 1
                and nvl(c.ndt_preference, 'BASIC') = p_ndt_pref
                and ( ( p_ndt_type = '1ST_QTR_NDT'
                        and trunc(sysdate) - trunc(a.plan_start_date) >= 90 )
                      or ( p_ndt_type = 'LAST_QTR_NDT'
                           and trunc(a.plan_end_date) - trunc(sysdate) >= 90 ) )
                and trunc(a.plan_end_date) > sysdate
                and a.plan_start_date <= sysdate
                and a.entrp_id = b.entrp_id
                and ( ( p_product_type = 'FSA'
                        and plan_type in ( 'FSA', 'LPF', 'DCA' ) )
                      or ( p_product_type = 'HRA'
                           and product_type = p_product_type ) )
                and nvl(a.non_discrm_flag, 'Y') <> 'N'
                and not exists (
                    select
                        *
                    from
                        plan_notices c
                    where
                            notice_type = p_ndt_type
                        and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP'
                        and c.entity_id = a.ben_plan_id
                )
            group by
                b.acc_num,
                b.entrp_id
        ) loop
            l_record_t.acc_num := x.acc_num;
            l_record_t.entrp_id := x.entrp_id;
            l_record_t.name := pc_entrp.get_entrp_name(x.entrp_id);
            l_record_t.plan_start := x.plan_start;
            l_record_t.plan_end := x.plan_end;
            l_record_t.plan_start_date := x.plan_start_date;
            l_record_t.plan_end_date := x.plan_end_date;
            l_record_t.template_name := pc_lookups.get_meaning(p_product_type
                                                               || '_'
                                                               || p_ndt_pref, 'NDT_TEMPLATE_NAME');

            pipe row ( l_record_t );
        end loop;
    end get_compliance_data;

    procedure export_cms_termed_msp_file (
        x_file_name out varchar2
    ) as

        b_lob          blob;
        l_utl_id       utl_file.file_type;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_line_tbl     varchar2_4000_tbl;
        l_line_count   number := 0;
        l_dest_blob    blob;
        l_src_offset   number := 1;
        l_dest_offset  number := 1;
        l_src_osin     number;
        l_dst_osin     number;
        l_rreid        varchar2(255) := '000038675';
        l_source_bfile bfile := bfilename('DEBIT_CARD_DIR',
                                          'CMS_MSP_'
                                          || to_char(sysdate, 'mmddyyyyhhmiss')
                                          || '.txt');
    begin
  -- followed guidelines from the link
  -- http://www.cms.gov/Medicare/Coordination-of-Benefits-and-Recovery/Mandatory-Insurer-Reporting-For-Group-Health-Plans/Downloads/New-Downloads/MMSEA-Revised-July-14-2014-GHP-User-Guide-Version-4-4.pdf
        l_file_name := 'CMS_TERMED_MSP_'
                       || to_char(sysdate, 'mmddyyyyhhmiss')
                       || '.txt';
        l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
        l_line := 'H0'
                  || l_rreid
                  || 'MSPI'
                  || to_char(sysdate, 'YYYYMMDD')
                  || lpad(' ', 402, ' ');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select
                rpad(
                    nvl(a.hic_number, ' '),
                    12,
                    ' '
                )              -- HIC Number (12)
                || rpad(
                    substr(b.last_name, 1, 6),
                    6,
                    ' '
                )           -- Sur name (6)
                || substr(b.first_name, 1, 1)                      -- First name (1)
                || rpad(
                    nvl(
                        to_char(b.birth_date, 'YYYYMMDD'),
                        ' '
                    ),
                    8,
                    ' '
                )              -- Birth Date (8)
                || decode(b.gender, 'M', '1', 'F', '2',
                          '0')          -- Sex (1)
                || rpad(
                    nvl(a.cms_doc_crl_number, ' '),
                    15,
                    ' '
                )             -- DCN (15)
                || '1'                                           -- Transaction Type (1)
                || 'R'                                           -- Coverage Type (1)
                || rpad(
                    replace(b.ssn, '-'),
                    9,
                    ' '
                )                -- SSN (9)
                || to_char(a.effective_date, 'YYYYMMDD')          -- Effective Date (8)
                || nvl(
                    to_char(a.effective_end_date, 'YYYYMMDD'),
                    '00000000'
                ) -- Termination Date (8)
                || '01'                                           -- Relationship Code (2)
                || rpad(
                    substr(b.first_name, 1, 9),
                    9,
                    ' '
                )           -- Policy Holder's First Name  (9)
                || rpad(
                    substr(b.last_name, 1, 16),
                    16,
                    ' '
                )         -- Policy Holder's Last Name  (16)
                || rpad(
                    replace(b.ssn, '-'),
                    9,
                    ' '
                )                -- Policy Holder's SSN  (9)
                ||
                case
                        when pc_entrp.count_person(b.entrp_id) < 20              then
                            '0'
                        when pc_entrp.count_person(b.entrp_id) between 20 and 99 then
                            '1'
                        else
                            '2'
                end        -- Employer Size(1)
                || rpad(
                    nvl(
                        to_char(b.entrp_id),
                        ' '
                    ),
                    20,
                    ' '
                )      -- Group Policy Number(1)
                || rpad(b.pers_id, 17, ' ')                         -- Individual Policy Number(1)
                || '1'                                            -- Subscriber Only (1)
                || '1'                                            -- Employee Status (1)
                || rpad(
                    replace(
                        pc_entrp.get_tax_id(b.entrp_id),
                        '-'
                    ),
                    9,
                    ' '
                ) -- TIN (9)
                || '841637046' line                               -- TPA TIN (9)
            from
                medicare_pers_record a,
                person               b
            where
                    a.pers_id = b.pers_id
                and b.pers_main is null
                and a.tin_result_code is not null
                and a.effective_end_date is not null
            union
            select
                rpad(
                    nvl(a.hic_number, ' '),
                    12,
                    ' '
                )                       -- HIC Number (12)
                || rpad(
                    substr(b.last_name, 1, 6),
                    6,
                    ' '
                )             -- Sur name (6)
                || substr(b.first_name, 1, 1)                        -- First name (1)
                || rpad(
                    nvl(
                        to_char(b.birth_date, 'YYYYMMDD'),
                        ' '
                    ),
                    8,
                    ' '
                )                -- Birth Date (8)
                || decode(b.gender, 'M', '1', 'F', '2',
                          '0')           -- Sex (1)
                || rpad(
                    nvl(a.cms_doc_crl_number, ' '),
                    15,
                    ' '
                )               -- DCN (15)
                || '1'                                           --- Transaction Type (1)
                || 'R'                                           --- Coverage Type (1)
                || rpad(
                    nvl(
                        replace(b.ssn, '-'),
                        ' '
                    ),
                    9,
                    ' '
                )                  -- SSN (9)
                || to_char(a.effective_date, 'YYYYMMDD')           -- Effective Date (8)
                || nvl(
                    to_char(a.effective_end_date, 'YYYYMMDD'),
                    '00000000'
                ) -- Termination Date (8)
                || lpad(
                    nvl(b.relat_code, '04'),
                    2,
                    '0'
                )              -- Relationship Code (2)
                || rpad(
                    substr(c.first_name, 1, 9),
                    9,
                    ' '
                )            -- Policy Holder's First Name  (9)
                || rpad(
                    substr(c.last_name, 1, 16),
                    16,
                    ' '
                )          -- Policy Holder's Last Name  (16)
                || rpad(
                    nvl(
                        replace(c.ssn, '-'),
                        ' '
                    ),
                    9,
                    ' '
                )                 -- Policy Holder's SSN  (9)
                ||
                case
                        when pc_entrp.count_person(c.entrp_id) < 20              then
                            '0'
                        when pc_entrp.count_person(c.entrp_id) between 20 and 99 then
                            '1'
                        else
                            '2'
                end                      -- Employer Size(1)
                || rpad(
                    nvl(
                        to_char(c.entrp_id),
                        ' '
                    ),
                    20,
                    ' '
                )      -- Group Policy Number(1)
                || rpad(b.pers_id, 17, ' ')                          -- Individual Policy Number(1)
                || '1'                                             -- Subscriber Only (1)
                || '1'                                             -- Employee Status (1)
                || rpad(
                    replace(
                        pc_entrp.get_tax_id(c.entrp_id),
                        '-'
                    ),
                    9,
                    ' '
                ) -- TIN (9)
                || '841637046'                                      -- TPA TIN (9)
            from
                medicare_pers_record a,
                person               b,
                person               c
            where
                    a.pers_id = b.pers_id
                and b.pers_main is not null
                and a.effective_end_date is not null
                and a.tin_result_code is not null
                and b.pers_main = c.pers_id
            union
            select distinct
                rpad(
                    nvl(a.hic_number, ' '),
                    12,
                    ' '
                )              -- HIC Number (12)
                || rpad(
                    substr(b.last_name, 1, 6),
                    6,
                    ' '
                )           -- Sur name (6)
                || substr(b.first_name, 1, 1)                      -- First name (1)
                || rpad(
                    nvl(
                        to_char(b.birth_date, 'YYYYMMDD'),
                        ' '
                    ),
                    8,
                    ' '
                )              -- Birth Date (8)
                || decode(b.gender, 'M', '1', 'F', '2',
                          '0')          -- Sex (1)
                || rpad(
                    nvl(a.cms_doc_crl_number, ' '),
                    15,
                    ' '
                )             -- DCN (15)
                || '1'                                           -- Transaction Type (1)
                || 'R'                                           -- Coverage Type (1)
                || rpad(
                    replace(b.ssn, '-'),
                    9,
                    ' '
                )                -- SSN (9)
                || to_char(a.effective_date, 'YYYYMMDD')          -- Effective Date (8)
                || nvl(
                    to_char(a.effective_date, 'YYYYMMDD'),
                    '00000000'
                ) -- Termination Date (8)
                || '01'                                           -- Relationship Code (2)
                || rpad(
                    substr(b.first_name, 1, 9),
                    9,
                    ' '
                )           -- Policy Holder's First Name  (9)
                || rpad(
                    substr(b.last_name, 1, 16),
                    16,
                    ' '
                )         -- Policy Holder's Last Name  (16)
                || rpad(
                    replace(b.ssn, '-'),
                    9,
                    ' '
                )                -- Policy Holder's SSN  (9)
                ||
                case
                        when pc_entrp.count_person(b.entrp_id) < 20              then
                            '0'
                        when pc_entrp.count_person(b.entrp_id) between 20 and 99 then
                            '1'
                        else
                            '2'
                end        -- Employer Size(1)
                || rpad(
                    nvl(
                        to_char(b.entrp_id),
                        ' '
                    ),
                    20,
                    ' '
                )      -- Group Policy Number(1)
                || rpad(b.pers_id, 17, ' ')                         -- Individual Policy Number(1)
                || '1'                                            -- Subscriber Only (1)
                || '1'                                            -- Employee Status (1)
                || rpad(
                    replace(
                        pc_entrp.get_tax_id(b.entrp_id),
                        '-'
                    ),
                    9,
                    ' '
                ) -- TIN (9)
                || '841637046' line                               -- TPA TIN (9)
            from
                medicare_pers_record      a,
                person                    b,
                account                   c,
                ben_plan_enrollment_setup bp,
                ben_plan_enrollment_setup er
            where
                    a.pers_id = b.pers_id
                and b.pers_main is null
                and a.tin_result_code is not null
                and er.is_cms_opted = 'Y'
                and bp.plan_end_date > a.effective_date
                and a.acc_num = c.acc_num
                and c.acc_id = bp.acc_id
                and bp.ben_plan_id_main = er.ben_plan_id
            union
            select distinct
                rpad(
                    nvl(a.hic_number, ' '),
                    12,
                    ' '
                )              -- HIC Number (12)
                || rpad(
                    substr(b.last_name, 1, 6),
                    6,
                    ' '
                )           -- Sur name (6)
                || substr(b.first_name, 1, 1)                      -- First name (1)
                || rpad(
                    nvl(
                        to_char(b.birth_date, 'YYYYMMDD'),
                        ' '
                    ),
                    8,
                    ' '
                )              -- Birth Date (8)
                || decode(b.gender, 'M', '1', 'F', '2',
                          '0')          -- Sex (1)
                || rpad(
                    nvl(a.cms_doc_crl_number, ' '),
                    15,
                    ' '
                )             -- DCN (15)
                || '1'                                           -- Transaction Type (1)
                || 'R'                                           -- Coverage Type (1)
                || rpad(
                    replace(b.ssn, '-'),
                    9,
                    ' '
                )                -- SSN (9)
                || to_char(a.effective_date, 'YYYYMMDD')          -- Effective Date (8)
                || nvl(
                    to_char(a.effective_date, 'YYYYMMDD'),
                    '00000000'
                ) -- Termination Date (8)
                || '01'                                           -- Relationship Code (2)
                || rpad(
                    substr(d.first_name, 1, 9),
                    9,
                    ' '
                )           -- Policy Holder's First Name  (9)
                || rpad(
                    substr(d.last_name, 1, 16),
                    16,
                    ' '
                )         -- Policy Holder's Last Name  (16)
                || rpad(
                    replace(b.ssn, '-'),
                    9,
                    ' '
                )                -- Policy Holder's SSN  (9)
                ||
                case
                        when pc_entrp.count_person(b.entrp_id) < 20              then
                            '0'
                        when pc_entrp.count_person(b.entrp_id) between 20 and 99 then
                            '1'
                        else
                            '2'
                end        -- Employer Size(1)
                || rpad(
                    nvl(
                        to_char(b.entrp_id),
                        ' '
                    ),
                    20,
                    ' '
                )      -- Group Policy Number(1)
                || rpad(d.pers_id, 17, ' ')                         -- Individual Policy Number(1)
                || '1'                                            -- Subscriber Only (1)
                || '1'                                            -- Employee Status (1)
                || rpad(
                    replace(
                        pc_entrp.get_tax_id(b.entrp_id),
                        '-'
                    ),
                    9,
                    ' '
                ) -- TIN (9)
                || '841637046' line                               -- TPA TIN (9)
            from
                medicare_pers_record      a,
                person                    b,
                account                   c,
                ben_plan_enrollment_setup bp,
                ben_plan_enrollment_setup er,
                person                    d
            where
                    a.pers_id = b.pers_id
                and b.pers_main is null
                and a.tin_result_code is not null
                and er.is_cms_opted = 'Y'
                and b.pers_main = d.pers_id
                and bp.plan_end_date > a.effective_date
                and a.acc_num = c.acc_num
                and c.acc_id = bp.acc_id
                and bp.ben_plan_id_main = er.ben_plan_id
        ) loop
            l_line := substr(
                rpad(x.line, 424, ' '),
                1,
                424
            );

            l_line_count := l_line_count + 1;
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := 'T0'
                  || l_rreid
                  || 'MSPI'
                  || to_char(sysdate, 'YYYYMMDD')
                  || lpad(l_line_count, 9, '0')
                  || lpad(' ', 393, ' ');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        utl_file.fclose(file => l_utl_id);
        if l_line_count > 0 then
            x_file_name := l_file_name;
        end if;
    exception
        when others then
            htp.p(sqlerrm
                  || '...'
                  || dbms_utility.format_error_backtrace);
    end export_cms_termed_msp_file;

end pc_compliance;
/

