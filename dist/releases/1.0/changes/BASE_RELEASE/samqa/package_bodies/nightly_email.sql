-- liquibase formatted sql
-- changeset SAMQA:1754373951684 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\nightly_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/nightly_email.sql:null:47f630e03a9cbb1c3d37f8b17d778948be41fbae:create

create or replace package body samqa.nightly_email as

    procedure pending_accounts as

        l_file       utl_file.file_type;
        l_buffer     raw(32767);
        l_amount     binary_integer := 32767;
        l_pos        integer := 1;
        l_blob       blob;
        l_blob_len   integer;
        exc_no_file exception;
        l_create_ddl varchar2(32000);
        lv_dest_file varchar2(300) := 'Pending_Data_Entry_'
                                      || to_char(sysdate, 'YYYYMMDD')
                                      || '.csv';
    begin
        l_file := utl_file.fopen('MAILER_DIR', lv_dest_file, 'w', 32767);
        utl_file.put_line(l_file, 'Account Number, Note ', true);
        for x in (
            select
                acc_num
                || ','
                || note line
            from
                account
            where
                account_status = 3
                or complete_flag = 0
            union all
            select
                acc_num
                || ','
                || note
            from
                account
            where
                note like '%Broker Does Not%'
        ) loop
            utl_file.put_line(l_file, x.line, true);
        end loop;

        utl_file.fclose(l_file);
        mail_utility.email_files(
            from_name    => 'oracle',
            to_names     => 'duarte.batista@sterlingadministration.com,vanitha.subramanyam@sterlingadministration.com',
            subject      => 'Pending Accounts',
            html_message => '<html><body><br>
                         Check and Verify the attached Pending Applications
                       <br><br>
                      </body></html>',
            attach       => samfiles('/home/oracle/mailer/' || lv_dest_file)
        );

    exception
        when others then
-- Close the file if something goes wrong.
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;
    end pending_accounts;

    procedure error_accounts as

        l_file        utl_file.file_type;
        l_buffer      raw(32767);
        l_amount      binary_integer := 32767;
        l_pos         integer := 1;
        l_blob        blob;
        l_blob_len    integer;
        exc_no_file exception;
        l_create_ddl  varchar2(32000);
        lv_error_file varchar2(300) := 'Missing_Information_'
                                       || to_char(sysdate, 'YYYYMMDD')
                                       || '.csv';
    begin
        l_file := utl_file.fopen('MAILER_DIR', lv_error_file, 'w', 32767);
        utl_file.put_line(l_file, 'Account Number, Note ', true);
        for x in (
            select
                first_name
                || ','
                || last_name
                || ','
                || note line
            from
                mass_enrollments
            where
                error_message is not null
                and error_column not in ( 'DUPLICATE', 'SUCCESS' )
        ) loop
            utl_file.put_line(l_file, x.line, true);
        end loop;

        utl_file.fclose(l_file);
        mail_utility.email_files(
            from_name    => 'oracle',
            to_names     => 'Lola.Christensen@sterlingadministration.com,Kristi.Walker@sterlingadministration.com',
            subject      => 'Error Accounts',
            html_message => '<html><body><br>
                         Check and Verify the attached Error Applications,
			 Go to Data Entry -> Enrollment - Error Fix to fix the accounts
                       <br><br>
                      </body></html>',
            attach       => samfiles('/home/oracle/mailer/' || lv_error_file)
        );

    exception
        when others then
-- Close the file if something goes wrong.
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;
    end error_accounts;

end nightly_email;
/

