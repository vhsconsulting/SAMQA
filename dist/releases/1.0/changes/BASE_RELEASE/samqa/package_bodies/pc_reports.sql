-- liquibase formatted sql
-- changeset SAMQA:1754374076574 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_reports.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_reports.sql:null:3a11a68b96a322c030e3fcc29b23a5d8c3b431eb:create

create or replace package body samqa.pc_reports as

    function get_last_payment_info (
        p_entrp_id   in number,
        p_start_date varchar2,
        p_end_date   varchar2
    ) return sys_refcursor is
        thecursor sys_refcursor;
    begin
        open thecursor for select
                                                  (
                                                      json_object(
                                                          key 'member_id' value a.orig_sys_vendor_ref,
                                                          key 'acc_id' value c.acc_id,
                                                          key 'depositdate' value c.depositdate,
                                                          key 'paid_amount' value c.paid_amount,
                                                          key 'Note ' value c.note
                                                      )
                                                  ) last_payment_info
                                              from
                                                  person         a,
                                                  account        b,
                                                  cobra_premiums c
                           where
                                   a.pers_id = b.pers_id
                               and c.acc_id = b.acc_id
                               and a.entrp_id = p_entrp_id
                               and c.depositdate >= to_date(p_start_date, 'mm/dd/yyyy')
                               and c.depositdate <= to_date(p_end_date, 'mm/dd/yyyy');

        return thecursor;
    end;

    function get_qb_plan_info (
        p_entrp_id   in number,
        p_start_date varchar2,
        p_end_date   varchar2
    ) return sys_refcursor is
        thecursor sys_refcursor;
    begin
        open thecursor for select
                                                  a.entrp_id entrp_id,
                                                  json_arrayagg(
                                                      json_object(    --- KEY  'member_id' value  d.Orig_Sys_Vendor_Ref ,
                                                          key 'Plan_Name' value c.plan_name,
                                                          key 'Insurence_type' value c.plan_type,
                                                          key 'Plan_Number' value c.plan_number,
                                                          key 'Policy_Number' value c.policy_number,
                                                          key 'Governing_State' value c.governing_state,
                                                                  key 'Plan_Start_Date' value c.plan_start_date,
                                                          key 'Plan_End_Date' value c.plan_end_date,
                                                          key 'Carrier_Contact_Name' value c.carrier_contact_name,
                                                          key 'Carrier_Contact_Email' value c.carrier_contact_email,
                                                          key 'Carrier_Phone_No' value c.carrier_phone_no,
                                                                  key 'Carrier_Addr' value c.carrier_addr,
                                                          key 'Carrier_Name' value c.carrier_name,
                                                          key 'Plan_Effective_Date' value c.plan_effective_date,
                                                          key 'Coverage_Start_Date' value a.coverage_start_date,
                                                          key 'Coverage_End_Date' value a.coverage_end_date,
                                                                  key 'Coverage_Eff_Date' value a.coverage_eff_date,
                                                          key 'Months_Of_Cobra' value a.months_of_cobra,
                                                          key 'Days_To_Elect' value a.days_to_elect,
                                                          key 'First_Premium_Due_Days' value a.first_premium_due_days,
                                                          key 'Next_Premium_Due_Days' value a.next_premium_due_days,
                                                                  key 'status' value a.status,
                                                          key 'Status_Date' value a.status_date,
                                                          key 'Election_Postmark_Date' value a.election_postmark_date,
                                                          key 'Premium_Amount' value a.premium_amount
                                                      )
                                                  )          plan_info
                                              from
                                                  plan_elections a,
                                                  enterprise     b,
                                                  cobra_plans    c,
                                                  person         d
                           where
                                   a.entrp_id = p_entrp_id
                               and a.entrp_id = b.entrp_id
                               and a.pers_id = d.pers_id
                               and a.cobra_plan_id = c.cobra_plan_id
                               and a.coverage_start_date >= to_date(p_start_date, 'mm/dd/yyyy')
                               and a.coverage_end_date <= to_date(p_end_date, 'mm/dd/yyyy')
                           group by
                               a.entrp_id;

        return thecursor;
    end;

    function get_qb_dependent_member_info (
        p_entrp_id         in number,
        p_event_start_date varchar2,
        p_event_end_date   varchar2
    ) return sys_refcursor is
        thecursor sys_refcursor;
    begin
        open thecursor for select
                                                  c.name          client_name,
                                                  d.division_name division_name,
                                                  json_arrayagg((
                                                      json_object(
                                                          key 'Entrp_id' value d.entrp_id,
                                                                  key 'Member_id' value b.orig_sys_vendor_ref,
                                                                  key 'full_name' value b.full_name,
                                                               ---   Key 'Member_id'  value b.ssn ,
                                                                ---  Key 'Client_Name'   value  c.Name ,
                                                                  key 'SSN' value b.ssn,
                                                                  key 'Relation' value pc_lookups.get_meaning(b.relat_code, 'RELATIVE'
                                                                  ),
                                                           ---       Key 'Client_Name' Value   c.Name ,
                                                          ----          Key 'division_name' Value d.division_name,
                                                                  key 'masked_ssn' value b.masked_ssn,
                                                                  key 'gender' value decode(b.gender, 'M', 'Male', 'F', 'Female',
                                                                                            null),
                                                                  key 'Birth_Date' value b.birth_date,
                                                                  key 'Address' value b.address,
                                                                  key 'address2' value b.address2,
                                                                  key 'City' value b.city,
                                                                  key 'State' value b.state,
                                                                  key 'postal_code' value b.zip,
                                                                  key 'City' value b.city,
                                                                  key 'Phone_Day' value b.phone_day,
                                                                  key 'Phone_Even' value b.phone_even,
                                                                  key 'b.Email' value b.email,
                                                                  key 'event_type' value a.event_type,
                                                                  key 'event_entity' value a.event_entity,
                                                                  key 'Qualifying_event_date' value a.event_date,
                                                                  key 'event_type' value a.event_type
                                                      )
                                                  ))              qb_member_info
                                              from
                                                  qualifying_event     a,
                                                  person               b,
                                                  enterprise           c,
                                                  employer_divisions   d,
                                                  newcobra.qb_master_v e
                           where
                                   a.pers_id = e.pers_id
                               and e.pers_id = b.pers_main
                               and nvl(b.division_code, '*') = d.division_code
                               and b.entrp_id = c.entrp_id
                               and c.entrp_id = d.entrp_id
                               and event_date >= to_date(p_event_start_date, 'mm/dd/yyyy')
                               and event_date <= to_date(p_event_end_date, 'mm/dd/yyyy')
                               and c.entrp_id = p_entrp_id;

        return thecursor;
    end;

    function get_qb_member_info (
        p_entrp_id         in number,
        p_event_start_date varchar2,
        p_event_end_date   varchar2
    ) return sys_refcursor is
        thecursor sys_refcursor;
    begin
        open thecursor for select
                                                  (
                                                      json_object(
                                                          key 'Entrp_id' value d.entrp_id,
                                                                  key 'Member_id' value b.orig_sys_vendor_ref,
                                                                  key 'full_name' value b.full_name,
                                                                  key 'Member_id' value b.ssn,
                                                                  key 'Client_Name' value c.name,
                                                                  key 'SSN' value b.ssn,
                                                                  key 'Client_Name' value c.name,
                                                                  key 'division_name' value d.division_name,
                                                                  key 'masked_ssn' value b.masked_ssn,
                                                                  key 'gender' value decode(gender, 'M', 'Male', 'F', 'Female',
                                                                                            null),
                                                                  key 'Birth_Date' value b.birth_date,
                                                                  key 'Address' value b.address,
                                                                  key 'address2' value b.address2,
                                                                  key 'City' value b.city,
                                                                  key 'State' value b.state,
                                                                  key 'postal_code' value b.zip,
                                                                  key 'City' value b.city,
                                                                  key 'Phone_Day' value b.phone_day,
                                                                  key 'Phone_Even' value b.phone_even,
                                                                  key 'b.Email' value b.email,
                                                                  key 'event_type' value a.event_type,
                                                                  key 'event_entity' value a.event_entity,
                                                                  key 'Qualifying_event_date' value a.event_date,
                                                                  key 'event_type' value a.event_type
                                                      )
                                                  ) qb_member_info
                                              from
                                                  qualifying_event   a,
                                                  person             b,
                                                  enterprise         c,
                                                  employer_divisions d
                           where
                                   a.pers_id = b.pers_id
                               and nvl(b.division_code, '*') = d.division_code
                               and b.entrp_id = c.entrp_id
                               and c.entrp_id = d.entrp_id
                               and event_date >= to_date(p_event_start_date, 'mm/dd/yyyy')
                               and event_date <= to_date(p_event_end_date, 'mm/dd/yyyy')
                               and c.entrp_id = p_entrp_id;

        return thecursor;
    end;

    function plan_status (
        p_plan_type in varchar2,
        p_pers_id   in number
    ) return varchar2 is
        l_status varchar2(20);
    begin
        select
            a.status
        into l_status
        from
            plan_elections a,
            cobra_plans    b
        where
                a.pers_id = p_pers_id
            and a.cobra_plan_id = b.cobra_plan_id
            and b.plan_type = p_plan_type
            and rownum < 2;

        return l_status;
    end plan_status;

    function get_plan_rate_renewal_report (
        p_entrp_id in number
    ) return sys_refcursor is
        thecursor sys_refcursor;
    begin
        open thecursor for select
                                                  (
                                                      json_object(
                                                          key 'Entrp_id' value a.entrp_id,
                                                          key 'Client_name' value a.name,
                                                          key 'division_name' value d.division_name,
                                                          key 'client_address' value a.address,
                                                          key 'client_city' value a.city,
                                                                  key 'client_state' value a.state,
                                                          key 'carrier_name' value b.carrier_name,
                                                          key 'carrier_contact_name' value b.carrier_contact_name,
                                                          key 'carrier_contact_email' value b.carrier_contact_email,
                                                          key 'carrier_phone_no' value b.carrier_phone_no,
                                                                  key 'plan_number' value b.plan_number,
                                                          key 'plan_type' value b.plan_type,
                                                          key 'plan_name' value b.plan_name,
                                                          key 'effective_date' value c.effective_date,
                                                          key 'end_Date' value c.end_date,
                                                                  key 'renewal_date' value c.renewal_date,
                                                          key 'address1' value d.address1,
                                                          key 'address2' value d.address2,
                                                          key 'city' value d.city,
                                                          key 'zip' value d.zip,
                                                                  key 'phone' value d.phone
                                                      )
                                                  ) plan_rate_renewal_report
                                              from
                                                  enterprise         a,
                                                  cobra_plans        b,
                                                  cobra_plan_rates   c,
                                                  employer_divisions d
                           where
                                   a.entrp_id = b.entrp_id
                               and b.cobra_plan_id = c.cobra_plan_id
                               and b.entrp_id = p_entrp_id
                               and a.entrp_id = d.entrp_id (+);

        return thecursor;
    end;

    function get_generated_letters_detail_report (
        p_entrp_id in number
    ) return sys_refcursor is
        thecursor sys_refcursor;
    begin
        open thecursor for select
                                                  (
                                                      json_object(
                                                          key 'client_name' value b.name,
                                                                  key 'member_id' value a.memberid,
                                                                  key 'dependent_Id' value a.dependentid,
                                                                  key 'pdf_Generated_time' value a.datetime,
                                                                  key 'description' value a.description,
                                                                  key 'entity_type_desc' value decode(a.dependentid, null, 'QB', 'Dependent'
                                                                  ),
                                                                  key 'Addressee' value c.full_name
                                                      )
                                                  ) generated_letters_detail
                                              from
                                                  qbcommunication a,
                                                  enterprise      b,
                                                  person          c
                           where
                                   c.orig_sys_vendor_ref = to_char(a.memberid)
                               and b.entrp_id = c.entrp_id
                               and b.entrp_id = p_entrp_id;

        return thecursor;
    end;

    function get_generated_letters_summary_report (
        p_entrp_id in number
    ) return sys_refcursor is
        thecursor sys_refcursor;
    begin
        open thecursor for select
                                                  (
                                                      json_object(
                                                          key 'client_name' value b.name,
                                                                  key 'Report_name' value a.description,
                                                                  key 'division_name' value(
                                                              select
                                                                  division_name
                                                              from
                                                                  employer_divisions z
                                                              where
                                                                      z.division_code = c.division_code
                                                                  and rownum < 2
                                                          ),
                                                                  key 'lettersent' value count(a.lettersent)
                                                      )
                                                  ) generated_letters_summary
                                              from
                                                  qbcommunication a,
                                                  enterprise      b,
                                                  person          c
                           where
                                   c.orig_sys_vendor_ref = to_char(a.memberid)
                               and b.entrp_id = c.entrp_id
                               and b.entrp_id = p_entrp_id
                           group by
                               a.description,
                               b.name,
                               c.division_code;

        return thecursor;
    end;

    function get_paid_through_report (
        p_entrp_id   in number,
        p_start_date varchar2,
        p_end_date   varchar2
    )
