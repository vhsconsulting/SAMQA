create or replace package body samqa.pc_nightly_email as

    procedure email_sam_users as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
    begin
        l_html_message := '<html>
      <head>
          <title>SAM Users </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> SAM USERS </p>
       </table>
        </body>
        </html>';
        l_sql := ' select SAM_USERS.USER_ID as "User ID",
                SAM_USERS.USER_NAME as "User Name",
                EMPLOYEE.FIRST_NAME as "First Name",
                EMPLOYEE.LAST_NAME as "Last Name",
                SAM_USERS.EXPIRES_ON as "Expires On",
                SAM_USERS.CREATED_ON as " Created On",
                sam_roles.role_description as "Role" ,
                SAM_USERS.STATUS as "Status",
                SAM_USERS.FAILED_LOGINS as "Failed Logins",
                SAM_USERS.LAST_ACTIVITY_DATE as "Last Activity Date"
                from SAM_USERS , sam_roles,EMPLOYEE
                where sam_users.role_id=sam_roles.role_id 
                and sam_users.user_id=employee.user_id';
        mail_utility.report_emails('oracle@sterlingadministration.com',
                                   'franco.espinoza@sterlingadministration.com,dana.ramos@sterlingadministration.com,'
                                   || 'shavee.kapoor@sterlingadministration.com,Lindsey.Neville@sterlingadministration.com'
                                   || ',cindy.carrillo@sterlingadministration.com,Sarah.Soman@sterlingadministration.com'
                                   || ',techlog@sterlingadministration.com',
                                   'sam_users'
                                   || to_char(sysdate, 'YYYYMMDD')
                                   || '.xls',
                                   l_sql,
                                   l_html_message,
                                   'SAM USERS (Executive)');

        utl_file.fcopy('MAILER_DIR', --THIS IS A ORACLE DIRECTORY
                       'sam_users'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '.xls', --FILE NAME
                       'REPORT_DIR', --THIS IS A ORACLE DIRECTORY
                       'sam_users'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '.xls'); --DESTINATION FILE

    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end email_sam_users;

    procedure email_void_invoices as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
    begin
        l_html_message := '<html>
      <head>
          <title>Voided Invoices in SAM on '
                          || to_char(sysdate, 'MM/DD/YYYY')
                          || ' </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> Voided Invoices in SAM </p>
       </table>
        </body>
        </html>';
        l_sql := '  select  ACC_NUM "Account Number",INVOICE_ID "Invoice #", BILLING_NAME "Billing Name"
                  FROM ar_invoice WHERE approved_date is not null
		  AND status = ''VOID''
                  AND TRUNC(CANCELLED_DATE) >= TRUNC(SYSDATE-1)  ';
        mail_utility.report_emails('oracle@sterlingadministration.com',
                                   'corp.finance@sterlingadministration.com,techsupport@sterlingadministration.com',
                                   'void_invoices_'
                                   || to_char(sysdate, 'MMDDYYYY')
                                   || '.xls',
                                   l_sql,
                                   l_html_message,
                                   'Voided Invoices on ' || to_char(sysdate, 'MM/DD/YYYY'));

    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end email_void_invoices;

    procedure pending_accounts as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
    begin
        l_html_message := '<html>
      <head>
          <title>Pending Accounts Report</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> Report contains all the pending accounts for HSA and HRA account type </p>
       </table>
        </body>
        </html>';
        l_sql := ' SELECT first_name "First Name"
                                   , last_name "Last Name"
                                   , a.acc_num "Account Number"
                                   , pc_entrp.get_entrp_name(b.entrp_id) "Employer Name"
                                   ,  a.note "Note"
                              FROM  account a
                                  , person b
	                            WHERE  account_status = 3
                               AND    a.pers_id = b.pers_id ';
        mail_utility.report_emails('oracle@sterlingadministration.com', 'dana.ramos@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,'
                                                                        || 'cindy.carrillo@sterlingadministration.com,customer.service@sterlingadministration.com'
                                                                        || ',vanitha.subramanyam@sterlingadministration.com', 'pending_accounts.xls'
                                                                        , l_sql, l_html_message,
                                   'Pending Accounts Report');

    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end pending_accounts;

    procedure account_under_review as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
    begin
        l_html_message := '<html>
      <head>
          <title>Accounts Under Review</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> Report contains all the accounts under pending review </p>
       </table>
        </body>
        </html>';
        l_sql := ' SELECT B.FIRST_NAME,B.LAST_NAME,B.ADDRESS,B.CITY,B.STATE,B.ZIP,A.ACC_NUM
                FROM ACCOUNT A,PERSON B WHERE A.PERS_ID=B.PERS_ID AND A.AT_RISK_OF=''Y'' ';
        mail_utility.report_emails('oracle@sterlingadministration.com', 'Managers@sterlingadministration.com', 'Accounts_Under_Review.xls'
        , l_sql, l_html_message,
                                   'Accounts Under Review');
    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end account_under_review;

    procedure unpaid_sales_accounts as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
    begin
        l_html_message := '<html>
      <head>
          <title>Unpaid Accounts to Sales Rep </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> Report contains all the accounts that sales rep did not get paid with commission </p>
       </table>
        </body>
        </html>';
        l_sql := ' select ACCOUNT.ACC_NUM "Account Number",
                     CASE WHEN ACCOUNT.ACC_NUM IS NOT NULL THEN
                         pc_account.acc_balance(ACCOUNT.ACC_ID,''01-JAN-2004'',SYSDATE)
                      END  "Balance",
                      TO_CHAR(ACCOUNT.START_DATE,''MM/DD/YYYY'') "Effective Date",
                      DECODE(ACCOUNT.COMPLETE_FLAG,1,''Yes'',''No'') "Setup Complete",
                      PC_ACCOUNT.GET_SALESREP_NAME(ACCOUNT.SALESREP_ID) "Sales Rep"
              from  "ACCOUNT"
                   ,"PLANS"
               WHERE TRUNC(ACCOUNT.START_DATE) >= TRUNC(SYSDATE,''YYYY'')
                 AND   TRUNC(ACCOUNT.START_DATE) <= TRUNC(SYSDATE,''MM'')-1
                 AND   ACCOUNT.ACCOUNT_STATUS =1
                 AND   ACCOUNT.PLAN_CODE  = PLANS.PLAN_CODE
                 AND   ACCOUNT.PLAN_CODE IN (1,2)
                 AND   PLANS.PLAN_SIGN = ''SHA''
                 AND   ACCOUNT.ENTRP_ID IS NULL
                 AND   NOT EXISTS ( SELECT * FROM sales_commission_history
                       WHERE  sales_commission_history.ACC_NUM = ACCOUNT.ACC_NUM) ';
        mail_utility.report_emails('customer.service@sterlingadministration.com', 'shavee.kapoor@sterlingadministration.com,' || 'vanitha.subramanyam@sterlingadministration.com,corp.finance@sterlingadministration.com'
        , 'unpaid_accounts.xls', l_sql, l_html_message,
                                   'Salesrep Unpaid Accounts Report');

    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end unpaid_sales_accounts;

    procedure fee_bucket_close_acc as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
    begin
        l_html_message := '<html>
      <head>
          <title>Fee Bucket Balance for Closed Accounts </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> Report contains all the closed accounts that have fee bucket balance </p>
       </table>
        </body>
        </html>';
        l_sql := ' SELECT ACC_NUM "Account Number"
                    , PC_ACCOUNT.FEE_BUCKET_BALANCE(ACC_ID) "Fee Bucket Balance"
              FROM ACCOUNT
              WHERE ACCOUNT_STATUS = 4
              AND   PC_ACCOUNT.FEE_BUCKET_BALANCE(ACC_ID) > 0 ';
        mail_utility.report_emails('oracle@sterlingadministration.com', 'dana.ramos@sterlingadministration.com,shavee.kapoor@sterlingadministration.com,' || 'vanitha.subramanyam@sterlingadministration.com,corp.finance@sterlingadministration.com'
        , 'fee_bucket.xls', l_sql, l_html_message,
                                   'Fee Bucket Balance on Closed Accounts');

    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end fee_bucket_close_acc;

    procedure fee_problem as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
    begin
        l_html_message := '<html>
      <head>
          <title>Monthly Fee Discrepancy for Central Valley Bank Accounts </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> Please verify the fee amounts charged to Central Valley
          accounts in the attached list and make necessary correction. </p>
       </table>
        </body>
        </html>';
        l_sql := ' SELECT acc_num "Account Number", a.pay_date "Pay Date" , a.amount "Fee Amount"
               FROM   payment a, account b
	             WHERE  a.acc_id = b.acc_id
	             AND    a.pay_date >= TO_DATE(''11/01/2007'',''MM/DD/YYYY'')
	             AND    b.acc_num LIKE ''CVB%''
	             AND    a.reason_code  = 2
	             AND    NOT EXISTS ( SELECT * FROM PLAN_FEE
	                                 WHERE PLAN_CODE= B.PLAN_CODE
			                           	 AND   FEE_AMOUNT = a.AMOUNT)';
        mail_utility.report_emails('oracle@sterlingadministration.com', 'shavee.kapoor@sterlingadministration.com,' || 'vanitha.subramanyam@sterlingadministration.com,corp.finance@sterlingadministration.com'
        , 'cvb_monthly.xls', l_sql, l_html_message,
                                   'Monthly Fee Discrepancy for Central Valley Bank Account');

    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end fee_problem;

    procedure error_accounts as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
    begin
        l_html_message := '<html>
      <head>
          <title>Error Accounts (Paper Application) </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> Report contains all the error accounts </p>
       </table>
        </body>
        </html>';
        l_sql := ' SELECT first_name "First Name"
                    , last_name "Last Name"
		    , error_message "Error Message"
		    , note "Note"
               FROM   mass_enrollments
	       WHERE  error_message IS NOT NULL AND error_column IS NOT NULL
               AND ERROR_COLUMN NOT IN (''DUPLICATE'',''SUCCESS'') ';
        mail_utility.report_emails('oracle@sterlingadministration.com', 'dana.ramos@sterlingadministration.com', 'error_accounts.xls'
        , l_sql, l_html_message,
                                   'Error Accounts (Paper Application)');
    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end error_accounts;

    procedure suspacious_accounts as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
    begin
        l_html_message := '<html>
      <head>
          <title>Error Accounts (Paper Application) </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> Please verify the attached list to fix the accounts with suspicious debit card activity </p>
       </table>
        </body>
        </html>';
        l_sql := '  SELECT  ACC_NUM "Account Number"
                      , pay_date "Pay Date"
		      , balance "Balance"
		      , note "Note"
	        FROM	(SELECT B.ACC_NUM, A.pay_date
		              ,''Debit Card Disbursements for negative balance'' note
			           ,pc_account.acc_balance(a.acc_id,''01-JAN-04'',SYSDATE) balance
	        	FROM   PAYMENT A, Account b
		WHERE  REASON_CODE = 13
		AND    A.ACC_ID = B.ACC_ID
		AND    PAY_DATE = TRUNC(SYSDATE)
		AND    pc_account.acc_balance(a.acc_id,''01-JAN-04'',PAY_DATE) < 0
		AND    pc_account.acc_balance(a.acc_id) < 0) WHERE 1 = 1 ';
        dbms_output.put_line('sql ' || l_sql);
        mail_utility.report_emails('oracle@sterlingadministration.com', 'shavee.kapoor@sterlingadministration.com,' || 'dana.ramos@sterlingadministration.com,financedepartment@sterlingadministration.com'
        , 'suspicious_accounts.xls', l_sql, l_html_message,
                                   'Suspicious Accounts');

    exception
        when others then
