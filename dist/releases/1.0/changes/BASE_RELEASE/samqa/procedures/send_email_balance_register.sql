-- liquibase formatted sql
-- changeset SAMQA:1754374146284 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\send_email_balance_register.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/send_email_balance_register.sql:null:b8db9bf717ec2dc85bcfcfabcd57d0123a9b7a97:create

create or replace procedure samqa.send_email_balance_register (
    p_account_type in varchar2,
    p_end_date     in date
) as
    l_html_message varchar2(32000);
    l_sql          varchar2(32000);
begin
    l_html_message := '<html>
      <head>
          <title>Financial: HSA Monthly Balance Register report </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p>Monthly Balance Register report</p>
       </table>
        </body>
        </html>';
    l_sql := 'select NAME,ACC_NUM,AMOUNT FROM TABLE(
             PC_FIN_RECON_REPORT.get_hsa_balance_details('''
             || p_end_date
             || ''' ))';
    dbms_output.put_line('SQL ' || l_sql);
    mail_utility.report_emails('oracle@sterlingadministration.com',
                               'vanitha.subramanyam@sterlingadministration.com',
                               'balance_register'
                               || p_account_type
                               || '_'
                               || to_char(p_end_date, 'mmddyyyy')
                               || '.xls',
                               l_sql,
                               l_html_message,
                               'Balance Register for '
                               || p_account_type
                               || ' as of '
                               || to_char(p_end_date, 'mmddyyyy'));

exception
    when others then
-- Close the file if something goes wrong.

        dbms_output.put_line('error message ' || sqlerrm);
end send_email_balance_register;
/