----FUNCTION Get_Paid_through_Report ( p_entrp_id   in Number,  )
     return sys_refcursor is
        thecursor sys_refcursor;
        l_acc_num varchar2(30) := null;
    begin
        open thecursor for select
                                                  (
                                                      json_object(
                                                          key 'client_name' value b.name,
                                                                  key 'division_code' value a.division_code,
                                                                  key 'acc_num' value e.acc_num,
                                                                  key 'Birth_Date' value to_char(a.birth_date, 'MM/DD/YYYY'),
                                                                  key 'Title' value a.title,
                                                                  key 'Gender' value a.gender,
                                                                  key 'masked_ssn' value a.masked_ssn,
                                 ---KEY  'Ssn' VALUE    a.Ssn  ,
                                                                  key 'Address' value a.address,
                                                                  key 'City' value a.city,
                                                                  key 'State' value a.state,
                                ---  key 'PERS_ID'         VALUE  a.pers_id
                                                                  key 'person_name' value a.full_name,
                                                                  key 'divison_name' value pc_employer_divisions.get_division_name(a.division_code
                                                                  , a.entrp_id),
                                                                  key 'paid_thru_date' value to_char(
                                                              pc_premium.get_paid_thru_date(e.acc_id),
                                                              'MM/DD/YYYY'
                                                          ),
                                                                  key 'event_date' value to_char(c.event_date, 'MM/DD/YYYY'),
                                                                  key 'sales_rep' value pc_sales_team.get_cust_srvc_rep_name_for_er(b.entrp_id
                                                                  ),
                                                                  key 'last_day_of_COBRA' value(
                                                              select
                                                                  max(last_day_of_cobra)
                                                              from
                                                                  plan_elections pe
                                                              where
                                                                  a.pers_id = pe.pers_id
                                                          )
                                                      )
                                                  ) get_paid_through
                                              from
                                                  person           a,
                                                  enterprise       b,
                                                  qualifying_event c,
                                                  account          e
                           where
                                   a.entrp_id = p_entrp_id
                               and a.pers_id = e.pers_id
                               and a.entrp_id = b.entrp_id
                               and c.pers_id = a.pers_id
                               and exists (
                                   select
                                       *
                                   from
                                       plan_elections g
                                   where
                                           g.pers_id = a.pers_id
                                       and g.status = 'E'
                               )
                               and trunc(pc_premium.get_paid_thru_date(e.acc_id)) between to_date(p_start_date, 'MM/DD/YYYY') and to_date
                               (p_end_date, 'MM/DD/YYYY');

        return thecursor;
    end;

    function get_carrier_notifications_report (
        p_entrp_id in number
    ) return sys_refcursor is
        thecursor sys_refcursor;
        l_acc_num varchar2(30) := null;
    begin
        open thecursor for select
                                                  (
                                                      json_object(
                                                          key 'er_acc_num' value e.acc_num,
                                                          key 'Carrier_Name' value cariier_name,
                                                          key 'Cariier_Name' value cariier_name,
                                                          key 'Carrier_Contact_Email' value carrier_contact_email,
                                                          key 'Carrier_Phone_No' value carrier_phone_no,
                                                                  key 'Carrier_Addr' value carrier_addr,
                                                          key 'EE acc_num' value b.acc_num,
                                                          key 'full_name' value b.first_name
                                                                                || ' '
                                                                                || b.last_name,
                                                          key 'birth_Date' value b.birth_date,
                                                          key 'gender' value b.gender,
                                                                  key 'ssn' value ssn,
                                                          key 'masked_ssn' value b.masked_ssn,
                                                          key 'address' value b.address,
                                                          key 'city' value b.city,
                                                          key 'phone_Day' value b.phone_day,
                                                                  key 'phone_even' value b.phone_even,
                                                          key 'email' value b.email,
                                                          key 'note' value b.note,
                                                          key 'hire_date' value b.hire_date,
                                                          key 'Employer_Name' value d.name,
                                                                  key 'Tax_Id' value d.entrp_code,
                                                          key 'Address_er' value d.address,
                                                          key 'City_er' value d.city,
                                                          key 'State_er' value d.state,
                                                          key 'phone_even' value b.phone_even,
                                                                  key 'Zip_Er' value d.zip,
                                                          key 'Entrp_Contact' value d.entrp_contact,
                                                          key 'Entrp_Phones' value d.entrp_phones,
                                                          key 'Entrp_Email' value d.entrp_email,
                                                          key 'email' value b.email,
                                                                  key 'Note_er' value d.note
                                                      )
                                                  ) carrier_notifications
                                              from
                                                  carrier_notification a,
                                                  qb_master_v          b,
                                                  enterprise           d,
                                                  account              e
                           where
                                   a.entrp_id = b.entrp_id
                               and d.entrp_id = a.entrp_id
                               and a.entity_id is not null
                               and e.entrp_id = d.entrp_id
                               and e.entrp_id = p_entrp_id;
                                              ----        and e.acc_num Like  nvl( :P6_ACC_NUM, e.acc_num)

        return thecursor;
    end get_carrier_notifications_report;

    function get_ben_plan_report (
        p_entrp_id        in number,
        p_plan_start_date date,
        p_end_date        date
    ) return sys_refcursor is
        thecursor sys_refcursor;
        l_acc_num varchar2(30) := null;
    begin
        open thecursor for select
                                                  (
                                                      json_object(
                                                          key 'Employer_name' value a.name,
                                                          key 'Tax_id' value a.entrp_code,
                                                          key ', a.address' value a.address,
                                                          key 'city' value a.city,
                                                          key ' State' value a.state,
                                                                  key ' QB_Name' value d.full_name,
                                                          key ' SSN' value d.ssn,
                                                          key 'Member_id' value d.orig_sys_vendor_ref,
                                                          key ' Plan_Name' value b.plan_name,
                                                          key ' Plan_type' value b.plan_type,
                                                                  key '  governing_State' value b.governing_state,
                                                          key ' plan_Start_Date' value b.plan_start_date,
                                                          key ' plan_End_Date' value b.plan_end_date,
                                                          key ' event_id' value c.event_id,
                                                          key ' coverage_level' value c.coverage_level,
                                                                  key ' status' value c.status,
                                                          key ' termination_Date' value c.termination_date,
                                                          key ' Premium_Amount' value c.premium_amount
                                                      )
                                                  ) qb_ben_plan
                                              from
                                                  enterprise     a,
                                                  cobra_plans    b,
                                                  plan_elections c,
                                                  person         d
                           where
                                   a.entrp_id = b.entrp_id
                               and b.cobra_plan_id = c.cobra_plan_id
                               and d.pers_id = c.pers_id
                               and b.plan_start_date between nvl(p_plan_start_date, b.plan_start_date) and nvl(p_end_date, b.plan_start_date
                               )
                               and a.entrp_id = p_entrp_id;

        return thecursor;
    end get_ben_plan_report;

    function get_qb_summary_report (
        p_entrp_id   in number,
        p_start_date varchar2,
        p_end_date   varchar2,
        p_status     varchar2
    ) return sys_refcursor is
        thecursor sys_refcursor;
        l_acc_num varchar2(30) := null;
    begin
        begin
            select
                acc_num
            into l_acc_num
            from
                account
            where
                entrp_id = p_entrp_id;

        exception
            when no_data_found then
                l_acc_num := null;
        end;

        if l_acc_num is not null then
            open thecursor for select
                                                      (
                                                          json_object(
                                                              key 'acc_num' value f.acc_num,
                                                                      key 'Member_id' value b.orig_sys_vendor_ref,
                                                                      key 'SSN' value format_ssn(b.ssn),
                                                                      key 'Birth_date' value to_char(b.birth_date, 'MM/DD/YYYY'),
                                                                      key 'Name' value b.full_name,
                                                                      key 'ER_NAME' value d.name,
                                                                      key 'Gender' value nvl(
                                                                  pc_lookups.get_meaning(gender, 'GENDER'),
                                                                  'Male'
                                                              ),
                                                                      key 'Address' value max(b.address
                                                                                              || ' , '
                                                                                              || b.city
                                                                                              || ' , '
                                                                                              || b.state
                                                                                              || ' , '
                                                                                              || b.zip),
                                                                      key 'Phone' value b.phone_day,
                                                                      key 'Email' value b.email,
                                                                      key 'Send_General_Right_Letter' value b.send_general_right_letter
                                                                      ,
                                                                      key 'Election_Date' value election_date,
                                                                      key 'Insurance_Type' value insurance_type,
                                                                      key 'Employee_Type' value max(employee_type),
                                                                      key 'Plan_Name' value a.plan_name,
                                                                      key 'Division_Name' value c.division_name,
                                                                      key 'Termination_Date' value to_char(e.termination_date, 'MM/DD/YYYY'
                                                                      ),
                                     --            KEY  'No_Of_Emp_Terminated' VALUE    Count( B.Pers_Id)  ,
                                                                      key 'Status' value regexp_replace(
                                                                  listagg(pc_lookups.get_meaning(e.status, 'COBRA_ELECTION_STATUS'),
                                                                          ',') within group(
                                                                  order by
                                                                      e.status
                                                                  ),
                                                                  '([^,]+)(,\1)+',
                                                                  '\1')
                                                          )
                                                      ) qb_summary
                                                  from
                                                      cobra_plans        a,
                                                      person             b,
                                                      employer_divisions c,
                                                      enterprise         d,
                                                      plan_elections     e,
                                                      account            f
                               where
                                       a.entrp_id = b.entrp_id
                                   and c.division_id (+) = a.division_id
                                   and a.entrp_id = d.entrp_id
                                   and d.entrp_id = p_entrp_id
                                   and e.cobra_plan_id = a.cobra_plan_id
                                   and e.status = nvl(p_status, e.status)
                                   and b.pers_id = e.pers_id --- rprabu 06/06/2022
                                   and b.pers_id = f.pers_id   --- rprabu 06/06/2022
                               group by
                                   f.acc_num,
                                   b.orig_sys_vendor_ref,
                                   b.ssn,
                                   b.birth_date,
                                   b.full_name,
                                   d.name,
                                   b.gender,
                                   b.phone_day,
                                   b.email,
                                   b.send_general_right_letter,
                                   e.election_date,
                                   e.insurance_type,
                                   a.plan_name,
                                   c.division_name,
                                   termination_date;

        elsif l_acc_num is null then
            open thecursor for select
                                                      (
                                                          json_object(
                                                              key 'entrp_id' value d.entrp_id,
                                                                      key 'Name' value d.name,
                                                                      key 'Division_Name' value c.division_name,
                                                                      key 'Termination_Date' value e.termination_date,
                                                                      key 'No_Of_Emp_Terminated' value count(b.pers_id),
                                                                      key 'Status' value regexp_replace(
                                                                  listagg(e.status, ',') within group(
                                                                  order by
                                                                      e.status
                                                                  ),
                                                                  '([^,]+)(,\1)+',
                                                                  '\1')
                                                          )
                                                      ) qb_summary
                                                  from
                                                      cobra_plans        a,
                                                      person             b,
                                                      employer_divisions c,
                                                      enterprise         d,
                                                      plan_elections     e
                               where
                                       a.entrp_id = b.entrp_id
                                   and c.division_id (+) = a.division_id
                                   and a.entrp_id = d.entrp_id
                                   and d.entrp_id = p_entrp_id
                                   and b.pers_id = e.pers_id
                               group by
                                   d.entrp_id,
                                   d.name,
                                   c.division_name,
                                   termination_date;

        end if;

        return thecursor;
    end get_qb_summary_report;

    function get_qb_plan_members (
        p_acc_num          in varchar2,
        p_event_start_date varchar2,
        p_event_end_date   varchar2
    ) return sys_refcursor is
        thecursor sys_refcursor;
    begin
        open thecursor for select
                                                  (
                                                      json_object(
                                                          key 'acc_num' value d.acc_num,
                                                                  key 'name' value a.first_name
                                                                                   || ' '
                                                                                   || last_name,
                                                                  key 'SSN' value a.ssn,
                                                                  key 'ER_name' value c.name,
                                                                  key 'coverage_Eff_Date' value to_char(b.coverage_eff_date, 'MM/DD/YYYY'
                                                                  ),
                                                                  key 'coverage_start_Date' value to_char(b.coverage_start_date, 'MM/DD/YYYY'
                                                                  ),
                                                                  key 'coverage_End_Date' value to_char(b.coverage_end_date, 'MM/DD/YYYY'
                                                                  ),
                                                                  key 'Status' value pc_lookups.get_meaning(b.status, 'COBRA_ELECTION_STATUS'
                                                                  ),
                                                                  key 'address' value a.address,
                                                                  key 'address2' value a.address2,
                                                                  key 'city' value a.city,
                                                                  key 'state' value a.state,
                                                                  key 'zip' value a.zip,
                                                                  key 'city' value a.city
                                                      )
                                                  ) qb
                                              from
                                                  person           a,
                                                  plan_elections   b,
                                                  enterprise       c,
                                                  account          d,
                                                  qualifying_event e
                           where
                                   a.pers_id = b.pers_id
                               and a.pers_id = e.pers_id
                               and a.entrp_id = c.entrp_id
                               and a.entrp_id = d.entrp_id
                               and trunc(b.coverage_start_date) between to_date(p_event_start_date, 'MM/DD/YYYY') and to_date(p_event_end_date
                               , 'MM/DD/YYYY')
                               and d.acc_num = p_acc_num;

        return thecursor;
    end get_qb_plan_members;

    function get_client_by_postal_code_report (
        p_entrp_id in varchar2,
        p_er_name  in varchar2
    ) return sys_refcursor is
        thecursor sys_refcursor;
    begin
        open thecursor for select
                                                      json_object(
                                                          key 'entrp_code' value a.entrp_code,
                                                          key 'Clientinfo' value b.first_name
                                                                                 || ' '
                                                                                 || b.last_name
                                                                                 || ' '
                                                                                 || b.phone
                                                                                 || ' '
                                                                                 || b.email
                                                                                 || ' '
                                                                                 || b.fax
                                                                                 || ' '
                                                                                 || c.state
                                                                                 || ' '
                                                                                 || c.zip,
                                                          key 'division_id' value c.division_id,
                                                          key 'division_name' value c.division_name,
                                                          key 'start_date' value b.start_date,
                                                                  key 'status' value null
                                                      )
                                                  client
                                              from
                                                  enterprise         a,
                                                  contact            b,
                                                  employer_divisions c
                           where
                                   b.entity_type = 'ENTERPRISE'
                               and to_char((a.entrp_id)) = ( replace(b.entity_id, '-') )
                               and a.name like '%'
                                               || p_er_name
                                               || '%'
                               and ( a.entrp_id ) = ( c.entrp_id )
                               and ( a.entrp_id ) = nvl(p_entrp_id, a.entrp_id);

        return thecursor;
    end get_client_by_postal_code_report;

    function get_new_hire_report (
        p_entrp_id           in number,
        p_process_start_date varchar2,
        p_process_end_date   varchar2
    ) return sys_refcursor is
        thecursor sys_refcursor;
    begin
        open thecursor for select
                    --     Max(  b.name)  client_name   ,
                   --        Max(nvl(c.division_name, b.name ))     Division_name ,
                 ---  JSON_ARRAYAGG(
                                                  (
                                                      json_object(
                                                          key 'full_name' value a.full_name,
                                                          key ' SSN' value a.ssn,
                                                          key 'Masked SSN ' value a.masked_ssn,
                                                          key 'Address ' value a.address,
                                                          key 'Address  2' value a.address2,
                                                                  key 'City' value a.city,
                                                          key 'State ' value a.state,
                                                          key 'Zip' value a.zip,
                                                          key 'member_id' value a.orig_sys_vendor_ref,
                                                          key 'Processed_date ' value d.processed_date,
                                                                  key 'Entrp_id ' value b.entrp_id
                                                      )
                                                  ) new_hire
                                              from
                                                  person             a,
                                                  enterprise         b,
                                                  employer_divisions c,
                                                  notice_events      d
                           where
                                   person_type = 'NPM'
                               and a.entrp_id = p_entrp_id
                               and a.entrp_id = b.entrp_id
                 ---      and rownum < 21
                               and d.entrp_id (+) = b.entrp_id
                --     and  nvl(d.processed_Date , '*')  >=   nvl( to_date(p_process_start_Date , 'mm/dd/yyyy')       , '*')
                 ---    and  nvl(d.processed_Date, '*')  <=  nvl(  to_date(p_process_End_Date , 'mm/dd/yyyy')        , '*')
                               and a.pers_id = d.pers_id (+)
                               and a.division_code = c.division_code (+)
                               and a.entrp_id = c.entrp_id (+);

        return thecursor;
    end get_new_hire_report;

    function get_paid_through_date (
        p_entrp_id in number,
        p_status   in varchar2
    ) return clob is
        l_clob              clob;
        l_paid_through_clob clob;
        l_data              clob;
        l_blob              blob;
        l_output_file       varchar2(255);
    begin

	--IF p_entrp_id IS NOT NULL THEN

        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'paid-thru-'
                                             || ac.acc_num
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'curr_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'entrp_name' value er.name,
                                        key 'PAID_THRU' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'PERS_ID' value a.pers_id,
                                                        key 'PERS_NAME' value a.full_name,
                                                        key 'MEMBER_TYPE' value 'QB',
                                                        key 'DIVISON_NAME' value pc_employer_divisions.get_division_name(a.division_code
                                                        , a.entrp_id),
                                                        key 'SSN' value a.masked_ssn,
                                                        key 'PAID_THRU_DATE' value to_char(
                                                    pc_premium.get_paid_thru_date(e.acc_id),
                                                    'MM/DD/YYYY'
                                                ),
                                                        key 'EVENT_DATE' value to_char(qe.event_date, 'MM/DD/YYYY')
                                            returning clob)
                                        order by
                                            qe.event_date desc
                                        returning clob)
                                    from
                                        person           a,
                                        account          e,
                                        qualifying_event qe
                                    where
                                            a.entrp_id = er.entrp_id
                                        and a.pers_id = qe.pers_id
                                        and qe.event_type <> 'DISABILITY'
                                        and a.pers_id = e.pers_id
                                        and exists(
                                            select
                                                *
                                            from
                                                plan_elections,
                                                (
                                                            select
                                                                *
                                                            from
                                                                table(apex_string.split(p_status, ':'))
                                                        ) x
                                            where
                                                    pers_id = a.pers_id
                                                and status = x.column_value
                                        )
                                        and e.account_type = 'COBRA'
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = nvl(p_entrp_id, er.entrp_id)
                and er.entrp_id = ac.entrp_id
                and ac.account_status = 1
                and ac.account_type = 'COBRA'
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_paid_through_clob := j.files;
        end loop;
  --  END IF;

        return l_paid_through_clob;
    end get_paid_through_date;

 -- Added by Swamy for Cobra NEw Disbursement Report
    function get_disbursement_report (
        p_entrp_id in number
    ) return clob is

        l_clob              clob;
        l_blob              blob;
        l_disbursement_clob clob;
        l_data              clob;
        l_output_file       varchar2(255);
        v_date              varchar2(50);
        l_entrp_id          number;
    begin
     -- insert into app_log values ('p_pers_id'||p_pers_id,sysdate);

        for k in (
            select
                pc_reports.get_cobra_disbursement_details(p_entrp_id, null, null, null) disbursement_details
            from
                dual
        ) loop
            l_disbursement_clob := k.disbursement_details;
        end loop;

        /*FOR m IN (SELECT TO_CHAR(current_timestamp,'MM/DD/YYYY HH12:MI AM') l_date FROM dual) LOOP
           v_date := m.l_date;
        END LOOP;

         IF l_clob IS NOT NULL THEN
            FOR k IN ( SELECT json_mergepatch(l_clob,l_disbursement_clob RETURNING CLOB) json_data from DUAL) LOOP
               l_data := k.json_data;
            END LOOP;
         ELSE
           l_data := l_disbursement_clob;
         END IF;
         */

        return l_disbursement_clob;
    end get_disbursement_report;

  -- Added by Swamy for Cobra NEw Disbursement Report
    function get_cobra_disbursement_details (
        p_entrp_id        in number,
        p_start_date      in date,
        p_end_date        in date,
        p_disbursement_id in number
    ) return clob is
        l_clob                    clob;
        l_cobra_disbursement_clob clob;
        l_data                    clob;
        l_blob                    blob;
        l_output_file             varchar2(255);
    begin
        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'Cobra-Disbursement-'
                                             || p_disbursement_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'curr_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'entrp_name' value er.name,
                                        key 'address' value er.address,
                                        key 'city' value er.city,
                                        key 'state' value er.state,
                                        key 'zip' value er.zip,
                                        key 'check_date' value to_char(ey.check_date, 'MM/DD/YYYY'),
                                        key 'check_note' value ey.note,
                                        key 'check_amount' value format_money(ey.check_amount),
                                        key 'DETAIL' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'PERIOD' value to_char(c.premium_start_date, 'Month YYYY'),
                                                        key 'CARRIER' value(
                                                    select
                                                        carrier_name
                                                    from
                                                        cobra_plans
                                                    where
                                                            entrp_id = c.entrp_id
                                                        and plan_name = ar.invoice_line_type
                                                        and rownum = 1
                                                ),
                                                        key 'DIVISION_NAME' value s.division_name,
                                                        key 'QB_NAME' value s.qb_first_name
                                                                            || ', '
                                                                            || s.qb_last_name,
                                                        key 'PREMIUM' value nvl(s.premium_posted, 0),
                                                        key 'PLAN' value ar.invoice_line_type
                                            returning clob)
                                        returning clob)
                                    from
                                        cobra_payments                 c,
                                        newcobra.cobra_payment_staging s,
                                        payment                        p,
                                        ar_invoice_lines               ar
                                    where
                                            ey.employer_payment_id = c.employer_payment_id
                                        and c.batch_number = s.batch_number
                                        and c.entrp_id = s.entrp_id
                                        and s.reason_mode = 'RECEIPT'
                                        and c.premium_start_date = s.start_date
                                        and c.premium_end_date = s.end_date
                                        and p.change_num = s.change_num
                                        and p.claim_id = s.batch_number
                                        and p.pay_num = ar.invoice_id
                                        and ar.rate_code <> 91
                                        and c.cobra_payment_id = p_disbursement_id
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise        er,
                account           ac,
                employer_payments ey
            where
                    er.entrp_id = ac.entrp_id
               -- AND AC.ACCOUNT_STATUS = 1
                and ac.account_type = 'COBRA'
                and er.entrp_id = ey.entrp_id
                and ey.employer_payment_id = (
                    select
                        max(employer_payment_id)
                    from
                        employer_payments
                    where
                            cobra_disbursement_id = p_disbursement_id
                        and entrp_id = ey.entrp_id
                )
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_cobra_disbursement_clob := j.files;
        end loop;

        return l_cobra_disbursement_clob;
    end get_cobra_disbursement_details;

  -- Added by Swamy for Cobra NEw Disbursement Report
    function get_disb_details (
        p_disbursement_id in number
    ) return clob is
        l_clob                    clob;
        l_cobra_disbursement_clob clob;
        l_data                    clob;
        l_blob                    blob;
        l_output_file             varchar2(255);
    begin
        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'Cobra-Disbursement-'
                                             || p_disbursement_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'curr_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'entrp_name' value er.name,
                                        key 'address' value er.address,
                                        key 'city' value er.city,
                                        key 'state' value er.state,
                                        key 'zip' value er.zip,
                                        key 'check_date' value ey.check_date,
                                        key 'check_note' value ey.note,
                                        key 'check_amount' value format_money(ey.check_amount),
                                        key 'DETAIL' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'PERIOD' value to_char(c.premium_start_date, 'Month YYYY'),
                                                        key 'CARRIER' value cp.carrier_name,
                                                        key 'DIVISION_NAME' value s.division_name,
                                                        key 'QB_NAME' value s.qb_first_name
                                                                            || ', '
                                                                            || s.qb_last_name,
                                                        key 'PREMIUM' value format_money(nvl(rp.rate_plan_cost, 0)),
                                                        key 'PLAN' value rp.rate_basis
                                            returning clob)
                                        returning clob)
                                    from
                                        cobra_payments        c,
                                        cobra_payment_staging s,
                                        ar_invoice_lines      l,
                                        rate_plan_detail      rp,
                                        plan_elections        pe,
                                        cobra_plans           cp
                                    where
                                            ey.employer_payment_id = c.employer_payment_id
                                        and c.batch_number = s.batch_number
                                        and c.entrp_id = s.entrp_id
                                        and ey.entrp_id = s.entrp_id
                                        and s.reason_mode = 'RECEIPT'
                                        and s.invoice_id = l.invoice_id
                                        and l.rate_plan_detail_id = rp.rate_plan_detail_id
                                        and rp.rate_code = '91'
                                        and pe.plan_election_id = rp.plan_id
                                        and cp.cobra_plan_id = pe.cobra_plan_id
                                                      --AND ep.cobra_disbursement_id = P_COBRA_DISBURSEMENT_ID
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise        er,
                account           ac,
                employer_payments ey
            where
                    er.entrp_id = ac.entrp_id
                and ac.account_status = 1
                and ac.account_type = 'COBRA'
                and er.entrp_id = ey.entrp_id
                and ey.cobra_disbursement_id = p_disbursement_id
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_cobra_disbursement_clob := j.files;
        end loop;

        return l_cobra_disbursement_clob;
    end get_disb_details;

