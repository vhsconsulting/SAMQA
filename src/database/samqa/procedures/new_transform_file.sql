create or replace procedure samqa.new_transform_file (
    p_file_name in varchar2
) is

    l_utl_id        utl_file.file_type;
    l_outfile_name  varchar2(255);
    l_line          varchar2(3200);
    l_line_count    number := 0;
    l_col_tbl       gen_xl_xml.varchar2_tbl;
    l_col_value_tbl gen_xl_xml.varchar2_tbl;
    i               number := 0;
begin
    l_outfile_name := 'TRANSFORMED'
                      || p_file_name
                      || to_char(sysdate, 'HHMMSS')
                      || '.xls';

    l_line := 'Account number, SSN, Employer Amount, Employee Amount, Employer Fee, Employee Fee,Note, Plan Type, Payroll Date,Employee ID,'
    ;
    l_col_tbl(1) := 'Account number';
    l_col_tbl(2) := 'SSN';
    l_col_tbl(3) := 'Employer Amount';
    l_col_tbl(4) := 'Employee Amount';
    l_col_tbl(5) := 'Employer Fee';
    l_col_tbl(6) := 'Employee Fee';
    l_col_tbl(7) := 'Note';
    l_col_tbl(8) := 'Plan Type';
    l_col_tbl(9) := 'Payroll Date';
    l_col_tbl(10) := 'Employee ID';

    /*From: Wendy Suyetsugu [mailto:Wendy.Suyetsugu@hawaiiantel.com]
      Sent: Wednesday, October 16, 2013 1:12 PM
      To: Mark Fukuhara; Sarah Soman
      Cc: Leina Chow; Jeff Furumura; Sheri Braunthal
      Subject: RE: FSA Requests/Questions and Follow-Up Info

      Hi Mark,

      Attached is a sample file and below is the layout.

      The format looks like:
      Length             Position            Information
          20                 1 - 20                Employee Number (ID)
           1                  21 - 21             Account Type
      1 = Dependent care (DCFSA),
      2 = Health (HCFSA)
      6 = Bus Pass (BUSFSA)
      7 = Parking (PKGFSA) and
      8 = Van Pool (VANFSA)
           8                 22 - 29               Deduction Date  YYYYMMDD
           8                 30 - 37              Deduction Amount

      Thanks!
      Wendy

      Wendy.Suyetsugu@Hawaiiantel.com
      Human Resources - HRIS  Sales Compensation
      Office: 808/546-4409
      Mobile: 808/286-7379
      Fax: 808/546-6194
      */
    for x in (
        select
            substr(line_number, 1, 20)       employee_id,
            decode(
                substr(line_number, 21, 1),
                '1',
                'DCA',
                '2',
                'FSA',
                '6',
                'TRN',
                '8',
                'TRN',
                '7',
                'PKG'
            )                                plan_type,
            trim(substr(line_number, 22, 8)) deduction_date,
            trim(substr(line_number, 30, 7)) amount
        from
            ht_list_bill_external a
    ) loop
        l_line := null;
        for xx in (
            select
                a.ssn,
                b.acc_num
            from
                person  a,
                account b
            where
                    a.entrp_id = 11881
                and a.pers_id = b.pers_id
                and a.orig_sys_vendor_ref = trim(x.employee_id)
        ) loop
            i := i + 1;
            l_line := xx.acc_num
                      || ','
                      || xx.ssn;
            l_col_value_tbl(i) := xx.acc_num;
            i := i + 1;
            l_col_value_tbl(i) := xx.ssn;
        end loop;

        if l_line is null then
            i := i + 1;
            l_col_value_tbl(i) := null;
            i := i + 1;
            l_col_value_tbl(i) := null;
        end if;

        i := i + 1;
        l_col_value_tbl(i) := x.amount;
        i := i + 1;
        l_col_value_tbl(i) := 0;
        i := i + 1;
        l_col_value_tbl(i) := 0;
        i := i + 1;
        l_col_value_tbl(i) := 0;
        i := i + 1;
        l_col_value_tbl(i) := null;
        i := i + 1;
        l_col_value_tbl(i) := x.plan_type;
        i := i + 1;
        l_col_value_tbl(i) := to_char(to_date(x.deduction_date, 'YYYYMMDD'), 'MM/DD/YYYY');

        i := i + 1;
        l_col_value_tbl(i) := x.employee_id;
    end loop;

    mail_utility.send_file(
        p_from_email    => 'httelecom_listbill@sterlingadministration.com',
        p_to_email      => 'vanitha.subramanyam@sterlingadministration.com',
        p_file_name     => l_outfile_name,
        p_directory     => 'LISTBILL_DIR',
        p_dir_path      => '/u01/app/oracle/oradata/listbill/',
        p_html_message  => 'Hawaiian Telecom Transformed Scheduler Contribution File',
        p_report_title  => 'Hawaiian Telecom Transformed Scheduler Contribution File',
        p_col_tbl       => l_col_tbl,
        p_col_value_tbl => l_col_value_tbl
    );

exception
    when others then
        raise;
end new_transform_file;
/


-- sqlcl_snapshot {"hash":"8d9782f7e50552e4f1c932bd9bdb274882c64700","type":"PROCEDURE","name":"NEW_TRANSFORM_FILE","schemaName":"SAMQA","sxml":""}