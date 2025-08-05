create or replace package body samqa.pc_check_process is

    procedure send_email_on_hsa_checks (
        p_file_id number
    ) as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
        l_email_id     varchar2(4000);
    begin
        l_html_message := '<html>
      <head>
          <title>HSA/LSA checks to CNB </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> HSA/LSA checks to CNB  </p>
       </table>
        </body>
        </html>';
        l_sql := 'SELECT pr.acc_num "Account Number"
	 ,pc_person.get_person_name(c.pers_id) "Employee Name"
	 ,pc_person.get_entrp_name(c.pers_id) "Employer Name"
	 ,c.claim_id "Claim Number"
	 ,c.claim_code "Claim Code"
	 ,c.claim_date_start "Date Received"
	 ,c.claim_amount  "Claim Amount"
	 ,c.claim_paid "Claim Paid"
	 ,c.claim_pending "Claim Pending"
	 ,c.denied_amount "Denied Amount"
	 ,chk.check_number "Check Number"
	 ,chk.check_amount "Check Amount"
	 ,chk.status "Status"
	 ,pr.claim_type "Claim Paid to "
	 ,pr.provider_name "Provider Name in Claim"
	 ,pc_payee.get_payee_name(pr.vendor_id) "Provider Name in Check"
   FROM  claimn c
		 ,payment_register pr
		 ,checks chk
		 ,cnb_check_sent_details  cnb
  WHERE  pr.claim_type IN (''EMPLOYER'',''HSA_TRANSFER'',''SUBSCRIBER'',''PROVIDER'',''SUBSCRIBER_ONLINE'',''PROVIDER_ONLINE'',''OUTSIDE_INVESTMENT_TRANSFER'')
	AND  C.claim_id = pr.claim_id
	AND cnb.check_number = chk.check_number

    AND  chk.entity_type IN (''HSA_CLAIM'',''LSA_CLAIM'')
	AND  chk.source_system = ''ADMINISOURCE''
	AND  chk.entity_id = C.claim_id
	AND  chk.check_amount > 0

	AND  pr.vendor_id IS NOT NULL
	AND cnb.file_id =  ' || p_file_id;
        pc_log.log_error('pc_check_process.send_email_on_cobra_checks user_id: ', user);
        if user in ( 'SAM', 'RJOSHI' ) then
            l_email_id := 'vanitha.subramanyam@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,corp.finance@sterlingadministration.com,josie.vega@sterlingadministration.com' || 'denise.law@sterlingadministration.com,finance.department@sterlingadministration.com'
            ;
        else
            l_email_id := 'it-team@sterlingadministration.com';
        end if;

        pc_log.log_error('pc_check_process.send_email_on_hsa_checks ', 'l_email_id: ' || l_email_id);
        pc_log.log_error('pc_check_process.send_email_on_hsa_checks ', 'USER: ' || user);
        mail_utility.report_emails('oracle@sterlingadministration.com',
                                   l_email_id,
                                   'hsa_lsa_checks'
                                   || to_char(sysdate, 'MMDDYYYY')
                                   || '.xls',
                                   l_sql,
                                   l_html_message,
                                   'HSA/LSA checks sent to CNB on ' || to_char(sysdate, 'MM/DD/YYYY'));

    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end send_email_on_hsa_checks;

    procedure send_email_on_cobra_checks as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
        l_email_id     varchar2(4000);
    begin
        l_html_message := '<html>
      <head>
          <title>COBRA Employer checks to CNB </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Employer checks to CNB  </p>
       </table>
        </body>
        </html>';
        l_sql := '  select  d.name "Employer Name"
                        ,pr.acc_num "Account Number"
                        ,chk.check_date "Check Date"
                        ,chk.check_number "Check Number"
                        ,chk.check_amount "Check Amount"
                        ,D.ENTRP_CODE "TAX ID"
                   FROM   EMPLOYER_PAYMENTS C,payment_register pr , CHECKS chk, ENTERPRISE d
                      ,   ACCOUNT acc
            --      WHERE  pr.claim_type = ''COBRA_DISBURSEMENT''
              WHERE  pr.claim_type in (  ''COBRA_DISBURSEMENT'', ''COBRA_PAYMENTS'')
                  AND    d.entrp_id = c.entrp_id
                  AND    acc.entrp_id = d.entrp_id
                  AND    acc.account_type = ''COBRA''
                  and    c.payment_register_id = pr.payment_register_id
                  and    chk.entity_type = ''EMPLOYER_PAYMENTS''
                  AND    chk.source_system = ''ADMINISOURCE''
                  and    chk.entity_id = c.payment_register_id
                  AND    chk.status IN (  ''READY'' ) ';
        pc_log.log_error('pc_cobra_disbursement.send_email_on_cobra_checks', 'l_sql ' || l_sql);
        pc_log.log_error('pc_check_process.send_email_on_cobra_checks user_id: ', user);
        if user in ( 'SAM', 'RJOSHI' ) then
            l_email_id := 'vanitha.subramanyam@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,corp.finance@sterlingadministration.com,josie.vega@sterlingadministration.com' || 'denise.law@sterlingadministration.com,finance.department@sterlingadministration.com'
            ;
        else
            l_email_id := 'it-team@sterlingadministration.com';
        end if;

        mail_utility.report_emails('oracle@sterlingadministration.com',
                                   l_email_id,
                                   'cobra_employer_checks'
                                   || to_char(sysdate, 'MMDDYYYY')
                                   || '.xls',
                                   l_sql,
                                   l_html_message,
                                   'COBRA checks sent to CNB on ' || to_char(sysdate, 'MM/DD/YYYY'));

    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end send_email_on_cobra_checks;

    procedure send_email_on_employer_checks as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
        l_email_id     varchar2(4000);
    begin
        l_html_message := '<html>
      <head>
          <title>Employer checks to CNB </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Employer checks to CNB  </p>
       </table>
        </body>
        </html>';
        l_sql := '  select  d.name "Employer Name"
                        ,pr.acc_num "Account Number"
                        ,chk.check_date "Check Date"
                        ,chk.check_number "Check Number"
                        ,chk.check_amount "Check Amount"
                   FROM   EMPLOYER_PAYMENTS C,payment_register pr , CHECKS chk, ENTERPRISE d
                      ,   ACCOUNT acc
                  WHERE  pr.claim_type = ''EMPLOYER''
                  AND    d.entrp_id = c.entrp_id
                  AND    acc.entrp_id = d.entrp_id
                  AND    acc.account_type <> ''COBRA''
                  and    c.payment_register_id = pr.payment_register_id
                  and    chk.entity_type = ''EMPLOYER_PAYMENTS''
                  AND    chk.source_system = ''ADMINISOURCE''
                  and    chk.entity_id = c.payment_register_id
                  AND    chk.status = ''READY''';
        pc_log.log_error('pc_check_process.send_email_on_cobra_checks user_id: ', user);
        if user in ( 'SAM', 'RJOSHI' ) then
            l_email_id := 'vanitha.subramanyam@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,corp.finance@sterlingadministration.com,josie.vega@sterlingadministration.com' || 'denise.law@sterlingadministration.com,finance.department@sterlingadministration.com'
            ;
        else
            l_email_id := 'it-team@sterlingadministration.com';
        end if;

        mail_utility.report_emails('oracle@sterlingadministration.com',
                                   l_email_id,
                                   'employer_checks'
                                   || to_char(sysdate, 'MMDDYYYY')
                                   || '.xls',
                                   l_sql,
                                   l_html_message,
                                   'Employer checks sent to CNB on ' || to_char(sysdate, 'MM/DD/YYYY'));

    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end send_email_on_employer_checks;

    procedure send_email_on_hra_fsa_checks (
        p_file_id in number
    ) as

        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
        l_email_id     varchar2(4000);
        l_file_name    varchar2(100);
        ls_subject     varchar2(3200);
    begin
        l_html_message := '<html>
      <head> ';
        l_html_message := l_html_message || '<title>HRA/FSA checks to CNB </title> ';
        l_html_message := l_html_message || ' </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%"> ';
        l_html_message := l_html_message || '<p>HRA/FSA checks to CNB </p> ';
        l_html_message := l_html_message || ' </table>
        </body>
        </html>';
        l_sql := 'SELECT 
                      pr.acc_num "Account Number"
                     ,pc_person.get_person_name(c.pers_id) "Employee Name"
                     ,pc_person.get_entrp_name(c.pers_id) "Employer Name"
                     ,c.claim_id "Claim Number"
                     ,c.claim_code "Claim Code"
                     ,c.claim_date_start "Date Received"
                     ,c.claim_amount  "Claim Amount"
                     ,c.claim_paid "Claim Paid"
                     ,c.claim_pending "Claim Pending"
                     ,c.denied_amount "Denied Amount"
                     ,chk.check_number "Check Number"
                     ,chk.check_amount "Check Amount"
                     ,chk.status "Status"
                     ,TO_CHAR(c.plan_start_date,''MM/DD/YYYY'')||''-''||TO_CHAR(c.plan_end_date,''MM/DD/YYYY'') "Plan Year"
                     ,c.service_type "Service Type"                     
                FROM CLAIMN C,payment_register pr , CHECKS chk, cnb_check_sent_details cnb



                WHERE pr.claim_type IN (''SUBSCRIBER'',''PROVIDER'',''SUBSCRIBER_ONLINE'',''PROVIDER_ONLINE'')

                 AND c.claim_id = pr.claim_id
                 AND chk.entity_type = ''CLAIMN''
                 AND chk.source_system = ''ADMINISOURCE''
                 AND chk.entity_id = C.claim_id
                 AND pr.vendor_id IS NOT NULL
                 AND chk.check_number = cnb.check_number
                 AND cnb.file_id = ' || p_file_id;
        l_file_name := 'hra_fsa_checks'
                       || to_char(sysdate, 'MMDDYYYY')
                       || '.xls';
        ls_subject := 'HRA/FSA checks sent to CNB on ' || to_char(sysdate, 'MM/DD/YYYY');
        if user in ( 'SAM', 'RJOSHI' ) then
            l_email_id := 'vanitha.subramanyam@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,corp.finance@sterlingadministration.com,josie.vega@sterlingadministration.com' || 'denise.law@sterlingadministration.com,finance.department@sterlingadministration.com'
            ;
        else
            l_email_id := 'it-team@sterlingadministration.com';
        end if;

        mail_utility.report_emails('oracle@sterlingadministration.com', l_email_id, l_file_name, l_sql, l_html_message,
                                   ls_subject);
    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
            pc_log.log_error('pc_check_process.send_email_on_cobra_checks error: ', sqlerrm);
    end send_email_on_hra_fsa_checks;

    procedure send_email_on_broker_checks as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
    begin
        l_html_message := '<html>
      <head>
          <title>Broker checks to CNB </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Broker checks to Adminisource  </p>
       </table>
        </body>
        </html>';
        l_sql := 'SELECT   PC_BROKER.GET_BROKER_LIC(A.BROKER_ID) "Broker Lience"
                     , PC_BROKER.GET_BROKER_NAME(A.BROKER_ID) "Broker Name"
                     , B.CHECK_NUMBER "Check Number"
                     , TO_CHAR(B.CHECK_DATE,''MM/DD/YYYY'') "Check Date"
                     , TO_CHAR(A.PERIOD_START_DATE,''MM/DD/YYYY'')||'' to ''||TO_CHAR(A.PERIOD_END_DATE,''MM/DD/YYYY'') "Note"
                     , 1020 "Expense Account"
                     , ''YES'' "Detailed Payments"
                     , 1  "No of Distributions"
                     , '' '' "Invoice Paid"
                     , A.NOTE "Decscription"
                     , 2003 "GL Account"
                     , B.CHECK_AMOUNT "Check Amount"
                     , A.BROKER_ID "Broker ID"
                     , A.ACCOUNT_TYPE "Product"
                FROM  BROKER_PAYMENTS A, CHECKS B
                WHERE A.TRANSACTION_NUMBER = B.CHECK_NUMBER
                AND   A.BROKER_PAYMENT_ID = B.ENTITY_ID
                AND   B.STATUS =''READY''
                AND   B.ENTITY_TYPE = ''BROKER_PAYMENTS''
                AND   B.SOURCE_SYSTEM = ''ADMINISOURCE''
                AND   B.STATUS  = ''READY'' ';
        mail_utility.report_emails('oracle@sterlingadministration.com',
                                   'Franco.Espinoza@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,'
                                   || 'corp.finance@sterlingadministration.com,lola.christensen@sterlingadministration.com'
                                   || ',Finance.Department@sterlingadministration.com',
                                   'broker_checks'
                                   || to_char(sysdate, 'MMDDYYYY')
                                   || '.xls',
                                   l_sql,
                                   l_html_message,
                                   'Broker checks sent to CNB on ' || to_char(sysdate, 'MM/DD/YYYY'));

    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end send_email_on_broker_checks;

    function get_file_name (
        p_action in varchar2,
        p_result in varchar2 default 'RESULT'
    ) return varchar2 is
        x_file_name varchar2(320);
    begin
        pc_log.log_error('get_file_name', p_action);
        select
            'Receipt_' || file_name
        into x_file_name
        from
            metavante_files
        where
                file_id = (
                    select
                        max(file_id)
                    from
                        metavante_files
                    where
                            file_action = p_action
                        and nvl(result_flag, 'N') = 'N'
                )
    --  AND   trunc(creation_date) >=  trunc(sysdate)-1
            and nvl(result_flag, 'N') = 'N';

        return x_file_name;
    exception
        when others then
            return null;
    end get_file_name;

    function get_commission_payable_to (
        p_broker_id in number
    ) return varchar2 as
        broker_rec  varchar2(2000);
        account_num varchar2(20);
    begin
        select
            '"'
            || substr(b.commissions_payable_to, 1, 50)
            || '","'
            || substr(b.broker_lic, 1, 20)
            || '",'
            || replace(
                replace(
                    replace(('"'
                             || substr(xx.address, 1, 75)
                             || '"'
                             || ','
                             || null
                             || ',"'
                             || substr(xx.city, 1, 30)
                             || '",'
                             || substr(xx.state, 1, 30)
                             || ','
                             || substr(xx.zip, 1, 5)),
                            chr(94),
                            ' '),
                    chr(10)
                ),
                chr(13)
            )
        into broker_rec
        from
            person xx,
            broker b
        where
                pers_id = p_broker_id
            and xx.pers_id = b.broker_id;

        return broker_rec;
    end get_commission_payable_to;

    function get_broker (
        p_broker_id in number
    ) return varchar2 as
        broker_rec  varchar2(2000);
        account_num varchar2(20);
    begin
        select
            '"'
            || substr(xx.last_name, 1, 50)
            || '","'
            || substr(xx.first_name, 1, 50)
            || '","'
            || substr(xx.middle_name, 1, 1)
            || '",'
            || '"'
            || substr(b.broker_lic, 1, 20)
            || '",'
            || replace(
                replace(
                    replace(('"'
                             || substr(xx.address, 1, 75)
                             || '"'
                             || ','
                             || '"'
                             || substr(xx.address2, 1, 75)
                             || '",'
                             || '"'
                             || substr(xx.city, 1, 30)
                             || '",'
                             || substr(xx.state, 1, 30)
                             || ','
                             || substr(xx.zip, 1, 5)),
                            chr(94),
                            ' '),
                    chr(10)
                ),
                chr(13)
            )
        into broker_rec
        from
            person xx,
            broker b
        where
                pers_id = p_broker_id
            and xx.pers_id = b.broker_id;

        return broker_rec;
    end get_broker;

    function get_broker_info (
        p_broker_id in number
    ) return varchar2 as
        broker_rec  varchar2(2000);
        account_num varchar2(20);
    begin
        select
            '"'
            || substr(xx.last_name, 1, 50)
            || '","'
            || substr(xx.first_name, 1, 50)
            || '","'
            || substr(xx.middle_name, 1, 1)
            || '",'
            || '"'
            || substr(b.broker_lic, 1, 20)
            || '"'
        into broker_rec
        from
            person xx,
            broker b
        where
                pers_id = p_broker_id
            and xx.pers_id = b.broker_id;

        return broker_rec;
    end get_broker_info;

    function get_patient_name (
        p_claim_id in number
    ) return varchar2 is
        l_patient_name varchar2(3200);
    begin
        for x in (
            select -- wm_concat(patient_dep_name) patient_name   -- Commented by RPRABU 0n 17/10/2017
                listagg(patient_dep_name, ',') within group(
                order by
                    patient_dep_name
                ) patient_name -- Added by RPRABU 0n 17/10/2017
            from
                (
                    select distinct
                        claim_id,
                        patient_dep_name
                    from
                        claim_detail
                    where
                        claim_id = p_claim_id
                )
            group by
                claim_id
            order by
                claim_id desc
        ) loop
            l_patient_name := x.patient_name;
        end loop;

        return l_patient_name;
    end;

    function get_broker_address (
        p_broker_id in number
    ) return varchar2 as
        broker_rec  varchar2(2000);
        account_num varchar2(20);
    begin
        select
            replace(
                replace(
                    replace(('"'
                             || substr(xx.address, 1, 75)
                             || '"'
                             || ','
                             || '"'
                             || substr(xx.address2, 1, 75)
                             || '",'
                             || '"'
                             || substr(xx.city, 1, 30)
                             || '",'
                             || substr(xx.state, 1, 30)
                             || ','
                             || substr(xx.zip, 1, 5)),
                            chr(94),
                            ' '),
                    chr(10)
                ),
                chr(13)
            )
        into broker_rec
        from
            person xx,
            broker b
        where
                pers_id = p_broker_id
            and xx.pers_id = b.broker_id;

        return broker_rec;
    end get_broker_address;

    function get_employee (
        person_id  number,
        account_id number
    ) return varchar2 as
        employee    varchar2(250);
        account_num varchar2(20);
    begin
        select
            acc_num
        into account_num
        from
            account
        where
            acc_id = account_id;

        select
            '"'
            || substr(xx.last_name, 1, 50)
            || '","'
            || substr(xx.first_name, 1, 50)
            || '","'
            || substr(xx.middle_name, 1, 1)
            || '",'
            || account_num
        into employee
        from
            person xx
        where
            pers_id = person_id;

        return employee;
    end;

    function get_employee_address (
        person_id number
    ) return varchar2 as
        employee_address varchar2(250);
    begin
        select
            replace(
                replace(
                    replace(('"'
                             || substr(xx.address, 1, 75)
                             || '"'
                             || ','
                             || null
                             || ',"'
                             || substr(xx.city, 1, 30)
                             || '",'
                             || substr(xx.state, 1, 30)
                             || ','
                             || substr(xx.zip, 1, 5)),
                            chr(94),
                            ' '),
                    chr(10)
                ),
                chr(13)
            )
        into employee_address
        from
            person xx
        where
            pers_id = person_id;

        return employee_address;
    end;

    function get_employee_name_address (
        person_id number
    ) return varchar2 as
        employee_address varchar2(250);
    begin
        select
            '"'
            || substr(xx.last_name, 1, 50)
            || ' '
            || substr(xx.first_name, 1, 50)
            || ' '
            || substr(xx.middle_name, 1, 1)
            || '",'
            || '"'
            || replace(
                replace(
                    replace((substr(xx.address, 1, 75)
                             || '"'
                             || ','
                             || null
                             || ','
                             || substr(xx.city, 1, 30)
                             || ','
                             || substr(xx.state, 1, 30)
                             || ','
                             || substr(xx.zip, 1, 5)),
                            chr(94),
                            ' '),
                    chr(10)
                ),
                chr(13)
            )
        into employee_address
        from
            person xx
        where
            pers_id = person_id;

        return employee_address;
    end;

    function get_provider (
        p_claim_id number
    ) return varchar2 as
        provider varchar2(250);
    begin
        select
            '"'
            || replace(
                substr(xx.vendor_name, 1, 50),
                '"',
                ''
            )
            || '",'
            || '"'
            || replace(
                replace(
                    replace((replace(
                        substr(xx.address1, 1, 75),
                        '"',
                        ''
                    )
                             || '"'
                             || ','
                             || '"'
                             || replace(xx.address2, '"', '')
                             || '"'
                             || ','
                             || substr(xx.city, 1, 30)
                             || ','
                             || substr(xx.state, 1, 30)
                             || ','
                             || substr(xx.zip, 1, 5)),
                            chr(94),
                            ' '),
                    chr(10)
                ),
                chr(13)
            )
        into provider
        from
            vendors xx
        where
            vendor_id = (
                select
                    vendor_id
                from
                    payment_register
                where
                    claim_id = p_claim_id
            );

        return provider;
    end;

    function get_provider_acc_num (
        p_vendor_id number
    ) return varchar2 as
        l_acc_num varchar2(255);
    begin
        for x in (
            select
                substr(vendor_acc_num, 1, 20) vendor_acc_num
            from
                vendors
            where
                vendor_id = p_vendor_id
        ) loop
            l_acc_num := regexp_replace(x.vendor_acc_num, '[^[:alnum:]]', null); -- adminisource rejects all the files with special character
   --  l_acc_num := x.vendor_acc_num;

        end loop;

        return l_acc_num;
    end get_provider_acc_num;

    function get_claim_id (
        p_check_number in number
    ) return number is
        l_claim_id number;
    begin
        for x in (
            select
                entity_id
            from
                checks
            where
                check_number = p_check_number
        ) loop
            l_claim_id := x.entity_id;
        end loop;

        return l_claim_id;
    end get_claim_id;

    function get_claim_number (
        p_claim_id in number
    ) return varchar2 as
        l_claim_number varchar2(1000);
    begin
        for x in (
            select
                claim_id,
                listagg(claim_number, ',') within group(
                order by
                    claim_number
                ) claim_number
                                       ---wm_concat(claim_number) claim_number -- Commented and LISTAGG Added by RPRABU 0n 17/10/2017
            from
                (
                    select distinct
                        claim_id,
                        claim_number
                    from
                        claim_interface
                    where
                        claim_id = p_claim_id
                )
            group by
                claim_id
        ) loop
            l_claim_number := x.claim_number;
        end loop;

        return l_claim_number;
    end get_claim_number;
/*** For Payroll integration claims, once the excel report is downloaded
     update the status to SENT ***/

    procedure update_check_status (
        p_check_id in number,
        p_user_id  in number,
        p_status   in varchar2
    ) is
        l_claim_id    number;
        l_entity_type varchar2(30);
    begin
        if
            p_status is not null
            and p_status not in ( 'ERROR', 'PURGE_AND_REISSUE' )
        then
            update checks
            set
                status = p_status,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                check_id = p_check_id;

            if p_status in ( 'PURGED', 'READY' ) then
                for x in (
                    select
                        entity_id
                    from
                        checks
                    where
                            check_id = p_check_id
                        and entity_type = 'CLAIMN'
                ) loop
                    if p_status = 'READY' then
                        update claimn
                        set
                            released_date = sysdate,
                            released_by = p_user_id,
                            payment_release_date = sysdate,
                            payment_released_by = p_user_id,
                            claim_status =
                                case
                                    when claim_amount = claim_paid then
                                        'PAID'
                                    when claim_amount > claim_paid then
                                        'PARTIALLY_PAID'
                                end
                        where
                            claim_id = x.entity_id;

                        update payment_register
                        set
                            insufficient_fund_flag = 'Y'
                        where
                                claim_id = x.entity_id
                            and claim_id in (
                                select
                                    claim_id
                                from
                                    claimn
                                where
                                        claim_id = x.entity_id
                                    and claim_status = 'PARTIALLY_PAID'
                            );

                    end if;
       -- Purged means the check has been issued from sterling office
       -- and dont want to be issued through adminisource
                    if p_status = 'PURGED' then
                        update claimn
                        set
                            released_date = sysdate,
                            released_by = p_user_id,
                            payment_release_date = sysdate,
                            payment_released_by = p_user_id,
                            claim_status = 'PAID'
                        where
                                claim_id = x.entity_id
                            and claim_status in ( 'PENDING_APPROVAL', 'READY_TO_PAY' );

                    end if;

                end loop;

            end if;

        end if;

        if p_status = 'PURGE_AND_REISSUE' then
            update checks
            set
                status = p_status,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                check_id = p_check_id
            returning entity_id,
                      entity_type into l_claim_id, l_entity_type;

            insert into checks (
                check_id,
                acc_id,
                check_number,
                check_amount,
                check_date,
                mailed_date,
                issued_date,
                returned,
                entity_type,
                entity_id,
                source_system,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                status,
                check_source
            )
                select
                    checks_seq.nextval,
                    acc_id,
                    checks_seq.currval,
                    check_amount,
                    check_date,
                    mailed_date,
                    issued_date,
                    returned,
                    entity_type,
                    entity_id,
                    source_system,
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id
        --,  case when ENTITY_TYPE = 'EMPLOYER_PAYMENTS' THEN 'OPEN' ELSE 'READY' END
                    ,
                    case
                        when entity_type in ( 'BROKER_PAYMENTS', 'EMPLOYER_PAYMENTS' ) then
                            'OPEN'
                        else
                            'READY'
                    end,
                    check_source -- added by Joshi for 12155
                from
                    checks
                where
                    check_id = p_check_id;

            if l_entity_type = 'CLAIMN' then
                update claimn
                set
                    claim_status = decode(claim_status, 'PAID', 'READY_TO_PAY', claim_status)
                where
                    claim_id = l_claim_id;
   /* commented by Joshi for 8889.
    ELSE
       UPDATE EMPLOYER_PAYMENTS
       SET    check_number = ( SELECT check_number from checks where entity_id = l_claim_id
                                AND entity_type = 'EMPLOYER_PAYMENTS'
                                AND status = 'OPEN' and rownum = 1)
       WHERE  payment_register_id = l_claim_id;
   */
   -- Added by Joshi for 8889.

            elsif l_entity_type = 'EMPLOYER_PAYMENTS' then
                update employer_payments
                set
                    check_number = (
                        select
                            check_number
                        from
                            checks
                        where
                                entity_id = l_claim_id
                            and entity_type = 'EMPLOYER_PAYMENTS'
                            and status = 'OPEN'
                            and rownum = 1
                    ),
                    check_date = sysdate
                where
                    payment_register_id = l_claim_id;

            elsif l_entity_type = 'BROKER_PAYMENTS' then
                update broker_payments
                set
                    check_number = (
                        select
                            check_number
                        from
                            checks
                        where
                                entity_id = l_claim_id
                            and entity_type = 'BROKER_PAYMENTS'
                            and status = 'OPEN'
                            and rownum = 1
                    ),
                    transaction_number = (
                        select
                            check_number
                        from
                            checks
                        where
                                entity_id = l_claim_id
                            and entity_type = 'BROKER_PAYMENTS'
                            and status = 'OPEN'
                            and rownum = 1
                    )
                where
                    broker_payment_id = l_claim_id;
    -- code ends here 8889.
            end if;

        end if;

        if p_status = 'ERROR' then
            for x in (
                select
                    entity_id,
                    entity_type
                from
                    checks
                where
                    check_id = p_check_id
            ) loop
                if x.entity_type = 'CLAIMN' then
                    delete from payment b
                    where
                        claimn_id = x.entity_id;

                    update claimn
                    set
                        claim_status = 'ERROR',
                        note = '***Claim is marked as error by '
                               || get_user_name(p_user_id)
                               || ' on '
                               || to_char(sysdate, 'mm/dd/yyyy hh:mi:ss')
                    where
                        claim_id = x.entity_id;

                    update payment_register
                    set
                        cancelled_flag = 'Y',
                        claim_error_flag = 'Y',
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                        claim_id = x.entity_id;

                else
                    update payment_register
                    set
                        cancelled_flag = 'Y',
                        claim_error_flag = 'Y',
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                        payment_register_id = x.entity_id;

                end if;

                update checks
                set
                    status = 'CANCELLED',
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                    check_id = p_check_id;

            end loop;
        end if;

    end update_check_status;

    procedure insert_pay_receipt (
        p_pay_id       in number,
        p_check_amount in number,
        p_acc_id       in number,
        p_user_id      in number,
        x_check_number out number
    ) is
    begin
        insert into checks (
            check_id,
            acc_id,
            check_number,
            check_amount,
            check_date,
            entity_type,
            entity_id,
            source_system,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            status
        ) values ( checks_seq.nextval,
                   p_acc_id,
                   checks_seq.currval,
                   p_check_amount,
                   sysdate,
                   'PAYMENT',
                   p_pay_id,
                   'PAY_RECEIPT',
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id,
                   'READY' ) returning check_number into x_check_number;

    end insert_pay_receipt;

    procedure insert_check (
        p_claim_id     in number,
        p_check_amount in number,
        p_acc_id       in number,
        p_user_id      in number,
        p_status       in varchar2 default 'READY',
        p_source       in varchar2 default 'CLAIMN',
        x_check_number out number
    ) is
    begin
        insert into checks (
            check_id,
            acc_id,
            check_number,
            check_amount,
            check_date,
            entity_type,
            entity_id,
            source_system,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            status
        ) values ( checks_seq.nextval,
                   p_acc_id,
                   checks_seq.currval,
                   p_check_amount,
                   sysdate,
                   nvl(p_source, 'CLAIMN'),
                   p_claim_id,
                   'ADMINISOURCE',
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id,
                   nvl(p_status, 'READY') ) returning check_number into x_check_number;

    end insert_check;

    procedure send_check (
        p_entrp_id  in number,
        p_status    in varchar2,
        x_file_name out varchar2
    ) is

        l_file_id      number;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_sqlerrm      varchar2(32000);
        l_utl_id       utl_file.file_type;
  --  tpa CONSTANT varchar2(100) :='T002965' ||','|| 'Sterling Health Services Administrator' ||','|| '475 14th Street' ||','|| 'Suite 650' ||','|| 'Oakland' ||','|| 'CA' ||','|| '94612';
        l_check_number number;
        l_file_count   number;
    begin
        l_file_id := pc_debit_card.insert_file_seq('CHECK');
   -- l_file_name := '01STL'||TO_CHAR(SYSDATE,'YYYYMMDD')||'01';
        select
            count(*)
        into l_file_count
        from
            external_files
        where
                file_action = 'CHECK'
            and trunc(creation_date) = trunc(sysdate);

        l_file_name := '02'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '0'
                       || l_file_count;

        x_file_name := l_file_name;
        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;

        send_email_on_hra_fsa_checks('NORMAL');

    --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --production
        l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
        for x in (
            select
                c.claim_amount,
                c.claim_id,
                c.claim_paid,
                c.claim_pending,
                c.deductible_amount,
                case
                    when pr.claim_type in ( 'PROVIDER', 'PROVIDER_ONLINE', 'PROVIDER_EDI' ) then
                        'Y'
                    else
                        'N'
                end                                         provider_flag,
                pr.vendor_id,
                c.pers_id,
                pr.acc_id,
                substr(
                    pc_entrp.get_bps_acc_num_from_acc_id(pr.acc_id),
                    1,
                    18
                )                                           employer_id,
                substr(
                    pc_person.get_entrp_name(c.pers_id),
                    1,
                    50
                )                                           employer_name,
                substr(
                    case
                        when c.service_type in('HRA', 'HRP', 'HR5', 'HR4', 'ACO') then
                            'HRA'
                        when c.service_type = 'DCA' then
                            'DEP'
                        when c.service_type = 'UA1' then
                            'BIK'
                        when c.service_type = 'IIR' then
                            'INS'
                        else c.service_type
                    end, 1, 3)                                     service_type,
                chk.check_amount,
                c.prov_name,
                c.claim_code,
                c.claim_date_start,
                to_char(c.service_start_date, 'MM/DD/YYYY') service_date,
                case
                    when pr.claim_type in ( 'PROVIDER', 'PROVIDER_ONLINE' ) then
                        nvl(
                            get_patient_name(c.claim_id),
                            pc_person.get_person_name(c.pers_id)
                        )
                    else
                        pc_person.get_person_name(c.pers_id)
                end                                         patient_name,
                c.denied_amount,
                lead(c.claim_id, 1)
                over(
                    order by
                        rownum
                )                                           next_claim_id,
                chk.check_number,
                get_provider_acc_num(pr.vendor_id)          vendor_acc_num,
                regexp_replace(pr.memo, '[[:cntrl:]]', '')  memo
            from
                claimn           c,
                payment_register pr,
                checks           chk
            where
                c.claim_status in ( 'READY_TO_PAY', 'PARTIALLY_PAID' )
                and pr.claim_type in ( 'SUBSCRIBER', 'PROVIDER', 'SUBSCRIBER_ONLINE', 'PROVIDER_ONLINE' )
                and c.claim_id = pr.claim_id
                and chk.entity_type = 'CLAIMN'
                and chk.source_system = 'ADMINISOURCE'
                and chk.entity_id = c.claim_id
                and pc_account.acc_balance(pr.acc_id,
                                           c.plan_start_date,
                                           c.plan_end_date,
                                           pc_account.get_account_type(pr.acc_id),
                                           c.service_type) >= 0
                and chk.status = nvl(p_status, 'READY')
                and pr.vendor_id is not null
                and c.entrp_id = nvl(p_entrp_id, c.entrp_id)
                and not exists (
                    select
                        *
                    from
                        checks
                    where
                            checks.status = 'PURGE_AND_REISSUE'
                        and checks.entity_id = chk.entity_id
                        and chk.entity_type = checks.entity_type
                )
            union
            select
                c.claim_amount,
                c.claim_id,
                c.claim_paid,
                c.claim_pending,
                c.deductible_amount,
                case
                    when pr.claim_type in ( 'PROVIDER', 'PROVIDER_ONLINE', 'PROVIDER_EDI' ) then
                        'Y'
                    else
                        'N'
                end                                         provider_flag,
                pr.vendor_id,
                c.pers_id,
                pr.acc_id,
                substr(
                    pc_entrp.get_bps_acc_num_from_acc_id(pr.acc_id),
                    1,
                    18
                )                                           employer_id,
                substr(
                    pc_person.get_entrp_name(c.pers_id),
                    1,
                    50
                )                                           employer_name,
                substr(
                    case
                        when c.service_type in('HRA', 'HRP', 'HR5', 'HR4', 'ACO') then
                            'HRA'
                        when c.service_type = 'DCA' then
                            'DEP'
                        when c.service_type = 'UA1' then
                            'BIK'
                        when c.service_type = 'IIR' then
                            'INS'
                        else c.service_type
                    end, 1, 3)                                     service_type,
                chk.check_amount,
                c.prov_name,
                c.claim_code,
                c.claim_date_start,
                to_char(c.service_start_date, 'MM/DD/YYYY') service_date,
                case
                    when pr.claim_type in ( 'PROVIDER', 'PROVIDER_ONLINE' ) then
                        nvl(
                            get_patient_name(c.claim_id),
                            pc_person.get_person_name(c.pers_id)
                        )
                    else
                        pc_person.get_person_name(c.pers_id)
                end                                         patient_name,
                c.denied_amount,
                lead(c.claim_id, 1)
                over(
                    order by
                        rownum
                )                                           next_claim_id,
                chk.check_number,
                get_provider_acc_num(pr.vendor_id)          vendor_acc_num,
                regexp_replace(pr.memo, '[[:cntrl:]]', '')  memo
            from
                claimn           c,
                payment_register pr,
                checks           chk
            where
                pr.claim_type in ( 'SUBSCRIBER', 'PROVIDER', 'SUBSCRIBER_ONLINE', 'PROVIDER_ONLINE' )
                and c.claim_id = pr.claim_id
                and chk.entity_type = 'CLAIMN'
                and chk.source_system = 'ADMINISOURCE'
                and chk.entity_id = c.claim_id
                    --  AND  chk.entity_id = 1313117
                   --   AND  PC_ACCOUNT.ACC_BALANCE(PR.ACC_ID,C.PLAN_START_DATE,C.PLAN_END_DATE,PC_ACCOUNT.GET_ACCOUNT_TYPE(PR.ACC_ID),C.SERVICE_TYPE) >= 0
                and chk.status = nvl(p_status, 'READY')
                and chk.check_amount > 0
                and exists (
                    select
                        *
                    from
                        checks
                    where
                            checks.status = 'PURGE_AND_REISSUE'
                        and checks.entity_id = chk.entity_id
                        and chk.entity_type = checks.entity_type
                )
                and pr.vendor_id is not null
        ) loop
            l_line := 250
                      || ','
                      || 'T002965'
                      || ','
                      || l_file_id
                      || ','
                      || 1
                      || ','
                      || to_char(sysdate, 'mm/dd/yyyy');

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(x.claim_id);
     -- dbms_output.put_line(l_line);
     --Line 1
    -- INSERT_CHECK(x.claim_id,x.check_amount,x.acc_id,P_USER_ID,l_check_number);--userid is 1 for testing
            l_line := '01'
                      || ','
                      || tpa
                      || ','
                      || to_char(sysdate, 'mm/dd/yyyy')
                      || ','
                      || x.check_amount
                      || ','
                      || x.check_number
                      || ',"'
                      || x.employer_name
                      || '",'
                      || x.employer_id
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || x.provider_flag
                      || ','
                      || get_provider(x.claim_id);

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);
     --Line 2
            l_line := '02'
                      || ','
                      || get_employee(x.pers_id, x.acc_id)
                      || ','
                      || get_employee_address(x.pers_id);

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);
     --Line 3
            l_line := '03'
                      || ','
                      || x.claim_id
                      || --claim number
                       ','
                      || nvl(x.service_date,
                             to_char(x.claim_date_start, 'mm/dd/yyyy'))
                      || ','
                      || x.service_type
                      || --account_type
                       ',"'
                      || substr(x.memo, 1, 100)
                      || --Merchant
                       '",'
                      || x.claim_amount
                      || ','
                      || null
                      ||--prior amt
                       ','
                      || null
                      ||--offset amt
                       ','
                      || x.check_amount
                      || ','
                      || x.check_amount
                      || --total_amt
                       ','
                      || x.claim_id
                      || --manual claim num
                       ','
                      || x.deductible_amount
                      || --applied to deductible
                       ','
                      || null
                      || --exclusion amt
                       ','
                      || null
                      || --exclusion code
                       ','
                      || null
                      || --exclusion description
                       ','
                      || x.denied_amount
                      || ','
                      || null
                      || --denial error code
                       ','
                      || null
                      || --denial error desc
                       ','
                      || x.claim_pending
                      || --low funds amt
                       ','
                      || null
                      || --low funds error code
                       ','
                      || null
                      || -- low funds  desc
                       ','
                      || get_employee(x.pers_id, x.acc_id)
                      || ',"'
                      || substr(x.patient_name, 1, 50)
                      || --claimant_first_nam
                       '","'
                      || substr(x.patient_name, 51, 100)
                      || --claimant last name
                       '",'
                      || null
                      || --claimant middle
                       ',"'
                      || substr(x.vendor_acc_num, 1, 20)
                      || --account number
                       '",'
                      || null   --SCC
                      ;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);

     --Line 6
            l_line := '06';
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
    /* if x.next_claim_id is not null then  --not the last row
        UTL_FILE.PUT_LINE( file => l_utl_id , buffer => l_line );
        --dbms_output.put_line(l_line);
     else
        UTL_FILE.put( file => l_utl_id , buffer => l_line );
        --dbms_output.put(l_line);--testing

     end if;*/

            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

        end loop;

        utl_file.fclose(file => l_utl_id);
        if file_length(x_file_name, 'CHECKS_DIR') = 0 then
            x_file_name := null;
            update external_files
            set
                result_flag = 'Y',
                sent_flag = 'Y'
            where
                file_id = l_file_id;

        end if;

        commit;
    exception
        when others then
            rollback;
            raise_application_error(-20030, 'Check File Creation Process Failed. ' || sqlerrm);
    end send_check;

    procedure send_edi_check (
        p_entrp_id  in number,
        x_file_name out varchar2
    ) is

        l_file_id       number;
        l_file_name     varchar2(3200);
        l_line          varchar2(32000);
        l_sqlerrm       varchar2(32000);
        l_utl_id        utl_file.file_type;
  --  tpa CONSTANT varchar2(100) :='T002965' ||','|| 'Sterling Health Services Administrator' ||','|| '475 14th Street' ||','|| 'Suite 650' ||','|| 'Oakland' ||','|| 'CA' ||','|| '94612';
        l_check_number  number;
        l_file_count    number;
        l_prior_payment number := 0;
        l_claim_number  varchar2(1000);
    begin
        l_file_id := pc_debit_card.insert_file_seq('CHECK');
   -- l_file_name := '01STL'||TO_CHAR(SYSDATE,'YYYYMMDD')||'01';
        select
            count(*)
        into l_file_count
        from
            external_files
        where
                file_action = 'CHECK'
            and trunc(creation_date) = trunc(sysdate);

        l_file_name := '02'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '0'
                       || l_file_count;

        x_file_name := l_file_name;
        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;

        send_email_on_hra_fsa_checks('EDI');

    --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --production
        l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
        for x in (
            select
                c.claim_amount,
                c.service_start_date,
                c.service_end_date,
                c.claim_id,
                c.claim_paid,
                c.claim_pending,
                c.deductible_amount,
                case
                    when pr.claim_type in ( 'PROVIDER', 'PROVIDER_ONLINE', 'PROVIDER_EDI' ) then
                        'Y'
                    else
                        'N'
                end                                        provider_flag,
                pr.vendor_id,
                c.pers_id,
                pr.acc_id,
                substr(
                    pc_entrp.get_bps_acc_num_from_acc_id(pr.acc_id),
                    1,
                    18
                )                                          employer_id,
                substr(
                    pc_person.get_entrp_name(c.pers_id),
                    1,
                    50
                )                                          employer_name,
                substr(
                    case
                        when c.service_type in('HRA', 'HRP', 'HR5', 'HR4', 'ACO') then
                            'HRA'
                        when c.service_type = 'DCA' then
                            'DEP'
                        when c.service_type = 'UA1' then
                            'BIK'
                        when c.service_type = 'IIR' then
                            'INS'
                        else c.service_type
                    end, 1, 3)                                    service_type,
                chk.check_amount,
                c.prov_name,
                c.claim_code,
                c.claim_date_start,
                c.denied_amount,
                lead(c.claim_id, 1)
                over(
                    order by
                        rownum
                )                                          next_claim_id,
                chk.check_number,
                get_provider_acc_num(pr.vendor_id)         vendor_acc_num,
                regexp_replace(pr.memo, '[[:cntrl:]]', '') memo
            from
                claimn           c,
                payment_register pr,
                checks           chk
            where
                c.claim_status in ( 'READY_TO_PAY', 'PARTIALLY_PAID' )
                and pr.claim_type in ( 'SUBSCRIBER_EDI', 'PROVIDER_EDI' )
                and c.claim_id = pr.claim_id
                and chk.entity_type = 'CLAIMN'
                and chk.source_system = 'ADMINISOURCE'
                and chk.entity_id = c.claim_id
                and pc_account.acc_balance(pr.acc_id,
                                           c.plan_start_date,
                                           c.plan_end_date,
                                           pc_account.get_account_type(pr.acc_id),
                                           c.service_type) >= 0
                and chk.status = 'READY'
                 --     AND  pr.acc_num = 'FSA276680'
                and pr.vendor_id is not null
                and c.entrp_id = nvl(p_entrp_id, c.entrp_id)
        ) loop
            l_line := 250
                      || ','
                      || 'T002965'
                      || ','
                      || l_file_id
                      || ','
                      || 1
                      || ','
                      || to_char(sysdate, 'mm/dd/yyyy');

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(x.claim_id);
     -- dbms_output.put_line(l_line);
     --Line 1
    -- INSERT_CHECK(x.claim_id,x.check_amount,x.acc_id,P_USER_ID,l_check_number);--userid is 1 for testing
            l_line := '01'
                      || ','
                      || tpa
                      || ','
                      || to_char(sysdate, 'mm/dd/yyyy')
                      || ','
                      || x.check_amount
                      || ','
                      || x.check_number
                      || ',"'
                      || x.employer_name
                      || '",'
                      || x.employer_id
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || x.provider_flag
                      || ','
                      || get_provider(x.claim_id);

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);
     --Line 2
            l_line := '02'
                      || ','
                      || get_employee(x.pers_id, x.acc_id)
                      || ','
                      || get_employee_address(x.pers_id);

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);
     --Line 3
            l_prior_payment := 0;
            for xx in (
                select
                    sum(amount) amount
                from
                    payment
                where
                        claimn_id = x.claim_id
                    and ( pay_num is not null
                          or pay_num <> x.check_number )
            ) loop
                l_prior_payment := xx.amount;
            end loop;

            l_line := '03'
                      || ','
                      || x.claim_id
                      || --claim number
                       ','
                      || to_char(x.claim_date_start, 'mm/dd/yyyy')
                      || ','
                      || x.service_type
                      || --account_type
                       ',"'
                      || substr(x.memo, 1, 100)
                      || --Merchant
                       '",'
                      || x.claim_amount
                      || ','
                      || l_prior_payment
                      ||--prior amt
                       ','
                      || null
                      ||--offset amt
                       ','
                      || x.check_amount
                      || ','
                      || x.check_amount
                      || --total_amt
                       ','
                      || x.claim_id
                      || --manual claim num
                       ','
                      || x.deductible_amount
                      || --applied to deductible
                       ','
                      || null
                      || --exclusion amt
                       ','
                      || null
                      || --exclusion code
                       ','
                      || null
                      || --exclusion description
                       ','
                      || x.denied_amount
                      || ','
                      || null
                      || --denial error code
                       ','
                      || null
                      || --denial error desc
                       ','
                      || x.claim_pending
                      || --low funds amt
                       ','
                      || null
                      || --low funds error code
                       ','
                      || null
                      || -- low funds  desc
                       ','
                      || get_employee(x.pers_id, x.acc_id)
                      || ','
                      || null
                      || --claimant_first_nam
                       ','
                      || null
                      || --claimant last name
                       ','
                      || null
                      || --claimant middle
                       ',"'
                      || substr(x.vendor_acc_num, 1, 20)
                      || --account number
                       '",'
                      || null   --SCC
                      ;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);

            l_claim_number := pc_check_process.get_claim_number(x.claim_id);
     --Line 6
            l_line := '06'
                      || ','
                      || '"Reimbursement for services incurred between '
                      || to_char(x.service_start_date, 'MM/DD/YYYY')
                      || ' and '
                      || to_char(x.service_end_date, 'MM/DD/YYYY')
                      ||
                case
                    when l_claim_number is null then
                        ''
                    else ' and for claim number(s): '
                         || substr(
                        pc_check_process.get_claim_number(x.claim_id),
                        1,
                        500
                    )
                end
                      || '",';

            if x.next_claim_id is not null then  --not the last row
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
        --dbms_output.put_line(l_line);
            else
                utl_file.put(
                    file   => l_utl_id,
                    buffer => l_line
                );
        --dbms_output.put(l_line);--testing

            end if;

            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

        end loop;

        utl_file.fclose(file => l_utl_id);
        if file_length(x_file_name, 'CHECKS_DIR') = 0 then
            x_file_name := null;
            update external_files
            set
                result_flag = 'Y'
            where
                file_id = l_file_id;

        end if;

        commit;
    exception
        when others then
            rollback;
            raise_application_error(-20030, 'Check File Creation Process Failed. ' || sqlerrm);
    end send_edi_check;

    procedure send_hsa_check (
        p_entrp_id  in number,
        p_status    in varchar2,
        x_file_name out varchar2
    ) is

        l_file_id      number;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_sqlerrm      varchar2(32000);
        l_utl_id       utl_file.file_type;
 --   tpa CONSTANT varchar2(100) :='T002965' ||','|| 'Sterling Health Services Administrator' ||','|| '475 14th Street' ||','|| 'Suite 650' ||','|| 'Oakland' ||','|| 'CA' ||','|| '94612';
        l_check_number number;
        l_file_count   number;
    begin
        l_file_id := pc_debit_card.insert_file_seq('CHECK');
   -- l_file_name := '01STL'||TO_CHAR(SYSDATE,'YYYYMMDD')||'01';
        select
            count(*)
        into l_file_count
        from
            external_files
        where
                file_action = 'CHECK'
            and trunc(creation_date) = trunc(sysdate);

        l_file_name := '03'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '0'
                       || l_file_count;

        x_file_name := l_file_name;
        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;
    /*** Sending email to finance about the checks being mailed **/
--    pc_check_process.send_email_on_hsa_checks;

	-- Below added by Swamy for Ticket#9912 on 10/08/2021
   -- pc_check_process.send_email_on_lsa_checks;

    --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --production
        l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
        for x in (
            select
                c.claim_amount,
                c.claim_id,
                c.claim_paid,
                c.claim_pending,
                c.deductible_amount,
                case
                    when pr.claim_type in ( 'HSA_TRANSFER', 'PROVIDER', 'PROVIDER_ONLINE', 'OUTSIDE_INVESTMENT_TRANSFER' ) then
                        'Y'
                    else
                        'N'
                end                                 provider_flag,
                pr.vendor_id,
                c.pers_id,
                pr.acc_id,
                substr(
                    pc_entrp.get_bps_acc_num_from_acc_id(pr.acc_id),
                    1,
                    18
                )                                   employer_id,
                pc_person.get_entrp_name(c.pers_id) employer_name,
                                            --C.SERVICE_TYPE ,
                chk.check_amount,
                c.prov_name,
                c.claim_code,
                c.claim_date_start,
                c.denied_amount,
                lead(c.claim_id, 1)
                over(
                    order by
                        rownum
                )                                   next_claim_id,
                chk.check_number,
                case
                    when pr.claim_type = 'SUBSCRIBER'
                         and pr.note like 'Fee Deposit%' then
                        regexp_replace(pr.note, '[[:cntrl:]]', '')
                        || nvl(
                            regexp_replace(pr.memo, '[[:cntrl:]]', ''),
                            ''
                        )
                    when pr.claim_type = 'SUBSCRIBER' then
                        'Provider Name:'
                        || c.prov_name
                        || ' '' '
                        || nvl(
                            regexp_replace(pr.memo, '[[:cntrl:]]', ''),
                            ''
                        )
                    when pr.claim_type = 'PROVIDER'   then
                        regexp_replace(pr.note, '[[:cntrl:]]', '')
                        || ' '
                        || nvl(
                            regexp_replace(pr.memo, '[[:cntrl:]]', ''),
                            ''
                        )
                        || ' '
                        || ' Patient Name:'
                        || pr.patient_name
                    else
                        regexp_replace(pr.note, '[[:cntrl:]]', '')
                        || nvl(
                            regexp_replace(pr.memo, '[[:cntrl:]]', ''),
                            ''
                        )
                end                                 note,
                case
                    when pr.claim_type = 'SUBSCRIBER' then
                        pr.acc_num
                    else
                        get_provider_acc_num(pr.vendor_id)
                end                                 acc_num
            from
                claimn           c,
                payment_register pr,
                checks           chk
            where
                pr.claim_type in ( 'EMPLOYER', 'HSA_TRANSFER', 'SUBSCRIBER', 'PROVIDER', 'SUBSCRIBER_ONLINE',
                                   'PROVIDER_ONLINE', 'OUTSIDE_INVESTMENT_TRANSFER' )
                and c.claim_id = pr.claim_id
                and chk.entity_type in ( 'HSA_CLAIM', 'LSA_CLAIM' )    -- LSA_CLAIM added by Swamy for Ticket#9912 on 10/08/2021
                and chk.source_system = 'ADMINISOURCE'
                and chk.entity_id = c.claim_id
                and chk.check_amount > 0
              --   AND  PC_ACCOUNT.ACC_BALANCE(PR.ACC_ID) >= 0
                and chk.status = nvl(p_status, 'READY')
                and pr.vendor_id is not null
        ) loop
            l_line := 250
                      || ','
                      || 'T002965'
                      || ','
                      || l_file_id
                      || ','
                      || 1
                      || ','
                      || to_char(sysdate, 'mm/dd/yyyy');

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(x.claim_id);
     -- dbms_output.put_line(l_line);
     --Line 1
    -- INSERT_CHECK(x.claim_id,x.check_amount,x.acc_id,P_USER_ID,l_check_number);--userid is 1 for testing
            l_line := '01'
                      || ','
                      || tpa
                      || ','
                      || to_char(sysdate, 'mm/dd/yyyy')
                      || ','
                      || x.check_amount
                      || ','
                      || x.check_number
                      || ',"'
                      || substr(x.employer_name, 1, 50)
                      || '",'
                      || 'STLHSA,'
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || x.provider_flag;

   /*  IF x.provider_flag = 'N' THEN
       l_line := l_line  ||','||get_employee_name_address(x.pers_id);
     ELSE*/
            l_line := l_line
                      || ','
                      || get_provider(x.claim_id);
 --    END IF;
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);
     --Line 2
            l_line := '02'
                      || ','
                      || get_employee(x.pers_id, x.acc_id)
                      || ','
                      || get_employee_address(x.pers_id);

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);
     --Line 3
            l_line := '03'
                      || ','
                      || x.claim_id
                      || --claim number
                       ','
                      || to_char(x.claim_date_start, 'mm/dd/yyyy')
                      || ','
                      || null
                      || --account_type
                       ',"'
                      || substr(x.note, 1, 100)
                      || --Merchant
                       '",'
                      || x.claim_amount
                      || ','
                      || null
                      ||--prior amt
                       ','
                      || null
                      ||--offset amt
                       ','
                      || x.check_amount
                      || ','
                      || x.check_amount
                      || --total_amt
                       ','
                      || x.claim_id
                      || --manual claim num
                       ','
                      || x.deductible_amount
                      || --applied to deductible
                       ','
                      || null
                      || --exclusion amt
                       ','
                      || null
                      || --exclusion code
                       ','
                      || null
                      || --exclusion description
                       ','
                      || x.denied_amount
                      || ','
                      || null
                      || --denial error code
                       ','
                      || null
                      || --denial error desc
                       ','
                      || x.claim_pending
                      || --low funds amt
                       ','
                      || null
                      || --low funds error code
                       ','
                      || null
                      || -- low funds  desc
                       ','
                      || get_employee(x.pers_id, x.acc_id)
                      || ','
                      || null
                      || --claimant_first_nam
                       ','
                      || null
                      || --claimant last name
                       ','
                      || null
                      || --claimant middle
                       ','
                      || x.acc_num
                      || --account number
                       ','
                      || null   --SCC
                      ;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);

     --Line 6
            l_line := '06';
            if x.next_claim_id is not null then  --not the last row
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
        --dbms_output.put_line(l_line);
            else
                utl_file.put(
                    file   => l_utl_id,
                    buffer => l_line
                );
        --dbms_output.put(l_line);--testing

            end if;

            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

        end loop;

        utl_file.fclose(file => l_utl_id);
        if file_length(x_file_name, 'CHECKS_DIR') = 0 then
            update external_files
            set
                result_flag = 'Y',
                sent_flag = 'Y'
            where
                file_id = x_file_name;

            x_file_name := null;
        end if;

        commit;
        pc_check_process.send_email_on_hsa_checks(l_file_id);
    exception
        when others then
            rollback;
            raise_application_error(-20030, 'Check File Creation Process Failed. ' || sqlerrm);
    end send_hsa_check;

    procedure send_broker_check (
        p_broker_id in number,
        p_message   in varchar2,
        x_file_name out varchar2
    ) is

        l_file_id      number;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_sqlerrm      varchar2(32000);
        l_utl_id       utl_file.file_type;
--    tpa CONSTANT varchar2(100) :='T002965' ||','|| 'Sterling Health Services Administrator' ||','|| '475 14th Street' ||','|| 'Suite 650' ||','|| 'Oakland' ||','|| 'CA' ||','|| '94612';
        l_check_number number;
        l_file_count   number;
    begin
        l_file_id := pc_debit_card.insert_file_seq('BROKER_CHECK');
   -- l_file_name := '01STL'||TO_CHAR(SYSDATE,'YYYYMMDD')||'01';
        select
            count(*)
        into l_file_count
        from
            external_files
        where
                file_action = 'BROKER_CHECK'
            and trunc(creation_date) = trunc(sysdate);

        l_file_name := '04'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '0'
                       || l_file_count;

        x_file_name := l_file_name;
        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;
    /*** Sending email to finance about the checks being mailed **/
        pc_check_process.send_email_on_broker_checks;

    --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --production
        l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
        for x in (
            select
                pc_broker.get_broker_lic(pr.broker_id)                      broker_lic
                 --  , regexp_replace(pc_broker.get_broker_name(pr.broker_id),'[[:cntrl:]]','') broker_name --SK COMMENTED ON 10_02_2018
                ,
                regexp_replace(l.commissions_payable_to, '[[:cntrl:]]', '') broker_name,
                pr.period_start_date,
                pr.period_end_date,
                chk.check_number,
                chk.check_amount,
                chk.status,
                regexp_replace(pr.note, '[[:cntrl:]]', '')                  note,
                pr.broker_id,
                chk.check_date
            from
                broker_payments pr,
                checks          chk,
                broker          l -- Added by sk -10_02_2018
            where
                    chk.entity_type = 'BROKER_PAYMENTS'
                and chk.source_system = 'ADMINISOURCE'
                and chk.status in ( 'READY' )
                and pr.broker_id = l.broker_id -- Added by sk -10_02_2018
                and pr.transaction_number = chk.check_number
                and chk.entity_id = pr.broker_payment_id
        ) loop
            l_line := 250
                      || ','
                      || 'T002965'
                      || ','
                      || l_file_id
                      || ','
                      || 1
                      || ','
                      || to_char(sysdate, 'mm/dd/yyyy');

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(x.claim_id);
     -- dbms_output.put_line(l_line);
     --Line 1
    -- INSERT_CHECK(x.claim_id,x.check_amount,x.acc_id,P_USER_ID,l_check_number);--userid is 1 for testing
            l_line := '01'
                      || ','
                      || tpa
                      || ','
                      || to_char(sysdate, 'mm/dd/yyyy')
                      || ','
                      || x.check_amount
                      || ','
                      || x.check_number
                      || ',"'
                      || substr(x.broker_name, 1, 50)
                      || '",STLBROKER,'
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || 'Y';

   /*  IF x.provider_flag = 'N' THEN
       l_line := l_line  ||','||get_employee_name_address(x.pers_id);
     ELSE*/
            l_line := l_line
                      || ',"'
                      || substr(x.broker_name, 1, 100)
                      || '",'
                      || regexp_replace(
                get_broker_address(x.broker_id),
                '[[:cntrl:]]',
                ''
            );
 --    END IF;
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);
     --Line 2
            l_line := '02'
                      || ','
                      || get_broker(x.broker_id);
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);
     --Line 3
            l_line := '03'
                      || ','
                      || x.check_number
                      || --claim number
                       ','
                      || to_char(x.check_date, 'mm/dd/yyyy')
                      || ','
                      || null
                      || --account_type
                       ',"'
                      || substr(x.note, 1, 100)
                      || --Merchant
                       '",'
                      || x.check_amount
                      || ','
                      || null
                      ||--prior amt
                       ','
                      || null
                      ||--offset amt
                       ','
                      || x.check_amount
                      || ','
                      || x.check_amount
                      || --total_amt
                       ','
                      || null
                      || --manual claim num
                       ','
                      || null
                      || --applied to deductible
                       ','
                      || null
                      || --exclusion amt
                       ','
                      || null
                      || --exclusion code
                       ','
                      || null
                      || --exclusion description
                       ','
                      || null
                      || ','
                      || null
                      || --denial error code
                       ','
                      || null
                      || --denial error desc
                       ','
                      || null
                      || --low funds amt
                       ','
                      || null
                      || --low funds error code
                       ','
                      || null
                      || -- low funds  desc
                       ','
                      || get_broker_info(x.broker_id)
                      || ','
                      || null
                      || --claimant_first_nam
                       ','
                      || null
                      || --claimant last name
                       ','
                      || null
                      || --claimant middle
                       ',"'
                      || substr(x.broker_lic, 1, 20)
                      || --account number
                       '",'
                      || null   --SCC
                      ;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);

     --Line 6
            l_line := '06,'
                      || p_message
                      || ',';
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

        end loop;

        utl_file.fclose(file => l_utl_id);
        if file_length(x_file_name, 'CHECKS_DIR') = 0 then
            x_file_name := null;
            update external_files
            set
                result_flag = 'Y',
                sent_flag = 'Y'
            where
                file_id = l_file_id;

        end if;

        commit;
    exception
        when others then
            rollback;
            raise_application_error(-20030, 'Check File Creation Process Failed. ' || sqlerrm);
    end send_broker_check;

    procedure send_er_check (
        x_file_name out varchar2
    ) is

        l_file_id      number;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_sqlerrm      varchar2(32000);
        l_utl_id       utl_file.file_type;
 --   tpa CONSTANT varchar2(100) :='T002965' ||','|| 'Sterling Health Services Administrator' ||','|| '475 14th Street' ||','|| 'Suite 650' ||','|| 'Oakland' ||','|| 'CA' ||','|| '94612';
        l_check_number number;
        l_file_count   number;
    begin
        l_file_id := pc_debit_card.insert_file_seq('CHECK');

   -- l_file_name := '01STL'||TO_CHAR(SYSDATE,'YYYYMMDD')||'01';
        select
            count(*)
        into l_file_count
        from
            external_files
        where
                file_action = 'CHECK'
            and trunc(creation_date) = trunc(sysdate);

        l_file_name := '03'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '0'
                       || l_file_count;

        x_file_name := l_file_name;
        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;
    /*** Sending email to finance about the checks being mailed **/

        send_email_on_employer_checks;
    --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --production
        l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
        for x in (
            select
                c.check_amount,
                c.employer_payment_id                     claim_id,
                c.check_amount                            claim_paid,
                0                                         claim_pending,
                0                                         deductible_amount,
                'N'                                       provider_flag,
                pr.vendor_id,
                c.entrp_id,
                pr.acc_id,
                pc_entrp.get_bps_acc_num(c.entrp_id)      employer_id,
                regexp_replace(d.name, '[[:cntrl:]]', '') employer_name,
                regexp_replace(d.name, '[[:cntrl:]]', '') name,
                pr.claim_code,
                c.check_date,
                0                                         denied_amount,
                lead(c.payment_register_id, 1)
                over(
                    order by
                        rownum
                )                                         next_claim_id,
                chk.check_number,
                regexp_replace(c.memo, '[[:cntrl:]]', '') note,
                pr.acc_num,
                regexp_replace('"'
                               || substr(ve.vendor_name, 1, 50)
                               || '",'
                               || '"'
                               || replace(
                    replace(
                        replace((substr(ve.address1, 1, 75)
                                 || '"'
                                 || ',,'
                                 || substr(ve.city, 1, 30)
                                 || ','
                                 || substr(ve.state, 1, 30)
                                 || ','
                                 || substr(ve.zip, 1, 5)),
                                chr(94),
                                ' '),
                        chr(10)
                    ),
                    chr(13)
                ),
                               '[[:cntrl:]]',
                               '')                        provider_name,
                regexp_replace('"'
                               || substr(d.name, 1, 50)
                               || '",,,'
                               || pr.acc_num,
                               '[[:cntrl:]]',
                               '')                        employer,
                regexp_replace('"'
                               || replace(
                    replace(
                        replace((substr(ve.address1, 1, 75)
                                 || '"'
                                 || ',,'
                                 || substr(ve.city, 1, 30)
                                 || ','
                                 || substr(ve.state, 1, 30)
                                 || ','
                                 || substr(ve.zip, 1, 5)),
                                chr(94),
                                ' '),
                        chr(10)
                    ),
                    chr(13)
                ),
                               '[[:cntrl:]]',
                               '')                        employer_address
            from
                employer_payments c,
                payment_register  pr,
                checks            chk,
                enterprise        d,
                vendors           ve,
                account           acc
            where
                    pr.claim_type = 'EMPLOYER'
                and d.entrp_id = c.entrp_id
                and acc.entrp_id = d.entrp_id
                and acc.account_type not in ( 'COBRA', 'FSA', 'HRA' )/**Ticket6497 ***/
                and pr.vendor_id = ve.vendor_id
                and chk.check_amount > 0
                and c.payment_register_id = pr.payment_register_id
                and chk.entity_type = 'EMPLOYER_PAYMENTS'
                and chk.source_system = 'ADMINISOURCE'
                and chk.entity_id = c.payment_register_id
                and chk.status = 'READY'
        ) loop
            l_line := 250
                      || ','
                      || 'T002965'
                      || ','
                      || l_file_id
                      || ','
                      || 1
                      || ','
                      || to_char(sysdate, 'mm/dd/yyyy');

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(x.claim_id);
     -- dbms_output.put_line(l_line);
     --Line 1
    -- INSERT_CHECK(x.claim_id,x.check_amount,x.acc_id,P_USER_ID,l_check_number);--userid is 1 for testing

            l_line := '01'
                      || ','
                      || tpa
                      || ','
                      || to_char(sysdate, 'mm/dd/yyyy')
                      || ','
                      || x.check_amount
                      || ','
                      || x.check_number
                      || ',"'
                      || substr(x.employer_name, 1, 40)
                      || '",'
                      || 'STLHSA,'
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || x.provider_flag;

   /*  IF x.provider_flag = 'N' THEN
       l_line := l_line  ||','||get_employee_name_address(x.pers_id);
     ELSE*/
            l_line := l_line
                      || ','
                      || x.provider_name;
 --    END IF;
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);
     --Line 2
            l_line := '02'
                      || ','
                      || x.employer
                      || ','
                      || x.employer_address;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);
     --Line 3
            l_line := '03'
                      || ','
                      || x.claim_id
                      || --claim number
                       ','
                      || to_char(x.check_date, 'mm/dd/yyyy')
                      || ','
                      || null
                      || --account_type
                       ',"'
                      || substr(x.note, 1, 100)
                      || --Merchant
                       '",'
                      || x.check_amount
                      || ','
                      || null
                      ||--prior amt
                       ','
                      || null
                      ||--offset amt
                       ','
                      || x.check_amount
                      || ','
                      || x.check_amount
                      || --total_amt
                       ','
                      || x.claim_id
                      || --manual claim num
                       ','
                      || x.deductible_amount
                      || --applied to deductible
                       ','
                      || null
                      || --exclusion amt
                       ','
                      || null
                      || --exclusion code
                       ','
                      || null
                      || --exclusion description
                       ','
                      || x.denied_amount
                      || ','
                      || null
                      || --denial error code
                       ','
                      || null
                      || --denial error desc
                       ','
                      || x.claim_pending
                      || --low funds amt
                       ','
                      || null
                      || --low funds error code
                       ','
                      || null
                      || -- low funds  desc
                       ','
                      || x.employer
                      || ','
                      || null
                      || --claimant_first_nam
                       ','
                      || null
                      || --claimant last name
                       ','
                      || null
                      || --claimant middle
                       ','
                      || x.acc_num
                      || --account number
                       ','
                      || null   --SCC
                      ;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);

     --Line 6
            l_line := '06';
            if x.next_claim_id is not null then  --not the last row
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
        --dbms_output.put_line(l_line);
            else
                utl_file.put(
                    file   => l_utl_id,
                    buffer => l_line
                );
        --dbms_output.put(l_line);--testing

            end if;

            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

        end loop;

        utl_file.fclose(file => l_utl_id);
        if file_length(x_file_name, 'CHECKS_DIR') = 0 then
            x_file_name := null;
            update external_files
            set
                result_flag = 'Y',
                sent_flag = 'Y'
            where
                file_id = l_file_id;

        end if;

        commit;
    exception
        when others then
            rollback;
            raise_application_error(-20030, 'Check File Creation Process Failed. ' || sqlerrm);
    end send_er_check;

    procedure send_cobra_check (
        x_file_name out varchar2
    ) is

        l_file_id      number;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_sqlerrm      varchar2(32000);
        l_utl_id       utl_file.file_type;
 --   tpa CONSTANT varchar2(100) :='T002965' ||','|| 'Sterling Health Services Administrator' ||','|| '475 14th Street' ||','|| 'Suite 650' ||','|| 'Oakland' ||','|| 'CA' ||','|| '94612';
        l_check_number number;
        l_file_count   number;
    begin
        l_file_id := pc_debit_card.insert_file_seq('CHECK');

   -- l_file_name := '01STL'||TO_CHAR(SYSDATE,'YYYYMMDD')||'01';
        select
            count(*)
        into l_file_count
        from
            external_files
        where
                file_action = 'CHECK'
            and trunc(creation_date) = trunc(sysdate);

        l_file_name := '05'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '0'
                       || l_file_count;

        x_file_name := l_file_name;
        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;
    /*** Sending email to finance about the checks being mailed **/

        send_email_on_cobra_checks;
    --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --production
        l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
        for x in (
            select
                c.check_amount,
                c.employer_payment_id                     claim_id,
                c.check_amount                            claim_paid,
                0                                         claim_pending,
                0                                         deductible_amount,
                'N'                                       provider_flag,
                pr.vendor_id,
                c.entrp_id,
                pr.acc_id,
                pc_entrp.get_bps_acc_num(c.entrp_id)      employer_id,
                regexp_replace(d.name, '[[:cntrl:]]', '') employer_name,
                regexp_replace(d.name, '[[:cntrl:]]', '') name,
                pr.claim_code,
                c.check_date,
                0                                         denied_amount,
                lead(c.payment_register_id, 1)
                over(
                    order by
                        rownum
                )                                         next_claim_id,
                chk.check_number,
                regexp_replace(c.note, '[[:cntrl:]]', '') note,
                pr.acc_num,
                regexp_replace('"'
                               || substr(ve.vendor_name, 1, 50)
                               || '",'
                               || '"'
                               || replace(
                    replace(
                        replace((substr(ve.address1, 1, 75)
                                 || '"'
                                 || ',,'
                                 || substr(ve.city, 1, 30)
                                 || ','
                                 || substr(ve.state, 1, 30)
                                 || ','
                                 || substr(ve.zip, 1, 5)),
                                chr(94),
                                ' '),
                        chr(10)
                    ),
                    chr(13)
                ),
                               '[[:cntrl:]]',
                               '')                        provider_name,
                regexp_replace('"'
                               || substr(d.name, 1, 50)
                               || '",,,'
                               || pr.acc_num,
                               '[[:cntrl:]]',
                               '')                        employer,
                regexp_replace('"'
                               || replace(
                    replace(
                        replace((substr(ve.address1, 1, 75)
                                 || '"'
                                 || ',,'
                                 || substr(ve.city, 1, 30)
                                 || ','
                                 || substr(ve.state, 1, 30)
                                 || ','
                                 || substr(ve.zip, 1, 5)),
                                chr(94),
                                ' '),
                        chr(10)
                    ),
                    chr(13)
                ),
                               '[[:cntrl:]]',
                               '')                        employer_address
            from
                employer_payments c,
                payment_register  pr,
                checks            chk,
                enterprise        d,
                vendors           ve,
                account           acc
	--	WHERE   pr.claim_type = 'COBRA_DISBURSEMENT'
            where
                pr.claim_type in ( 'COBRA_DISBURSEMENT', 'COBRA_PAYMENTS' )   -- commneted above and added by Joshi for 11603
                and d.entrp_id = c.entrp_id
                and acc.entrp_id = d.entrp_id
                and acc.account_type = 'COBRA'
                and pr.vendor_id = ve.vendor_id
                and chk.check_amount > 0
                and c.payment_register_id = pr.payment_register_id
                and chk.entity_type = 'EMPLOYER_PAYMENTS'
                and chk.source_system = 'ADMINISOURCE'
                and chk.entity_id = c.payment_register_id
                and chk.status = 'READY'
        ) loop
            l_line := 250
                      || ','
                      || 'T002965'
                      || ','
                      || l_file_id
                      || ','
                      || 1
                      || ','
                      || to_char(sysdate, 'mm/dd/yyyy');

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(x.claim_id);
     -- dbms_output.put_line(l_line);
     --Line 1
    -- INSERT_CHECK(x.claim_id,x.check_amount,x.acc_id,P_USER_ID,l_check_number);--userid is 1 for testing

            l_line := '01'
                      || ','
                      || tpa
                      || ','
                      || to_char(sysdate, 'mm/dd/yyyy')
                      || ','
                      || x.check_amount
                      || ','
                      || x.check_number
                      || ',"'
                      || substr(x.employer_name, 1, 40)
                      || '",'
                      || 'STLCOB,'
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || x.provider_flag;

   /*  IF x.provider_flag = 'N' THEN
       l_line := l_line  ||','||get_employee_name_address(x.pers_id);
     ELSE*/
            l_line := l_line
                      || ','
                      || x.provider_name;
 --    END IF;
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);
     --Line 2
            l_line := '02'
                      || ','
                      || x.employer
                      || ','
                      || x.employer_address;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);
     --Line 3
            l_line := '03'
                      || ','
                      || x.claim_id
                      || --claim number
                       ','
                      || to_char(x.check_date, 'mm/dd/yyyy')
                      || ','
                      || null
                      || --account_type
                       ',"'
                      || substr(x.note, 1, 100)
                      || --Merchant
                       '",'
                      || x.check_amount
                      || ','
                      || null
                      ||--prior amt
                       ','
                      || null
                      ||--offset amt
                       ','
                      || x.check_amount
                      || ','
                      || x.check_amount
                      || --total_amt
                       ','
                      || x.claim_id
                      || --manual claim num
                       ','
                      || x.deductible_amount
                      || --applied to deductible
                       ','
                      || null
                      || --exclusion amt
                       ','
                      || null
                      || --exclusion code
                       ','
                      || null
                      || --exclusion description
                       ','
                      || x.denied_amount
                      || ','
                      || null
                      || --denial error code
                       ','
                      || null
                      || --denial error desc
                       ','
                      || x.claim_pending
                      || --low funds amt
                       ','
                      || null
                      || --low funds error code
                       ','
                      || null
                      || -- low funds  desc
                       ','
                      || x.employer
                      || ','
                      || null
                      || --claimant_first_nam
                       ','
                      || null
                      || --claimant last name
                       ','
                      || null
                      || --claimant middle
                       ','
                      || x.acc_num
                      || --account number
                       ','
                      || null   --SCC
                      ;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);

     --Line 6
            l_line := '06';
            if x.next_claim_id is not null then  --not the last row
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
        --dbms_output.put_line(l_line);
            else
                utl_file.put(
                    file   => l_utl_id,
                    buffer => l_line
                );
        --dbms_output.put(l_line);--testing

            end if;

            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

        end loop;

        utl_file.fclose(file => l_utl_id);
        if file_length(x_file_name, 'CHECKS_DIR') = 0 then
            x_file_name := null;
            update external_files
            set
                result_flag = 'Y',
                sent_flag = 'Y'
            where
                file_id = l_file_id;

        end if;

        commit;
    exception
        when others then
            rollback;
            raise_application_error(-20030, 'Check File Creation Process Failed. ' || sqlerrm);
    end send_cobra_check;

    procedure process_check_result (
        p_file_name in varchar2
    ) is

        l_claimn_id    number;
        app_exception exception;
        l_error_msg    varchar2(100);
        ctr            number := 0;
        l_sqlerrm      varchar2(100);
        l_check_amount number := 0;
        l_entity_type  varchar2(30);
    begin
        if file_length(p_file_name, 'CHECKS_DIR') > 0 then
            begin
                execute immediate '
                   ALTER TABLE check_external
                    location (CHECKS_DIR:'''
                                  || p_file_name
                                  || ''')';
                update external_files
                set
                    result_flag = 'Y'
                where
                    file_name = replace(p_file_name, 'Receipt_');

            exception
                when others then
                    l_sqlerrm := 'Error in Changing location of checks file' || sqlerrm;
                    pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  ' || p_file_name
                    );
                    raise app_exception;
            end;

            for x in (
                select
                    to_number(a.check_number)        check_number,
                    b.acc_id,
                    b.pers_id,
                    to_date(check_dt, 'MM/DD/YYYY')  check_date,
                    to_date(mailed_dt, 'MM/DD/YYYY') mailed_date,
                    ch.check_amount
                from
                    check_external a,
                    account        b,
                    checks         ch
                where
                        a.acc_num = b.acc_num
                    and to_number(a.check_number) = ch.check_number
            )
  --for x in(select * from check_external_test)
             loop
                l_claimn_id := null;
                ctr := ctr + 1;
                begin
                    update checks ch
                    set
                        ch.check_date = x.check_date,
                        ch.mailed_date = x.mailed_date,
                        status = 'MAILED',
                        last_updated_by = 0,
                        last_update_date = sysdate
                    where
                            ch.check_number = x.check_number
                        and ch.acc_id = x.acc_id
                        and ch.source_system = 'ADMINISOURCE'
                        and ch.entity_type in ( 'HSA_CLAIM', 'CLAIMN', 'EMPLOYER_PAYMENTS', 'LSA_CLAIM' )   -- LSA_CLAIM added by Swamy for Ticket#9912 on 10/08/2021
                    returning entity_id,
                              entity_type into l_claimn_id, l_entity_type;

                    update checks ch
                    set
                        ch.check_date = x.check_date,
                        ch.mailed_date = x.mailed_date,
                        status = 'MAILED',
                        last_updated_by = 0,
                        last_update_date = sysdate
                    where
                            ch.check_number = x.check_number
                        and ch.acc_id = x.acc_id
                        and ch.source_system = 'ADMINISOURCE'
                        and ch.check_source = 'MANUAL'
                        and ch.entity_type in ( 'EMPLOYER_PAY', 'INVOICE', 'LIST_BILL', 'COBRA_DISBURSE', 'EMPLOYEE_HSA_CLAIM',
                                                'EMPLOYEE_HRAFSA_CLAIM' );

                    if l_entity_type = 'EMPLOYER_PAYMENTS' then
                        update employer_payments
                        set
                            check_number = x.check_number,
                            check_date = x.check_date,
                            last_updated_by = 0,
                            last_update_date = sysdate
                        where
                            payment_register_id = l_claimn_id;

                        update payment_register
                        set
                            peachtree_interfaced = 'Y',
                            last_update_date = sysdate
                        where
                            payment_register_id = l_claimn_id;

                    else
                        update payment p
                        set
                            pay_num = x.check_number,
                            last_updated_by = 0,
                            last_updated_date = sysdate,
                            paid_date = sysdate
                        where
                                p.claimn_id = l_claimn_id
                            and pay_num is null
                            and amount = x.check_amount
        --    and    reason_code in (11,12)
                            and acc_id = x.acc_id;
          --  and    NVL(debit_card_posted,'N') = 'N';

            -- updating for purge and reissue
                        update payment p
                        set
                            pay_num = x.check_number,
                            last_updated_by = 0,
                            last_updated_date = sysdate,
                            paid_date = sysdate
                        where
                                p.claimn_id = l_claimn_id
                            and pay_num is not null
                            and amount = x.check_amount
        --    and    reason_code in (11,12)
                            and exists (
                                select
                                    *
                                from
                                    checks
                                where
                                        p.pay_num = checks.check_number
                                    and status = 'PURGE_AND_REISSUE'
                                    and entity_type in ( 'HSA_CLAIM', 'CLAIM', 'CLAIMN', 'LSA_CLAIM' )   -- LSA_CLAIM added by Swamy for Ticket#9912 on 10/08/2021
                                    and entity_id = p.claimn_id
                            )
                            and acc_id = x.acc_id;

                        update claimn
                        set
                            claim_status =
                                case
                                    when claim_pending > 0 then
                                        'PARTIALLY_PAID'
                                    else
                                        'PAID'
                                end
                        where
                                claim_id = l_claimn_id
                            and pers_id = x.pers_id;

                        update payment_register
                        set
                            peachtree_interfaced = 'Y',
                            last_update_date = sysdate
                        where
                            claim_id = l_claimn_id;

                    end if;
            --review
           -- pc_claim.update_claim_totals(l_claimn_id);
           -- pc_claim.update_claim_status(l_claimn_id);
                exception
                    when app_exception then
                        pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  '
                                                                                                 || p_file_name
                                                                                                 || ' Error '
                                                                                                 || sqlerrm);
                end;

            end loop;

        end if;

        update external_files
        set
            result_flag = 'Y'
        where
            ( file_length(file_name, 'CHECKS_DIR') = 0
              or file_exists(file_name, 'CHECKS_DIR') <> 'TRUE' )
            and result_flag is null
            and file_action = 'CHECK';

        pc_log.log_error('pc_check_process.process_check_result',
                         'REPLACE(p_file_name,Receipt_) ' || replace(p_file_name, 'Receipt_'));
        pc_webservice_batch.upd_edi_repo_file_process_flag(
            p_file_name   => 'Receipt_' || p_file_name,
            p_vendor_name => 'EMDEON',
            p_feed_type   => 'ADMINISOURCE'
        );  -- Added by Swamy for Server Migration

    exception
        when app_exception then
            pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  '
                                                                                     || p_file_name
                                                                                     || ' Error '
                                                                                     || sqlerrm);
        when others then
            rollback;
            pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  '
                                                                                     || p_file_name
                                                                                     || ' Error '
                                                                                     || sqlerrm);
    end process_check_result;

    procedure process_broker_check_result (
        p_file_name in varchar2
    ) is

        l_claimn_id    number;
        app_exception exception;
        l_error_msg    varchar2(100);
        ctr            number := 0;
        l_sqlerrm      varchar2(100);
        l_check_amount number := 0;
    begin
        begin
            execute immediate '
                   ALTER TABLE check_external
                    location (CHECKS_DIR:'''
                              || p_file_name
                              || ''')';
            update external_files
            set
                result_flag = 'Y'
            where
                file_name = replace(p_file_name, 'Receipt_');

        exception
            when others then
                l_sqlerrm := 'Error in Changing location of checks file' || sqlerrm;
                pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  ' || p_file_name
                );
                raise app_exception;
        end;

        for x in (
            select
                a.check_number,
                b.broker_id,
                to_date(check_dt, 'MM/DD/YYYY')  check_date,
                to_date(mailed_dt, 'MM/DD/YYYY') mailed_date
            from
                check_external a,
                broker         b
            where
                a.acc_num = b.broker_lic
        )
  --for x in(select * from check_external_test)
         loop
            l_claimn_id := null;
            ctr := ctr + 1;
            begin
                update checks ch
                set
                    ch.check_date = x.check_date,
                    ch.mailed_date = x.mailed_date,
                    status = 'MAILED',
                    last_updated_by = 0,
                    last_update_date = sysdate
                where
                        ch.check_number = x.check_number
                    and ch.source_system = 'ADMINISOURCE'
                    and ch.entity_type in ( 'BROKER_PAYMENTS' );



            --review
           -- pc_claim.update_claim_totals(l_claimn_id);
           -- pc_claim.update_claim_status(l_claimn_id);
            exception
                when app_exception then
                    pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  '
                                                                                             || p_file_name
                                                                                             || ' Error '
                                                                                             || sqlerrm);
            end;

        end loop;

    exception
        when app_exception then
            pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  '
                                                                                     || p_file_name
                                                                                     || ' Error '
                                                                                     || sqlerrm);
        when others then
            rollback;
            pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  '
                                                                                     || p_file_name
                                                                                     || ' Error '
                                                                                     || sqlerrm);
    end process_broker_check_result;

    function check_mailed (
        p_entity_id   in varchar2,
        p_entity_type in varchar2
    ) return varchar2 is
        l_flag varchar2(1);
    begin
        for x in (
            select
                *
            from
                checks
            where
                    entity_id = p_entity_id
                and entity_type = p_entity_type
                and status = 'MAILED'
        ) loop
            l_flag := 'Y';
        end loop;

        return nvl(l_flag, 'N');
    end;

    function check_created (
        p_entity_id   in varchar2,
        p_entity_type in varchar2
    ) return varchar2 is
        l_flag varchar2(1);
    begin
        for x in (
            select
                *
            from
                checks
            where
                    entity_id = p_entity_id
                and entity_type = p_entity_type
        ) loop
            l_flag := 'Y';
        end loop;

        return nvl(l_flag, 'N');
    end;

    procedure update_unmailed_checks (
        p_claim_id      in number,
        p_amount        in number,
        p_claim_amount  in number,
        p_check_id      in number,
        p_acc_status    in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
        l_account_type varchar2(10);   -- Added by Swamy for Ticket#9912 on 10/08/2021
    begin
        for x in (
            select distinct
                a.acc_id,
                b.check_amount,
                a.pay_date,
                a.paid_date,
                a.pay_num,
                a.reason_code
            from
                payment          a,
                checks           b,
                payment_register c
            where
                    a.claimn_id = p_claim_id
                and a.claimn_id = b.entity_id
                and a.claimn_id = c.claim_id
                and a.reason_code = c.pay_reason
                   --AND a.reason_code = apex_application.g_f06(apex_application.g_f01(i))
        ) loop
                   -- Added by Swamy for Ticket#9912 on 10/08/2021
            l_account_type := null;
            l_account_type := pc_account.get_account_type(x.acc_id);
            l_account_type := nvl(l_account_type, 'HSA');
                   -- End of addition by Swamy 9912

                    --Create negative payment for the org amount
            insert into payment (
                change_num,
                acc_id,
                pay_date,
                amount,
                reason_code,
                claimn_id,
                pay_num,
                note,
                plan_type,
                paid_date
            ) values ( change_seq.nextval,
                       x.acc_id,
                       x.pay_date,
                       - ( x.check_amount ),
                       x.reason_code,
                       p_claim_id,
                       x.pay_num,
                       'Creating negative payment after updating the Check amount',
                       l_account_type   -- 'HSA' replaced with l_account_type by Swamy for Ticket#9912 on 10/08/2021
                       ,
                       sysdate );

                     --Create new payment for the updated amount
            insert into payment (
                change_num,
                acc_id,
                pay_date,
                amount,
                reason_code,
                claimn_id,
                pay_num,
                note,
                plan_type,
                paid_date
            ) values ( change_seq.nextval,
                       x.acc_id,
                       x.pay_date,
                       p_amount--Updated amount
                       ,
                       x.reason_code,
                       p_claim_id --Claim ID
                       ,
                       x.pay_num,
                       'Creating new payment after updating the Check amount',
                       l_account_type   -- 'HSA' replaced with l_account_type by Swamy for Ticket#9912 on 10/08/2021
                       ,
                       sysdate );

        end loop;

        update checks
        set
            check_amount = p_amount
        where
            check_number = p_check_id;

        if
            p_amount < p_claim_amount
            and p_acc_status in ( 1, 2 )
        then --Acct is not closed
            --Paid Amount will be equal to the new updated amount
            update claimn
            set
                claim_paid = p_amount,
                claim_pending = p_claim_amount - p_amount,
                claim_status = 'PARTIALLY_PAID'
            where
                claim_id = p_claim_id;

            update payment_register
            set
                insufficient_fund_flag = 'Y'
            where
                claim_id = p_claim_id;

        else  --If acct is closed .These records do not go to the NSF screen
            update claimn
            set
                claim_paid = p_amount,
                claim_amount = p_amount,
                claim_pending = 0
            where
                claim_id = p_claim_id;

              -- UPDATE PAYMENT_REGISTER
               --set claim_amount = p_amount
               --WHERE claim_id = p_claim_id;

        end if;

        x_error_status := 'S';
    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end update_unmailed_checks;

    function get_paid_amount (
        p_claim_id in number
    ) return number is
        v_tot_amt number;
        v_pay_amt number;
        v_chk_amt number;
    begin
  --BEGIN
   -- SELECT sum(CHECK_AMOUNT)
    --INTO v_chk_amt
    --FROM CHECKS
    --WHERE entity_id = p_claim_id
    --AND STATUS in ('READY','SENT','MAILED');
   --EXCEPTION
    --WHEN OTHERS THEN
     -- v_chk_amt := 0;
   --END ;

        begin
            select
                nvl(
                    sum(amount),
                    0
                )
            into v_pay_amt
            from
                payment    a,
                pay_reason b
            where
                    claimn_id = p_claim_id
                and a.reason_code = b.reason_code
                and b.reason_type = 'DISBURSEMENT';

        exception
            when others then
                v_pay_amt := 0;
        end;

        return v_pay_amt;

  --Ask For every check there is a payment created. Only in case of unknow issues ,payment does not get created
  --So total amt cannot be sum of tthese 2 ?
  --IF v_chk_amt > v_pay_amt THEN
    --p_tot_amt := v_chk_amt + v_pay_amt ;
    --p_error_status := 'E' ;
  --ELSE
    --p_tot_amt := v_chk_amt ;
   -- p_error_status := 'S';
  --END IF;

    end get_paid_amount;

    procedure update_file_status (
        p_file_name     in varchar2,
        p_file_status   in varchar2,
        p_error_message in varchar2
    ) is
    begin
        update external_files
        set
            sent_flag = p_file_status,
            error_message = p_error_message
        where
            file_name = p_file_name;

    end update_file_status;

/**Ticket#6497 ****/
    procedure send_fsa_hra_er_check (
        x_file_name out varchar2
    ) is

        l_file_id      number;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_sqlerrm      varchar2(32000);
        l_utl_id       utl_file.file_type;
 --   tpa CONSTANT varchar2(100) :='T002965' ||','|| 'Sterling Health Services Administrator' ||','|| '475 14th Street' ||','|| 'Suite 650' ||','|| 'Oakland' ||','|| 'CA' ||','|| '94612';
        l_check_number number;
        l_file_count   number;
    begin
        l_file_id := pc_debit_card.insert_file_seq('CHECK');

   -- l_file_name := '01STL'||TO_CHAR(SYSDATE,'YYYYMMDD')||'01';
        select
            count(*)
        into l_file_count
        from
            external_files
        where
                file_action = 'CHECK'
            and trunc(creation_date) = trunc(sysdate);

        l_file_name := '02'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '0'
                       || l_file_count;

        x_file_name := l_file_name;
        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;
    /*** Sending email to finance about the checks being mailed **/

        send_email_on_employer_checks;
    --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --production
        l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
        for x in (
            select
                c.check_amount,
                c.employer_payment_id                     claim_id,
                c.check_amount                            claim_paid,
                0                                         claim_pending,
                0                                         deductible_amount,
                'N'                                       provider_flag,
                pr.vendor_id,
                c.entrp_id,
                pr.acc_id,
                pc_entrp.get_bps_acc_num(c.entrp_id)      employer_id,
                regexp_replace(d.name, '[[:cntrl:]]', '') employer_name,
                regexp_replace(d.name, '[[:cntrl:]]', '') name,
                pr.claim_code,
                c.check_date,
                0                                         denied_amount,
                lead(c.payment_register_id, 1)
                over(
                    order by
                        rownum
                )                                         next_claim_id,
                chk.check_number,
                regexp_replace(c.memo, '[[:cntrl:]]', '') note,
                pr.acc_num,
                regexp_replace('"'
                               || substr(ve.vendor_name, 1, 50)
                               || '",'
                               || '"'
                               || replace(
                    replace(
                        replace((substr(ve.address1, 1, 75)
                                 || '"'
                                 || ',,'
                                 || substr(ve.city, 1, 30)
                                 || ','
                                 || substr(ve.state, 1, 30)
                                 || ','
                                 || substr(ve.zip, 1, 5)),
                                chr(94),
                                ' '),
                        chr(10)
                    ),
                    chr(13)
                ),
                               '[[:cntrl:]]',
                               '')                        provider_name,
                regexp_replace('"'
                               || substr(d.name, 1, 50)
                               || '",,,'
                               || pr.acc_num,
                               '[[:cntrl:]]',
                               '')                        employer,
                regexp_replace('"'
                               || replace(
                    replace(
                        replace((substr(ve.address1, 1, 75)
                                 || '"'
                                 || ',,'
                                 || substr(ve.city, 1, 30)
                                 || ','
                                 || substr(ve.state, 1, 30)
                                 || ','
                                 || substr(ve.zip, 1, 5)),
                                chr(94),
                                ' '),
                        chr(10)
                    ),
                    chr(13)
                ),
                               '[[:cntrl:]]',
                               '')                        employer_address,
                substr(
                    case
                        when c.plan_type in('HRA', 'HRP', 'HR5', 'HR4', 'ACO') then
                            'HRA'
                        when c.plan_type = 'DCA' then
                            'DEP'
                        when c.plan_type = 'UA1' then
                            'BIK'
                        when c.plan_type = 'IIR' then
                            'INS'
                        else c.plan_type
                    end, 1, 3)                                   plan_type
            from
                employer_payments c,
                payment_register  pr,
                checks            chk,
                enterprise        d,
                vendors           ve,
                account           acc
            where
                    pr.claim_type = 'EMPLOYER'
                and d.entrp_id = c.entrp_id
                and acc.entrp_id = d.entrp_id
                and acc.account_type in ( 'FSA', 'HRA' )
                and pr.vendor_id = ve.vendor_id
                and chk.check_amount > 0
                and c.payment_register_id = pr.payment_register_id
                and chk.entity_type = 'EMPLOYER_PAYMENTS'
                and chk.source_system = 'ADMINISOURCE'
                and chk.entity_id = c.payment_register_id
                and chk.status = 'READY'
        ) loop
            l_line := 250
                      || ','
                      || 'T002965'
                      || ','
                      || l_file_id
                      || ','
                      || 1
                      || ','
                      || to_char(sysdate, 'mm/dd/yyyy');

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );

  --   l_line :='01'||','||tpa||','||to_char(sysdate,'mm/dd/yyyy')||','||x.check_amount||','||x.check_number||',"'||
    ---- substr(x.employer_name,1,40)||'",'||'STLFSA,'||null||','||null||','||null
    -- ||','||x.PROVIDER_FLAG;

     --STLHSA is replaced by EMPLOYER ID
            l_line := '01'
                      || ','
                      || tpa
                      || ','
                      || to_char(sysdate, 'mm/dd/yyyy')
                      || ','
                      || x.check_amount
                      || ','
                      || x.check_number
                      || ',"'
                      || substr(x.employer_name, 1, 40)
                      || '",'
                      || x.employer_id
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || x.provider_flag;

   /*  IF x.provider_flag = 'N' THEN
       l_line := l_line  ||','||get_employee_name_address(x.pers_id);
     ELSE*/
            l_line := l_line
                      || ','
                      || x.provider_name;
 --    END IF;
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);
     --Line 2
            l_line := '02'
                      || ','
                      || x.employer
                      || ','
                      || x.employer_address;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);
     --Line 3
            l_line := '03'
                      || ','
                      || x.claim_id
                      || --claim number
                       ','
                      || to_char(x.check_date, 'mm/dd/yyyy')
                      || ','
                      || x.plan_type
                      || --account_type
                       ',"'
                      || substr(x.note, 1, 100)
                      || --Merchant
                       '",'
                      || x.check_amount
                      || ','
                      || null
                      ||--prior amt
                       ','
                      || null
                      ||--offset amt
                       ','
                      || x.check_amount
                      || ','
                      || x.check_amount
                      || --total_amt
                       ','
                      || x.claim_id
                      || --manual claim num
                       ','
                      || x.deductible_amount
                      || --applied to deductible
                       ','
                      || null
                      || --exclusion amt
                       ','
                      || null
                      || --exclusion code
                       ','
                      || null
                      || --exclusion description
                       ','
                      || x.denied_amount
                      || ','
                      || null
                      || --denial error code
                       ','
                      || null
                      || --denial error desc
                       ','
                      || x.claim_pending
                      || --low funds amt
                       ','
                      || null
                      || --low funds error code
                       ','
                      || null
                      || -- low funds  desc
                       ','
                      || x.employer
                      || ','
                      || null
                      || --claimant_first_nam
                       ','
                      || null
                      || --claimant last name
                       ','
                      || null
                      || --claimant middle
                       ','
                      || x.acc_num
                      || --account number
                       ','
                      || null   --SCC
                      ;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);

     --Line 6
            l_line := '06';
            if x.next_claim_id is not null then  --not the last row
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
        --dbms_output.put_line(l_line);
            else
                utl_file.put(
                    file   => l_utl_id,
                    buffer => l_line
                );
        --dbms_output.put(l_line);--testing

            end if;

            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

        end loop;

        utl_file.fclose(file => l_utl_id);
        if file_length(x_file_name, 'CHECKS_DIR') = 0 then
            x_file_name := null;
            update external_files
            set
                result_flag = 'Y',
                sent_flag = 'Y'
            where
                file_id = l_file_id;

        end if;

        commit;
    exception
        when others then
            rollback;
            raise_application_error(-20030, 'Check File Creation Process Failed. ' || sqlerrm);
    end send_fsa_hra_er_check;

-- Added by Joshi for 9200

    procedure create_manual_check (
        p_acc_id           number,
        p_acc_num          varchar2,
        p_entity_name      varchar2,
        p_entity_id        varchar2,
        p_name             varchar2,
        p_address          varchar2,
        p_city             varchar2,
        p_state            varchar2,
        p_zip              varchar2,
        p_check_amount     number,
        p_check_date       date,
        p_memo             varchar2,
        p_transcation_type varchar2,
        p_check_reason     number,
        p_product_type     varchar2, -- Added by Joshi for 9792
        p_provider_flag    varchar2,
        p_user_id          number,
        x_check_number     out number
    ) is
        l_vendor_id number;
    begin

  -- Get the existing vendor or create new vendor based on the address.
        for x in (
            select
                a.vendor_id
            from
                vendors a
            where
                    a.orig_sys_vendor_ref = p_acc_num
                and a.address1 = p_address
                and a.city = p_city
                and a.state = p_state
                and a.zip = p_zip
                and a.vendor_name = p_name
        )  -- Added by Swamy for Ticket#10014 on  18/08/2021
         loop
            l_vendor_id := x.vendor_id;
        end loop;

 -- create vendor if vendor ID is not found.
        if l_vendor_id is null then
            if
                p_address is not null
                and p_city is not null
                and p_state is not null
            then
                insert into vendors (
                    vendor_id,
                    orig_sys_vendor_ref,
                    vendor_name,
                    address1,
                    address2,
                    city,
                    state,
                    zip,
                    acc_num,
                    vendor_status,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( vendor_seq.nextval,
                           p_acc_num,
                           p_name,
                           p_address,
                           null,
                           p_city,
                           p_state,
                           p_zip,
                           p_acc_num,
                           'A',
                           sysdate,
                           0,
                           sysdate,
                           0 ) returning vendor_id into l_vendor_id;

            end if;

        end if;

        insert into checks (
            check_id,
            acc_id,
            check_number,
            check_amount,
            check_date,
            entity_type,
            entity_id,
            source_system,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            status,
            check_source,
            vendor_id,
            memo,
            check_reason,
            entity_name,
            product_type,  -- Added by Joshi for 9792
            provider_flag
        ) values ( checks_seq.nextval,
                   p_acc_id,
                   checks_seq.currval,
                   p_check_amount,
                   sysdate,
                   p_transcation_type,
                   p_entity_id,
                   'ADMINISOURCE',
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id,
                   'OPEN',
                   'MANUAL',
                   l_vendor_id,
                   p_memo,
                   p_check_reason,
                   p_entity_name,
                   p_product_type, -- Added by Joshi for 9792
                   p_provider_flag ) returning check_number into x_check_number;

    end create_manual_check;

-- Added by Joshi for 9200.
    procedure send_manual_check (
        x_file_name out varchar2
    ) is

        l_file_id        number;
        l_file_name      varchar2(3200);
        l_line           varchar2(32000);
        l_sqlerrm        varchar2(32000);
        l_utl_id         utl_file.file_type;
 --   tpa CONSTANT varchar2(100) :='T002965' ||','|| 'Sterling Health Services Administrator' ||','|| '475 14th Street' ||','|| 'Suite 650' ||','|| 'Oakland' ||','|| 'CA' ||','|| '94612';
        l_check_number   number;
        l_file_count     number;
        p_message        varchar2(200) := null; -- to be assigned later
        l_all_file_names varchar2(1000) := null;
        l_row            number;
    begin

/********************** Generating manual check files(03) for HSA Employers and Employees ***********************/

/********************** Generating manual check files(03) for HSA Employers ***********************/
        begin
            l_file_id := pc_debit_card.insert_file_seq('CHECK');

   -- l_file_name := '01STL'||TO_CHAR(SYSDATE,'YYYYMMDD')||'01';
            select
                count(*)
            into l_file_count
            from
                external_files
            where
                    file_action = 'CHECK'
                and trunc(creation_date) = trunc(sysdate);

            l_file_name := '03'
                           || to_char(sysdate, 'YYYYMMDD')
                           || '0'
                           || l_file_count;

            x_file_name := l_file_name;
            if x_file_name is not null then
                if l_all_file_names is not null then
                    l_all_file_names := l_all_file_names
                                        || ','
                                        || x_file_name;
                else
                    l_all_file_names := x_file_name;
                end if;
            end if;

            update external_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;
    /*** Sending email to finance about the checks being mailed **/

     --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --production
    --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --testing
            l_row := 1;
            for x in (
                select
                    chk.check_amount,
                    null                                        claim_id,
                    chk.check_amount                            claim_paid,
                    0                                           claim_pending,
                    0                                           deductible_amount,
                    'N'                                         provider_flag,
                    chk.vendor_id,
                    d.entrp_id,
                    acc.acc_id,
                    pc_entrp.get_bps_acc_num(d.entrp_id)        employer_id,
                    regexp_replace(d.name, '[[:cntrl:]]', '')   employer_name,
                    regexp_replace(d.name, '[[:cntrl:]]', '')   name,
                    null,
                    chk.check_date,
                    0                                           denied_amount,
                    lead(chk.check_number, 1)
                    over(
                        order by
                            rownum
                    )                                           next_claim_id,
                    chk.check_number,
                    regexp_replace(chk.memo, '[[:cntrl:]]', '') note,
                    acc.acc_num,
                    regexp_replace('"'
                                   || substr(ve.vendor_name, 1, 50)
                                   || '",'
                                   || '"'
                                   || replace(
                        replace(
                            replace((substr(ve.address1, 1, 75)
                                     || '"'
                                     || ',,'
                                     || substr(ve.city, 1, 30)
                                     || ','
                                     || substr(ve.state, 1, 30)
                                     || ','
                                     || substr(ve.zip, 1, 5)),
                                    chr(94),
                                    ' '),
                            chr(10)
                        ),
                        chr(13)
                    ),
                                   '[[:cntrl:]]',
                                   '')                          provider_name,
                    regexp_replace('"'
                                   || substr(ve.vendor_name, 1, 50)
                                   || '",,,'
                                   || acc.acc_num,
                                   '[[:cntrl:]]',
                                   '')                          employer,--SK ADDED TO PICK CORRECT VENDOR
                    regexp_replace('"'
                                   || replace(
                        replace(
                            replace((substr(ve.address1, 1, 75)
                                     || '"'
                                     || ',,'
                                     || substr(ve.city, 1, 30)
                                     || ','
                                     || substr(ve.state, 1, 30)
                                     || ','
                                     || substr(ve.zip, 1, 5)),
                                    chr(94),
                                    ' '),
                            chr(10)
                        ),
                        chr(13)
                    ),
                                   '[[:cntrl:]]',
                                   '')                          employer_address
                from
                    checks     chk,
                    enterprise d,
                    vendors    ve,
                    account    acc
                where
                        chk.entity_id = d.entrp_id
                    and d.entrp_id = acc.entrp_id
                    and acc.account_type not in ( 'COBRA', 'FSA', 'HRA' )
                    and chk.vendor_id = ve.vendor_id
                    and chk.check_amount > 0
                    and chk.entity_type in ( 'EMPLOYEE_HSA_CLAIM', 'EMPLOYER_PAY', 'LIST_BILL' )
                    and chk.source_system = 'ADMINISOURCE'
                    and chk.entity_name = 'E'
                    and chk.status = 'READY'
                    and chk.check_source = 'MANUAL'
            ) loop
                if l_row = 1 then
                    l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
                    l_row := l_row + 1;
                end if;

                l_line := 250
                          || ','
                          || 'T002965'
                          || ','
                          || l_file_id
                          || ','
                          || 1
                          || ','
                          || to_char(sysdate, 'mm/dd/yyyy');

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
                l_line := '01'
                          || ','
                          || tpa
                          || ','
                          || to_char(sysdate, 'mm/dd/yyyy')
                          || ','
                          || x.check_amount
                          || ','
                          || x.check_number
                          || ',"'
                          || substr(x.employer_name, 1, 40)
                          || '",'
                          || 'STLHSA,'
                          || null
                          || ','
                          || null
                          || ','
                          || null
                          || ','
                          || x.provider_flag;

                l_line := l_line
                          || ','
                          || x.provider_name;
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --Line 2
                l_line := '02'
                          || ','
                          || x.employer
                          || ','
                          || x.employer_address;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line(l_line);
     --Line 3
                l_line := '03'
                          || ','
                          || x.claim_id
                          || --claim number
                           ','
                          || to_char(x.check_date, 'mm/dd/yyyy')
                          || ','
                          || null
                          || --account_type
                           ',"'
                          || substr(x.note, 1, 100)
                          || --Merchant
                           '",'
                          || x.check_amount
                          || ','
                          || null
                          ||--prior amt
                           ','
                          || null
                          ||--offset amt
                           ','
                          || x.check_amount
                          || ','
                          || x.check_amount
                          || --total_amt
                           ','
                          || x.claim_id
                          || --manual claim num
                           ','
                          || x.deductible_amount
                          || --applied to deductible
                           ','
                          || null
                          || --exclusion amt
                           ','
                          || null
                          || --exclusion code
                           ','
                          || null
                          || --exclusion description
                           ','
                          || x.denied_amount
                          || ','
                          || null
                          || --denial error code
                           ','
                          || null
                          || --denial error desc
                           ','
                          || x.claim_pending
                          || --low funds amt
                           ','
                          || null
                          || --low funds error code
                           ','
                          || null
                          || -- low funds  desc
                           ','
                          || x.employer
                          || ','
                          || null
                          || --claimant_first_nam
                           ','
                          || null
                          || --claimant last name
                           ','
                          || null
                          || --claimant middle
                           ','
                          || x.acc_num
                          || --account number
                           ','
                          || null   --SCC
                          ;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
       --Line 6
                l_line := '06';
                if x.next_claim_id is not null then  --not the last row
                    utl_file.put_line(
                        file   => l_utl_id,
                        buffer => l_line
                    );
        --dbms_output.put_line(l_line);
                else
                    utl_file.put(
                        file   => l_utl_id,
                        buffer => l_line
                    );
        --dbms_output.put(l_line);--testing

                end if;

                update checks
                set
                    status = 'SENT',
                    last_update_date = sysdate
                where
                    check_number = x.check_number;

            end loop;

            utl_file.fclose(file => l_utl_id);
            if file_length(x_file_name, 'CHECKS_DIR') = 0 then
                x_file_name := null;
                update external_files
                set
                    result_flag = 'Y',
                    sent_flag = 'Y'
                where
                    file_id = l_file_id;

            end if;

            commit;
        exception
            when others then
                rollback;
                raise_application_error(-20030, 'Manual Check File Creation Process for HSA Employer Failed. ' || sqlerrm);
        end;

/********************** Generating manual check files(03) for HSA Employee ***********************/
        begin
            l_file_id := pc_debit_card.insert_file_seq('CHECK');
   -- l_file_name := '01STL'||TO_CHAR(SYSDATE,'YYYYMMDD')||'01';
            select
                count(*)
            into l_file_count
            from
                external_files
            where
                    file_action = 'CHECK'
                and trunc(creation_date) = trunc(sysdate);

            l_file_name := '03'
                           || to_char(sysdate, 'YYYYMMDD')
                           || '0'
                           || l_file_count;

            x_file_name := l_file_name;
            update external_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            if x_file_name is not null then
                if l_all_file_names is not null then
                    l_all_file_names := l_all_file_names
                                        || ','
                                        || x_file_name;
                else
                    l_all_file_names := x_file_name;
                end if;
            end if;

    --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --production
    --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --testing
            l_row := 1;
            for x in (
                select
                    null                                        claim_amount,
                    null                                        claim_id,
                    0                                           claim_paid,
                    0                                           claim_pending,
                    0                                           deductible_amount,
                    chk.provider_flag,
                    chk.vendor_id,
                    chk.entity_id,
                    chk.acc_id,
                    substr(
                        pc_entrp.get_bps_acc_num_from_acc_id(chk.acc_id),
                        1,
                        18
                    )                                           employer_id,
                    pc_person.get_entrp_name(chk.entity_id)     employer_name,
                      --C.SERVICE_TYPE ,
                    chk.check_amount,
                    null                                        prov_name,
                    null                                        claim_code,
                    null                                        claim_date_start,
                    null                                        denied_amount,
                    lead(chk.check_number, 1)
                    over(
                        order by
                            rownum
                    )                                           next_claim_id,
                    chk.check_number,
                    regexp_replace(chk.memo, '[[:cntrl:]]', '') note,
                    acc.acc_num,
                      -- As per shavee, the name should be picked from person table for subscribers(08/26/2021)
                    '"'
                    || substr(p.last_name, 1, 50)
                    || '","'
                    || substr(p.first_name, 1, 50)
                    || '","'
                    || substr(p.middle_name, 1, 1)
                    || '",'
                    || acc.acc_num                              employee,--SK Commented to send check to vendor on 02/02/2021
                   --     regexp_replace('"'||substr(ve.vendor_name,1,50)||'",,,'|| acc.acc_num,'[[:cntrl:]]','')  Employee,--SK Added on 02/03/2021
                    replace(
                        replace(
                            replace(('"'
                                     || substr(ve.address1, 1, 75)
                                     || '"'
                                     || ','
                                     || null
                                     || ',"'
                                     || substr(ve.city, 1, 30)
                                     || '",'
                                     || substr(ve.state, 1, 30)
                                     || ','
                                     || substr(ve.zip, 1, 5)),
                                    chr(94),
                                    ' '),
                            chr(10)
                        ),
                        chr(13)
                    )                                           employee_address,
                    '"'
                    || replace(
                        substr(ve.vendor_name, 1, 50),
                        '"',
                        ''
                    )
                    || '",'
                    || '"'
                    || replace(
                        replace(
                            replace((replace(
                                substr(ve.address1, 1, 75),
                                '"',
                                ''
                            )
                                     || '"'
                                     || ','
                                     || '"'
                                     || replace(ve.address2, '"', '')
                                     || '"'
                                     || ','
                                     || substr(ve.city, 1, 30)
                                     || ','
                                     || substr(ve.state, 1, 30)
                                     || ','
                                     || substr(ve.zip, 1, 5)),
                                    chr(94),
                                    ' '),
                            chr(10)
                        ),
                        chr(13)
                    )                                           provider_address   -- Added by Swamy for Production issue dated 07/Jan/2021
                from
                    checks  chk,
                    account acc,
                    person  p,
                    vendors ve
                where
                        chk.entity_id = acc.pers_id
                    and acc.account_type = 'HSA'
                    and chk.entity_id = p.pers_id
                    and chk.vendor_id = ve.vendor_id
                    and chk.check_amount > 0
                    and chk.entity_type in ( 'EMPLOYEE_HSA_CLAIM', 'EMPLOYER_PAY', 'LIST_BILL' )
                    and chk.source_system = 'ADMINISOURCE'
                    and chk.status = 'READY'
                    and chk.entity_name = 'S'
                    and chk.check_source = 'MANUAL'
            ) loop
                if l_row = 1 then
                    l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
                    l_row := l_row + 1;
                end if;

                l_line := 250
                          || ','
                          || 'T002965'
                          || ','
                          || l_file_id
                          || ','
                          || 1
                          || ','
                          || to_char(sysdate, 'mm/dd/yyyy');

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line('Entered HSA Loop: l_line');
     --Line 1
                l_line := '01'
                          || ','
                          || tpa
                          || ','
                          || to_char(sysdate, 'mm/dd/yyyy')
                          || ','
                          || x.check_amount
                          || ','
                          || x.check_number
                          || ',"'
                          || substr(x.employer_name, 1, 50)
                          || '",'
                          || 'STLHSA,'
                          || null
                          || ','
                          || null
                          || ','
                          || null
                          || ','
                          || x.provider_flag;

                dbms_output.put_line('Entered HSA Loop line 1: l_line');
     --l_line := l_line  ||','||x.employee_address ;
                l_line := l_line
                          || ','
                          || x.provider_address; -- Commented above and added by Swamy for Production issue dated 07/Jan/2021
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line(l_line);
     --Line 2
                l_line := '02'
                          || ','
                          || x.employee
                          || ','
                          || x.employee_address;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line('line 2:' || l_line);
     --Line 3
                l_line := '03'
                          || ','
                          || x.claim_id
                          || --claim number
                           ','
                          || to_char(x.claim_date_start, 'mm/dd/yyyy')
                          || ','
                          || null
                          || --account_type
                           ',"'
                          || substr(x.note, 1, 100)
                          || --Merchant
                           '",'
                          || x.check_amount
                          ||  -- Replaced Claim_amount with x.check_amount by Swamy for Production issue dated 07/Jan/2021
                           ','
                          || null
                          ||--prior amt
                           ','
                          || null
                          ||--offset amt
                           ','
                          || x.check_amount
                          || ','
                          || x.check_amount
                          || --total_amt
                           ','
                          || x.claim_id
                          || --manual claim num
                           ','
                          || x.deductible_amount
                          || --applied to deductible
                           ','
                          || null
                          || --exclusion amt
                           ','
                          || null
                          || --exclusion code
                           ','
                          || null
                          || --exclusion description
                           ','
                          || x.denied_amount
                          || ','
                          || null
                          || --denial error code
                           ','
                          || null
                          || --denial error desc
                           ','
                          || x.claim_pending
                          || --low funds amt
                           ','
                          || null
                          || --low funds error code
                           ','
                          || null
                          || -- low funds  desc
                           ','
                          || x.employee
                          || ','
                          || null
                          || --claimant_first_nam
                           ','
                          || null
                          || --claimant last name
                           ','
                          || null
                          || --claimant middle
                           ','
                          || x.acc_num
                          || --account number
                           ','
                          || null   --SCC
                          ;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line(l_line);
                dbms_output.put_line('line 3:' || l_line);
     --Line 6
                l_line := '06';
                if x.next_claim_id is not null then  --not the last row
                    utl_file.put_line(
                        file   => l_utl_id,
                        buffer => l_line
                    );
                else
                    utl_file.put(
                        file   => l_utl_id,
                        buffer => l_line
                    );
                end if;

                update checks
                set
                    status = 'SENT',
                    last_update_date = sysdate
                where
                    check_number = x.check_number;

            end loop;

            utl_file.fclose(file => l_utl_id);
            if file_length(x_file_name, 'CHECKS_DIR') = 0 then
                update external_files
                set
                    result_flag = 'Y',
                    sent_flag = 'Y'
                where
                    file_id = x_file_name;

                x_file_name := null;
            end if;

            commit;
        exception
            when others then
                rollback;
                raise_application_error(-20034, 'Manual Check File Creation Process Failed for HSA EMployee Check. ' || sqlerrm);
        end;

/********************************* Generating manual check files(05)for COBRA Employers and Employee *******************************/

/********************************* Generating manual check files(05)for COBRA Employers *******************************/

        begin
            l_file_id := pc_debit_card.insert_file_seq('CHECK');
            select
                count(*)
            into l_file_count
            from
                external_files
            where
                    file_action = 'CHECK'
                and trunc(creation_date) = trunc(sysdate);

            l_file_name := '05'
                           || to_char(sysdate, 'YYYYMMDD')
                           || '0'
                           || l_file_count;

            x_file_name := l_file_name;
            if l_file_name is not null then
                if l_all_file_names is not null then
                    l_all_file_names := l_all_file_names
                                        || ','
                                        || x_file_name;
                else
                    l_all_file_names := x_file_name;
                end if;
            end if;

            update external_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

	--l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --testing

  --dbms_output.put_line('Entered CPBRA procedure');
            l_row := 1;
            for x in (
                select
                    chk.check_amount,
                    null                                        claim_id,
                    chk.check_amount                            claim_paid,
                    0                                           claim_pending,
                    0                                           deductible_amount,
                    'N'                                         provider_flag,
                    chk.vendor_id,
                    d.entrp_id,
                    acc.acc_id,
                    pc_entrp.get_bps_acc_num(d.entrp_id)        employer_id,
                    regexp_replace(d.name, '[[:cntrl:]]', '')   employer_name,
                    regexp_replace(d.name, '[[:cntrl:]]', '')   name,
                    null,
                    chk.check_date,
                    0                                           denied_amount,
                    lead(chk.check_number, 1)
                    over(
                        order by
                            rownum
                    )                                           next_claim_id,
                    chk.check_number,
                    regexp_replace(chk.memo, '[[:cntrl:]]', '') note,
                    acc.acc_num,
                    regexp_replace('"'
                                   || substr(ve.vendor_name, 1, 50)
                                   || '",'
                                   || '"'
                                   || replace(
                        replace(
                            replace((substr(ve.address1, 1, 75)
                                     || '"'
                                     || ',,'
                                     || substr(ve.city, 1, 30)
                                     || ','
                                     || substr(ve.state, 1, 30)
                                     || ','
                                     || substr(ve.zip, 1, 5)),
                                    chr(94),
                                    ' '),
                            chr(10)
                        ),
                        chr(13)
                    ),
                                   '[[:cntrl:]]',
                                   '')                          provider_name,
                    regexp_replace('"'
                                   || substr(ve.vendor_name, 1, 50)
                                   || '",,,'
                                   || acc.acc_num,
                                   '[[:cntrl:]]',
                                   '')                          employer,-- sk Updated D.Name to Vendor_Name on 02/23/2021.
                    regexp_replace('"'
                                   || replace(
                        replace(
                            replace((substr(ve.address1, 1, 75)
                                     || '"'
                                     || ',,'
                                     || substr(ve.city, 1, 30)
                                     || ','
                                     || substr(ve.state, 1, 30)
                                     || ','
                                     || substr(ve.zip, 1, 5)),
                                    chr(94),
                                    ' '),
                            chr(10)
                        ),
                        chr(13)
                    ),
                                   '[[:cntrl:]]',
                                   '')                          employer_address
                from
                    checks     chk,
                    enterprise d,
                    vendors    ve,
                    account    acc
                where
                        chk.entity_id = d.entrp_id
                    and d.entrp_id = acc.entrp_id
           -- AND    ACC.ACCOUNT_TYPE  = 'COBRA' -- commented and added below by Joshi 10323
                    and acc.account_type in ( 'COBRA', 'RB' )
                    and chk.vendor_id = ve.vendor_id
                    and chk.check_amount > 0
                    and chk.entity_type = 'COBRA_DISBURSE'
                    and chk.source_system = 'ADMINISOURCE'
                    and chk.status = 'READY'
                    and chk.check_source = 'MANUAL'
            ) loop

     --dbms_output.put_line('Entered Loop procedure');
                if l_row = 1 then
                    l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
                    l_row := l_row + 1;
                end if;

                l_line := 250
                          || ','
                          || 'T002965'
                          || ','
                          || l_file_id
                          || ','
                          || 1
                          || ','
                          || to_char(sysdate, 'mm/dd/yyyy');

     --dbms_output.put_line('l_line1:Header');

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
                l_line := '01'
                          || ','
                          || tpa
                          || ','
                          || to_char(sysdate, 'mm/dd/yyyy')
                          || ','
                          || x.check_amount
                          || ','
                          || x.check_number
                          || ',"'
                          || substr(x.employer_name, 1, 40)
                          || '",'
                          || 'STLCOB,'
                          || null
                          || ','
                          || null
                          || ','
                          || null
                          || ','
                          || x.provider_flag;

    --dbms_output.put_line('l_line1:file header');

                l_line := l_line
                          || ','
                          || x.provider_name;
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line('l_line1: ' || l_line);
     --Line 2
                l_line := '02'
                          || ','
                          || x.employer
                          || ','
                          || x.employer_address;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line('l_line2: ' || l_line);
     --Line 3
                l_line := '03'
                          || ','
                          || x.claim_id
                          || --claim number
                           ','
                          || to_char(x.check_date, 'mm/dd/yyyy')
                          || ','
                          || null
                          || --account_type
                           ',"'
                          || substr(x.note, 1, 100)
                          || --Merchant
                           '",'
                          || x.check_amount
                          || ','
                          || null
                          ||--prior amt
                           ','
                          || null
                          ||--offset amt
                           ','
                          || x.check_amount
                          || ','
                          || x.check_amount
                          || --total_amt
                           ','
                          || x.claim_id
                          || --manual claim num
                           ','
                          || x.deductible_amount
                          || --applied to deductible
                           ','
                          || null
                          || --exclusion amt
                           ','
                          || null
                          || --exclusion code
                           ','
                          || null
                          || --exclusion description
                           ','
                          || x.denied_amount
                          || ','
                          || null
                          || --denial error code
                           ','
                          || null
                          || --denial error desc
                           ','
                          || x.claim_pending
                          || --low funds amt
                           ','
                          || null
                          || --low funds error code
                           ','
                          || null
                          || -- low funds  desc
                           ','
                          || x.employer
                          || ','
                          || null
                          || --claimant_first_nam
                           ','
                          || null
                          || --claimant last name
                           ','
                          || null
                          || --claimant middle
                           ','
                          || x.acc_num
                          || --account number
                           ','
                          || null   --SCC
                          ;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line(l_line);
     --dbms_output.put_line('l_line3: ' || l_line);
     --Line 6
                l_line := '06';
                if x.next_claim_id is not null then  --NOT THE LAST ROW
                    utl_file.put_line(
                        file   => l_utl_id,
                        buffer => l_line
                    );
        --DBMS_OUTPUT.PUT_LINE(L_LINE);
                else
                    utl_file.put(
                        file   => l_utl_id,
                        buffer => l_line
                    );
                end if;

                update checks
                set
                    status = 'SENT',
                    last_update_date = sysdate
                where
                    check_number = x.check_number;

            end loop;

            utl_file.fclose(file => l_utl_id);
            if file_length(x_file_name, 'CHECKS_DIR') = 0 then
                x_file_name := null;
                update external_files
                set
                    result_flag = 'Y',
                    sent_flag = 'Y'
                where
                    file_id = l_file_id;

            end if;

            commit;
        exception
            when others then
                rollback;
                raise_application_error(-20032, 'MANUAL CHECK FILE CREATION PROCESS FAILED FOR COBRA EMPLOYER DISBURSEMENTS. ' || sqlerrm
                );
        end;

/********************** Generating manual check files(05) for COBRA QA Employees ***********************/
        begin
            l_file_id := pc_debit_card.insert_file_seq('CHECK');
            select
                count(*)
            into l_file_count
            from
                external_files
            where
                    file_action = 'CHECK'
                and trunc(creation_date) = trunc(sysdate);

            l_file_name := '05'
                           || to_char(sysdate, 'YYYYMMDD')
                           || '0'
                           || l_file_count;

            x_file_name := l_file_name;
            if l_file_name is not null then
                if l_all_file_names is not null then
                    l_all_file_names := l_all_file_names
                                        || ','
                                        || x_file_name;
                else
                    l_all_file_names := x_file_name;
                end if;
            end if;

            update external_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

	--l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --testing

  --dbms_output.put_line('Entered CPBRA procedure');
            l_row := 1;
            for x in (
                select
                    null                                        claim_amount,
                    null                                        claim_id,
                    0                                           claim_paid,
                    0                                           claim_pending,
                    0                                           deductible_amount,
                    chk.provider_flag,
                    chk.vendor_id,
                    chk.entity_id,
                    chk.acc_id,
                    substr(
                        pc_entrp.get_bps_acc_num_from_acc_id(chk.acc_id),
                        1,
                        18
                    )                                           employer_id,
                    pc_person.get_entrp_name(chk.entity_id)     employer_name,
                      --C.SERVICE_TYPE ,
                    chk.check_amount,
                    null                                        prov_name,
                    null                                        claim_code,
                    null                                        claim_date_start,
                    null                                        denied_amount,
                    lead(chk.check_number, 1)
                    over(
                        order by
                            rownum
                    )                                           next_claim_id,
                    chk.check_number,
                    regexp_replace(chk.memo, '[[:cntrl:]]', '') note,
                    acc.acc_num,
                      -- As per shavee, the name should be picked from Person table for subscribers(08/26/2021)
                    '"'
                    || substr(p.last_name, 1, 50)
                    || '","'
                    || substr(p.first_name, 1, 50)
                    || '","'
                    || substr(p.middle_name, 1, 1)
                    || '",'
                    || acc.acc_num                              employee,
                    --regexp_replace('"'||substr(ve.vendor_name,1,50)||'",,,'|| acc.acc_num,'[[:cntrl:]]','')  Employee,-- commented above Added by Joshi #10014 on 07/13/21
                    replace(
                        replace(
                            replace(('"'
                                     || substr(ve.address1, 1, 75)
                                     || '"'
                                     || ','
                                     || null
                                     || ',"'
                                     || substr(ve.city, 1, 30)
                                     || '",'
                                     || substr(ve.state, 1, 30)
                                     || ','
                                     || substr(ve.zip, 1, 5)),
                                    chr(94),
                                    ' '),
                            chr(10)
                        ),
                        chr(13)
                    )                                           employee_address,
                    '"'
                    || replace(
                        substr(ve.vendor_name, 1, 50),
                        '"',
                        ''
                    )
                    || '",'
                    || '"'
                    || replace(
                        replace(
                            replace((replace(
                                substr(ve.address1, 1, 75),
                                '"',
                                ''
                            )
                                     || '"'
                                     || ','
                                     || '"'
                                     || replace(ve.address2, '"', '')
                                     || '"'
                                     || ','
                                     || substr(ve.city, 1, 30)
                                     || ','
                                     || substr(ve.state, 1, 30)
                                     || ','
                                     || substr(ve.zip, 1, 5)),
                                    chr(94),
                                    ' '),
                            chr(10)
                        ),
                        chr(13)
                    )                                           provider_address   -- Added by Swamy for Production issue dated 07/Jan/2021
                from
                    checks  chk,
                    account acc,
                    person  p,
                    vendors ve
                where
                        chk.entity_id = acc.pers_id
                    and chk.entity_id = p.pers_id
                    and chk.vendor_id = ve.vendor_id
                    and chk.check_amount > 0
                    and chk.entity_type in ( 'COBRA_DISBURSE' )
                    and chk.source_system = 'ADMINISOURCE'
                    and chk.status = 'READY'
                    and chk.check_source = 'MANUAL'
            ) loop
                if l_row = 1 then
                    l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
                    l_row := l_row + 1;
                end if;

                l_line := 250
                          || ','
                          || 'T002965'
                          || ','
                          || l_file_id
                          || ','
                          || 1
                          || ','
                          || to_char(sysdate, 'mm/dd/yyyy');

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line('Entered HSA Loop: l_line');
     --Line 1
                l_line := '01'
                          || ','
                          || tpa
                          || ','
                          || to_char(sysdate, 'mm/dd/yyyy')
                          || ','
                          || x.check_amount
                          || ','
                          || x.check_number
                          || ',"'
                          || substr(x.employer_name, 1, 50)
                          || '",'
                          || 'STLCOB,'
                          || null
                          || ','
                          || null
                          || ','
                          || null
                          || ','
                          || x.provider_flag;

                dbms_output.put_line('Entered cobra Loop line 1: l_line');
     --l_line := l_line  ||','||x.employee_address ;
                l_line := l_line
                          || ','
                          || x.provider_address; -- Commented above and added by Swamy for Production issue dated 07/Jan/2021
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line(l_line);
     --Line 2
                l_line := '02'
                          || ','
                          || x.employee
                          || ','
                          || x.employee_address;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line('line 2:' || l_line);
     --Line 3
                l_line := '03'
                          || ','
                          || x.claim_id
                          || --claim number
                           ','
                          || to_char(x.claim_date_start, 'mm/dd/yyyy')
                          || ','
                          || null
                          || --account_type
                           ',"'
                          || substr(x.note, 1, 100)
                          || --Merchant
                           '",'
                          || x.check_amount
                          ||  -- Replaced Claim_amount with x.check_amount by Swamy for Production issue dated 07/Jan/2021
                           ','
                          || null
                          ||--prior amt
                           ','
                          || null
                          ||--offset amt
                           ','
                          || x.check_amount
                          || ','
                          || x.check_amount
                          || --total_amt
                           ','
                          || x.claim_id
                          || --manual claim num
                           ','
                          || x.deductible_amount
                          || --applied to deductible
                           ','
                          || null
                          || --exclusion amt
                           ','
                          || null
                          || --exclusion code
                           ','
                          || null
                          || --exclusion description
                           ','
                          || x.denied_amount
                          || ','
                          || null
                          || --denial error code
                           ','
                          || null
                          || --denial error desc
                           ','
                          || x.claim_pending
                          || --low funds amt
                           ','
                          || null
                          || --low funds error code
                           ','
                          || null
                          || -- low funds  desc
                           ','
                          || x.employee
                          || ','
                          || null
                          || --claimant_first_nam
                           ','
                          || null
                          || --claimant last name
                           ','
                          || null
                          || --claimant middle
                           ','
                          || x.acc_num
                          || --account number
                           ','
                          || null   --SCC
                          ;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line(l_line);
                dbms_output.put_line('line 3:' || l_line);
     --Line 6
                l_line := '06';
                if x.next_claim_id is not null then  --not the last row
                    utl_file.put_line(
                        file   => l_utl_id,
                        buffer => l_line
                    );
                else
                    utl_file.put(
                        file   => l_utl_id,
                        buffer => l_line
                    );
                end if;

                update checks
                set
                    status = 'SENT',
                    last_update_date = sysdate
                where
                    check_number = x.check_number;

            end loop;

            utl_file.fclose(file => l_utl_id);
            if file_length(x_file_name, 'CHECKS_DIR') = 0 then
                update external_files
                set
                    result_flag = 'Y',
                    sent_flag = 'Y'
                where
                    file_id = x_file_name;

                x_file_name := null;
            end if;

            commit;
        exception
            when others then
                rollback;
                raise_application_error(-20034, 'Manual Check File Creation Process Failed for cobra Employee. ' || sqlerrm);
        end;

/* SK CODE ENDED

/******* generating manual check file(02) for  HRA/FSA Employers and Employess */

/***** generating manual check files HRA/FSA Employers */
        begin
            l_file_id := pc_debit_card.insert_file_seq('CHECK');

   -- l_file_name := '01STL'||TO_CHAR(SYSDATE,'YYYYMMDD')||'01';
            select
                count(*)
            into l_file_count
            from
                external_files
            where
                    file_action = 'CHECK'
                and trunc(creation_date) = trunc(sysdate);

            l_file_name := '02'
                           || to_char(sysdate, 'YYYYMMDD')
                           || '0'
                           || l_file_count;

            x_file_name := l_file_name;
            if x_file_name is not null then
                if l_all_file_names is not null then
                    l_all_file_names := l_all_file_names
                                        || ','
                                        || x_file_name;
                else
                    l_all_file_names := x_file_name;
                end if;
            end if;

            update external_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;
    /*** Sending email to finance about the checks being mailed **/

     --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --production
    --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --testing
            l_row := 1;
            for x in (
                select
                    chk.check_amount,
                    null                                        claim_id,
                    chk.check_amount                            claim_paid,
                    0                                           claim_pending,
                    0                                           deductible_amount,
                    'N'                                         provider_flag,
                    chk.vendor_id,
                    d.entrp_id,
                    acc.acc_id,
                    pc_entrp.get_bps_acc_num(d.entrp_id)        employer_id,
                    regexp_replace(d.name, '[[:cntrl:]]', '')   employer_name,
                    regexp_replace(d.name, '[[:cntrl:]]', '')   name,
                    null,
                    chk.check_date,
                    0                                           denied_amount,
                    lead(chk.check_number, 1)
                    over(
                        order by
                            rownum
                    )                                           next_claim_id,
                    chk.check_number,
                    regexp_replace(chk.memo, '[[:cntrl:]]', '') note,
                    acc.acc_num,
                    regexp_replace('"'
                                   || substr(ve.vendor_name, 1, 50)
                                   || '",'
                                   || '"'
                                   || replace(
                        replace(
                            replace((substr(ve.address1, 1, 75)
                                     || '"'
                                     || ',,'
                                     || substr(ve.city, 1, 30)
                                     || ','
                                     || substr(ve.state, 1, 30)
                                     || ','
                                     || substr(ve.zip, 1, 5)),
                                    chr(94),
                                    ' '),
                            chr(10)
                        ),
                        chr(13)
                    ),
                                   '[[:cntrl:]]',
                                   '')                          provider_name,
                    regexp_replace('"'
                                   || substr(ve.vendor_name, 1, 50)
                                   || '",,,'
                                   || acc.acc_num,
                                   '[[:cntrl:]]',
                                   '')                          employer,--SK UPDATED TO PICK VENDOR NAME 02/25/2021
                    regexp_replace('"'
                                   || replace(
                        replace(
                            replace((substr(ve.address1, 1, 75)
                                     || '"'
                                     || ',,'
                                     || substr(ve.city, 1, 30)
                                     || ','
                                     || substr(ve.state, 1, 30)
                                     || ','
                                     || substr(ve.zip, 1, 5)),
                                    chr(94),
                                    ' '),
                            chr(10)
                        ),
                        chr(13)
                    ),
                                   '[[:cntrl:]]',
                                   '')                          employer_address,
                    nvl(chk.product_type, acc.account_type)     product_type -- Added by Joshi for 9792
                from
                    checks     chk,
                    enterprise d,
                    vendors    ve,
                    account    acc
                where
                        chk.entity_id = d.entrp_id
                    and d.entrp_id = acc.entrp_id
                    and acc.account_type in ( 'FSA', 'HRA' )
                    and chk.vendor_id = ve.vendor_id
                    and chk.check_amount > 0
                    and chk.entity_type in ( 'EMPLOYEE_HRAFSA_CLAIM', 'EMPLOYER_PAY', 'INVOICE' )
                    and chk.source_system = 'ADMINISOURCE'
                    and chk.entity_name = 'E'
                    and chk.status = 'READY'
                    and chk.check_source = 'MANUAL'
            ) loop
                if l_row = 1 then
                    l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
                    l_row := l_row + 1;
                end if;

                l_line := 250
                          || ','
                          || 'T002965'
                          || ','
                          || l_file_id
                          || ','
                          || 1
                          || ','
                          || to_char(sysdate, 'mm/dd/yyyy');

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
                l_line := '01'
                          || ','
                          || tpa
                          || ','
                          || to_char(sysdate, 'mm/dd/yyyy')
                          || ','
                          || x.check_amount
                          || ','
                          || x.check_number
                          || ',"'
                          ||
      -- substr(x.employer_name,1,40)||'",'||'STLHSA,'||null||','||null||','||null
                           substr(x.employer_name, 1, 40)
                          || '",'
                          || x.employer_id
                          || ','
                          || null
                          || ','
                          || null
                          || ','
                          || null
      -- Joshi: STLHSA is replaced by EMPLOYER ID
                          || ','
                          || x.provider_flag;

                l_line := l_line
                          || ','
                          || x.provider_name;
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --Line 2
                l_line := '02'
                          || ','
                          || x.employer
                          || ','
                          || x.employer_address;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line(l_line);
     --Line 3
                l_line := '03'
                          || ','
                          || x.claim_id
                          || --claim number
                           ','
                          || to_char(x.check_date, 'mm/dd/yyyy')
                          ||
              --  ','||null|| --account_type
                           ','
                          || x.product_type
                          || --account_type  -- commented and added by joshi for 9792
                           ',"'
                          || substr(x.note, 1, 100)
                          || --Merchant
                           '",'
                          || x.check_amount
                          || ','
                          || null
                          ||--prior amt
                           ','
                          || null
                          ||--offset amt
                           ','
                          || x.check_amount
                          || ','
                          || x.check_amount
                          || --total_amt
                           ','
                          || x.claim_id
                          || --manual claim num
                           ','
                          || x.deductible_amount
                          || --applied to deductible
                           ','
                          || null
                          || --exclusion amt
                           ','
                          || null
                          || --exclusion code
                           ','
                          || null
                          || --exclusion description
                           ','
                          || x.denied_amount
                          || ','
                          || null
                          || --denial error code
                           ','
                          || null
                          || --denial error desc
                           ','
                          || x.claim_pending
                          || --low funds amt
                           ','
                          || null
                          || --low funds error code
                           ','
                          || null
                          || -- low funds  desc
                           ','
                          || x.employer
                          || ','
                          || null
                          || --claimant_first_nam
                           ','
                          || null
                          || --claimant last name
                           ','
                          || null
                          || --claimant middle
                           ','
                          || x.acc_num
                          || --account number
                           ','
                          || null   --SCC
                          ;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
       --Line 6
                l_line := '06';
                if x.next_claim_id is not null then  --not the last row
                    utl_file.put_line(
                        file   => l_utl_id,
                        buffer => l_line
                    );
        --dbms_output.put_line(l_line);
                else
                    utl_file.put(
                        file   => l_utl_id,
                        buffer => l_line
                    );
        --dbms_output.put(l_line);--testing

                end if;

                update checks
                set
                    status = 'SENT',
                    last_update_date = sysdate
                where
                    check_number = x.check_number;

            end loop;

            utl_file.fclose(file => l_utl_id);
            if file_length(x_file_name, 'CHECKS_DIR') = 0 then
                x_file_name := null;
                update external_files
                set
                    result_flag = 'Y',
                    sent_flag = 'Y'
                where
                    file_id = l_file_id;

            end if;

            commit;
        exception
            when others then
                rollback;
                raise_application_error(-20030, 'Manual Check File Creation Process failed for HRA/FSA Employe ' || sqlerrm);
        end;

/***** generating manual check file(02) for Employee HRA/FSA claims */

        begin
            l_file_id := pc_debit_card.insert_file_seq('CHECK');
   -- l_file_name := '01STL'||TO_CHAR(SYSDATE,'YYYYMMDD')||'01';
            select
                count(*)
            into l_file_count
            from
                external_files
            where
                    file_action = 'CHECK'
                and trunc(creation_date) = trunc(sysdate);

            l_file_name := '02'
                           || to_char(sysdate, 'YYYYMMDD')
                           || '0'
                           || l_file_count;

            x_file_name := l_file_name;
            if x_file_name is not null then
                if l_all_file_names is not null then
                    l_all_file_names := l_all_file_names
                                        || ','
                                        || x_file_name;
                else
                    l_all_file_names := x_file_name;
                end if;
            end if;

            update external_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            send_email_on_hra_fsa_checks('NORMAL');

    --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --production
    --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --testing

            l_row := 1;
            for x in (
                select
                    null                                        claim_amount,
                    null                                        claim_id,
                    0                                           claim_paid,
                    0                                           claim_pending,
                    0                                           deductible_amount,
                    chk.provider_flag,
                    chk.vendor_id,
                    chk.entity_id,
                    chk.acc_id,
                    chk.check_date                              service_date,
                    substr(
                        pc_entrp.get_bps_acc_num_from_acc_id(chk.acc_id),
                        1,
                        18
                    )                                           employer_id,
                    pc_person.get_entrp_name(chk.entity_id)     employer_name,
                      --acc.account_type SERVICE_TYPE ,  -- Null replaced with account_type by Swamy
                    nvl(chk.product_type, acc.account_type)     service_type, -- commnted above and added by Joshi 9792
                    chk.check_amount,
                    null                                        prov_name,
                    null                                        claim_code,
                    null                                        claim_date_start,
                    pc_person.get_person_name(p.pers_id)        patient_name,    -- Added by Swamy friday
                    0                                           denied_amount,     -- Added by Swamy friday
                    lead(chk.check_number, 1)
                    over(
                        order by
                            rownum
                    )                                           next_claim_id,
                    chk.check_number,
                    regexp_replace(chk.memo, '[[:cntrl:]]', '') memo,
                    acc.acc_num                                 vendor_acc_num,
                      -- As per shavee, the name should be picked from Person table for subscribers(08/26/2021)
                    '"'
                    || substr(p.last_name, 1, 50)
                    || '","'
                    || substr(p.first_name, 1, 50)
                    || '","'
                    || substr(p.middle_name, 1, 1)
                    || '",'
                    || acc.acc_num                              employee,
                    '"'
                    || substr(p.last_name, 1, 50)
                    || '","'
                    || substr(p.first_name, 1, 50)
                    || '","'
                    || substr(p.middle_name, 1, 1)
                    || '"'                                      employee_name,
                     -- regexp_replace('"'||substr(ve.vendor_name,1,50)||'",,,'|| acc.acc_num,'[[:cntrl:]]','')  Employee,-- commented above Added by Joshi #10014 on 07/13/21
                     -- regexp_replace('"'||substr(ve.vendor_name,1,50)||'",,,', '[[:cntrl:]]','')  Employee_name, --Added by Joshi #10014 on 07/13/21
                    replace(
                        replace(
                            replace(('"'
                                     || substr(ve.address1, 1, 75)
                                     || '"'
                                     || ','
                                     || null
                                     || ',"'
                                     || substr(ve.city, 1, 30)
                                     || '",'
                                     || substr(ve.state, 1, 30)
                                     || ','
                                     || substr(ve.zip, 1, 5)),
                                    chr(94),
                                    ' '),
                            chr(10)
                        ),
                        chr(13)
                    )                                           employee_address   -- Added by Swamy friday
                from
                    checks  chk,
                    account acc,
                    person  p,
                    vendors ve
                where
                        chk.entity_id = acc.pers_id
                    and acc.account_type in ( 'HRA', 'FSA' )
                    and chk.entity_id = p.pers_id
                    and chk.vendor_id = ve.vendor_id
                    and chk.check_amount > 0
                    and chk.entity_type in ( 'EMPLOYEE_HRAFSA_CLAIM', 'EMPLOYER_PAY', 'INVOICE' )
                    and chk.source_system = 'ADMINISOURCE'
                    and chk.status = 'READY'
                    and chk.entity_name = 'S'
                    and chk.check_source = 'MANUAL'
            ) loop
                if l_row = 1 then
                    l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
                    l_row := l_row + 1;
                end if;

                l_line := 250
                          || ','
                          || 'T002965'
                          || ','
                          || l_file_id
                          || ','
                          || 1
                          || ','
                          || to_char(sysdate, 'mm/dd/yyyy');

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line(x.claim_id);
     -- dbms_output.put_line(l_line);
     --Line 1
    -- INSERT_CHECK(x.claim_id,x.check_amount,x.acc_id,P_USER_ID,l_check_number);--userid is 1 for testing
                l_line := '01'
                          || ','
                          || tpa
                          || ','
                          || to_char(sysdate, 'mm/dd/yyyy')
                          || ','
                          || x.check_amount
                          || ','
                          || x.check_number
                          || ',"'
                          || x.employer_name
                          || '",'
                          || x.employer_id
                          || ','
                          || null
                          || ','
                          || null
                          || ','
                          || null
                          || ','
                          || x.provider_flag
     -- ||','||x.Employee_name||','||x.employee_address;    -- Added by Swamy friday
                          || ','
                          || get_vendor_detail(x.vendor_id); -- Added by Joshi for 10458

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line(l_line);
     --Line 2
                l_line := '02'
                          || ','
                          || x.employee
                          || ','
                          || x.employee_address;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line(l_line);
     --Line 3
                l_line := '03'
                          || ','
                          || x.claim_id
                          || --claim number
                           ','
                          || nvl(
                    to_char(x.service_date, 'mm/dd/yyyy'),
                    to_char(x.claim_date_start, 'mm/dd/yyyy')
                )
                          ||  -- Added NVL by Swamy for Production issue dated 07/Jan/2021
                           ','
                          || x.service_type
                          || --account_type
                           ',"'
                          || substr(x.memo, 1, 100)
                          || --Merchant
                           '",'
                          || x.check_amount
                          ||   -- Replaced Claim_amount with x.check_amount by Swamy for Production issue dated 07/Jan/2021
                           ','
                          || null
                          ||--prior amt
                           ','
                          || null
                          ||--offset amt
                           ','
                          || x.check_amount
                          || ','
                          || x.check_amount
                          || --total_amt
                           ','
                          || x.claim_id
                          || --manual claim num
                           ','
                          || x.deductible_amount
                          || --applied to deductible
                           ','
                          || null
                          || --exclusion amt
                           ','
                          || null
                          || --exclusion code
                           ','
                          || null
                          || --exclusion description
                           ','
                          || x.denied_amount
                          || ','
                          || null
                          || --denial error code
                           ','
                          || null
                          || --denial error desc
                           ','
                          || x.claim_pending
                          || --low funds amt
                           ','
                          || null
                          || --low funds error code
                           ','
                          || null
                          || -- low funds  desc
                           ','
                          || x.employee
                          || ',"'
                          || substr(x.patient_name, 1, 50)
                          || --claimant_first_nam
                           '","'
                          || substr(x.patient_name, 51, 100)
                          || --claimant last name
                           '",'
                          || null
                          || --claimant middle
                           ',"'
                          || substr(x.vendor_acc_num, 1, 20)
                          || --account number
                           '",'
                          || null   --SCC
                          ;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
     --dbms_output.put_line(l_line);

     --Line 6
                l_line := '06';
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
                update checks
                set
                    status = 'SENT',
                    last_update_date = sysdate
                where
                    check_number = x.check_number;

            end loop;

            utl_file.fclose(file => l_utl_id);
            if file_length(x_file_name, 'CHECKS_DIR') = 0 then
                x_file_name := null;
                update external_files
                set
                    result_flag = 'Y',
                    sent_flag = 'Y'
                where
                    file_id = l_file_id;

            end if;

            commit;
            x_file_name := l_all_file_names;
        exception
            when others then
                rollback;
                raise_application_error(-20030, 'Manual Check File Creation Process Failed for HRA/FSA employee ' || sqlerrm);
        end;

    end send_manual_check;

    procedure process_manual_check_result (
        p_file_name in varchar2
    ) is

        l_claimn_id    number;
        app_exception exception;
        l_error_msg    varchar2(100);
        ctr            number := 0;
        l_sqlerrm      varchar2(100);
        l_check_amount number := 0;
        l_entity_type  varchar2(30);
    begin
        if file_length(p_file_name, 'CHECKS_DIR') > 0 then
            begin
                execute immediate 'ALTER TABLE CHECK_EXTERNAL LOCATION (CHECKS_DIR:'''
                                  || p_file_name
                                  || ''')';
                update external_files
                set
                    result_flag = 'Y'
                where
                    file_name = replace(p_file_name, 'Receipt_');

            exception
                when others then
                    l_sqlerrm := 'ERROR IN CHANGING LOCATION OF CHECKS FILE' || sqlerrm;
                    pc_debit_card.insert_alert('ERROR IN CHANGING LOCATION OF CHECKS FILE ', 'ERROR IN CHANGING LOCATION OF CHECKS FILE  ' || p_file_name
                    );
                    raise app_exception;
            end;

            for x in (
                select
                    a.check_number,
                    b.acc_id,
                    b.pers_id,
                    to_date(check_dt, 'MM/DD/YYYY')  check_date,
                    to_date(mailed_dt, 'MM/DD/YYYY') mailed_date,
                    ch.check_amount
                from
                    check_external a,
                    account        b,
                    checks         ch
                where
                        a.acc_num = b.acc_num
                    and a.check_number = ch.check_number
            )
	  --FOR X IN(SELECT * FROM CHECK_EXTERNAL_TEST)
             loop
                begin
                    update checks ch
                    set
                        ch.check_date = x.check_date,
                        ch.mailed_date = x.mailed_date,
                        status = 'MAILED',
                        last_updated_by = 0,
                        last_update_date = sysdate
                    where
                            ch.check_number = x.check_number
                        and ch.acc_id = x.acc_id
                        and ch.source_system = 'ADMINISOURCE'
                        and ch.check_source = 'MANUAL'
                        and ch.entity_type in ( 'EMPLOYER_PAY', 'INVOICE', 'LIST_BILL', 'COBRA_DISBURSE', 'EMPLOYEE_HSA_CLAIM',
                                                'EMPLOYEE_HRAFSA_CLAIM' );

                exception
                    when app_exception then
                        pc_debit_card.insert_alert('ERROR IN CHANGING LOCATION OF CHECKS FILE ', 'ERROR IN CHANGING LOCATION OF CHECKS FILE  '
                                                                                                 || p_file_name
                                                                                                 || ' ERROR '
                                                                                                 || sqlerrm);
                end;
            end loop;

        end if;

        update external_files
        set
            result_flag = 'Y'
        where
            ( file_length(file_name, 'CHECKS_DIR') = 0
              or file_exists(file_name, 'CHECKS_DIR') <> 'TRUE' )
            and result_flag is null
            and file_action = 'CHECK';

        pc_log.log_error('pc_check_process.PROCESS_MANUAL_CHECK_RESULT',
                         'REPLACE(p_file_name,Receipt_) ' || replace(p_file_name, 'Receipt_'));
        pc_webservice_batch.upd_edi_repo_file_process_flag(
            p_file_name   => 'Receipt_' || p_file_name,
            p_vendor_name => 'EMDEON',
            p_feed_type   => 'ADMINISOURCE'
        );  -- Added by Swamy for Server Migration

    exception
        when app_exception then
            pc_debit_card.insert_alert('ERROR IN CHANGING LOCATION OF CHECKS FILE ', 'ERROR IN CHANGING LOCATION OF CHECKS FILE  '
                                                                                     || p_file_name
                                                                                     || ' ERROR '
                                                                                     || sqlerrm);
        when others then
            rollback;
            pc_debit_card.insert_alert('ERROR IN CHANGING LOCATION OF CHECKS FILE ', 'ERROR IN CHANGING LOCATION OF CHECKS FILE  '
                                                                                     || p_file_name
                                                                                     || ' ERROR '
                                                                                     || sqlerrm);
    end process_manual_check_result;

    procedure send_manual_broker_check (
        x_file_name out varchar2
    ) is

        l_file_id      number;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_sqlerrm      varchar2(32000);
        l_utl_id       utl_file.file_type;
        l_check_number number;
        l_file_count   number;
        p_message      varchar2(200) := null; -- to be assigned later
        l_row          number;
    begin
        l_file_id := pc_debit_card.insert_file_seq('BROKER_CHECK');
   -- l_file_name := '01STL'||TO_CHAR(SYSDATE,'YYYYMMDD')||'01';
        select
            count(*)
        into l_file_count
        from
            external_files
        where
                file_action = 'BROKER_CHECK'
            and trunc(creation_date) = trunc(sysdate);

        l_file_name := '04'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '0'
                       || l_file_count;

        x_file_name := l_file_name;
        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;

    --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --testing
        l_row := 1;
        for x in (
            select
                pc_broker.get_broker_lic(chk.entity_id)                     broker_lic
                 --  , regexp_replace(pc_broker.get_broker_name(pr.broker_id),'[[:cntrl:]]','') broker_name --SK COMMENTED ON 10_02_2018
                ,
                regexp_replace(b.commissions_payable_to, '[[:cntrl:]]', '') broker_name,
                chk.check_date,
                chk.check_number,
                chk.check_amount,
                chk.status,
                regexp_replace(chk.memo, '[[:cntrl:]]', '')                 note,
                b.broker_id,
                ve.vendor_id,
                replace(
                    replace(
                        replace(('"'
                                 || substr(ve.address1, 1, 75)
                                 || '"'
                                 || ','
                                 || '"'
                                 || substr(ve.address2, 1, 75)
                                 || '",'
                                 || '"'
                                 || substr(ve.city, 1, 30)
                                 || '",'
                                 || substr(ve.state, 1, 30)
                                 || ','
                                 || substr(ve.zip, 1, 5)),
                                chr(94),
                                ' '),
                        chr(10)
                    ),
                    chr(13)
                )                                                           broker_address,
                '"'
                || replace(
                    substr(ve.vendor_name, 1, 50),
                    '"',
                    ''
                )
                || '",'
                || '"'
                || replace(
                    replace(
                        replace((replace(
                            substr(ve.address1, 1, 75),
                            '"',
                            ''
                        )
                                 || '"'
                                 || ','
                                 || '"'
                                 || replace(ve.address2, '"', '')
                                 || '"'
                                 || ','
                                 || substr(ve.city, 1, 30)
                                 || ','
                                 || substr(ve.state, 1, 30)
                                 || ','
                                 || substr(ve.zip, 1, 5)),
                                chr(94),
                                ' '),
                        chr(10)
                    ),
                    chr(13)
                )                                                           provider_address   -- Added by Swamy for Production issue dated 07/Jan/2021
            from
                checks  chk,
                broker  b,
                vendors ve
            where
                    chk.entity_id = b.broker_id
                and chk.vendor_id = ve.vendor_id
                and chk.entity_type = 'BROKER_PAY'
                and chk.source_system = 'ADMINISOURCE'
                and chk.status = 'READY'
                and chk.check_source = 'MANUAL'
        ) loop
            if l_row = 1 then
                l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
                l_row := l_row + 1;
            end if;

            l_line := 250
                      || ','
                      || 'T002965'
                      || ','
                      || l_file_id
                      || ','
                      || 1
                      || ','
                      || to_char(sysdate, 'mm/dd/yyyy');

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(x.claim_id);
     -- dbms_output.put_line(l_line);
     --Line 1
    -- INSERT_CHECK(x.claim_id,x.check_amount,x.acc_id,P_USER_ID,l_check_number);--userid is 1 for testing
            l_line := '01'
                      || ','
                      || tpa
                      || ','
                      || to_char(sysdate, 'mm/dd/yyyy')
                      || ','
                      || x.check_amount
                      || ','
                      || x.check_number
                      || ',"'
                      || substr(x.broker_name, 1, 50)
                      || '",STLBROKER,'
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || 'Y';

            l_line := l_line
                      || ','
                      || x.provider_address;  -- Added by Swamy for Production issue dated 07/Jan/2021

    -- later    l_line := l_line  ||',"'||substr(x.broker_name,1,100)||'",'||broker_address,'[[:cntrl:]]','');
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);
     --Line 2
            l_line := '02'
                      || ','
                      || get_broker(x.broker_id);
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);
     --Line 3
            l_line := '03'
                      || ','
                      || x.check_number
                      || --claim number
                       ','
                      || to_char(x.check_date, 'mm/dd/yyyy')
                      || ','
                      || null
                      || --account_type
                       ',"'
                      || substr(x.note, 1, 100)
                      || --Merchant
                       '",'
                      || x.check_amount
                      || ','
                      || null
                      ||--prior amt
                       ','
                      || null
                      ||--offset amt
                       ','
                      || x.check_amount
                      || ','
                      || x.check_amount
                      || --total_amt
                       ','
                      || null
                      || --manual claim num
                       ','
                      || null
                      || --applied to deductible
                       ','
                      || null
                      || --exclusion amt
                       ','
                      || null
                      || --exclusion code
                       ','
                      || null
                      || --exclusion description
                       ','
                      || null
                      || ','
                      || null
                      || --denial error code
                       ','
                      || null
                      || --denial error desc
                       ','
                      || null
                      || --low funds amt
                       ','
                      || null
                      || --low funds error code
                       ','
                      || null
                      || -- low funds  desc
                       ','
                      || get_broker_info(x.broker_id)
                      || ','
                      || null
                      || --claimant_first_nam
                       ','
                      || null
                      || --claimant last name
                       ','
                      || null
                      || --claimant middle
                       ',"'
                      || substr(x.broker_lic, 1, 20)
                      || --account number
                       '",'
                      || null   --SCC
                      ;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
     --dbms_output.put_line(l_line);

     --Line 6
            l_line := '06,'
                      || p_message
                      || ',';
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

        end loop;

        utl_file.fclose(file => l_utl_id);
        if file_length(x_file_name, 'CHECKS_DIR') = 0 then
            x_file_name := null;
            update external_files
            set
                result_flag = 'Y',
                sent_flag = 'Y'
            where
                file_id = l_file_id;

        end if;

        commit;
    exception
        when others then
            rollback;
            raise_application_error(-20031, 'Manual Check File Creation Process for broker Failed. ' || sqlerrm);
    end send_manual_broker_check;

    procedure process_broker_manual_check (
        p_file_name in varchar2
    ) is

        l_claimn_id    number;
        app_exception exception;
        l_error_msg    varchar2(100);
        ctr            number := 0;
        l_sqlerrm      varchar2(100);
        l_check_amount number := 0;
    begin
        begin
            execute immediate '
               ALTER TABLE check_external
                location (CHECKS_DIR:'''
                              || p_file_name
                              || ''')';
            update external_files
            set
                result_flag = 'Y'
            where
                file_name = replace(p_file_name, 'Receipt_');

        exception
            when others then
                l_sqlerrm := 'Error in Changing location of checks file' || sqlerrm;
                pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  ' || p_file_name
                );
                raise app_exception;
        end;

        for x in (
            select
                a.acc_num,
                c.check_number,
                b.broker_id,
                to_date(check_dt, 'MM/DD/YYYY')  check_date,
                to_date(mailed_dt, 'MM/DD/YYYY') mailed_date
            from
                check_external a,
                checks         c,
                broker         b
            where
                    c.entity_id = b.broker_id
                and a.check_number = c.check_number
                and c.entity_type = 'BROKER_PAY'
        ) loop
            begin
                dbms_output.put_line('X.CHECK_NUMBER:' || x.check_number);
                update checks ch
                set
                    ch.check_date = x.check_date,
                    ch.mailed_date = x.mailed_date,
                    status = 'MAILED',
                    last_updated_by = 0,
                    last_update_date = sysdate
                where
                        ch.check_number = x.check_number
                    and ch.source_system = 'ADMINISOURCE'
                    and ch.entity_type in ( 'BROKER_PAY' );

            exception
                when app_exception then
                    pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  '
                                                                                             || p_file_name
                                                                                             || ' Error '
                                                                                             || sqlerrm);
            end;
        end loop;

    exception
        when app_exception then
            pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  '
                                                                                     || p_file_name
                                                                                     || ' Error '
                                                                                     || sqlerrm);
        when others then
            rollback;
            pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  '
                                                                                     || p_file_name
                                                                                     || ' Error '
                                                                                     || sqlerrm);
    end process_broker_manual_check;

-- Added by Swamy for Ticket#9912 on 10/08/2021
    procedure send_email_on_lsa_checks (
        p_file_id number
    ) as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
        l_email_id     varchar2(4000);
    begin
        l_html_message := '<html>
      <head>
          <title>LSA checks to CNB </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>LSA checks to CNB  </p>
       </table>
        </body>
        </html>';
        l_sql := 'SELECT pr.acc_num "Account Number"
	 ,pc_person.get_person_name(c.pers_id) "Employee Name"
	 ,pc_person.get_entrp_name(c.pers_id) "Employer Name"
	 ,c.claim_id "Claim Number"
	 ,c.claim_code "Claim Code"
	 ,c.claim_date_start "Date Received"
	 ,c.claim_amount  "Claim Amount"
	 ,c.claim_paid "Claim Paid"
	 ,c.claim_pending "Claim Pending"
	 ,c.denied_amount "Denied Amount"
	 ,chk.check_number "Check Number"
	 ,chk.check_amount "Check Amount"
	 ,chk.status "Status"
	 ,pr.claim_type "Claim Paid to "
	 ,pr.provider_name "Provider Name in Claim"
	 ,pc_payee.get_payee_name(pr.vendor_id) "Provider Name in Check"
   FROM  claimn c
		 ,payment_register pr
		 ,checks chk
		 ,cnb_check_sent_details  cnb
  WHERE  pr.claim_type IN (''EMPLOYER'',''HSA_TRANSFER'',''SUBSCRIBER'',''PROVIDER'',''SUBSCRIBER_ONLINE'',''PROVIDER_ONLINE'',''OUTSIDE_INVESTMENT_TRANSFER'')
	AND  C.claim_id = pr.claim_id
	AND cnb.check_number = chk.check_number

	AND  chk.entity_type = ''LSA_CLAIM''
	AND  chk.source_system = ''ADMINISOURCE''
	AND  chk.entity_id = C.claim_id
	AND  chk.check_amount > 0

	AND  pr.vendor_id IS NOT NULL
	AND cnb.file_id = ' || p_file_id;
        if user in ( 'SAM', 'RJOSHI' ) then
            l_email_id := 'vanitha.subramanyam@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,corp.finance@sterlingadministration.com,josie.vega@sterlingadministration.com' || 'denise.law@sterlingadministration.com,finance.department@sterlingadministration.com'
            ;
        else
            l_email_id := 'it-team@sterlingadministration.com';
        end if;

        mail_utility.report_emails('oracle@sterlingadministration.com',
                                   l_email_id,
                                   'LSA_CHECKS'
                                   || to_char(sysdate, 'MMDDYYYY')
                                   || '.xls',
                                   l_sql,
                                   l_html_message,
                                   'LSA checks sent to CNB on ' || to_char(sysdate, 'MM/DD/YYYY'));

    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end send_email_on_lsa_checks;

-- Added by Joshi for 10458

    function get_vendor_detail (
        p_vendor_id number
    ) return varchar2 as
        provider varchar2(250);
    begin
        select
            '"'
            || replace(
                substr(xx.vendor_name, 1, 50),
                '"',
                ''
            )
            || '",'
            || '"'
            || replace(
                replace(
                    replace((replace(
                        substr(xx.address1, 1, 75),
                        '"',
                        ''
                    )
                             || '"'
                             || ','
                             || '"'
                             || replace(xx.address2, '"', '')
                             || '"'
                             || ','
                             || substr(xx.city, 1, 30)
                             || ','
                             || substr(xx.state, 1, 30)
                             || ','
                             || substr(xx.zip, 1, 5)),
                            chr(94),
                            ' '),
                    chr(10)
                ),
                chr(13)
            )
        into provider
        from
            vendors xx
        where
            vendor_id = p_vendor_id;

        return provider;
    end get_vendor_detail;

    procedure send_er_check_cnb (
        x_file_name out varchar2
    ) is

        l_file_id           number;
        l_file_name         varchar2(3200);
        l_line              varchar2(32000);
        l_sqlerrm           varchar2(32000);
        l_utl_id            utl_file.file_type;
 --   tpa CONSTANT varchar2(100) :='T002965' ||','|| 'Sterling Health Services Administrator' ||','|| '475 14th Street' ||','|| 'Suite 650' ||','|| 'Oakland' ||','|| 'CA' ||','|| '94612';
        l_check_number      number;
        l_file_count        number;
        i                   integer := 0;
        l_cnb_trans_ref_num varchar2(100);
    begin
        l_file_id := pc_debit_card.insert_file_seq('CHECK');

   -- l_file_name := '01STL'||TO_CHAR(SYSDATE,'YYYYMMDD')||'01';
        select
            count(*)
        into l_file_count
        from
            external_files
        where
                file_action = 'CHECK'
            and trunc(creation_date) = trunc(sysdate);

    --l_file_name := '03'||TO_CHAR(SYSDATE,'YYYYMMDD')||'0'||l_file_count;
        l_file_name := 'EASI_Tran.sterlingadmin_uat.'
                       || to_char(sysdate, 'YYYYMMDD')
                       || lpad(l_file_count, 4, '0')
                       || '.csv';

        dbms_output.put_line('l_file_name: ' || l_file_name);
        x_file_name := l_file_name;
        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;
    /*** Sending email to finance about the checks being mailed **/

        send_email_on_employer_checks;

    --l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --production
        l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
        i := 0;
        for x in (
            select
                c.check_amount,
                c.employer_payment_id                     claim_id,
                pr.vendor_id,
                c.entrp_id,
                pr.acc_id,
                acc.account_type,
                pc_entrp.get_bps_acc_num(c.entrp_id)      employer_id,
                to_char(
                    add_business_days(6,
                                      trunc(sysdate)),
                    'yyyy-mm-dd'
                )                                         check_date,
                0                                         denied_amount,
                chk.check_number,
                regexp_replace(c.memo, '[[:cntrl:]]', '') note,
                pr.acc_num,
                regexp_replace('"'
                               || substr(d.name, 1, 80)
                               || '"',
                               '[[:cntrl:]]',
                               '')                        employer,
                regexp_replace('"'
                               || replace(
                    replace(
                        replace((substr(ve.address1, 1, 35)
                                 || '"'
                                 || ',,,'
                                 || substr(ve.city, 1, 20)
                                 || ','
                                 || substr(ve.state, 1, 2)
                                 || ','
                                 || substr(ve.zip, 1, 5)),
                                chr(94),
                                ' '),
                        chr(10)
                    ),
                    chr(13)
                ),
                               '[[:cntrl:]]',
                               '')                        employer_address
            from
                employer_payments c,
                payment_register  pr,
                checks            chk,
                enterprise        d,
                vendors           ve,
                account           acc
            where
                    pr.claim_type = 'EMPLOYER'
                and d.entrp_id = c.entrp_id
                and acc.entrp_id = d.entrp_id
                and acc.account_type not in ( 'COBRA', 'FSA', 'HRA' )/**Ticket6497 ***/
                and pr.vendor_id = ve.vendor_id
                and chk.check_amount > 0
                and c.payment_register_id = pr.payment_register_id
                and chk.entity_type = 'EMPLOYER_PAYMENTS'
                and chk.source_system = 'ADMINISOURCE'
                and chk.entity_id = c.payment_register_id
                and chk.status = 'READY'
        ) loop
            i := i + 1;
            if i = 1 then
                l_line := pc_check_process.g_check_header_line;
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;

            l_cnb_trans_ref_num := 'CNB'
                                   || lpad(cnb_check_seq.nextval, 13, 0);
            l_line := l_cnb_trans_ref_num
                      || --  TranRef	
                       ','
                      || g_cnb_check_site_id
                      ||  --SiteId
                       ','
                      || 'check'
                      || --SettlementMethod
                       ','
                      || pc_check_process.get_cnb_check_payer_detail(x.account_type)
                      ||  -- PayerName,PayerAcctId,	PayerAcctType,	PayerBankId,PayerBankIdType
                       ','
                      || g_check_delivery_method
                      ||  -- DeliveryInstruction
                       ','
                      || g_delivery_inst
                      || --account_type
                       ','
                      || x.check_number
                      ||  --ChkNum
                       ',"'
                      || substr(x.note, 1, 80)
                      || --CheckMemo
                       '",'
                      || x.employer
                      ||   ---PayeeName
                       ','
                      || x.employer_address
                      || --PayeeAddr1	PayeeAddr2	PayeeAddr3	PayeeCity	PayeeState	PayeePostalCode
                       ','
                      || g_payeecountry
                      || --manual claim num
                       ','
                      || null
                      || --Memo
                       ','
                      || x.acc_num
                      || --BillingAcct
                       ','
                      || x.check_amount
                      || -- check Amt
                       ','
                      || x.check_date
                      || -- check Due date
                       ','
                      || null
                      || --InvoiceNumber
                       ','
                      || null
                      || --InvoiceAmount
                       ','
                      || null
                      || --InvoiceDate
                       ','
                      || null
                      || -- InvoiceDiscount
                       ','
                      || null
                      || --InvoiceAdjustment
                       ','
                      || 'SAMSYSTEM'
                      || --TxnCreators
                       ','
                      || null --version
                      ;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

            pc_check_process.insert_cnb_check_trans_detail(l_cnb_trans_ref_num, x.check_number, l_file_id, x.vendor_id, 'N');

        end loop;

        utl_file.fclose(file => l_utl_id);
        if file_length(x_file_name, 'CHECKS_DIR') = 0 then
            x_file_name := null;
            update external_files
            set
                result_flag = 'Y',
                sent_flag = 'Y'
            where
                file_id = l_file_id;

        end if;

        commit;
    exception
        when others then
            rollback;
            raise_application_error(-20030, 'Check File Creation Process Failed. ' || sqlerrm);
    end send_er_check_cnb;

    function get_payer_detail return varchar2 as
        ls_payer_detail varchar2(4000);
    begin
        ls_payer_detail := '"'
                           || 'Sterling Health Services, Inc'
                           || '"'
                           || ',1000,DDA,122016066,ABA';
        return ls_payer_detail;
    end get_payer_detail;

    procedure send_fsa_hra_er_check_cnb (
        x_file_name out varchar2
    ) is

        l_file_id           number;
        l_file_name         varchar2(3200);
        l_line              varchar2(32000);
        l_sqlerrm           varchar2(32000);
        l_utl_id            utl_file.file_type;
        l_check_number      number;
        l_file_count        number;
        i                   integer := 0;
        l_cnb_trans_ref_num varchar2(100);
    begin
        l_file_id := pc_debit_card.insert_file_seq('CHECK');
        select
            count(*)
        into l_file_count
        from
            external_files
        where
                file_action = 'CHECK'
            and trunc(creation_date) = trunc(sysdate);

        l_file_name := 'EASI_Tran.sterlingadmin_uat.'
                       || to_char(sysdate, 'YYYYMMDD')
                       || lpad(l_file_count, 4, '0')
                       || '.csv';

        x_file_name := l_file_name;
        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;

        send_email_on_employer_checks;
        l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing

        for x in (
            select
                c.check_amount,
                pr.vendor_id,
                c.entrp_id,
                pr.acc_id,
                acc.account_type,
                pc_entrp.get_bps_acc_num(c.entrp_id)      employer_id,
                regexp_replace(d.name, '[[:cntrl:]]', '') employer_name,
                regexp_replace(d.name, '[[:cntrl:]]', '') name,
                pr.claim_code,
                case
                    when c.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' ) then  -- Added by Josh for 12130
                        'HRA'
                    else
                        'FSA'
                end                                       service_type,
                to_char(
                    add_business_days(6,
                                      trunc(sysdate)),
                    'YYYY-MM-DD'
                )                                         check_date,
                chk.check_number,
                regexp_replace(c.memo, '[[:cntrl:]]', '') note,
                pr.acc_num,
                regexp_replace('"'
                               || substr(ve.vendor_name, 1, 50)
                               || '",'
                               || '"'
                               || replace(
                    replace(
                        replace((substr(ve.address1, 1, 75)
                                 || '"'
                                 || ',,'
                                 || substr(ve.city, 1, 30)
                                 || ','
                                 || substr(ve.state, 1, 30)
                                 || ','
                                 || substr(ve.zip, 1, 5)),
                                chr(94),
                                ' '),
                        chr(10)
                    ),
                    chr(13)
                ),
                               '[[:cntrl:]]',
                               '')                        provider_name,
                regexp_replace('"'
                               || substr(d.name, 1, 80)
                               || '"',
                               '[[:cntrl:]]',
                               '')                        employer,
                regexp_replace('"'
                               || replace(
                    replace(
                        replace((substr(ve.address1, 1, 35)
                                 || '"'
                                 || ',,,'
                                 || substr(ve.city, 1, 20)
                                 || ','
                                 || substr(ve.state, 1, 2)
                                 || ','
                                 || substr(ve.zip, 1, 5)),
                                chr(94),
                                ' '),
                        chr(10)
                    ),
                    chr(13)
                ),
                               '[[:cntrl:]]',
                               '')                        employer_address
            from
                employer_payments c,
                payment_register  pr,
                checks            chk,
                enterprise        d,
                vendors           ve,
                account           acc
            where
                    pr.claim_type = 'EMPLOYER'
                and d.entrp_id = c.entrp_id
                and acc.entrp_id = d.entrp_id
                and acc.account_type in ( 'FSA', 'HRA' )
                and pr.vendor_id = ve.vendor_id
                and chk.check_amount > 0
                and c.payment_register_id = pr.payment_register_id
                and chk.entity_type = 'EMPLOYER_PAYMENTS'
                and chk.source_system = 'ADMINISOURCE'
                and chk.entity_id = c.payment_register_id
                and chk.status = 'READY'
        ) loop
            i := i + 1;
            if i = 1 then
                l_line := pc_check_process.g_check_header_line;
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;

            l_cnb_trans_ref_num := 'CNB'
                                   || lpad(cnb_check_seq.nextval, 13, 0);
            l_line := l_cnb_trans_ref_num
                      || --  TranRef
                       ','
                      || g_cnb_check_site_id
                      ||  --SiteId
                       ','
                      || 'check'
                      || --SettlementMethod
                       ','
                      || pc_check_process.get_cnb_check_payer_detail(x.service_type)
                      ||  -- PayerName,PayerAcctId,	PayerAcctType,	PayerBankId,PayerBankIdType
                       ','
                      || g_check_delivery_method
                      ||  -- DeliveryInstruction
                       ','
                      || g_delivery_inst
                      || --account_type
                       ','
                      || x.check_number
                      ||  --ChkNum
                       ',"'
                      || substr(x.note, 1, 80)
                      || --CheckMemo
                       '",'
                      || x.employer
                      ||   ---PayeeName
                       ','
                      || x.employer_address
                      || --PayeeAddr1	PayeeAddr2	PayeeAddr3	PayeeCity	PayeeState	PayeePostalCode
                       ','
                      || g_payeecountry
                      || --manual claim num
                       ','
                      || null
                      || --Memo
                       ','
                      || x.acc_num
                      || --BillingAcct
                       ','
                      || x.check_amount
                      || -- check Amt
                       ','
                      || x.check_date
                      || -- check Due date
                       ','
                      || null
                      || --InvoiceNumber
                       ','
                      || null
                      || --InvoiceAmount
                       ','
                      || null
                      || --InvoiceDate
                       ','
                      || null
                      || -- InvoiceDiscount
                       ','
                      || null
                      || --InvoiceAdjustment
                       ','
                      || 'SAMSYSTEM'
                      || --TxnCreators
                       ','
                      || null --version
                      ;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

            pc_check_process.insert_cnb_check_trans_detail(l_cnb_trans_ref_num, x.check_number, l_file_id, x.vendor_id, 'N');

        end loop;

        utl_file.fclose(file => l_utl_id);
        if file_length(x_file_name, 'CHECKS_DIR') = 0 then
            x_file_name := null;
            update external_files
            set
                result_flag = 'Y',
                sent_flag = 'Y'
            where
                file_id = l_file_id;

        end if;

        commit;
    exception
        when others then
            rollback;
            raise_application_error(-20030, 'Check File Creation Process Failed. ' || sqlerrm);
    end send_fsa_hra_er_check_cnb;

    procedure send_cobra_check_cnb (
        x_file_name out varchar2
    ) is

        l_file_id           number;
        l_file_name         varchar2(3200);
        l_line              varchar2(32000);
        l_sqlerrm           varchar2(32000);
        l_utl_id            utl_file.file_type;
        l_check_number      number;
        l_file_count        number;
        i                   integer := 0;
        l_cnb_trans_ref_num varchar2(100);
    begin
        l_file_id := pc_debit_card.insert_file_seq('CHECK');

   -- l_file_name := '01STL'||TO_CHAR(SYSDATE,'YYYYMMDD')||'01';
        select
            count(*)
        into l_file_count
        from
            external_files
        where
                file_action = 'CHECK'
            and trunc(creation_date) = trunc(sysdate);

        l_file_name := 'EASI_Tran.sterlingadmin_uat.'
                       || to_char(sysdate, 'YYYYMMDD')
                       || lpad(l_file_count, 4, '0')
                       || '.csv';

        x_file_name := l_file_name;
        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;
    /*** Sending email to finance about the checks being mailed **/

        send_email_on_cobra_checks;
        l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
        for x in (
            select
                c.check_amount,
                pr.vendor_id,
                c.entrp_id,
                pr.acc_id,
                acc.account_type,
                pc_entrp.get_bps_acc_num(c.entrp_id)      employer_id,
                regexp_replace(d.name, '[[:cntrl:]]', '') employer_name,
                to_char(
                    add_business_days(6,
                                      trunc(sysdate)),
                    'YYYY-MM-DD'
                )                                         check_date,
                chk.check_number,
                regexp_replace(c.note, '[[:cntrl:]]', '') note,
                pr.acc_num,
                regexp_replace('"'
                               || substr(d.name, 1, 80)
                               || '"',
                               '[[:cntrl:]]',
                               '')                        employer,
                regexp_replace('"'
                               || replace(
                    replace(
                        replace((substr(ve.address1, 1, 35)
                                 || '"'
                                 || ',,,'
                                 || substr(ve.city, 1, 20)
                                 || ','
                                 || substr(ve.state, 1, 2)
                                 || ','
                                 || substr(ve.zip, 1, 5)),
                                chr(94),
                                ' '),
                        chr(10)
                    ),
                    chr(13)
                ),
                               '[[:cntrl:]]',
                               '')                        employer_address
            from
                employer_payments c,
                payment_register  pr,
                checks            chk,
                enterprise        d,
                vendors           ve,
                account           acc
            where
                pr.claim_type in ( 'COBRA_DISBURSEMENT', 'COBRA_PAYMENTS' )
                and d.entrp_id = c.entrp_id
                and acc.entrp_id = d.entrp_id
                and acc.account_type = 'COBRA'
                and pr.vendor_id = ve.vendor_id
                and chk.check_amount > 0
                and c.payment_register_id = pr.payment_register_id
                and chk.entity_type = 'EMPLOYER_PAYMENTS'
                and chk.source_system = 'ADMINISOURCE'
                and chk.entity_id = c.payment_register_id
                and chk.status = 'READY'
        ) loop
            i := i + 1;
            if i = 1 then
                l_line := pc_check_process.g_check_header_line;
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;

            l_cnb_trans_ref_num := 'CNB'
                                   || lpad(cnb_check_seq.nextval, 13, 0);
            l_line := l_cnb_trans_ref_num
                      || --  TranRef	
                       ','
                      || g_cnb_check_site_id
                      ||  --SiteId
                       ','
                      || 'check'
                      || --SettlementMethod
                       ','
                      || pc_check_process.get_cnb_check_payer_detail(x.account_type)
                      ||  -- PayerName,PayerAcctId,	PayerAcctType,	PayerBankId,PayerBankIdType
                       ','
                      || g_check_delivery_method
                      ||  -- DeliveryInstruction
                       ','
                      || g_delivery_inst
                      || --account_type
                       ','
                      || x.check_number
                      ||  --ChkNum
                       ',"'
                      || substr(x.note, 1, 80)
                      || --CheckMemo
                       '",'
                      || x.employer
                      ||   ---PayeeName
                       ','
                      || x.employer_address
                      || --PayeeAddr1	PayeeAddr2	PayeeAddr3	PayeeCity	PayeeState	PayeePostalCode
                       ','
                      || g_payeecountry
                      || --manual claim num
                       ','
                      || null
                      || --Memo
                       ','
                      || x.acc_num
                      || --BillingAcct
                       ','
                      || x.check_amount
                      || -- check Amt
                       ','
                      || x.check_date
                      || -- check Due date
                       ','
                      || null
                      || --InvoiceNumber
                       ','
                      || null
                      || --InvoiceAmount
                       ','
                      || null
                      || --InvoiceDate
                       ','
                      || null
                      || -- InvoiceDiscount
                       ','
                      || null
                      || --InvoiceAdjustment
                       ','
                      || 'SAMSYSTEM'
                      || --TxnCreators
                       ','
                      || null --version
                      ;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

            pc_check_process.insert_cnb_check_trans_detail(l_cnb_trans_ref_num, x.check_number, l_file_id, x.vendor_id, 'N');

        end loop;

        utl_file.fclose(file => l_utl_id);
        if file_length(x_file_name, 'CHECKS_DIR') = 0 then
            x_file_name := null;
            update external_files
            set
                result_flag = 'Y',
                sent_flag = 'Y'
            where
                file_id = l_file_id;

        end if;

        commit;
    exception
        when others then
            rollback;
            raise_application_error(-20030, 'Check File Creation Process Failed. ' || sqlerrm);
    end send_cobra_check_cnb;

/*
PROCEDURE SEND_MANUAL_CHECK_CNB(  X_FILE_NAME OUT VARCHAR2 )
   IS
    l_file_id   NUMBER;
    l_file_name VARCHAR2( 3200 ) ;
    l_line      VARCHAR2( 32000 ) ;
    l_sqlerrm   VARCHAR2( 32000 ) ;
    l_utl_id UTL_FILE.file_type;
    l_check_number number;
    l_file_count NUMBER;
    i Integer := 0;
    l_cnb_trans_ref_num varchar2(100);

BEGIN

    l_file_id   := pc_debit_card.insert_file_seq( 'CHECK' ) ;

   -- l_file_name := '01STL'||TO_CHAR(SYSDATE,'YYYYMMDD')||'01';
      SELECT  COUNT(*)
    INTO   l_file_count
    FROM   external_files
    WHERE  file_action = 'CHECK'
    AND    trunc(creation_date) = trunc(sysdate);

      l_file_name := 'EASI_Tran.sterlingadmin_uat.'||TO_CHAR(SYSDATE,'YYYYMMDD')||  lpad(l_file_count, 4, '0')  ||'.csv';
    X_FILE_NAME := l_file_name;

     UPDATE external_files
    SET file_name = l_file_name
    WHERE file_id = l_file_id;
    -- Sending email to finance about the checks being mailed 

  --  send_email_on_cobra_checks;
    l_utl_id := utl_file.fopen( 'CHECKS_DIR', l_file_name, 'w' );  --testing
    FOR x IN(  SELECT CHK.CHECK_AMOUNT ,
                                    CHK.VENDOR_ID ,
                                    D.ENTRP_ID  ,
                                    ACC.ACC_ID,
                                    ACC.ACCOUNT_TYPE,
                                    PC_ENTRP.GET_BPS_ACC_NUM(D.ENTRP_ID) EMPLOYER_ID,
                                    REGEXP_REPLACE(D.NAME,'[[:cntrl:]]','') EMPLOYER_NAME,
                                    to_char(add_business_days(6,TRUNC(SYSDATE)),'YYYY-MM-DD')  check_date,
                                    CHK.CHECK_NUMBER,
                                    REGEXP_REPLACE(CHK.MEMO ,'[[:cntrl:]]','') NOTE,
                                    ACC.ACC_NUM,
                                    regexp_replace('"'||substr(D.name,1,80)||'"','[[:cntrl:]]','')  employer,
                                    regexp_replace('"'||replace(replace(replace((substr(VE.address1,1,35)||'"'||',,,'
                                             || substr(VE.city,1,20)||','|| substr(VE.state,1,2)||','|| substr(VE.zip,1,5)) ,chr(94),' ')
                                              , chr(10)),chr(13)),'[[:cntrl:]]','') employer_address
                        FROM  CHECKS CHK, ENTERPRISE D,VENDORS VE, ACCOUNT ACC
                      WHERE  CHK.ENTITY_ID = D.ENTRP_ID
                           AND  D.ENTRP_ID = ACC.ENTRP_ID
                           AND  ACC.ACCOUNT_TYPE  NOT IN ( 'COBRA','FSA','HRA')
                           AND  CHK.VENDOR_ID = VE.VENDOR_ID
                           AND  CHK.CHECK_AMOUNT > 0
                           AND  CHK.ENTITY_TYPE IN ( 'EMPLOYEE_HSA_CLAIM','EMPLOYER_PAY', 'LIST_BILL'   )
                           AND  CHK.SOURCE_SYSTEM = 'ADMINISOURCE'
                           AND  CHK.ENTITY_NAME = 'E'
                           AND  CHK.STATUS = 'READY'
                           AND  CHK.CHECK_SOURCE = 'MANUAL' )
    LOOP

             i := i+1;

            IF  i = 1 THEN
                l_line := pc_check_process.g_check_header_line;
                UTL_FILE.PUT_LINE( file => l_utl_id , buffer => l_line );
            END IF;

             l_cnb_trans_ref_num := 'CNB'||LPAD(cnb_check_seq.nextval,13,0);

            l_line := 
                'CNB'||cnb_check_seq.nextval  || --  TranRef
                ','||'sterlingadmin_uat' ||  --SiteId
                ','||'check'|| --SettlementMethod
                ','||pc_check_process.get_cnb_check_payer_detail(x.account_type)||  -- PayerName,PayerAcctId,	PayerAcctType,	PayerBankId,PayerBankIdType
                ','||g_check_delivery_method||  -- DeliveryInstruction
                ','||g_delivery_inst|| --account_type
                ','||x.check_number ||  --ChkNum
                ',"'||substr(x.note,1,80)|| --CheckMemo
                '",'||x.employer||   ---PayeeName
                ','||x.employer_address|| --PayeeAddr1	PayeeAddr2	PayeeAddr3	PayeeCity	PayeeState	PayeePostalCode
                ','||g_PayeeCountry|| --manual claim num
                ','||null|| --Memo
                ','||x.acc_num|| --BillingAcct
                ','||x.check_amount|| -- check Amt
                ','||x.check_date|| -- check Due date
                ','||null|| --InvoiceNumber
                ','||null|| --InvoiceAmount
                ','||null|| --InvoiceDate
                ','||null|| -- InvoiceDiscount
                ','||null|| --InvoiceAdjustment
                ','||'SAMSYSTEM'|| --TxnCreators
                ','||null --version
                ;
            UTL_FILE.PUT_LINE( file => l_utl_id , buffer => l_line );

          UPDATE checks
                 SET status = 'SENT'
                    ,   last_update_date = sysdate
         WHERE  check_number = X.check_number;

         pc_check_process.INSERT_CNB_CHECK_TRANS_DETAIL( l_cnb_trans_ref_num, x.check_number, l_file_id);			

    END LOOP;

    utl_file.fclose(FILE => l_utl_id);
    IF  file_length(x_file_name,'CHECKS_DIR') = 0 THEN
        x_file_name := NULL;
        UPDATE external_files
        SET    result_flag = 'Y', sent_flag = 'Y'
        WHERE  file_id = l_file_id;
    END IF;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20030,'Check File Creation Process Failed. '||sqlerrm);

END SEND_MANUAL_CHECK_CNB;
*/

    procedure send_manual_check_cnb (
        x_file_name out varchar2
    ) is

        l_file_id           number;
        l_file_name         varchar2(3200);
        l_line              varchar2(32000);
        l_sqlerrm           varchar2(32000);
        l_utl_id            utl_file.file_type;
        l_check_number      number;
        l_file_count        number;
        i                   integer := 0;
        l_cnb_trans_ref_num varchar2(100);
        l_row               number;
        l_all_file_names    varchar2(1000) := null;
        l_payee_detail      varchar2(4000);
    begin

/********************** HSA Employers ***********************/
        l_file_id := pc_debit_card.insert_file_seq('CHECK');
        select
            count(*)
        into l_file_count
        from
            external_files
        where
                file_action = 'CHECK'
            and trunc(creation_date) = trunc(sysdate);

        l_file_name := 'EASI_Tran.sterlingadmin_uat.'
                       || to_char(sysdate, 'YYYYMMDD')
                       || lpad(l_file_count, 4, '0')
                       || '.csv';

        x_file_name := l_file_name;
        if x_file_name is not null then
            if l_all_file_names is not null then
                l_all_file_names := l_all_file_names
                                    || ','
                                    || x_file_name;
            else
                l_all_file_names := x_file_name;
            end if;
        end if;

        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;

        l_row := 0;
        for x in (
            select
                chk.check_amount,
                acc.account_type,
                ve.vendor_id,
                to_char(
                    add_business_days(6,
                                      trunc(sysdate)),
                    'YYYY-MM-DD'
                )                                           check_date,
                chk.check_number,
                regexp_replace(chk.memo, '[[:cntrl:]]', '') note,
                acc.acc_num,
                regexp_replace('"'
                               || substr(d.name, 1, 80)
                               || '"',
                               '[[:cntrl:]]',
                               '')                          employer,
                regexp_replace('"'
                               || replace(
                    replace(
                        replace((substr(ve.address1, 1, 35)
                                 || '"'
                                 || ','
                                 || '"'
                                 || substr(ve.address2, 1, 35)
                                 || '"'
                                 || ','
                                 || '"'
                                 || substr(ve.address3, 1, 35)
                                 || '"'
                                 || ','
                                 || substr(ve.city, 1, 20)
                                 || ','
                                 || substr(ve.state, 1, 2)
                                 || ','
                                 || substr(ve.zip, 1, 5)),
                                chr(94),
                                ' '),
                        chr(10)
                    ),
                    chr(13)
                ),
                               '[[:cntrl:]]',
                               '')                          employer_address
            from
                checks     chk,
                enterprise d,
                vendors    ve,
                account    acc
            where
                    chk.entity_id = d.entrp_id
                and d.entrp_id = acc.entrp_id
                and acc.account_type not in ( 'COBRA', 'FSA', 'HRA' )
                and chk.vendor_id = ve.vendor_id
                and chk.check_amount > 0
                and chk.entity_type in ( 'EMPLOYEE_HSA_CLAIM', 'EMPLOYER_PAY', 'LIST_BILL' )
                and chk.source_system = 'ADMINISOURCE'
                and chk.entity_name = 'E'
                and chk.status = 'READY'
                and chk.check_source = 'MANUAL'
        ) loop
            l_row := l_row + 1;
            if l_row = 1 then
                l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
                l_line := pc_check_process.g_check_header_line;
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
                l_row := l_row + 1;
            end if;

            l_cnb_trans_ref_num := 'CNB'
                                   || lpad(cnb_check_seq.nextval, 13, 0);
            l_line := l_cnb_trans_ref_num
                      || --  TranRef
                       ','
                      || g_cnb_check_site_id
                      ||  --SiteId
                       ','
                      || 'check'
                      || --SettlementMethod
                       ','
                      || pc_check_process.get_cnb_check_payer_detail(x.account_type)
                      ||  -- PayerName,PayerAcctId,	PayerAcctType,	PayerBankId,PayerBankIdType
                       ','
                      || g_check_delivery_method
                      ||  -- DeliveryInstruction
                       ','
                      || g_delivery_inst
                      || --account_type
                       ','
                      || x.check_number
                      ||  --ChkNum
                       ',"'
                      || substr(x.note, 1, 80)
                      || --CheckMemo
                       '",'
                      || x.employer
                      ||   ---PayeeName
                       ','
                      || x.employer_address
                      || --PayeeAddr1	PayeeAddr2	PayeeAddr3	PayeeCity	PayeeState	PayeePostalCode
                       ','
                      || g_payeecountry
                      || --manual claim num
                       ','
                      || null
                      || --Memo
                       ','
                      || x.acc_num
                      || --BillingAcct
                       ','
                      || x.check_amount
                      || -- check Amt
                       ','
                      || x.check_date
                      || -- check Due date
                       ','
                      || null
                      || --InvoiceNumber
                       ','
                      || null
                      || --InvoiceAmount
                       ','
                      || null
                      || --InvoiceDate
                       ','
                      || null
                      || -- InvoiceDiscount
                       ','
                      || null
                      || --InvoiceAdjustment
                       ','
                      || 'SAMSYSTEM'
                      || --TxnCreators
                       ','
                      || null --version
                      ;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

            pc_check_process.insert_cnb_check_trans_detail(l_cnb_trans_ref_num, x.check_number, l_file_id, x.vendor_id, 'N');

        end loop;

    /********************** HSA Employee ***********************/

        for x in (
            select
                p.pers_id,
                chk.check_amount,
                chk.check_number,
                to_char(
                    add_business_days(6,
                                      trunc(sysdate)),
                    'YYYY-MM-DD'
                )                                  check_date,
                chk.provider_flag,
                get_provider_acc_num(ve.vendor_id) vendor_acc_num,
                acc.account_type,
                regexp_replace(
                    substr(chk.memo, 1, 80),
                    '[[:cntrl:]]',
                    ''
                )                                  memo,
                ve.vendor_id
            from
                checks  chk,
                account acc,
                person  p,
                vendors ve
            where
                    chk.entity_id = acc.pers_id
                and acc.account_type = 'HSA'
                and chk.entity_id = p.pers_id
                and chk.vendor_id = ve.vendor_id
                and chk.check_amount > 0
                and chk.entity_type in ( 'EMPLOYEE_HSA_CLAIM', 'EMPLOYER_PAY', 'LIST_BILL' )
                and chk.source_system = 'ADMINISOURCE'
                and chk.status = 'READY'
                and chk.entity_name = 'S'
                and chk.check_source = 'MANUAL'
        ) loop
            l_row := l_row + 1;
            if l_row = 1 then
                l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
                l_line := pc_check_process.g_check_header_line;
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
                l_row := l_row + 1;
            end if;

            l_cnb_trans_ref_num := 'CNB'
                                   || lpad(cnb_check_seq.nextval, 13, 0);
            l_payee_detail := null;
            if x.provider_flag = 'Y' then
                for v in (
                    select
                        '"'
                        || replace(
                            substr(xx.vendor_name, 1, 50),
                            '"',
                            ''
                        )
                        || '",'
                        || '"'
                        || replace(
                            replace(
                                replace((substr(xx.address1, 1, 35)
                                         || '"'
                                         || ','
                                         || '"'
                                         || substr(xx.address2, 1, 35)
                                         || '"'
                                         || ','
                                         || '"'
                                         || substr(xx.address3, 1, 35)
                                         || '"'
                                         || ','
                                         || substr(xx.city, 1, 20)
                                         || ','
                                         || substr(xx.state, 1, 2)
                                         || ','
                                         || substr(xx.zip, 1, 5)),
                                        chr(94),
                                        ' '),
                                chr(10)
                            ),
                            chr(13)
                        ) address
                    from
                        vendors xx
                    where
                        vendor_id = x.vendor_id
                ) loop
                    l_payee_detail := v.address;
                end loop;
            else
                for v in (
                    select
                        '"'
                        || substr(xx.first_name, 1, 50)
                        || ' '
                        || substr(xx.last_name, 1, 29)
                        || ' '
                        || substr(xx.middle_name, 1, 1)
                        || '",'
                        || '"'
                        || replace(
                            replace(
                                replace((substr(xx.address, 1, 35)
                                         || '"'
                                         || ','
                                         || null
                                         || ','
                                         || null
                                         || ','
                                         || substr(xx.city, 1, 20)
                                         || ','
                                         || substr(xx.state, 1, 2)
                                         || ','
                                         || substr(xx.zip, 1, 11)),
                                        chr(94),
                                        ' '),
                                chr(10)
                            ),
                            chr(13)
                        ) address
                    from
                        person xx
                    where
                        pers_id = x.pers_id
                ) loop
                    l_payee_detail := v.address;
                end loop;
            end if;

            l_line := l_cnb_trans_ref_num
                      || ','
                      || g_cnb_check_site_id
                      || ','
                      || 'Check'
                      || ','
                      || pc_check_process.get_cnb_check_payer_detail(x.account_type)
                      || ','
                      || pc_check_process.g_check_delivery_method
                      || ','
                      || pc_check_process.g_delivery_inst
                      || ','
                      || x.check_number
                      || ','
                      || '"'
                      || x.memo
                      || '"'
                      || ','
                      || l_payee_detail
                      || ','
                      || pc_check_process.g_payeecountry
                      || ','
                      || null
                      || ','
                      || x.vendor_acc_num
                      || ','
                      || x.check_amount
                      || ','
                      || x.check_date
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || 'SAMSYSTEM'
                      || ','
                      || null;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

            pc_check_process.insert_cnb_check_trans_detail(l_cnb_trans_ref_num, x.check_number, l_file_id, x.vendor_id, x.provider_flag
            );

        end loop;

/************************* COBRA Employers *******************************/

        for x in (
            select
                chk.check_amount,
                acc.account_type,
                to_char(
                    add_business_days(6,
                                      trunc(sysdate)),
                    'YYYY-MM-DD'
                )                                           check_date,
                chk.check_number,
                ve.vendor_id,
                regexp_replace(chk.memo, '[[:cntrl:]]', '') note,
                acc.acc_num,
                regexp_replace('"'
                               || substr(ve.vendor_name, 1, 50)
                               || ' '
                               || acc.acc_num
                               || '"',
                               '[[:cntrl:]]',
                               '')                          employer,
                regexp_replace('"'
                               || replace(
                    replace(
                        replace((substr(ve.address1, 1, 35)
                                 || '"'
                                 || ','
                                 || '"'
                                 || substr(ve.address2, 1, 35)
                                 || '"'
                                 || ','
                                 || '"'
                                 || substr(ve.address3, 1, 35)
                                 || '"'
                                 || ','
                                 || substr(ve.city, 1, 20)
                                 || ','
                                 || substr(ve.state, 1, 2)
                                 || ','
                                 || substr(ve.zip, 1, 5)),
                                chr(94),
                                ' '),
                        chr(10)
                    ),
                    chr(13)
                ),
                               '[[:cntrl:]]',
                               '')                          employer_address
            from
                checks     chk,
                enterprise d,
                vendors    ve,
                account    acc
            where
                    chk.entity_id = d.entrp_id
                and d.entrp_id = acc.entrp_id
                   -- AND    ACC.ACCOUNT_TYPE  = 'COBRA' -- commented and added below by Joshi 10323
                and acc.account_type in ( 'COBRA', 'RB' )
                and chk.vendor_id = ve.vendor_id
                and chk.check_amount > 0
                and chk.entity_type = 'COBRA_DISBURSE'
                and chk.source_system = 'ADMINISOURCE'
                and chk.status = 'READY'
                and chk.check_source = 'MANUAL'
        ) loop
            l_row := l_row + 1;
            if l_row = 1 then
                l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
                l_row := l_row + 1;
                l_line := pc_check_process.g_check_header_line;
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;

            l_cnb_trans_ref_num := 'CNB'
                                   || lpad(cnb_check_seq.nextval, 13, 0);
            l_line := l_cnb_trans_ref_num
                      || --  TranRef
                       ','
                      || g_cnb_check_site_id
                      ||  --SiteId
                       ','
                      || 'check'
                      || --SettlementMethod
                       ','
                      || pc_check_process.get_cnb_check_payer_detail(x.account_type)
                      ||  -- PayerName,PayerAcctId,	PayerAcctType,	PayerBankId,PayerBankIdType
                       ','
                      || g_check_delivery_method
                      ||  -- DeliveryInstruction
                       ','
                      || g_delivery_inst
                      || --account_type
                       ','
                      || x.check_number
                      ||  --ChkNum
                       ',"'
                      || substr(x.note, 1, 80)
                      || --CheckMemo
                       '",'
                      || x.employer
                      ||   ---PayeeName
                       ','
                      || x.employer_address
                      || --PayeeAddr1	PayeeAddr2	PayeeAddr3	PayeeCity	PayeeState	PayeePostalCode
                       ','
                      || g_payeecountry
                      || --manual claim num
                       ','
                      || null
                      || --Memo
                       ','
                      || x.acc_num
                      || --BillingAcct
                       ','
                      || x.check_amount
                      || -- check Amt
                       ','
                      || x.check_date
                      || -- check Due date
                       ','
                      || null
                      || --InvoiceNumber
                       ','
                      || null
                      || --InvoiceAmount
                       ','
                      || null
                      || --InvoiceDate
                       ','
                      || null
                      || -- InvoiceDiscount
                       ','
                      || null
                      || --InvoiceAdjustment
                       ','
                      || 'SAMSYSTEM'
                      || --TxnCreators
                       ','
                      || null --version
                      ;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

            pc_check_process.insert_cnb_check_trans_detail(l_cnb_trans_ref_num, x.check_number, l_file_id, x.vendor_id, 'N');

        end loop;

/********************* COBRA QA Employees ***********************/

        for x in (
            select
                p.pers_id,
                chk.check_amount,
                chk.check_number,
                chk.provider_flag,
                to_char(
                    add_business_days(6,
                                      trunc(sysdate)),
                    'YYYY-MM-DD'
                )                                  check_date,
                get_provider_acc_num(ve.vendor_id) vendor_acc_num,
                acc.account_type,
                regexp_replace(
                    substr(chk.memo, 1, 80),
                    '[[:cntrl:]]',
                    ''
                )                                  memo,
                chk.vendor_id
            from
                checks  chk,
                account acc,
                person  p,
                vendors ve
            where
                    chk.entity_id = acc.pers_id
                and chk.entity_id = p.pers_id
                and chk.vendor_id = ve.vendor_id
                and chk.check_amount > 0
                and chk.entity_type in ( 'COBRA_DISBURSE' )
                and chk.source_system = 'ADMINISOURCE'
                and chk.status = 'READY'
                and chk.check_source = 'MANUAL'
        ) loop
            l_row := l_row + 1;
            if l_row = 1 then
                l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
                l_line := pc_check_process.g_check_header_line;
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
                l_row := l_row + 1;
            end if;

            l_cnb_trans_ref_num := 'CNB'
                                   || lpad(cnb_check_seq.nextval, 13, 0);
            l_payee_detail := null;
            if x.provider_flag = 'Y' then
                for v in (
                    select
                        '"'
                        || replace(
                            substr(xx.vendor_name, 1, 50),
                            '"',
                            ''
                        )
                        || '",'
                        || '"'
                        || replace(
                            replace(
                                replace((substr(xx.address1, 1, 35)
                                         || '"'
                                         || ','
                                         || '"'
                                         || substr(xx.address2, 1, 35)
                                         || '"'
                                         || ','
                                         || '"'
                                         || substr(xx.address3, 1, 35)
                                         || '"'
                                         || ','
                                         || substr(xx.city, 1, 20)
                                         || ','
                                         || substr(xx.state, 1, 2)
                                         || ','
                                         || substr(xx.zip, 1, 5)),
                                        chr(94),
                                        ' '),
                                chr(10)
                            ),
                            chr(13)
                        ) address
                    from
                        vendors xx
                    where
                        vendor_id = x.vendor_id
                ) loop
                    l_payee_detail := v.address;
                end loop;
            else
                for v in (
                    select
                        '"'
                        || substr(xx.first_name, 1, 50)
                        || ' '
                        || substr(xx.last_name, 1, 29)
                        || ' '
                        || substr(xx.middle_name, 1, 1)
                        || '",'
                        || '"'
                        || replace(
                            replace(
                                replace((substr(xx.address, 1, 35)
                                         || '"'
                                         || ','
                                         || null
                                         || ','
                                         || null
                                         || ','
                                         || substr(xx.city, 1, 20)
                                         || ','
                                         || substr(xx.state, 1, 2)
                                         || ','
                                         || substr(xx.zip, 1, 11)),
                                        chr(94),
                                        ' '),
                                chr(10)
                            ),
                            chr(13)
                        ) address
                    from
                        person xx
                    where
                        pers_id = x.pers_id
                ) loop
                    l_payee_detail := v.address;
                end loop;
            end if;

            l_line := l_cnb_trans_ref_num
                      || ','
                      || g_cnb_check_site_id
                      || ','
                      || 'Check'
                      || ','
                      || pc_check_process.get_cnb_check_payer_detail(x.account_type)
                      || ','
                      || pc_check_process.g_check_delivery_method
                      || ','
                      || pc_check_process.g_delivery_inst
                      || ','
                      || x.check_number
                      || ','
                      || '"'
                      || x.memo
                      || '"'
                      || ','
                      || l_payee_detail
                      || ','
                      || pc_check_process.g_payeecountry
                      || ','
                      || null
                      || ','
                      || x.vendor_acc_num
                      || ','
                      || x.check_amount
                      || ','
                      || x.check_date
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || 'SAMSYSTEM'
                      || ','
                      || null;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

            pc_check_process.insert_cnb_check_trans_detail(l_cnb_trans_ref_num, x.check_number, l_file_id, x.vendor_id, x.provider_flag
            );

        end loop;

        /***** **************************** HRA/FSA Employers ******************/

        for x in (
            select
                chk.check_amount,
                acc.account_type,
                to_char(
                    add_business_days(6,
                                      trunc(sysdate)),
                    'YYYY-MM-DD'
                )                                           check_date,
                chk.check_number,
                ve.vendor_id,
                regexp_replace(chk.memo, '[[:cntrl:]]', '') note,
                acc.acc_num,
                regexp_replace('"'
                               || substr(ve.vendor_name, 1, 50)
                               || ' '
                               || acc.acc_num
                               || '"',
                               '[[:cntrl:]]',
                               '')                          employer,
                regexp_replace('"'
                               || replace(
                    replace(
                        replace((substr(ve.address1, 1, 35)
                                 || '"'
                                 || ','
                                 || '"'
                                 || substr(ve.address2, 1, 35)
                                 || '"'
                                 || ','
                                 || '"'
                                 || substr(ve.address3, 1, 35)
                                 || '"'
                                 || ','
                                 || substr(ve.city, 1, 20)
                                 || ','
                                 || substr(ve.state, 1, 2)
                                 || ','
                                 || substr(ve.zip, 1, 5)),
                                chr(94),
                                ' '),
                        chr(10)
                    ),
                    chr(13)
                ),
                               '[[:cntrl:]]',
                               '')                          employer_address
            from
                checks     chk,
                enterprise d,
                vendors    ve,
                account    acc
            where
                    chk.entity_id = d.entrp_id
                and d.entrp_id = acc.entrp_id
                and acc.account_type in ( 'FSA', 'HRA' )
                and chk.vendor_id = ve.vendor_id
                and chk.check_amount > 0
                and chk.entity_type in ( 'EMPLOYEE_HRAFSA_CLAIM', 'EMPLOYER_PAY', 'INVOICE' )
                and chk.source_system = 'ADMINISOURCE'
                and chk.entity_name = 'E'
                and chk.status = 'READY'
                and chk.check_source = 'MANUAL'
        ) loop
            l_row := l_row + 1;
            if l_row = 1 then
                l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
                l_line := pc_check_process.g_check_header_line;
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
                l_row := l_row + 1;
            end if;

            l_cnb_trans_ref_num := 'CNB'
                                   || lpad(cnb_check_seq.nextval, 13, 0);
            l_line := l_cnb_trans_ref_num
                      || --  TranRef
                       ','
                      || g_cnb_check_site_id
                      ||  --SiteId
                       ','
                      || 'check'
                      || --SettlementMethod
                       ','
                      || pc_check_process.get_cnb_check_payer_detail(x.account_type)
                      ||  -- PayerName,PayerAcctId,	PayerAcctType,	PayerBankId,PayerBankIdType
                       ','
                      || g_check_delivery_method
                      ||  -- DeliveryInstruction
                       ','
                      || g_delivery_inst
                      || --account_type
                       ','
                      || x.check_number
                      ||  --ChkNum
                       ',"'
                      || substr(x.note, 1, 80)
                      || --CheckMemo
                       '",'
                      || x.employer
                      ||   ---PayeeName
                       ','
                      || x.employer_address
                      || --PayeeAddr1	PayeeAddr2	PayeeAddr3	PayeeCity	PayeeState	PayeePostalCode
                       ','
                      || g_payeecountry
                      || --manual claim num
                       ','
                      || null
                      || --Memo
                       ','
                      || x.acc_num
                      || --BillingAcct
                       ','
                      || x.check_amount
                      || -- check Amt
                       ','
                      || x.check_date
                      || -- check Due date
                       ','
                      || null
                      || --InvoiceNumber
                       ','
                      || null
                      || --InvoiceAmount
                       ','
                      || null
                      || --InvoiceDate
                       ','
                      || null
                      || -- InvoiceDiscount
                       ','
                      || null
                      || --InvoiceAdjustment
                       ','
                      || 'SAMSYSTEM'
                      || --TxnCreators
                       ','
                      || null --version
                      ;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

            pc_check_process.insert_cnb_check_trans_detail(l_cnb_trans_ref_num, x.check_number, l_file_id, x.vendor_id, 'N');

        end loop;

/**************Employee HRA/FSA claims ********************************/
        for x in (
            select
                p.pers_id,
                chk.check_amount,
                chk.check_number,
                chk.provider_flag,
                chk.vendor_id,
                to_char(
                    add_business_days(6,
                                      trunc(sysdate)),
                    'YYYY-MM-DD'
                )                                  check_date,
                get_provider_acc_num(ve.vendor_id) vendor_acc_num,
                acc.account_type,
                regexp_replace(
                    substr(chk.memo, 1, 80),
                    '[[:cntrl:]]',
                    ''
                )                                  memo
            from
                checks  chk,
                account acc,
                person  p,
                vendors ve
            where
                    chk.entity_id = acc.pers_id
                and acc.account_type in ( 'HRA', 'FSA' )
                and chk.entity_id = p.pers_id
                and chk.vendor_id = ve.vendor_id
                and chk.check_amount > 0
                and chk.entity_type in ( 'EMPLOYEE_HRAFSA_CLAIM', 'EMPLOYER_PAY', 'INVOICE' )
                and chk.source_system = 'ADMINISOURCE'
                and chk.status = 'READY'
                and chk.entity_name = 'S'
                and chk.check_source = 'MANUAL'
        ) loop
            l_row := l_row + 1;
            if l_row = 1 then
                l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');  --testing
                l_line := pc_check_process.g_check_header_line;
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
                l_row := l_row + 1;
            end if;

            l_cnb_trans_ref_num := 'CNB'
                                   || lpad(cnb_check_seq.nextval, 13, 0);
            l_payee_detail := null;
            if x.provider_flag = 'Y' then
                for v in (
                    select
                        '"'
                        || replace(
                            substr(xx.vendor_name, 1, 50),
                            '"',
                            ''
                        )
                        || '",'
                        || '"'
                        || replace(
                            replace(
                                replace((substr(xx.address1, 1, 35)
                                         || '"'
                                         || ','
                                         || '"'
                                         || substr(xx.address2, 1, 35)
                                         || '"'
                                         || ','
                                         || '"'
                                         || substr(xx.address3, 1, 35)
                                         || '"'
                                         || ','
                                         || substr(xx.city, 1, 20)
                                         || ','
                                         || substr(xx.state, 1, 2)
                                         || ','
                                         || substr(xx.zip, 1, 5)),
                                        chr(94),
                                        ' '),
                                chr(10)
                            ),
                            chr(13)
                        ) address
                    from
                        vendors xx
                    where
                        vendor_id = x.vendor_id
                ) loop
                    l_payee_detail := v.address;
                end loop;
            else
                for v in (
                    select
                        '"'
                        || substr(xx.first_name, 1, 50)
                        || ' '
                        || substr(xx.last_name, 1, 29)
                        || ' '
                        || substr(xx.middle_name, 1, 1)
                        || '",'
                        || '"'
                        || replace(
                            replace(
                                replace((substr(xx.address, 1, 35)
                                         || '"'
                                         || ','
                                         || null
                                         || ','
                                         || null
                                         || ','
                                         || substr(xx.city, 1, 20)
                                         || ','
                                         || substr(xx.state, 1, 2)
                                         || ','
                                         || substr(xx.zip, 1, 11)),
                                        chr(94),
                                        ' '),
                                chr(10)
                            ),
                            chr(13)
                        ) address
                    from
                        person xx
                    where
                        pers_id = x.pers_id
                ) loop
                    l_payee_detail := v.address;
                end loop;
            end if;

            l_line := l_cnb_trans_ref_num
                      || ','
                      || g_cnb_check_site_id
                      || ','
                      || 'Check'
                      || ','
                      || pc_check_process.get_cnb_check_payer_detail(x.account_type)
                      || ','
                      || pc_check_process.g_check_delivery_method
                      || ','
                      || pc_check_process.g_delivery_inst
                      || ','
                      || x.check_number
                      || ','
                      || '"'
                      || x.memo
                      || '"'
                      || ','
                      || l_payee_detail
                      || ','
                      || pc_check_process.g_payeecountry
                      || ','
                      || null
                      || ','
                      || x.vendor_acc_num
                      || ','
                      || x.check_amount
                      || ','
                      || x.check_date
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || 'SAMSYSTEM'
                      || ','
                      || null;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

            pc_check_process.insert_cnb_check_trans_detail(l_cnb_trans_ref_num, x.check_number, l_file_id, x.vendor_id, x.provider_flag
            );

        end loop;

        utl_file.fclose(file => l_utl_id);
        if file_length(x_file_name, 'CHECKS_DIR') = 0 then
            x_file_name := null;
            update external_files
            set
                result_flag = 'Y',
                sent_flag = 'Y'
            where
                file_id = l_file_id;

        end if;

        commit;
        x_file_name := l_all_file_names;
        send_email_on_manual_checks(l_file_id);
    exception
        when others then
            rollback;
            raise_application_error(-20030, 'Manual Check File Creation Process Failed for HRA/FSA employee '
                                            || sqlerrm
                                            || dbms_utility.format_error_backtrace);
    end send_manual_check_cnb;

    procedure insert_cnb_check_trans_detail (
        p_trans_ref     varchar2,
        p_check_number  varchar2,
        p_file_id       number,
        p_vendor_id     number,
        p_provider_flag varchar2
    ) is
    begin
        insert into cnb_check_sent_details (
            file_id,
            cnb_trans_ref,
            check_number,
            vendor_id,
            provider_flag,
            creation_date
        ) values ( p_file_id,
                   p_trans_ref,
                   p_check_number,
                   p_vendor_id,
                   p_provider_flag,
                   sysdate );

    end insert_cnb_check_trans_detail;

    function get_cnb_check_payer_detail (
        p_account_type varchar2
    ) return varchar2 is
        ls_payer_detail varchar2(4000);
    begin
        for j in (
            select
                ( '"'
                  || payer_name
                  || '"'
                  || ','
                  || payer_acct_id
                  || ','
                  || payer_acct_type
                  || ','
                  || payer_bank_id
                  || ','
                  || payer_bankid_type ) details
            from
                cnb_check_payer_detail
            where
                account_type = p_account_type
        ) loop
            ls_payer_detail := j.details;
        end loop;

        return ls_payer_detail;
    end get_cnb_check_payer_detail;

    procedure send_check_cnb (
        p_entrp_id  in number,
        p_status    in varchar2,
        x_file_name out varchar2
    ) is

        l_file_id           number;
        l_file_name         varchar2(3200);
        l_line              varchar2(32000);
        l_sqlerrm           varchar2(32000);
        l_utl_id            utl_file.file_type;
        l_check_number      number;
        l_file_count        number;
        l_trans_ref         varchar2(100);
        v_employer_num      varchar2(100);
        l_count             number := 0;
        l_cnb_trans_ref_num varchar2(100);
        l_check_due_date    varchar2(10);
        l_payee_detail      varchar2(4000);
    begin
        l_file_id := pc_debit_card.insert_file_seq('CHECK');
        select
            count(*)
        into l_file_count
        from
            external_files
        where
                file_action = 'CHECK'
            and trunc(creation_date) = trunc(sysdate);

        l_file_name := 'EASI_Tran.sterlingadmin_uat.'
                       || to_char(sysdate, 'YYYYMMDD')
                       || lpad(l_file_count, 4, 0)
                       || '.csv';

        x_file_name := l_file_name;
        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;

   -- send_email_on_hra_fsa_checks('NORMAL');

        l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');
        for x in (
            select
                c.pers_id,
                chk.check_amount,
                chk.check_number,
                c.claim_id,
                pr.vendor_id,
                case
                    when pr.claim_type in ( 'PROVIDER', 'PROVIDER_ONLINE', 'PROVIDER_EDI' ) then
                        'Y'
                    else
                        'N'
                end                                provider_flag,
                case
                    when c.service_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' ) then   -- Added by joshi for 12130
                        'HRA'
                    else
                        'FSA'
                end                                service_type,
                to_char(
                    add_business_days(6,
                                      trunc(sysdate)),
                    'YYYY-MM-DD'
                )                                  check_date,
                get_provider_acc_num(pr.vendor_id) vendor_acc_num,
                acc.account_type,
                regexp_replace(
                    substr(chk.memo, 1, 80),
                    '[[:cntrl:]]',
                    ''
                )                                  memo
            from
                claimn           c,
                payment_register pr,
                checks           chk,
                account          acc
            where
                c.claim_status in ( 'READY_TO_PAY', 'PARTIALLY_PAID' )
                and pr.claim_type in ( 'SUBSCRIBER', 'PROVIDER', 'SUBSCRIBER_ONLINE', 'PROVIDER_ONLINE' )
                and c.claim_id = pr.claim_id
                and chk.entity_type = 'CLAIMN'
                and c.pers_id = acc.pers_id
                and chk.source_system = 'ADMINISOURCE'
                and chk.entity_id = c.claim_id
                and pc_account.acc_balance(pr.acc_id,
                                           c.plan_start_date,
                                           c.plan_end_date,
                                           pc_account.get_account_type(pr.acc_id),
                                           c.service_type) >= 0
                and chk.status = nvl(p_status, 'READY')
                and pr.vendor_id is not null
                and c.entrp_id = nvl(p_entrp_id, c.entrp_id)
                and not exists (
                    select
                        *
                    from
                        checks
                    where
                            checks.status = 'PURGE_AND_REISSUE'
                        and checks.entity_id = chk.entity_id
                        and chk.entity_type = checks.entity_type
                )
            union
            select
                c.pers_id,
                chk.check_amount,
                chk.check_number,
                c.claim_id,
                pr.vendor_id,
                case
                    when pr.claim_type in ( 'PROVIDER', 'PROVIDER_ONLINE', 'PROVIDER_EDI' ) then
                        'Y'
                    else
                        'N'
                end                                provider_flag,
                case
                    when c.service_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' ) then -- Added by joshi for 12130
                        'HRA'
                    else
                        'FSA'
                end                                service_type,
                to_char(
                    add_business_days(6, chk.check_date),
                    'YYYY-MM-DD'
                )                                  check_date,
                get_provider_acc_num(pr.vendor_id) vendor_acc_num,
                acc.account_type,
                regexp_replace(
                    substr(chk.memo, 1, 80),
                    '[[:cntrl:]]',
                    ''
                )                                  memo
            from
                claimn           c,
                payment_register pr,
                checks           chk,
                account          acc
            where
                pr.claim_type in ( 'SUBSCRIBER', 'PROVIDER', 'SUBSCRIBER_ONLINE', 'PROVIDER_ONLINE' )
                and c.claim_id = pr.claim_id
                and chk.entity_type = 'CLAIMN'
                and c.pers_id = acc.pers_id
                and chk.source_system = 'ADMINISOURCE'
                and chk.entity_id = c.claim_id
                and chk.status = nvl(p_status, 'READY')
                and chk.check_amount > 0
                and exists (
                    select
                        *
                    from
                        checks
                    where
                            checks.status = 'PURGE_AND_REISSUE'
                        and checks.entity_id = chk.entity_id
                        and chk.entity_type = checks.entity_type
                )
                and pr.vendor_id is not null
        ) loop
            l_count := l_count + 1;
            l_cnb_trans_ref_num := 'CNB'
                                   || lpad(cnb_check_seq.nextval, 13, 0);
            if l_count = 1 then
                l_line := pc_check_process.g_check_header_line;
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;

        -- Added by Joshi for 12092 
            if x.provider_flag = 'Y' then
                l_payee_detail := pc_check_process.get_provider_cnb(x.claim_id);
            else
                l_payee_detail := pc_check_process.get_employee_name_address_cnb(x.pers_id);
            end if;

            l_line := l_cnb_trans_ref_num
                      || ','
                      || g_cnb_check_site_id
                      || ','
                      || 'Check'
                      || ','
                      || pc_check_process.get_cnb_check_payer_detail(x.service_type)
                      || ','
                      || pc_check_process.g_check_delivery_method
                      || ','
                      || pc_check_process.g_delivery_inst
                      || ','
                      || x.check_number
                      || ','
                      || '"'
                      || x.memo
                      || '"'
                      || ','
                      || l_payee_detail
                      || ','
                      || pc_check_process.g_payeecountry
                      || ','
                      || null
                      || ','
                      || x.vendor_acc_num
                      || ','
                      || x.check_amount
                      || ','
                      || x.check_date
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || 'SAMSYSTEM'
                      || ','
                      || null;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

            pc_check_process.insert_cnb_check_trans_detail(l_cnb_trans_ref_num, x.check_number, l_file_id, x.vendor_id, x.provider_flag
            );

        end loop;

        utl_file.fclose(file => l_utl_id);
        if file_length(x_file_name, 'CHECKS_DIR') = 0 then
            x_file_name := null;
            update external_files
            set
                result_flag = 'Y',
                sent_flag = 'Y'
            where
                file_id = l_file_id;

        end if;

        commit;
	 -- Added by Joshi for 12770
        if l_file_id is not null then
            pc_check_process.send_email_on_hra_fsa_checks(l_file_id);
        end if;
    exception
        when others then
            rollback;
            raise_application_error(-20030, 'Check File Creation Process Failed. ' || sqlerrm);
    end send_check_cnb;

    procedure send_edi_check_cnb (
        p_entrp_id  in number,
        x_file_name out varchar2
    ) is

        l_file_id           number;
        l_file_name         varchar2(3200);
        l_line              varchar2(32000);
        l_sqlerrm           varchar2(32000);
        l_utl_id            utl_file.file_type;
        l_check_number      number;
        l_file_count        number;
        l_trans_ref         varchar2(100);
        v_employer_num      varchar2(100);
        l_count             number := 0;
        l_cnb_trans_ref_num varchar2(100);
        l_check_due_date    varchar2(10);
        l_payee_detail      varchar2(4000);
    begin
        l_file_id := pc_debit_card.insert_file_seq('CHECK');
        select
            count(*)
        into l_file_count
        from
            external_files
        where
                file_action = 'CHECK'
            and trunc(creation_date) = trunc(sysdate);

        l_file_name := 'EASI_Tran.sterlingadmin_uat.'
                       || to_char(sysdate, 'YYYYMMDD')
                       || lpad(l_file_count, 4, 0)
                       || '.csv';

        x_file_name := l_file_name;
        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;

    --send_email_on_hra_fsa_checks('EDI');

        l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');
        for x in (
            select
                pr.vendor_id,
                c.pers_id,
                pr.acc_id,
                c.claim_id,
                case
                    when pr.claim_type in ( 'PROVIDER', 'PROVIDER_ONLINE', 'PROVIDER_EDI' ) then
                        'Y'
                    else
                        'N'
                end                                provider_flag,
                case
                    when c.service_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' ) then   -- Added by Joshi for 12130
                        'HRA'
                    else
                        'FSA'
                end                                service_type,
                substr(
                    pc_entrp.get_bps_acc_num_from_acc_id(pr.acc_id),
                    1,
                    18
                )                                  employer_id,
                substr(
                    pc_person.get_entrp_name(c.pers_id),
                    1,
                    50
                )                                  employer_name,
                chk.check_amount,
                chk.check_number,
                acc.account_type,
                get_provider_acc_num(pr.vendor_id) vendor_acc_num,
                to_char(
                    add_business_days(6,
                                      trunc(sysdate)),
                    'YYYY-MM-DD'
                )                                  check_date,
                regexp_replace(
                    substr(pr.memo, 1, 80),
                    '[[:cntrl:]]',
                    ''
                )                                  memo
            from
                claimn           c,
                payment_register pr,
                checks           chk,
                account          acc
            where
                c.claim_status in ( 'READY_TO_PAY', 'PARTIALLY_PAID' )
                and pr.claim_type in ( 'SUBSCRIBER_EDI', 'PROVIDER_EDI' )
                and c.claim_id = pr.claim_id
                and chk.entity_type = 'CLAIMN'
                and c.pers_id = acc.pers_id
                and chk.source_system = 'ADMINISOURCE'
                and chk.entity_id = c.claim_id
                and pc_account.acc_balance(pr.acc_id,
                                           c.plan_start_date,
                                           c.plan_end_date,
                                           pc_account.get_account_type(pr.acc_id),
                                           c.service_type) >= 0
                and chk.status = 'READY'
                and pr.vendor_id is not null
                and c.entrp_id = nvl(p_entrp_id, c.entrp_id)
        ) loop
            l_count := l_count + 1;
            l_cnb_trans_ref_num := 'CNB'
                                   || lpad(cnb_check_seq.nextval, 13, 0);
            if l_count = 1 then
                l_line := pc_check_process.g_check_header_line;
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;

         -- Added by Joshi for 12092 
            if x.provider_flag = 'Y' then
                l_payee_detail := pc_check_process.get_provider_cnb(x.claim_id);
            else
                l_payee_detail := pc_check_process.get_employee_name_address_cnb(x.pers_id);
            end if;

            l_line := l_cnb_trans_ref_num
                      || ','
                      || g_cnb_check_site_id
                      || ','
                      || 'Check'
                      || ','
                      || pc_check_process.get_cnb_check_payer_detail(x.service_type)
                      || ','
                      || pc_check_process.g_check_delivery_method
                      || ','
                      || pc_check_process.g_delivery_inst
                      || ','
                      || x.check_number
				--||','||substr(x.memo,1,80)
                      || ','
                      || '"'
                      || x.memo
                      || '"'
                      || ','
                      || l_payee_detail
                      || ','
                      || pc_check_process.g_payeecountry
                      || ','
                      || null
                      || ','
                      || x.vendor_acc_num
                      || ','
                      || x.check_amount
                      || ','
                      || x.check_date
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || 'SAMSYSTEM'
                      || ','
                      || null;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

            pc_check_process.insert_cnb_check_trans_detail(l_cnb_trans_ref_num, x.check_number, l_file_id, x.vendor_id, x.provider_flag
            );

        end loop;

        utl_file.fclose(file => l_utl_id);
        if file_length(x_file_name, 'CHECKS_DIR') = 0 then
            x_file_name := null;
            update external_files
            set
                result_flag = 'Y',
                sent_flag = 'Y'
            where
                file_id = l_file_id;

        end if;

        commit;
	-- Added by Joshi for 12770
        if l_file_id is not null then
            pc_check_process.send_email_on_edi_checks(l_file_id);
        end if;
    exception
        when others then
            rollback;
            raise_application_error(-20030, 'Check File Creation Process Failed. ' || sqlerrm);
    end send_edi_check_cnb;

    procedure send_hsa_check_cnb (
        p_entrp_id  in number,
        p_status    in varchar2,
        x_file_name out varchar2
    ) is

        l_file_id           number;
        l_file_name         varchar2(3200);
        l_line              varchar2(32000);
        l_sqlerrm           varchar2(32000);
        l_utl_id            utl_file.file_type;
        l_check_number      number;
        l_file_count        number;
        l_trans_ref         varchar2(100);
        v_employer_num      varchar2(100);
        l_count             number := 0;
        l_cnb_trans_ref_num varchar2(100);
        l_check_due_date    varchar2(10);
        l_payee_detail      varchar2(4000);
    begin
        l_file_id := pc_debit_card.insert_file_seq('CHECK');
        select
            count(*)
        into l_file_count
        from
            external_files
        where
                file_action = 'CHECK'
            and trunc(creation_date) = trunc(sysdate);

        l_file_name := 'EASI_Tran.sterlingadmin_uat.'
                       || to_char(sysdate, 'YYYYMMDD')
                       || lpad(l_file_count, 4, 0)
                       || '.csv';

        x_file_name := l_file_name;
        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;

    /*** Sending email to finance about the checks being mailed **/
   -- pc_check_process.send_email_on_hsa_checks;

	-- Below added by Swamy for Ticket#9912 on 10/08/2021
   --pc_check_process.send_email_on_lsa_checks;

        l_utl_id := utl_file.fopen('CHECKS_DIR', l_file_name, 'w');
        for x in (
            select
                c.claim_amount,
                c.pers_id,
                pr.acc_id,
                substr(
                    pc_entrp.get_bps_acc_num_from_acc_id(pr.acc_id),
                    1,
                    18
                )                                   employer_id,
                pc_person.get_entrp_name(c.pers_id) employer_name,
                chk.check_amount,
                chk.check_number,
                c.claim_id,
                pr.vendor_id,
                case
                    when pr.claim_type in ( 'HSA_TRANSFER', 'PROVIDER', 'PROVIDER_ONLINE', 'OUTSIDE_INVESTMENT_TRANSFER' ) then
                        'Y'
                    else
                        'N'
                end                                 provider_flag,
                to_char(
                    add_business_days(6,
                                      trunc(sysdate)),
                    'YYYY-MM-DD'
                )                                   check_date,
                case
                    when pr.claim_type = 'SUBSCRIBER'
                         and pr.note like 'Fee Deposit%' then
                        regexp_replace(pr.note, '[[:cntrl:]]', '')
                        || nvl(
                            regexp_replace(pr.memo, '[[:cntrl:]]', ''),
                            ''
                        )
                    when pr.claim_type = 'SUBSCRIBER' then
                        'Provider Name:'
                        || c.prov_name
                        || ' '' '
                        || nvl(
                            regexp_replace(pr.memo, '[[:cntrl:]]', ''),
                            ''
                        )
                    when pr.claim_type = 'PROVIDER'   then
                        regexp_replace(pr.note, '[[:cntrl:]]', '')
                        || ' '
                        || nvl(
                            regexp_replace(pr.memo, '[[:cntrl:]]', ''),
                            ''
                        )
                        || ' '
                        || ' Patient Name:'
                        || pr.patient_name
                    else
                        regexp_replace(pr.note, '[[:cntrl:]]', '')
                        || nvl(
                            regexp_replace(pr.memo, '[[:cntrl:]]', ''),
                            ''
                        )
                end                                 note,
                case
                    when pr.claim_type = 'SUBSCRIBER' then
                        pr.acc_num
                    else
                        pc_check_process.get_provider_acc_num(pr.vendor_id)
                end                                 acc_num,
                acc.account_type
            from
                claimn           c,
                payment_register pr,
                checks           chk,
                account          acc
            where
                pr.claim_type in ( 'EMPLOYER', 'HSA_TRANSFER', 'SUBSCRIBER', 'PROVIDER', 'SUBSCRIBER_ONLINE',
                                   'PROVIDER_ONLINE', 'OUTSIDE_INVESTMENT_TRANSFER' )
                and c.claim_id = pr.claim_id
                and chk.entity_type in ( 'HSA_CLAIM', 'LSA_CLAIM' )
                and chk.source_system = 'ADMINISOURCE'
                and chk.entity_id = c.claim_id
                and c.pers_id = acc.pers_id
                and chk.check_amount > 0
                and chk.status = nvl(p_status, 'READY')
                and pr.vendor_id is not null
                             --AND c.claim_id = 7888107
        ) loop
            l_count := l_count + 1;
            l_cnb_trans_ref_num := 'CNB'
                                   || lpad(cnb_check_seq.nextval, 13, 0);
            if l_count = 1 then
                l_line := pc_check_process.g_check_header_line;
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;

        -- Added by Joshi for 12092 
            if x.provider_flag = 'Y' then
                l_payee_detail := pc_check_process.get_provider_cnb(x.claim_id);
            else
                l_payee_detail := pc_check_process.get_employee_name_address_cnb(x.pers_id);
            end if;

            l_line := l_cnb_trans_ref_num
                      || ','
                      || g_cnb_check_site_id
                      || ','
                      || 'Check'
                      || ','
                      || pc_check_process.get_cnb_check_payer_detail(x.account_type)
                      || ','
                      || pc_check_process.g_check_delivery_method
                      || ','
                      || pc_check_process.g_delivery_inst
                      || ','
                      || x.check_number
				--||','||substr(x.note,1, 80)
                      || ','
                      || '"'
                      || substr(x.note, 1, 80)
                      || '"'
                      || ','
                      || l_payee_detail
                      || ','
                      || pc_check_process.g_payeecountry
                      || ','
                      || null
                      || ','
                      || x.acc_num
                      || ','
                      || x.check_amount
                      || ','
                      || x.check_date
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || null
                      || ','
                      || 'SAMSYSTEM'
                      || ','
                      || null;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            update checks
            set
                status = 'SENT',
                last_update_date = sysdate
            where
                check_number = x.check_number;

            pc_check_process.insert_cnb_check_trans_detail(l_cnb_trans_ref_num, x.check_number, l_file_id, x.vendor_id, x.provider_flag
            );

        end loop;

        utl_file.fclose(file => l_utl_id);
        if file_length(x_file_name, 'CHECKS_DIR') = 0 then
            x_file_name := null;
            update external_files
            set
                result_flag = 'Y',
                sent_flag = 'Y'
            where
                file_id = l_file_id;

        end if;

        commit;
	  -- Added by Joshi for 12770
        if l_file_id is not null then
            pc_check_process.send_email_on_hsa_checks(l_file_id);
        end if;
    exception
        when others then
            rollback;
            raise_application_error(-20030, 'Check File Creation Process Failed. ' || sqlerrm);
    end send_hsa_check_cnb;

    function get_employee_name_address_cnb (
        person_id in number
    ) return varchar2 as
        employee_address varchar2(250);
    begin
        select
            '"'
            || substr(xx.first_name, 1, 50)
            || ' '
            || substr(xx.last_name, 1, 29)
            || ' '
            || substr(xx.middle_name, 1, 1)
            || '",'
            || '"'
            || replace(
                replace(
                    replace((substr(xx.address, 1, 35)
                             || '"'
                             || ','
                             || null
                             || ','
                             || null
                             || ','
                             || substr(xx.city, 1, 20)
                             || ','
                             || substr(xx.state, 1, 2)
                             || ','
                             || substr(xx.zip, 1, 11)),
                            chr(94),
                            ' '),
                    chr(10)
                ),
                chr(13)
            )
        into employee_address
        from
            person xx
        where
            pers_id = person_id;

        return employee_address;
    end get_employee_name_address_cnb;

    function get_provider_cnb (
        p_claim_id number
    ) return varchar2 as
        provider varchar2(250);
    begin
        select
            '"'
            || replace(
                substr(xx.vendor_name, 1, 50),
                '"',
                ''
            )
            || '",'
            || '"'
            || replace(
                replace(
                    replace((substr(xx.address1, 1, 35)
                             || '"'
                             || ','
                             || '"'
                             || substr(xx.address2, 1, 35)
                             || '"'
                             || ','
                             || '"'
                             || substr(xx.address3, 1, 35)
                             || '"'
                             || ','
                             || substr(xx.city, 1, 20)
                             || ','
                             || substr(xx.state, 1, 2)
                             || ','
                             || substr(xx.zip, 1, 5)),
                            chr(94),
                            ' '),
                    chr(10)
                ),
                chr(13)
            )
        into provider
        from
            vendors xx
        where
            vendor_id = (
                select
                    vendor_id
                from
                    payment_register
                where
                    claim_id = p_claim_id
            );

        return provider;
    end;

    procedure process_check_result_cnb (
        p_file_name in varchar2
    ) is

        l_claimn_id    number;
        app_exception exception;
        l_error_msg    varchar2(100);
        ctr            number := 0;
        l_sqlerrm      varchar2(100);
        l_check_amount number := 0;
        l_entity_type  varchar2(30);
    begin
        if file_length(p_file_name, 'CHECKS_DIR') > 0 then
            begin
                execute immediate '
                       ALTER TABLE check_result_ext_cnb
                        location (CHECKS_DIR:'''
                                  || p_file_name
                                  || ''')';
            exception
                when others then
                    l_sqlerrm := 'Error in Changing location of checks file' || sqlerrm;
                    pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  ' || p_file_name
                    );
                    raise app_exception;
            end;

            for x in (
                select
                    ch.check_number,
                    ch.check_amount,
                    b.acc_id,
                    b.pers_id,
                    ch_ext.cnb_trans_ref,
                    ch_ext.status_code,
                    ch_ext.status_name,
                    ch_ext.status_desc
                from
                    check_result_ext_cnb   ch_ext,
                    cnb_check_sent_details csc,
                    account                b,
                    checks                 ch
                where
                        ch_ext.cnb_trans_ref = csc.cnb_trans_ref
                    and csc.check_number = ch.check_number
                    and csc.processed_date is null
                    and ch.acc_id = b.acc_id
            ) loop
                begin
                    update cnb_check_sent_details
                    set
                        process_status = decode(
                            upper(x.status_name),
                            'PROCESSED',
                            'P',
                            'E'
                        ),
                        status_code = x.status_code,
                        error_message = x.status_desc,
                        processed_date = sysdate
                    where
                            cnb_trans_ref = x.cnb_trans_ref
                        and check_number = x.check_number;

                    pc_log.log_error('pc_check_process.process_check_result_cnb  rowcount 1', sql%rowcount);
                    if upper(x.status_name) = 'PROCESSED' then
                        update checks ch
                        set
                            ch.mailed_date = sysdate, ---CH.check_date = X.check_date,
                            status = 'MAILED',
                            last_updated_by = 0,
                            last_update_date = sysdate
                        where
                                ch.check_number = x.check_number
                            and ch.acc_id = x.acc_id
                            and ch.source_system = 'ADMINISOURCE'
                            and ch.entity_type in ( 'HSA_CLAIM', 'CLAIMN', 'EMPLOYER_PAYMENTS', 'LSA_CLAIM' )   -- LSA_CLAIM added by Swamy for Ticket#9912 on 10/08/2021
                        returning entity_id,
                                  entity_type into l_claimn_id, l_entity_type;

                        pc_log.log_error('pc_check_process.process_check_result_cnb  rowcount 2', sql%rowcount);
                        update checks ch
                        set
                            ch.mailed_date = sysdate,   -- X.mailed_date,
                            status = 'MAILED',
                            last_updated_by = 0,
                            last_update_date = sysdate
                        where
                                ch.check_number = x.check_number
                            and ch.acc_id = x.acc_id
                            and ch.source_system = 'ADMINISOURCE'
                            and ch.check_source = 'MANUAL'
                            and ch.entity_type in ( 'EMPLOYER_PAY', 'INVOICE', 'LIST_BILL', 'COBRA_DISBURSE', 'EMPLOYEE_HSA_CLAIM',
                                                    'EMPLOYEE_HRAFSA_CLAIM' );

                        pc_log.log_error('pc_check_process.process_check_result_cnb  rowcount 3', sql%rowcount);
                        if l_entity_type = 'EMPLOYER_PAYMENTS' then
                            update employer_payments
                            set
                                check_number = x.check_number,
                                last_updated_by = 0,
                                last_update_date = sysdate
                            where
                                payment_register_id = l_claimn_id;

                            pc_log.log_error('pc_check_process.process_check_result_cnb  rowcount 5', sql%rowcount);
                            update payment_register
                            set
                                peachtree_interfaced = 'Y',
                                last_update_date = sysdate
                            where
                                payment_register_id = l_claimn_id;

                            pc_log.log_error('pc_check_process.process_check_result_cnb  rowcount 6', sql%rowcount);
                        else
                            update payment p
                            set
                                pay_num = x.check_number,
                                last_updated_by = 0,
                                last_updated_date = sysdate,
                                paid_date = sysdate
                            where
                                    p.claimn_id = l_claimn_id
                                and pay_num is null
                                and amount = x.check_amount
                                and acc_id = x.acc_id;

                            pc_log.log_error('pc_check_process.process_check_result_cnb  rowcount 7', sql%rowcount); 

                      -- updating for purge and reissue
                            update payment p
                            set
                                pay_num = x.check_number,
                                last_updated_by = 0,
                                last_updated_date = sysdate,
                                paid_date = sysdate
                            where
                                    p.claimn_id = l_claimn_id
                                and pay_num is not null
                                and amount = x.check_amount
                                and exists (
                                    select
                                        *
                                    from
                                        checks
                                    where
                                            p.pay_num = checks.check_number
                                        and status = 'PURGE_AND_REISSUE'
                                        and entity_type in ( 'HSA_CLAIM', 'CLAIM', 'CLAIMN', 'LSA_CLAIM' )   -- LSA_CLAIM added by Swamy for Ticket#9912 on 10/08/2021
                                        and entity_id = p.claimn_id
                                )
                                and acc_id = x.acc_id;

                            pc_log.log_error('pc_check_process.process_check_result_cnb  rowcount 8', sql%rowcount);
                            update claimn
                            set
                                claim_status =
                                    case
                                        when claim_pending > 0 then
                                            'PARTIALLY_PAID'
                                        else
                                            'PAID'
                                    end
                            where
                                    claim_id = l_claimn_id
                                and pers_id = x.pers_id;

                            pc_log.log_error('pc_check_process.process_check_result_cnb  rowcount 9', sql%rowcount);
                            update payment_register
                            set
                                peachtree_interfaced = 'Y',
                                last_update_date = sysdate
                            where
                                claim_id = l_claimn_id;

                            pc_log.log_error('pc_check_process.process_check_result_cnb  rowcount 10', sql%rowcount);
                        end if;

                    end if;

                exception
                    when app_exception then
                        pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  '
                                                                                                 || p_file_name
                                                                                                 || ' Error '
                                                                                                 || sqlerrm);
                end;
            end loop;

        end if;

        pc_webservice_batch.upd_edi_repo_file_process_flag(
            p_file_name   => p_file_name,
            p_vendor_name => 'CNB',
            p_feed_type   => 'STATUS_FILE'
        );  -- Added by Swamy for Server Migration

    exception
        when app_exception then
            pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  '
                                                                                     || p_file_name
                                                                                     || ' Error '
                                                                                     || sqlerrm);
        when others then
            rollback;
            pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  '
                                                                                     || p_file_name
                                                                                     || ' Error '
                                                                                     || sqlerrm);
    end process_check_result_cnb;

    procedure process_check_result_ack_cnb (
        p_file_name in varchar2
    ) is

        l_claimn_id    number;
        app_exception exception;
        l_error_msg    varchar2(100);
        ctr            number := 0;
        l_sqlerrm      varchar2(100);
        l_check_amount number := 0;
        l_entity_type  varchar2(30);
    begin
        pc_log.log_error('pc_check_process.process_check_result_ACK_CNB  p_file_name :  ', p_file_name);
        if file_length(p_file_name, 'CHECKS_DIR') > 0 then
            begin
                execute immediate '
                       ALTER TABLE CHECK_RESULT_ACK_EXT_CNB
                        location (CHECKS_DIR:'''
                                  || p_file_name
                                  || ''')';
            exception
                when others then
                    l_sqlerrm := 'Error in Changing location of checks file' || sqlerrm;
                    pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  ' || p_file_name
                    );
                    raise app_exception;
            end;

            for x in (
                select
                    ch.check_number,
                    ch.check_amount,
                    b.acc_id,
                    b.pers_id,
                    ch_ext.cnb_trans_ref,
                    ch_ext.status,
                    ch_ext.reason
                from
                    check_result_ack_ext_cnb ch_ext,
                    cnb_check_sent_details   csc,
                    account                  b,
                    checks                   ch
                where
                        ch_ext.cnb_trans_ref = csc.cnb_trans_ref
                    and csc.check_number = ch.check_number
                    and ch.acc_id = b.acc_id
            ) loop
                update cnb_check_sent_details
                set
                    ackowledgement_status = x.status,
                    error_message = nvl(error_message, x.reason)
                where
                        cnb_trans_ref = x.cnb_trans_ref
                    and check_number = x.check_number;

                pc_log.log_error('pc_check_process.process_check_result_cnb  rowcount for check number: ', x.cnb_trans_ref
                                                                                                           || '  '
                                                                                                           || sql%rowcount);

            end loop;

            pc_webservice_batch.upd_edi_repo_file_process_flag(
                p_file_name   => p_file_name,
                p_vendor_name => 'CNB',
                p_feed_type   => 'ACKNOWLEDGEMENT_FILE'
            );  -- Added by Swamy for Server Migration
        end if;

    exception
        when app_exception then
            pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  '
                                                                                     || p_file_name
                                                                                     || ' Error '
                                                                                     || sqlerrm);
        when others then
            rollback;
            pc_debit_card.insert_alert('Error in Changing location of checks file ', 'Error in Changing location of checks file  '
                                                                                     || p_file_name
                                                                                     || ' Error '
                                                                                     || sqlerrm);
    end process_check_result_ack_cnb;

    procedure send_email_on_manual_checks (
        p_file_id number
    ) as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
        l_email_id     varchar2(4000);
    begin
        l_html_message := '<html>
      <head>
          <title>HSA checks to Adminisource </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> Manual Checks to CNB  </p>
       </table>
        </body>
        </html>';
        l_sql := ' SELECT  ACC.ACC_NUM ,
                case when acc.pers_id  is not null then 
                    pc_person.get_person_name(acc.pers_id)
                else
                    pc_account.get_employer_name(acc.acc_id)
                end Name,
				ACC.ACCOUNT_TYPE,
				CHK.CHECK_NUMBER,
				CHK.CHECK_AMOUNT ,
				REGEXP_REPLACE(CHK.MEMO ,''[[:cntrl:]]'', '''') NOTE
	FROM  CHECKS CHK,  ACCOUNT ACC, cnb_check_sent_details cs
  WHERE CHK.ACC_ID = ACC.ACC_ID
	   AND  CHK.CHECK_AMOUNT > 0
	   AND  chk.check_number = cs.check_number
	   AND  CHK.CHECK_SOURCE = ''MANUAL''
	   AND cs.file_id  = ' || p_file_id;
        if user in ( 'SAM', 'RJOSHI' ) then
            l_email_id := 'vanitha.subramanyam@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,corp.finance@sterlingadministration.com,josie.vega@sterlingadministration.com' || 'denise.law@sterlingadministration.com,finance.department@sterlingadministration.com'
            ;
        else
            l_email_id := 'it-team@sterlingadministration.com';
        end if;

        pc_log.log_error('pc_check_process.send_email_on_manual_checks ', 'l_email_id: ' || l_email_id);
        pc_log.log_error('pc_check_process.send_email_on_manual_checks ', 'USER: ' || user);
        mail_utility.report_emails('oracle@sterlingadministration.com',
                                   l_email_id,
                                   'Manual_checks'
                                   || to_char(sysdate, 'MMDDYYYY')
                                   || '.xls',
                                   l_sql,
                                   l_html_message,
                                   'Manual checks sent to CNB on ' || to_char(sysdate, 'MM/DD/YYYY'));

    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end send_email_on_manual_checks;

    procedure send_email_on_edi_checks (
        p_file_id in number
    ) as

        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
        l_email_id     varchar2(4000);
        l_file_name    varchar2(100);
        ls_subject     varchar2(3200);
    begin
        l_html_message := '<html> <head> ';
        l_html_message := l_html_message || ' <title>HRA/FSA EDI checks to CNB </title> ';
        l_html_message := l_html_message || ' </head> <body bgcolor="#FFFFFF" link="#000080"> <table cellspacing="0" cellpadding="0" width="100%"> '
        ;
        l_html_message := l_html_message || ' <p> HRA/FSA EDI checks to CNB </p> ';
        l_html_message := l_html_message || ' </table>  </body>  </html>';
        l_sql := 'SELECT 
                      pr.acc_num "Account Number"
                     ,pc_person.get_person_name(c.pers_id) "Employee Name"
                     ,pc_person.get_entrp_name(c.pers_id) "Employer Name"
                     ,c.claim_id "Claim Number"
                     ,c.claim_code "Claim Code"
                     ,c.claim_date_start "Date Received"
                     ,c.claim_amount  "Claim Amount"
                     ,c.claim_paid "Claim Paid"
                     ,c.claim_pending "Claim Pending"
                     ,c.denied_amount "Denied Amount"
                     ,chk.check_number "Check Number"
                     ,chk.check_amount "Check Amount"
                     ,chk.status "Status"
                     ,TO_CHAR(c.plan_start_date,''MM/DD/YYYY'')||''-''||TO_CHAR(c.plan_end_date,''MM/DD/YYYY'') "Plan Year"
                     ,c.service_type "Service Type"                     
                FROM CLAIMN C,payment_register pr , CHECKS chk, cnb_check_sent_details cnb
                WHERE c.claim_status IN (''READY_TO_PAY'',''PARTIALLY_PAID''  )
                 AND pr.claim_type IN (''SUBSCRIBER_EDI'',''PROVIDER_EDI'')
                 AND c.claim_id = pr.claim_id
                 AND chk.entity_type = ''CLAIMN''
                 AND chk.source_system = ''ADMINISOURCE''
                 AND chk.entity_id = C.claim_id
                 AND pc_account.acc_balance(pr.acc_id,c.plan_start_date,c.plan_end_date,pc_account.get_account_type(pr.acc_id),c.service_type) >= 0
                 AND pr.vendor_id IS NOT NULL
                 AND chk.check_number = cnb.check_number
                 AND cnb.file_id = ' || p_file_id;
        l_file_name := 'hra_fsa_checks_edi'
                       || to_char(sysdate, 'MMDDYYYY')
                       || '.xls';
        ls_subject := 'HRA/FSA checks(EDI) sent to CNB on ' || to_char(sysdate, 'MM/DD/YYYY');
        if user in ( 'SAM', 'RJOSHI' ) then
            l_email_id := 'vanitha.subramanyam@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,corp.finance@sterlingadministration.com,josie.vega@sterlingadministration.com' || 'denise.law@sterlingadministration.com,finance.department@sterlingadministration.com'
            ;
        else
            l_email_id := 'it-team@sterlingadministration.com';
        end if;

        mail_utility.report_emails('oracle@sterlingadministration.com', l_email_id, l_file_name, l_sql, l_html_message,
                                   ls_subject);
    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
            pc_log.log_error('pc_check_process.send_email_on_cobra_checks error: ', sqlerrm);
    end send_email_on_edi_checks;

end pc_check_process;
/


-- sqlcl_snapshot {"hash":"ed0405134826a424281ea1960900d52e12aa7442","type":"PACKAGE_BODY","name":"PC_CHECK_PROCESS","schemaName":"SAMQA","sxml":""}