--------prabu 20/10/2022 plan Rate renewal Report
    function get_plan_renewal_rates (
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) return clob is

        l_clob              clob;
        l_plan_renewal_clob clob;
        l_data              clob;
        l_blob              blob;
        l_output_file       varchar2(255);
        l_no_of_days        number;
    begin
        l_no_of_days := p_end_date - p_start_date;
        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'Plan_Rate_Renewal-'
                                             || ac.acc_num
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'CURR_DATE' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'ENTRP_NAME' value er.name,
                                        key 'ADDRESS1' value er.address,
                                        key 'ADDRESS2' value er.city
                                                             || ', '
                                                             || er.state
                                                             || '  '
                                                             || er.zip,
                                        key 'DIVISION_NAME' value ed.division_name,
                                        key 'DIV_ADDRESS1' value ed.address1,
                                        key 'DIV_ADDRESS2' value ed.city
                                                                 || ', '
                                                                 || ed.state
                                                                 || '  '
                                                                 || ed.zip,
                                        key 'NO_OF_DAYS' value l_no_of_days,
                                        key 'NO_OF_RECORDS' value pc_reports.count_plan_records(p_entrp_id, p_start_date, p_end_date)
                                        ,
                                        key 'PLAN_RENEWAL' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'END_DATE' value to_char(b.end_date, 'MM/DD/YYYY'),
                                                        key 'RENEWAL_DATE' value to_char(b.renewal_date, 'MM/DD/YYYY'),
                                                        key 'EFFECTIVE_DATE' value to_char(b.effective_date, 'MM/DD/YYYY')
                                                                  ----     ,KEY 'DIVISON_NAME'    VALUE  PC_EMPLOYER_DIVISIONS.get_division_name_BY_ID(A.DIVISION_id,A.ENTRP_ID)
                                                        ,
                                                        key 'CARRIER_NAME' value a.carrier_name,
                                                        key 'PLAN_NAME' value a.plan_name
                                            )
                                        returning clob)
                                    from
                                        cobra_plans      a,
                                        cobra_plan_rates b
                                    where
                                            a.entrp_id = er.entrp_id
                                        and a.cobra_plan_id = b.cobra_plan_id
                                        and b.renewal_date between p_start_date and p_end_date
                                        --   and a.division_id =ed.division_id(+)
                                        and a.entrp_id = ac.entrp_id
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise         er,
                account            ac,
                employer_divisions ed ---, Employer_divisions ED
            where
                    er.entrp_id = nvl(p_entrp_id, er.entrp_id)
                and er.entrp_id = ac.entrp_id
                and ac.account_status = 1
                and ed.entrp_id (+) = er.entrp_id
                and ac.account_type = 'COBRA'
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_plan_renewal_clob := j.files;
        end loop;
  --  END IF;

        return l_plan_renewal_clob;
    end get_plan_renewal_rates;

    function count_plan_records (
        p_entrp_id   number,
        p_start_date date,
        p_end_date   date
    ) return number is
    begin
        for i in (
            select
                count(renewal_date) renewal_date
            from
                cobra_plans      a,
                cobra_plan_rates b
            where
                    a.cobra_plan_id = b.cobra_plan_id
                and a.entrp_id = p_entrp_id
                and renewal_date between p_start_date and p_end_date
        ) loop
            return i.renewal_date;
        end loop;
    end;

    -- Added by Swamy for Cobra NEw Disbursement Report
    function get_disbursement_details (
        p_entrp_id        in number,
        p_disbursement_id in number
    ) return clob is
        l_clob                    clob;
        l_cobra_disbursement_clob clob;
        l_data                    clob;
        l_blob                    blob;
        l_output_file             varchar2(255);
    begin
        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'Cobra-Disbursement-'
                                             || ac.acc_num
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'curr_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                        key 'entrp_name' value er.name,
                                        key 'address' value er.address,
                                        key 'city' value er.city,
                                        key 'state' value er.state,
                                        key 'zip' value er.zip,
                                        key 'check_date' value ey.check_date,
                                        key 'check_note' value ey.note,
                                        key 'cobra_disbursement_detail' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'BILLING_PERIOD' value to_char(c.premium_start_date, 'Month YYYY'),
                                                        key 'CARRIER' value null,
                                                        key 'DIVISON_NAME' value s.division_name,
                                                        key 'QB_NAME' value s.qb_first_name
                                                                            || ', '
                                                                            || s.qb_last_name,
                                                        key 'PREMIUM_AMOUNT' value nvl(
                                                    abs(cs.premium_posted),
                                                    0
                                                ),
                                                        key 'BENEFIT_PLANS' value l.invoice_line_type,
                                                        key 'check_date' value ep.check_date,
                                                        key 'check_note' value ep.note
                                            )
                                        returning clob)
                                    from
                                        employer_payments     ep,
                                        cobra_payments        c,
                                        cobra_payment_staging s--, AR_INVOICE_LINES L
                                        ,
                                        cobra_payment_staging cs,
                                        ar_invoice_lines      l
                                                    --    , rate_plan_detail r
                                                    --    , plan_elections p
                                                    --    , cobra_plans cp
                                    where
                                            ep.employer_payment_id = c.employer_payment_id
                                        and c.batch_number = s.batch_number
                                        and cs.batch_number = s.batch_number
                                        and cs.entrp_acc_id = s.entrp_acc_id
                                        and cs.reason_mode = 'RECEIPT'
                                        and c.entrp_id = s.entrp_id
                                        and ep.entrp_id = s.entrp_id
                                                     -- AND s.INVOICE_ID = L.INVOICE_ID
                                        and s.entrp_id = nvl(p_entrp_id, s.entrp_id)
                                        and s.reason_mode = 'PAYMENT'
                                        and ep.cobra_disbursement_id = p_disbursement_id
                                        and cs.invoice_id = l.invoice_id 
                                                  --    and l.rate_plan_detail_id= r.rate_plan_detail_id
                                                  --    and r.plan_id= p.plan_election_id 
                                                  --    and p.cobra_plan_id = cp.cobra_plan_id
                                                      --AND s.start_date >= p_start_date
                                                     -- AND s.end_date <= p_end_date
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise        er,
                account           ac,
                employer_payments ey
            where
                    er.entrp_id = nvl(p_entrp_id, er.entrp_id)
                and er.entrp_id = ac.entrp_id
                and ac.account_status = 1
                and ac.account_type = 'COBRA'
                and er.entrp_id = ey.entrp_id
                and ey.cobra_disbursement_id = p_disbursement_id
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_cobra_disbursement_clob := j.files;
        end loop;

        return l_cobra_disbursement_clob;
    end get_disbursement_details;