-- Close the file if something goes wrong.
            dbms_output.put_line('error message ' || sqlerrm);
    end suspacious_accounts;

    procedure closing_accounts as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
    begin
        l_html_message := '<html>
      <head>
          <title>Closing Accounts </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>  Please verify the attached list  of closing accounts for today </p>
       </table>
        </body>
        </html>';
        l_sql := '   SELECT  ACC_NUM "Account Number"
                       , END_DATE "Close Date"
		                   , balance "Balance"
		                  , note "Note"
	              FROM	(SELECT ACC_NUM,TO_CHAR(END_DATE,''MM/DD/YYYY'') END_DATE
	                        ,case when  suspended_date is not null THEN
			                       ''Suspended Account for More than 90 days''
			                     else
			                        ''Manually Closed Accounts''
			                     end note,pc_account.acc_balance(acc_id) balance
	                    	FROM   ACCOUNT
	                    	WHERE  TRUNC(END_DATE) = TRUNC(SYSDATE)
	                     	AND    ACCOUNT_STATUS = 4
                      	order by 1) WHERE 1 = 1 ';
        mail_utility.report_emails('oracle@sterlingadministration.com',
                                   'shavee.kapoor@sterlingadministration.com,dana.ramos@sterlingadministration.com',
                                   'closing_accounts'
                                   || to_char(sysdate, 'MMDDYYYY')
                                   || '.xls',
                                   l_sql,
                                   l_html_message,
                                   'Closing Accounts');

    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end closing_accounts;

    procedure not_closed_accounts as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
    begin
        l_html_message := '<html>
      <head>
          <title>Suspended Accounts </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> Please verify the attached list of suspended accounts , that will not be closed until reviewed by operations </p>
       </table>
        </body>
        </html>';
        l_sql := '  SELECT  ACC_NUM "Account Number"
                      , suspended_date "Suspended Date"
		      , balance "Balance"
		      , note "Note"
                FROM    (SELECT ACC_NUM,TO_CHAR(suspended_date, ''MM/DD/YYYY'') suspended_date,
                             ''Suspended Accounts for More than 90 days, Accounts
			      will not be closed automatically, pending review by operations''
                                          note
		                 ,pc_account.acc_balance(acc_id) balance
                        FROM   ACCOUNT
                        WHERE  SYSDATE-SUSPENDED_DATE > 90
                        AND    pc_account.acc_balance(acc_id)  < 0
                        AND    ACCOUNT_STATUS = 2
                        order by 1) WHERE 1 = 1 ';
        mail_utility.report_emails('oracle@sterlingadministration.com',
                                   'shavee.kapoor@sterlingadministration.com,dana.ramos@sterlingadministration.com',
                                   'suspended_accounts'
                                   || to_char(sysdate, 'MMDDYYYY')
                                   || '.xls',
                                   l_sql,
                                   l_html_message,
                                   'Suspended Accounts');

    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end not_closed_accounts;

    procedure claim_fee_problem as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
    begin
        l_html_message := '<html>
      <head>
          <title>Double Claim Fee for Provider Online </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> Please verify the attached list  of  accounts for today  </p>
       </table>
        </body>
        </html>';
        l_sql := '  SELECT * FROM ( SELECT b.acc_num "Account Number"
                      , a.pay_date "Pay Date"
		      , a.note "Note"
                  from payment a, payment_register b
                   where a.note like ''generate for claim%''
                   and a.acc_id = b.acc_id
                   and a.claimn_id = b.claim_id
                   and b.claim_type = ''PROVIDER_ONLINE''
                   group by  b.acc_num,a.pay_date,a.note,a.claimn_id
                   having  count(a.change_num) > 1 ) WHERE 1 = 1';
        mail_utility.report_emails('oracle@sterlingadministration.com', 'shavee.kapoor@sterlingadministration.com,vanitha.subramanyam@sterlingadministration.com'
        , 'provider_online.xls', l_sql, l_html_message,
                                   'Double Claim Fee for Provider Online');
    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end claim_fee_problem;