/*
PROCEDURE disbursement_report_blob(
  p_entrp_id             IN NUMBER
 ,p_disbursement_id      IN NUMBER
) 
IS
  l_clob          CLOB;
  l_result        BLOB;
  x_output_file   VARCHAR2(4000);
  l_file_name     VARCHAR2(255);
  l_workspace_id  NUMBER;
  l_binds         wwv_flow_plugin_util.t_bind_list; 
BEGIN
      -- Function to get the clob data in JSON format
      l_clob := pc_reports.get_disbursement_details (p_entrp_id         => p_entrp_id
                                                    ,p_disbursement_id  => p_disbursement_id
                                                    );
      
       pc_log.log_error('In disbursement_report_blob',p_entrp_id||' l_clob :='||l_clob||' p_disbursement_id :='||p_disbursement_id);  
       IF NVL(l_clob,'*') <> '*' THEN                                             
         -- File name
         x_output_file := 'Disbursement_'||p_disbursement_id||'_Report';
         -- Apex url
         aop_api_pkg.g_aop_url := 'http://216.109.157.48:8010/';
         -- Creating a apex session
         aop_api_pkg.create_apex_session(p_app_id       => 104,
                                         p_enable_debug => 'Y');
       
         pc_log.log_error('In disbursement_report_blob **1',p_entrp_id||' l_clob :='||l_clob||' p_disbursement_id :='||p_disbursement_id||'x_output_file :='||x_output_file);  
 
         -- USing JSON data and using report template, get the blob format of the report
         l_result := aop_api_pkg.plsql_call_to_aop (
                                          p_data_type       => aop_api_pkg.c_source_type_json_files ,
                                          p_data_source     => l_clob,
                                          p_template_type   => 'APEX',
                                          p_template_source => 'COBRA_DISBURSEMENT_REPORT.docx', 
                                          p_output_type     => 'pdf',
                                          p_output_filename => x_output_file,
                                          p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                                          p_aop_url         => 'http://216.109.157.48:8010/',
                                          p_app_id          => 104);

                                          
          pc_log.log_error('In disbursement_report_blob **2',p_entrp_id||' l_clob :='||l_clob||' p_disbursement_id :='||p_disbursement_id||' x_output_file :='||x_output_file);                    
             IF l_result is not null then
                  -- Delete the existing data
                   DELETE 
                     FROM disbursement_blobs 
                    WHERE disbursement_ID = p_disbursement_id 
                      AND TEMPLATE_CODE = 'COBRA_DISBURSEMENT_REPORT.docx';
                  pc_log.log_error('In disbursement_report_blob **3',p_entrp_id||' l_clob :='||l_clob||' p_disbursement_id :='||p_disbursement_id);                      
                  -- Insert the report in the BLOB format
                  INSERT INTO disbursement_blobs(disbursement_ID
                                                ,disbursement_BLOB
                                                ,TEMPLATE_CODE
                                                ,FILE_NAME
                                                ) 
                                         VALUES (p_disbursement_id
                                                 ,l_result
                                                 ,'COBRA_DISBURSEMENT_REPORT.docx'
                                                 ,x_output_file
                                                 );
             END IF;
       END IF;
EXCEPTION
WHEN OTHERS THEN
    pc_log.log_error('In disbursement_report_blob othesr ',sqlerrm);  
END disbursement_report_blob;
*/