-- not used
    procedure debit_card_balance as

        l_file         utl_file.file_type;
        l_buffer       raw(32767);
        l_amount       binary_integer := 32767;
        l_pos          integer := 1;
        l_blob         blob;
        l_blob_len     integer;
        exc_no_file exception;
        l_create_ddl   varchar2(32000);
        lv_error_file  varchar2(300) := 'debit_card'
                                       || to_char(sysdate, 'YYYYMMDD')
                                       || '.csv';
        l_exists       varchar2(1);
        l_html_message varchar2(32000);
    begin
        l_file := utl_file.fopen('MAILER_DIR', lv_error_file, 'w', 32767);
        utl_file.put_line(l_file, 'Account Number         ,Card Balance    , Balance      , SSN ', true);
        for x in (
            select
                acc_num
                || '   ,'
                || current_card_value
                || '   ,'
                || balance
                || '   ,'
                || ssn line
            from
                (
                    select
                        pc_person.acc_num(card_id)          acc_num,
                        new_card_value                      current_card_value,
                        pc_account.new_acc_balance(card_id) balance,
                        replace(ssn, '-')                   ssn
                    from
                        card_debit a,
                        person     b,
                        account    c
                    where
                            new_card_value - pc_account.acc_balance_card(null, card_id) > 0
                        and a.card_id = b.pers_id
                        and b.pers_id = c.pers_id
                        and c.account_status in ( 1, 2, 3 )
                )
        ) loop
            utl_file.put_line(l_file, x.line, true);
            l_exists := 'Y';
        end loop;

        utl_file.fclose(l_file);
        l_html_message := null;
        if l_exists = 'Y' then
            mail_utility.email_files(
                from_name    => 'oracle',
                to_names     => 'vanitha.subramanyam@sterlingadministration.com',
                subject      => 'Debit Card Activity for ' || to_char(sysdate, 'mm/dd/yyyy'),
                html_message => l_html_message,
                attach       => samfiles('/home/oracle/mailer/' || lv_error_file)
            );
        end if;

    exception
        when others then
-- Close the file if something goes wrong.
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;
            dbms_output.put_line('error message ' || sqlerrm);
    end debit_card_balance;

    procedure notify_er_terminated_ee_in_ach is
    begin
        null;
    end notify_er_terminated_ee_in_ach;

    procedure notify_pending_approvals is
    begin
        null;
    end notify_pending_approvals;

    procedure notify_account_termination is
    begin
        null;
    end notify_account_termination;

    procedure schedule_fsahra_notifications is
    begin

-- HRA/FSA Renewals for the following month

        pc_notifications.plan_renewal_notification;

-- Non-Discrimination Testing Notification for HRA/FSA
        pc_notifications.non_discrim_notification;
-- HRA/FSA Renewals for the current_month

        pc_notifications.send_email_hra_fsa_renewal;
        pc_notifications.hrafsa_approval_report;
        pc_notifications.hrafsa_ae_change_report;
        pc_notifications.hra_employer_balances;
        pc_notifications.fsa_employer_balances;
 -- Changes Report
        pc_web_er_renewal.pos_renewal_det_fsa;
        pc_web_er_renewal.pos_renewal_det_hra;

-- BPS ERRORS
        pc_notifications.email_hrafsa_address_error;
        pc_notifications.email_hrafsa_deductible;
        pc_notifications.email_hrafsa_enrollments;
        pc_notifications.email_hrafsa_dep_card_error;
        pc_notifications.email_hrafsa_payment_error;
        pc_notifications.email_hrafsa_receipt_error;
        pc_notifications.email_annual_election_error;
        pc_notifications.email_hrafsa_bal_diff_error;
        pc_notifications.hrafsa_negative_balance_report;