-- Called from Website 

-- Added by Swamy 30jan2023 for Cobra NEw Disbursement Report which is called from PHP 
-- This procedure will get the data in JSON format using entrp id. This JSON is then used to generate report with report template stored in APEX  static application files. 
-- and then convert it into blob and store it into a table.
    function disbursement_report_blob (
        p_entrp_id        in number,
        p_disbursement_id in number
    ) return blob is

        l_clob         clob;
        l_result       blob;
        x_output_file  varchar2(4000);
        l_file_name    varchar2(255);
        l_workspace_id number;
        l_binds        wwv_flow_plugin_util.t_bind_list;
        pragma autonomous_transaction;
    begin
      -- Function to get the clob data in JSON format
     /* l_clob := pc_reports.get_disbursement_details (p_entrp_id         => p_entrp_id
                                                    ,p_disbursement_id  => p_disbursement_id
                                                    );
      */
        l_clob := pc_reports.get_cobra_disbursement_details(
            p_entrp_id        => p_entrp_id,
            p_start_date      => null,
            p_end_date        => null,
            p_disbursement_id => p_disbursement_id
        );

        if nvl(l_clob, '*') <> '*' then                                             
         -- File name
            x_output_file := 'Disbursement_'
                             || p_disbursement_id
                             || '_report.pdf';
         -- Apex url
            aop_api_pkg.g_aop_url := 'http://216.109.157.48:8010/';
            aop_api_pkg.g_aop_mode := 'production';
         
		 -- Creating a apex session
            aop_api_pkg.create_apex_session(
                p_app_id       => 104,
                p_enable_debug => 'N'
            );
            pc_log.log_error('In disbursement_report_blob **1', p_entrp_id
                                                                || ' p_disbursement_id :='
                                                                || p_disbursement_id
                                                                || 'x_output_file :='
                                                                || x_output_file);  
         
         -- USing JSON data and using report template, get the blob format of the report
            l_result := aop_api_pkg.plsql_call_to_aop(
                p_data_type       => aop_api_pkg.c_source_type_json_files,
                p_data_source     => l_clob,
                p_template_type   => aop_api_pkg.c_source_type_apex,
                p_template_source => 'COBRA_DISBURSEMENT_REPORT.docx',
                p_output_type     => aop_api_pkg.c_pdf_pdf,
                p_output_filename => x_output_file,
                p_output_encoding => aop_api_pkg.c_output_encoding_raw,
                p_aop_url         => 'http://216.109.157.48:8010/',
                p_app_id          => 104
            );

        end if;

        return l_result;
    exception
        when others then
            pc_log.log_error('In disbursement_report_blob others ', sqlerrm);
            raise;
    end disbursement_report_blob;

    function get_npm (
        p_entrp_id           in number,
        p_process_start_date varchar2,
        p_process_end_date   varchar2
    ) return clob is
        l_clob clob;
    begin
        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'curr_date' value to_char(sysdate, 'MM/DD/YYYY'),
                                key 'entrp_name' value er.name,
                                key 'NPM' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'full_name' value a.full_name,
                                                key 'ssn' value a.ssn,
                                                key 'masked_ssn' value a.masked_ssn,
                                                key 'address' value a.address,
                                                key 'address2' value a.address2,
                                                key 'city' value a.city,
                                                key 'state' value a.state,
                                                key 'zip' value a.zip,
                                                key 'member_id' value nvl(a.orig_sys_vendor_ref, a.pers_id),
                                                key 'processed_date' value to_char(d.processed_date, 'MM/DD/YYYY'),
                                                key 'division_name' value pc_person.get_division_name(a.pers_id),
                                                key 'entrp_id ' value a.entrp_id
                                    returning clob)
                                returning clob) new_hire
                            from
                                person        a,
                                notice_events d
                            where
                                    a.person_type = 'NPM'
                                and a.entrp_id = er.entrp_id
                                and a.pers_id = d.pers_id
                                and a.entrp_id = er.entrp_id
                                and d.process_status = 'W'
                                and a.creation_date between p_process_start_date and p_process_end_date
                                and d.template_code = 'COBRA_GENERAL_RIGHTS_NOTICE'
                        )
                    returning clob)
                returning clob) files
            from
                enterprise er,
                account    ac
            where
                    er.entrp_id = p_entrp_id
                and er.entrp_id = ac.entrp_id
                and ac.account_status = 1
                and ac.account_type = 'COBRA'
            group by
                er.entrp_id,
                ac.acc_num
        ) loop
            l_clob := j.files;
        end loop;
  --  END IF;

        return l_clob;
    end get_npm;

    function get_qb_summary_clob (
        p_pers_id in number,
        p_status  in varchar2
    ) return clob is
        l_clob clob;
    begin
        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'qb-summary.pdf',
                                key 'data' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        'P' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'DOB' value to_char(p.birth_date, 'MM/DD/YYYY'),
                                                                key 'SSN' value p.masked_ssn,
                                                                key 'PERS_NAME' value p.full_name,
                                                                key 'ADDRESS' value p.address,
                                                                key 'ADDRESS2' value nvl(p.address2, ' '),
                                                                key 'CITY' value p.city,
                                                                key 'STATE' value p.state,
                                                                key 'ZIP' value p.zip,
                                                                key 'EMAIL' value p.email,
                                                                key 'PHONE' value p.phone_day,
                                                                key 'GENDER' value p.gender,
                                                                key 'ENTRP_NAME' value pc_entrp.get_entrp_name(p.entrp_id),
                                                                key 'DIVISION_NAME' value pc_person.get_division_name(p.pers_id)
                                                    returning clob)
                                                returning clob)
                                            from
                                                dual
                                        ),
                                                'PAYMENT' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'PMD' value to_char(postmark_date, 'MM/DD/YYYY'),
                                                                key 'ENTERED_DATE' value to_char(fee_date, 'MM/DD/YYYY'),
                                                                key 'AMOUNT' value format_money(amount),
                                                                key 'METHOD' value pc_lookups.get_pay_type(pay_code),
                                                                key 'CC_NUMBER' value cc_number
                                                    returning clob)
                                                returning clob)
                                            from
                                                (
                                                    select
                                                        nvl(postmark_date, fee_date) postmark_date,
                                                        fee_date,
                                                        amount_add + ee_fee_amount   amount,
                                                        i.pay_code,
                                                        cc_number
                                                    from
                                                        income  i,
                                                        account a
                                                    where
                                                            i.acc_id = a.acc_id
                                                        and a.pers_id = p.pers_id
                                                        and a.account_type = 'COBRA'
                                                        and i.change_num =(
                                                            select
                                                                max(change_num)
                                                            from
                                                                income ii
                                                            where
                                                                    ii.acc_id = i.acc_id
                                                                and ii.fee_code in(91, 92)
                                                            group by
                                                                ii.acc_id
                                                            having
                                                                sum(amount_add + ee_fee_amount) > 0
                                                        )
                                                    union
                                                    select
                                                        max(due_date)                   postmark_date,
                                                        max(fee_date),
                                                        sum(amount_add + ee_fee_amount) amount,
                                                        max(i.pay_code),
                                                        max(cc_number)
                                                    from
                                                        income  i,
                                                        account a
                                                    where
                                                            i.acc_id = a.acc_id
                                                        and a.pers_id = p.pers_id
                                                        and fee_code = 4
                                                        and a.account_type = 'COBRA'
                                                        and i.due_date in(
                                                            select
                                                                max(due_date)
                                                            from
                                                                income ii
                                                            where
                                                                    ii.acc_id = i.acc_id
                                                                and ii.fee_code = 4
                                                            group by
                                                                ii.acc_id
                                                            having
                                                                sum(amount_add + ee_fee_amount) > 0
                                                        )
                                                )
                                        ),
                                                'EVENT' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'EVENT_TYPE' value nvl(
                                                            nvl(
                                                                pc_lookups.get_meaning(e.event_type, 'EE_EVENT_TYPE'),
                                                                pc_lookups.get_meaning(e.event_type, 'DEP_EVENT_TYPE')
                                                            ),
                                                            initcap(event_type)
                                                        ),
                                                                key 'EVENT_DATE' value to_char(event_date, 'MM/DD/YYYY'),
                                                                key 'EVENT_CATEGORY' value initcap(event_entity),
                                                                key 'OE_DATE' value to_char(original_enrollment_date, 'MM/DD/YYYY'),
                                                                key 'SEC_EVENT_FLAG' value 'No',
                                                                key 'LEGACY_FLAG' value 'No'
                                                    returning clob)
                                                returning clob)
                                            from
                                                qualifying_event e
                                            where
                                                    e.pers_id = p.pers_id
                                                and event_type <> 'DISABILITY'
                                        ),
                                                'DISABILITY' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'APPROVED' value e.approved,
                                                                key 'EVENT_DATE' value to_char(event_date, 'MM/DD/YYYY')
                                                    returning clob)
                                                returning clob)
                                            from
                                                qualifying_event e
                                            where
                                                    e.pers_id = p.pers_id
                                                and event_type = 'DISABILITY'
                                        ),
                                                'S' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'NEXT_PMD' value to_char(start_date, 'MM/DD/YYYY'),
                                                                key 'PREMIUM_AMOUNT' value format_money(premium_amount),
                                                                key 'LATEST_PMD' value to_char(end_date, 'MM/DD/YYYY')
                                                    returning clob)
                                                returning clob)
                                            from
                                                table(pc_premium.f_get_premium(p.pers_id))
                                            where
                                                    start_date > sysdate
                                                and rownum = 1
                                        ),
                                                'NOTICE' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'SR_DATE' value to_char(specific_notice_date, 'MM/DD/YYYY'),
                                                                key 'CONV_LETTER_DATE' value to_char(conv_letter_date, 'MM/DD/YYYY')
                                                    )
                                                returning clob)
                                            from
                                                (
                                                    select
                                                        max(
                                                            case
                                                                when template_code in('COBRA Specific Rights Notice Letter', 'COBRA_SPECIFIC_RIGHTS_NOTICE'
                                                                ) then
                                                                    processed_date
                                                                else
                                                                    null
                                                            end
                                                        )         specific_notice_date,
                                                        max(
                                                                    case
                                                                        when template_code in('Conversion Option Notice', 'CALIFORNIA_CONVERSION_OPTION_LETTER'
                                                                        ) then
                                                                            processed_date
                                                                        else
                                                                            null
                                                                    end
                                                                ) conv_letter_date
                                                    from
                                                        notice_events e
                                                    where
                                                            e.pers_id = p.pers_id
                                                        and template_code in('COBRA_SPECIFIC_RIGHTS_NOTICE', 'COBRA Specific Rights Notice Letter'
                                                        , 'Conversion Option Notice', 'CALIFORNIA_CONVERSION_OPTION_LETTER')
                                                    group by
                                                        e.pers_id
                                                )
                                        ),
                                                'PLANS' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'PLAN_NAME' value cp.plan_name,
                                                                key 'PLAN_TYPE' value cp.plan_type,
                                                                key 'ELECTION_DATE' value to_char(
                                                            nvl(e.election_date, e.status_date),
                                                            'MM/DD/YYYY'
                                                        ),
                                                                key 'CARRIER' value cp.carrier_name,
                                                                key 'COVERAGE_LEVEL' value pc_lookups.get_meaning(e.coverage_level, 'COBRA_COVERAGE_TYPE'
                                                                ),
                                                                key 'PREMIUM_AMOUNT' value round(e.premium_amount, 2),
                                                                key 'PREMIUM_WITH_FEE' value round(e.premium_amount * 102 / 100, 2),
                                                                key 'FDOC' value to_char(e.first_day_of_cobra, 'MM/DD/YYYY'),
                                                                key 'LDOC' value to_char(e.last_day_of_cobra, 'MM/DD/YYYY'),
                                                                key 'COV_START_DATE' value to_char(
                                                            greatest(e.coverage_start_date, e.first_day_of_cobra),
                                                            'MM/DD/YYYY'
                                                        ),
                                                                key 'COV_END_DATE' value to_char(
                                                            least(e.coverage_end_date,
                                                                  nvl(e.rate_end_date, e.last_day_of_cobra)),
                                                            'MM/DD/YYYY'
                                                        ),
                                                                key 'STATUS' value e.status
                                                    returning clob)
                                                returning clob)
                                            from
                                                plan_elections   e,
                                                cobra_plans      cp,
                                                qualifying_event qe
                                            where
                                                    e.pers_id = p.pers_id
                                                and e.cobra_plan_id = cp.cobra_plan_id
                                                and qe.event_id = e.event_id
                                                and qe.pers_id = e.pers_id
                                                and e.last_day_of_cobra > sysdate
                                                and e.status not in('TP')
                                                and qe.event_type <> 'DISABILITY'
                                           -- AND cobra_plan_rate_detail_id IS NOT NULL
                                        )
                                    returning clob)
                                returning clob) as qb_data
                            from
                                person  p,
                                account a
                            where
                                    person_type = 'QB'
                                and a.pers_id = p.pers_id
                                and a.account_type = 'COBRA'
                                and p.pers_id = p_pers_id
                        )
                    returning clob)
                returning clob) files
            from
                dual
        ) loop
            l_clob := j.files;
        end loop;

        return l_clob;
    end get_qb_summary_clob;

    function get_qb_summary (
        p_pers_id in number,
        p_status  in varchar2
    ) return clob is
        l_clob clob;
    begin
        for j in (
            select
                json_arrayagg(
                    json_object(
                        'P' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'DOB' value to_char(p.birth_date, 'MM/DD/YYYY'),
                                                key 'SSN' value p.masked_ssn,
                                                key 'PERS_NAME' value p.full_name,
                                                key 'ADDRESS' value p.address,
                                                key 'ADDRESS2' value nvl(p.address2, ' '),
                                                key 'CITY' value p.city,
                                                key 'STATE' value p.state,
                                                key 'ZIP' value p.zip,
                                                key 'EMAIL' value p.email,
                                                key 'PHONE' value p.phone_day,
                                                key 'GENDER' value p.gender,
                                                key 'ENTRP_NAME' value pc_entrp.get_entrp_name(p.entrp_id),
                                                key 'DIVISION_NAME' value pc_person.get_division_name(p.pers_id)
                                    returning clob)
                                returning clob)
                            from
                                dual
                        ),
                                'PAYMENT' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'PMD' value to_char(postmark_date, 'MM/DD/YYYY'),
                                                key 'ENTERED_DATE' value to_char(fee_date, 'MM/DD/YYYY'),
                                                key 'AMOUNT' value format_money(amount),
                                                key 'METHOD' value pc_lookups.get_pay_type(pay_code),
                                                key 'CC_NUMBER' value cc_number
                                    returning clob)
                                returning clob)
                            from
                                (
                                    select
                                        nvl(postmark_date, fee_date) postmark_date,
                                        fee_date,
                                        amount_add + ee_fee_amount   amount,
                                        i.pay_code,
                                        cc_number
                                    from
                                        income  i,
                                        account a
                                    where
                                            i.acc_id = a.acc_id
                                        and a.pers_id = p.pers_id
                                        and a.account_type = 'COBRA'
                                        and i.change_num =(
                                            select
                                                max(change_num)
                                            from
                                                income ii
                                            where
                                                    ii.acc_id = i.acc_id
                                                and ii.fee_code in(91, 92, 4)
                                            group by
                                                ii.acc_id
                                            having
                                                sum(amount_add + ee_fee_amount) > 0
                                        )
                                )
                        ),
                                'EVENT' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'EVENT_TYPE' value nvl(
                                            nvl(
                                                pc_lookups.get_meaning(e.event_type, 'EE_EVENT_TYPE'),
                                                pc_lookups.get_meaning(e.event_type, 'DEP_EVENT_TYPE')
                                            ),
                                            initcap(event_type)
                                        ),
                                                key 'EVENT_DATE' value to_char(event_date, 'MM/DD/YYYY'),
                                                key 'EVENT_CATEGORY' value initcap(event_entity),
                                                key 'OE_DATE' value to_char(original_enrollment_date, 'MM/DD/YYYY'),
                                                key 'SEC_EVENT_FLAG' value 'No',
                                                key 'LEGACY_FLAG' value 'No'
                                    returning clob)
                                returning clob)
                            from
                                qualifying_event e
                            where
                                    e.pers_id = p.pers_id
                                and event_type <> 'DISABILITY'
                        ),
                                'DISABILITY' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'APPROVED' value e.approved,
                                                key 'EVENT_DATE' value to_char(event_date, 'MM/DD/YYYY')
                                    returning clob)
                                returning clob)
                            from
                                qualifying_event e
                            where
                                    e.pers_id = p.pers_id
                                and event_type = 'DISABILITY'
                        ),
                                'S' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'NEXT_PMD' value to_char(start_date, 'MM/DD/YYYY'),
                                                key 'PREMIUM_AMOUNT' value format_money(premium_amount),
                                                key 'LATEST_PMD' value to_char(end_date, 'MM/DD/YYYY')
                                    returning clob)
                                returning clob)
                            from
                                table(pc_premium.f_get_premium(p.pers_id))
                            where
                                    start_date >= nvl((
                                        select
                                            min(start_date)
                                        from
                                            ar_invoice
                                        where
                                                entity_id = p.pers_id
                                            and status = 'PROCESSED'
                                            and invoice_reason = 'PREMIUM'
                                    ),
                                                      sysdate)
                                and rownum = 1
                        ),
                                'NOTICE' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'SR_DATE' value to_char(specific_notice_date, 'MM/DD/YYYY'),
                                                key 'CONV_LETTER_DATE' value to_char(conv_letter_date, 'MM/DD/YYYY')
                                    )
                                returning clob)
                            from
                                (
                                    select
                                        max(
                                            case
                                                when template_code in('COBRA Specific Rights Notice Letter', 'COBRA_SPECIFIC_RIGHTS_NOTICE'
                                                ) then
                                                    processed_date
                                                else
                                                    null
                                            end
                                        )         specific_notice_date,
                                        max(
                                                    case
                                                        when template_code in('Conversion Option Notice', 'CALIFORNIA_CONVERSION_OPTION_LETTER'
                                                        ) then
                                                            processed_date
                                                        else
                                                            null
                                                    end
                                                ) conv_letter_date
                                    from
                                        notice_events e
                                    where
                                            e.pers_id = p.pers_id
                                        and template_code in('COBRA_SPECIFIC_RIGHTS_NOTICE', 'COBRA Specific Rights Notice Letter', 'Conversion Option Notice'
                                        , 'CALIFORNIA_CONVERSION_OPTION_LETTER')
                                    group by
                                        e.pers_id
                                )
                        ),
                                'PLANS' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        key 'PLAN_NAME' value cp.plan_name,
                                                key 'PLAN_TYPE' value cp.plan_type,
                                                key 'ELECTION_DATE' value to_char(
                                            nvl(e.election_date, e.status_date),
                                            'MM/DD/YYYY'
                                        ),
                                                key 'CARRIER' value cp.carrier_name,
                                                key 'COVERAGE_LEVEL' value pc_lookups.get_meaning(e.coverage_level, 'COBRA_COVERAGE_TYPE'
                                                ),
                                                key 'PREMIUM_AMOUNT' value round(e.premium_amount, 2),
                                                key 'PREMIUM_WITH_FEE' value round(e.premium_amount * 102 / 100, 2),
                                                key 'FDOC' value to_char(e.first_day_of_cobra, 'MM/DD/YYYY'),
                                                key 'LDOC' value to_char(e.last_day_of_cobra, 'MM/DD/YYYY'),
                                                key 'COV_START_DATE' value to_char(
                                            greatest(e.coverage_start_date, e.first_day_of_cobra),
                                            'MM/DD/YYYY'
                                        ),
                                                key 'COV_END_DATE' value to_char(
                                            least(e.coverage_end_date,
                                                  nvl(e.rate_end_date, e.last_day_of_cobra)),
                                            'MM/DD/YYYY'
                                        ),
                                                key 'STATUS' value e.status
                                    returning clob)
                                returning clob)
                            from
                                plan_elections   e,
                                cobra_plans      cp,
                                qualifying_event qe,
                                (
                                    select
                                        *
                                    from
                                        table(apex_string.split(p_status, ':'))
                                )                s
                            where
                                    e.pers_id = p.pers_id
                                and e.cobra_plan_id = cp.cobra_plan_id
                                and qe.event_id = e.event_id
                                and qe.pers_id = e.pers_id
                                and e.last_day_of_cobra > sysdate
                                and e.status = s.column_value
                                and qe.event_type <> 'DISABILITY'
                                           -- AND cobra_plan_rate_detail_id IS NOT NULL
                        )
                    returning clob)
                returning clob) as summary
            from
                person  p,
                account a
            where
                    person_type = 'QB'
                and a.pers_id = p.pers_id
                and a.account_type = 'COBRA'
                and exists (
                    select
                        *
                    from
                        plan_elections pe1,
                        (
                            select
                                *
                            from
                                table ( apex_string.split(p_status, ':') )
                        )              s
                    where
                            pe1.pers_id = p.pers_id
                        and pe1.status = s.column_value
                )
                and p.pers_id = p_pers_id
        ) loop
            l_clob := j.summary;
        end loop;

        return l_clob;
    end get_qb_summary;

    function get_qb_summary_by_entrp (
        p_entrp_id   in number,
        p_status     in varchar2 default 'E:P:PR:TE',
        p_start_date in date,
        p_end_date   in date
    ) return clob is
        l_clob clob;
    begin
        log_errors('get_qb_summary_by_entrp.P_STATUS' || nvl(p_status, 'IS NULL'));
        log_errors('get_qb_summary_by_entrp.p_entrp_id'
                   || p_entrp_id
                   || 'length(p_entrp_id)'
                   || length(p_entrp_id));
        log_errors('get_qb_summary_by_entrp.p_start_date' || p_start_date);
        log_errors('get_qb_summary_by_entrp.p_end_date' || p_end_date);
        log_errors('get_qb_summary_by_entrp.p_entrp_id' || length(p_entrp_id));
        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'SUMMARY' value(
                            select
                                json_arrayagg(
                                    json_object(
                                        'P' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'DOB' value to_char(p.birth_date, 'MM/DD/YYYY'),
                                                                key 'SSN' value p.masked_ssn,
                                                                key 'PERS_NAME' value p.full_name,
                                                                key 'ADDRESS' value p.address,
                                                                key 'ADDRESS2' value nvl(p.address2, ' '),
                                                                key 'CITY' value p.city,
                                                                key 'STATE' value p.state,
                                                                key 'ZIP' value p.zip,
                                                                key 'EMAIL' value p.email,
                                                                key 'PHONE' value p.phone_day,
                                                                key 'GENDER' value p.gender,
                                                                key 'ACC_NUM' value a.acc_num,
                                                                key 'ENTRP_NAME' value pc_entrp.get_entrp_name(p.entrp_id),
                                                                key 'DIVISION_NAME' value pc_person.get_division_name(p.pers_id),
                                                                key 'pageBreakTag' value 'true'
                                                    returning clob)
                                                returning clob)
                                            from
                                                dual
                                        ),
                                                'PAYMENT' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'PMD' value to_char(postmark_date, 'MM/DD/YYYY'),
                                                                key 'ENTERED_DATE' value to_char(fee_date, 'MM/DD/YYYY'),
                                                                key 'AMOUNT' value format_money(nvl(amount, 0)),
                                                                key 'METHOD' value pc_lookups.get_pay_type(pay_code),
                                                                key 'CC_NUMBER' value cc_number
                                                    returning clob)
                                                returning clob)
                                            from
                                                (
                                                    select
                                                        nvl(postmark_date, fee_date) postmark_date,
                                                        fee_date,
                                                        amount_add + ee_fee_amount   amount,
                                                        i.pay_code,
                                                        cc_number
                                                    from
                                                        income  i,
                                                        account a
                                                    where
                                                            i.acc_id = a.acc_id
                                                        and a.pers_id = p.pers_id
                                                        and a.account_type = 'COBRA'
                                                        and i.change_num =(
                                                            select
                                                                max(change_num)
                                                            from
                                                                income ii
                                                            where
                                                                    ii.acc_id = i.acc_id
                                                                and ii.fee_code in(91, 92, 4)
                                                            group by
                                                                ii.acc_id
                                                            having
                                                                sum(amount_add + ee_fee_amount) > 0
                                                        )
                                                )
                                        ),
                                                'EVENT' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'EVENT_TYPE' value nvl(
                                                            nvl(
                                                                pc_lookups.get_meaning(e.event_type, 'EE_EVENT_TYPE'),
                                                                pc_lookups.get_meaning(e.event_type, 'DEP_EVENT_TYPE')
                                                            ),
                                                            initcap(event_type)
                                                        ),
                                                                key 'EVENT_DATE' value to_char(event_date, 'MM/DD/YYYY'),
                                                                key 'EVENT_CATEGORY' value initcap(event_entity),
                                                                key 'OE_DATE' value to_char(original_enrollment_date, 'MM/DD/YYYY'),
                                                                key 'SEC_EVENT_FLAG' value 'No',
                                                                key 'LEGACY_FLAG' value 'No'
                                                    returning clob)
                                                returning clob)
                                            from
                                                qualifying_event e
                                            where
                                                    e.pers_id = p.pers_id
                                                and event_type <> 'DISABILITY'
                                      -- and e.event_date >=  p_start_date
                                      --   and e.event_date <=  p_end_date
                                                and exists(
                                                    select
                                                        *
                                                    from
                                                        plan_elections pe,
                                                        (
                                                                    select
                                                                        *
                                                                    from
                                                                        table(apex_string.split(p_status, ':'))
                                                                )      s
                                                    where
                                                            pers_id = p.pers_id
                                                        and pe.status = s.column_value
                                                )
                                        ),
                                                'DISABILITY' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'APPROVED' value e.approved,
                                                                key 'EVENT_DATE' value to_char(event_date, 'MM/DD/YYYY')
                                                    returning clob)
                                                returning clob)
                                            from
                                                qualifying_event e
                                            where
                                                    e.pers_id = p.pers_id
                                                and event_type = 'DISABILITY'
										--    and e.event_date >=  p_start_date
                                        ---   and e.event_date <=  p_end_date			
                                                and exists(
                                                    select
                                                        *
                                                    from
                                                        plan_elections pe,
                                                        (
                                                                    select
                                                                        *
                                                                    from
                                                                        table(apex_string.split(p_status, ':'))
                                                                )      s
                                                    where
                                                            pers_id = p.pers_id
                                                        and pe.status = s.column_value
                                                )
                                        ),
                                                'S' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'NEXT_PMD' value to_char(start_date, 'MM/DD/YYYY'),
                                                                key 'PREMIUM_AMOUNT' value format_money(premium_amount),
                                                                key 'LATEST_PMD' value to_char(end_date, 'MM/DD/YYYY')
                                                    returning clob)
                                                returning clob)
                                            from
                                                table(pc_premium.f_get_premium(p.pers_id))
                                            where
                                                    start_date >= nvl((
                                                        select
                                                            min(start_date)
                                                        from
                                                            ar_invoice
                                                        where
                                                                entity_id = p.pers_id
                                                            and status = 'PROCESSED'
                                                            and invoice_reason = 'PREMIUM'
                                                    ),
                                                                      sysdate)
                                                and rownum = 1
                                        ),
                                                'NOTICE' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'SR_DATE' value to_char(specific_notice_date, 'MM/DD/YYYY'),
                                                                key 'CONV_LETTER_DATE' value to_char(conv_letter_date, 'MM/DD/YYYY')
                                                    )
                                                returning clob)
                                            from
                                                (
                                                    select
                                                        max(
                                                            case
                                                                when template_code in('COBRA Specific Rights Notice Letter', 'COBRA_SPECIFIC_RIGHTS_NOTICE'
                                                                ) then
                                                                    processed_date
                                                                else
                                                                    null
                                                            end
                                                        )         specific_notice_date,
                                                        max(
                                                                    case
                                                                        when template_code in('Conversion Option Notice', 'CALIFORNIA_CONVERSION_OPTION_LETTER'
                                                                        ) then
                                                                            processed_date
                                                                        else
                                                                            null
                                                                    end
                                                                ) conv_letter_date
                                                    from
                                                        notice_events e
                                                    where
                                                            e.pers_id = p.pers_id
                                                        and template_code in('COBRA_SPECIFIC_RIGHTS_NOTICE', 'COBRA Specific Rights Notice Letter'
                                                        , 'Conversion Option Notice', 'CALIFORNIA_CONVERSION_OPTION_LETTER')
                                                    group by
                                                        e.pers_id
                                                )
                                        ),
                                                'PLANS' value(
                                            select
                                                json_arrayagg(
                                                    json_object(
                                                        key 'PLAN_NAME' value cp.plan_name,
                                                                key 'PLAN_TYPE' value cp.plan_type,
                                                                key 'ELECTION_DATE' value to_char(e.election_date, 'MM/DD/YYYY'),
                                                                key 'CARRIER' value cp.carrier_name,
                                                                key 'COVERAGE_LEVEL' value pc_lookups.get_meaning(e.coverage_level, 'COBRA_COVERAGE_TYPE'
                                                                ),
                                                                key 'PREMIUM_AMOUNT' value round(e.premium_amount, 2),
                                                                key 'PREMIUM_WITH_FEE' value round(e.premium_amount * 102 / 100, 2),
                                                                key 'FDOC' value to_char(e.first_day_of_cobra, 'MM/DD/YYYY'),
                                                                key 'LDOC' value to_char(e.last_day_of_cobra, 'MM/DD/YYYY'),
                                                                key 'COV_START_DATE' value to_char(
                                                            greatest(e.coverage_start_date, e.first_day_of_cobra),
                                                            'MM/DD/YYYY'
                                                        ),
                                                                key 'COV_END_DATE' value to_char(
                                                            least(e.coverage_end_date,
                                                                  nvl(e.rate_end_date, e.last_day_of_cobra)),
                                                            'MM/DD/YYYY'
                                                        ),
                                                                key 'STATUS' value pc_lookups.get_meaning(e.status, 'COBRA_ELECTION_STATUS'
                                                                ),
                                                                key 'SUBSIDY_END_DATE' value(
                                                            select
                                                                to_char(
                                                                    max(rp.effective_end_date),
                                                                    'MM/DD/YYYY'
                                                                )
                                                            from
                                                                subsidy_schedule rp
                                                            where
                                                                    rp.pers_id = e.pers_id
                                                                and rp.plan_type = cp.plan_type
                                                        ),
                                                                key 'SUBSIDY_FLAG' value(
                                                            select
                                                                'Yes'
                                                            from
                                                                subsidy_schedule rp
                                                            where
                                                                    rp.pers_id = e.pers_id
                                                                and rp.plan_type = cp.plan_type
                                                                and rownum = 1
                                                        )
                                                    returning clob)
                                                returning clob)
                                            from
                                                plan_elections   e,
                                                cobra_plans      cp,
                                                qualifying_event qe,
                                                (
                                                    select
                                                        *
                                                    from
                                                        table(apex_string.split(p_status, ':'))
                                                )                s
                                            where
                                                    e.pers_id = p.pers_id
                                                and e.cobra_plan_id = cp.cobra_plan_id
                                                and qe.event_id = e.event_id
                                                and qe.pers_id = e.pers_id
                                                and e.last_day_of_cobra > sysdate
                                                and e.status = s.column_value
                                                and qe.event_type <> 'DISABILITY'
                                                and e.coverage_start_date between p_start_date and p_end_date        --- Added  by rprabu 15/09/2023 
                                 ---           AND    LEAST(E.coverage_end_date, NVL(E.RATE_END_DATE,SYSDATE)) >=  p_end_date
                                  -----          AND    E.coverage_start_date   <=  p_end_date  
                                           -- AND cobra_plan_rate_detail_id IS NOT NULL
                                        )
                                    returning clob)
                                returning clob) as qb_data
                            from
                                person  p,
                                account a
                            where
                                    person_type = 'QB'
                                and a.pers_id = p.pers_id
                                and a.account_type = 'COBRA'
                                and exists(
                                    select
                                        1
                                    from
                                        plan_elections pe1,
                                        (
                                                    select
                                                        *
                                                    from
                                                        table(apex_string.split(p_status, ':'))
                                                )      s
                                    where
                                            pe1.pers_id = p.pers_id
                                        and pe1.status = s.column_value
                                        and pe1.coverage_start_date between p_start_date and p_end_date        --- Added  by rprabu 15/09/2023 
                            -- and  LEAST(PE1.coverage_end_date, NVL(PE1.RATE_END_DATE,SYSDATE))  >=  p_end_date
                            -- and  pe1.coverage_start_date   <=  p_end_date  
                                )
                                and p.entrp_id = p_entrp_id
                        )
                    returning clob)
                returning clob) summary
            from
                dual
        ) loop
            l_clob := j.summary;
     --   log_errors('get_qb_summary_by_entrp.l_clob'||l_clob);

        end loop;

        return l_clob;
    end get_qb_summary_by_entrp;