-- San Francisco Ordinance Reports
        pc_notifications.email_sf_ord_term_rep;
        pc_notifications.email_sf_ord_exp_rep;
        pc_notifications.send_email_on_payment_diff;
        pc_notifications.send_email_on_check_diff;
        pc_notifications.send_email_on_amount_2500;
        pc_notifications.notify_claim_after_plan_yr;
        pc_notifications.notify_claim_before_plan_yr;
        pc_notifications.notify_service_after_plan_yr;
        if to_char(sysdate, 'DD') in ( '31', '01' ) then
            pc_notifications.email_fsa_enrollment_numbers;
        end if;

        if to_char(sysdate, 'DD') in ( '31', '01' ) then
            pc_notifications.email_fsa_new_enrollments;
        end if;

        if to_char(sysdate, 'DD') in ( '31', '01' ) then
            pc_notifications.email_hra_enrollment_numbers;
        end if;

        if to_char(sysdate, 'DD') in ( '31', '01' ) then
            pc_notifications.email_hra_new_enrollments;
        end if;

        pc_notifications.notify_no_plan_yr;
        pc_notifications.send_email_on_bellarmine;
        pc_notifications.email_fsa_ee_with_cobra;
--   PC_NOTIFICATIONS.notify_eob_claims; -- health expense no longer supported
        pc_notifications.list_pending_claims;
        pc_notifications.notify_takeover;
        process_upload.notify_annual_election;
        pc_notifications.webform_er_daily_notfication;  -- Added by Joshi for Webform enrollment notification.
        pc_notifications.hra_fsa_employer_balances_report; -- added by Joshi to generate balance report as per date for shavee.
    ---8683 rprabu 16/04/2020
        begin
            update email_notifications
            set
                mail_status = 'READY'
            where
                    mail_status = 'OPEN'
                and event = 'ROLLOVER_NOTIFY_EVENT';

        end;
    exception
        when others then
            null;
    end schedule_fsahra_notifications;

    procedure schedule_hsa_notifications is
    begin
        pc_notifications.notify_fraud;
        pc_notifications.send_email_on_ofac_results;
        pc_notifications.send_email_on_id_results;
        pc_notifications.notify_fraud;
        pc_notifications.notify_fraud;
        pc_notifications.notify_fraud;
        pc_notifications.email_hsa_address_error;
        pc_notifications.email_hsa_dep_card_error;
        pc_notifications.email_hsa_payment_error;
        pc_notifications.email_hsa_receipt_error;
        pc_notifications.send_email_duplicate_epayment;
        pc_notifications.email_hsa_incomplete_accounts;
        pc_notifications.closed_hsa_account_balances;
        if to_char(sysdate, 'DD') in ( '31', '01' ) then
            pc_notifications.email_hsa_enrollment_numbers;
        end if;

        if to_char(sysdate, 'DD') in ( '31', '01' ) then
            pc_notifications.email_fsa_enrollment_numbers;
        end if;

        if to_char(sysdate, 'DD') in ( '31', '01' ) then
            pc_notifications.email_fsa_new_enrollments;
        end if;

        if to_char(sysdate, 'DD') in ( '31', '01' ) then
            pc_notifications.email_hra_enrollment_numbers;
        end if;

        if to_char(sysdate, 'DD') in ( '31', '01' ) then
            pc_notifications.email_hra_new_enrollments;
        end if;

        pc_notifications.email_duplicate_claims;
        pc_notifications.send_email_on_5498;
        pc_nightly_email.pending_accounts;
        if to_char(sysdate, 'D') = '2' then
            pc_nightly_email.account_under_review;
        end if;
        pc_nightly_email.unpaid_sales_accounts;
        pc_nightly_email.error_accounts;
        pc_nightly_email.suspacious_accounts;
        pc_nightly_email.closing_accounts;
        pc_nightly_email.not_closed_accounts;
        pc_notifications.closed_account_reactivation;
        pc_notifications.employer_setup_fee;
    end schedule_hsa_notifications;

    procedure schedule_comp_notifications is
    begin
        pc_notifications.email_pop_renewals_details;
        pc_notifications.compliance_payment_report;
        pc_notifications.notify_comp_discrim_testing;
        pc_notifications.daily_renewal_erisa;
        pc_notifications.pop_renewals;
        pc_web_er_renewal.pos_renewal_det_erisa;
        pc_notifications.daily_online_renewal_inv_erisa;
        pc_web_er_renewal.pos_renewal_det_pop;                -- Added By Joshi For 5020 Pop Renewal
        pc_notifications.daily_online_renewal_inv_pop;       -- Added By Joshi For 5020 Pop Renewal
        pc_web_er_renewal.pos_renewal_det_form_5500;          -- Added By Prabu For 8135 Form_5500 Renewal on 06-Dec-2019
        pc_notifications.daily_online_rwl_inv_form_5500;      -- Added By Prabu For 7856 Form5500 Renewal
        pc_nightly_email.email_sam_users;
    end schedule_comp_notifications;

    procedure schedule_cobra_notifications is
    begin
        pc_notifications.daily_renewal_cobra;
   --   PC_WEB_ER_RENEWAL.pos_renewal_det_cobra; commented by Joshi as per shavee.
        pc_notifications.daily_online_renewal_inv_cobra;
    end schedule_cobra_notifications;

    procedure schedule_general_notifications is
    begin
        pc_nightly_email.email_void_invoices;
        pc_notifications.email_er_enrollment_report;
        pc_notifications.email_enrollment_report;
        pc_notifications.ach_duplicate_report;
        pc_notifications.enrollments_audit_report;
        pc_notifications.email_sam_report;
        pc_notifications.email_renewal_report;
        pc_notifications.email_rate_plan_details;
        pc_notifications.email_invoice_report_details;
        if to_char(sysdate, 'D') = '20' then
            pc_notifications.email_void_invoice_report;
        end if;
        if to_char(sysdate, 'D') = '2' then
            pc_notifications.email_closed_opportunities;
        end if;
        pc_notifications.email_online_incomplete_app;
        pc_notifications.email_sales_leads;
        pc_notifications.email_suspended_cards;
        pc_notifications.email_multi_product_client;
        pc_nightly_email.fee_bucket_close_acc;
        pc_web_compliance.post_weekly_renewal_details;
        pc_notifications.past_due_renewals;
        pc_notifications.daily_online_er_regn;
        pc_notifications.daily_completed_employer;
        pc_notifications.daily_new_er_invoice;
   -- PC_INVOICE_REPORTS.send_inv_remind_notif;  commented by Joshi for 11648. This is moved to new CRON

        pc_notifications.notify_approved_claims;
        pc_notifications.daily_schedule_contrib_report; -- Added by Joshi for PPP (daily contribution report for new/update schedule)
        pc_notifications.send_scheduler_remind_email; -- Added by Joshi for PPP ( send 4 days prior reminder on payroll process)
        pc_account.close_all_accounts;      -- Added by Swamy for Ticket#7568
 --  Pc_Cobra_Notifications.Run_Cobra_Automatic_Emails; ----- Rprabu 25/09/2023 For COBRA AUTOMATIC  EmailS
        pc_notifications.er_add_remitt_bank_notiification;  --Added by Joshi for 12621
    end schedule_general_notifications;

    procedure schedule_ext_notifications is
    begin
        pc_notifications.process_deny_notification;
        pc_notifications.suspended_60days_notification;
        pc_notifications.catchup_55_notification;
    /*PC_NOTIFICATIONS.catchup_65_notification;*/
        pc_notifications.notify_er_check_posted;
        pc_notifications.notify_hsa_ee_incomplete;
        pc_notifications.process_sfo_notifications;
   /* IF to_char(sysdate,'D') = '2' then
       PC_NOTIFICATIONS.process_new_ben_plans;
      PC_NOTIFICATIONS.process_qe_approval;
    END IF;*/
        if to_char(sysdate, 'D') = '2' then
            pc_notifications.notify_pending_approvals;
        end if;
  -- no template defined for this yet
 --   PC_NOTIFICATIONS.ERISA_RENEWAL_NOTICE;
  --  PC_NOTIFICATIONS.COBRA_RENEWAL_NOTICE;
        pc_notifications.notify_acct_termination;
        pc_notifications.email_unsubstantiated_txn;
        pc_user_bank_acct.send_giact_bank_remind_notif; -- Added by Joshi for 12396
    end schedule_ext_notifications;

    procedure schedule_invoice_notifications is
    begin
        pc_invoice_reports.schedule_invoice_report;
        if to_char(sysdate, 'DD') = '02' then
            pc_notifications.send_emails_inv_not_generated;
        end if;
    end schedule_invoice_notifications;

end pc_nightly_email;
/


-- sqlcl_snapshot {"hash":"ab945d958ce837f2af3d5bae1b9759216c8d882b","type":"PACKAGE_BODY","name":"PC_NIGHTLY_EMAIL","schemaName":"SAMQA","sxml":""}