--Added by Karthe on 07-Feb-2023 for CLOB AOP reports
    function get_wex_disbursement_clob (
        p_cobra_disbursement_id in number
    ) return clob is
        l_clob clob;
        l_sum  number;
    begin
        for i in (
            select
                nvl(adjusted_premium,
                    (
                    select
                        sum(premium_amount) sum_pre_amt
                    from
                        cobra_disbursement_detail b
                    where
                        b.cobra_disbursement_id = a.cobra_disbursement_id
                )) sum_pre_amt
            from
                cobra_disbursements a
            where
                a.cobra_disbursement_id = p_cobra_disbursement_id
        ) loop
            l_sum := i.sum_pre_amt;
        end loop;

        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'filename' value 'Cobra-Disbursement-'
                                             || p_cobra_disbursement_id
                                             || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'frm_name' value 'Sterling Health Services Administration',
                                        key 'frm_add1' value 'PO Box 71107',
                                        key 'frm_add2' value 'COBRA Administration Dept',
                                        key 'frm_add3' value 'Oakland , CA 94612',
                                        key 'check_amount' value '$'
                                                                 || to_char(a.premium_amount, 'fm9999990D00'),
                                        key 'entrp_name' value a.client_name,
                                        key 'rmt_attn' value 'Attn:'
                                                             || a.remittance_first_name
                                                             || ' '
                                                             || a.remittance_last_name,
                                        key 'address' value a.remittance_address1,
                                        key 'city' value a.remittance_city,
                                        key 'state' value a.remittance_state,
                                        key 'zip' value a.remittance_postal_code,
                                        key 'check_date' value to_char(a.creation_date, 'MM/DD/YYYY'),
                                        key 'check_note' value to_char(a.premium_start_date, 'Month YYYY')
                                                               || ' Disbursement',
                                        key 'DETAIL' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'PERIOD' value to_char(premium_start_date, 'Month YYYY'),
                                                        key 'DIVISION_NAME' value division_name,
                                                        key 'CARRIER' value carrier,
                                                        key 'PLAN' value plan_name,
                                                        key 'QB_NAME' value qb_name,
                                                        key 'PREMIUM' value premium_amount,
                                                        key 'DUE_DATE' value premium_due_date
                                            )
                                        returning clob)
                                    from
                                        (
                                            select distinct
                                                a.premium_start_date,
                                                a.premium_end_date,
                                                a.entrp_id,
                                                a.acc_num,
                                                b.division_name,
                                                b.memberid,
                                                b.carrier_first_name
                                                || ' '
                                                || b.carrier_last_name            carrier,
                                                b.plan_name,
                                                a.client_id,
                                                b.premium_amount,
                                                b.qb_first_name
                                                || ', '
                                                || b.qb_last_name                 qb_name,
                                                to_char(b.premium_due_date, 'MM/DD/YYYY') premium_due_date
                                            from
                                                cobra_disbursements       a,
                                                cobra_disbursement_detail b
                                            where
                                                    a.cobra_disbursement_id = b.cobra_disbursement_id
                                                and a.cobra_disbursement_id = p_cobra_disbursement_id
                                        )
                                )
                            returning clob)
                        returning clob)
                    returning clob)
                returning clob) files
            from
                cobra_disbursements a
            where
                    a.cobra_disbursement_id = p_cobra_disbursement_id
                and rownum = 1
            group by
                a.cobra_disbursement_id
        ) loop
            l_clob := j.files;
        end loop;

        return l_clob;
    end get_wex_disbursement_clob;
   
   
   --Added by Karthe for QB Payments Report for Website on 09-Feb-2022
    function get_qb_payments_clob (
        p_employer   in number,
        p_status     in varchar2 default 'E:P:PR:TP:TE',
        p_start_date in date,
        p_end_date   in date
    ) return clob is
        l_clob clob;
    begin
        for j in (
            select
                json_arrayagg(
                    json_object(
                        key 'file_name' value 'QB Payments Report-'
                                              || p_employer
                                              || '.pdf',
                                key 'data' value json_arrayagg(
                                json_object(
                                key 'entrp_name' value ae.name,
                                        key 'STMT' value(
                                    select
                                        json_arrayagg(
                                            json_object(
                                                key 'qb_name' value qb_name,
                                                        key 'list_bill' value list_bill,
                                                        key 'ssn' value masked_ssn,
                                                        key 'acc_num' value acc_num,
                                                        key 'fee_dt' value to_char(fee_date, 'MM/DD/YYYY'),
                                                        key 'due_dt' value to_char(due_date, 'MM/DD/YYYY'),
                                                        key 'pm_dt' value to_char(
                                                    nvl(postmark_date, fee_date),
                                                    'MM/DD/YYYY'
                                                ),
                                                        key 'od_ref' value orig_doc_ref,
                                                        key 'premium' value format_money(nvl(premium, 0)),
                                                        key 'fee' value format_money(nvl(fee, 0)),
                                                        key 'note' value note
                                            )
                                        returning clob)
                                    from
                                        (
                                            select
                                                pc_entrp.get_entrp_name(p.entrp_id) employer_name,
                                                p.first_name
                                                || ' '
                                                || p.last_name              qb_name,
                                                i.list_bill,
                                                i.change_num,
                                                a.acc_num,
                                                i.fee_date,
                                                i.due_date,
                                                i.postmark_date,
                                                i.orig_doc_ref,
                                                i.note,
                                                p.masked_ssn,
                                                i.amount_add                        premium,
                                                i.ee_fee_amount                     fee
                                            from
                                                income  i,
                                                account a,
                                                person  p
                                            where
                                                    i.acc_id = a.acc_id
                                                and a.pers_id = p.pers_id
                                                and a.account_type = 'COBRA'
                                                                                            --  AND I.CHANGE_NUM = I.LIST_BILL
                                                and i.fee_date between p_start_date and p_end_date
                                                and p.entrp_id = p_employer
                                                and exists(
                                                    select
                                                        *
                                                    from
                                                        plan_elections,
                                                        (
                                                                            select
                                                                                *
                                                                            from
                                                                                table(apex_string.split(p_status, ':'))
                                                                        ) s
                                                    where
                                                            pers_id = p.pers_id
                                                        and status = s.column_value
                                                )
                                            union all
                                            select
                                                pc_entrp.get_entrp_name(p.entrp_id) employer_name,
                                                p.first_name
                                                || ' '
                                                || p.last_name              qb_name,
                                                i.list_bill,
                                                i.change_num,
                                                a.acc_num,
                                                i.fee_date,
                                                nvl(i.due_date, ar.end_date),
                                                i.postmark_date,
                                                i.orig_doc_ref,
                                                i.note,
                                                p.masked_ssn,
                                                i.amount_add                        premium,
                                                i.ee_fee_amount                     fee
                                            from
                                                income     i,
                                                account    a,
                                                person     p,
                                                ar_invoice ar
                                            where
                                                    i.acc_id = a.acc_id
                                                and a.pers_id = p.pers_id
                                                and a.account_type = 'COBRA'
                                                and i.list_bill = ar.invoice_id
                                                and i.fee_date between p_start_date and p_end_date
                                                and p.entrp_id = p_employer
                                                and exists(
                                                    select
                                                        *
                                                    from
                                                        plan_elections,
                                                        (
                                                                            select
                                                                                *
                                                                            from
                                                                                table(apex_string.split(p_status, ':'))
                                                                        ) s
                                                    where
                                                            pers_id = p.pers_id
                                                        and status = s.column_value
                                                )
                                        )
                                )
                            returning clob)
                        order by
                            6 desc
                        returning clob)
                    returning clob)
                returning clob) files
            from
                enterprise ae
            where
                ae.entrp_id = p_employer
            group by
                ae.entrp_id
        ) loop
            l_clob := j.files;
        end loop;

        return l_clob;
    end get_qb_payments_clob;
  -- End Added by Karthe for QB Payments Report for Website on 09-Feb-2022
end pc_reports;
/

