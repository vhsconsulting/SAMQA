-- liquibase formatted sql
-- changeset SAMQA:1754373951598 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\mail_utility.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/mail_utility.sql:null:2ef347bca1febabcebe232113e20bdfea8e1d3b7:create

create or replace package body samqa.mail_utility as

    procedure report_emails (
        p_from_email   in varchar2,
        p_to_email     in varchar2,
        p_file_name    in varchar2,
        p_sql          in varchar2,
        p_html_message in varchar2,
        p_report_title in varchar2
    ) is

        l_sql           varchar2(32000);
        l_col_tbl       gen_xl_xml.varchar2_tbl;
        l_col_value_tbl gen_xl_xml.varchar2_tbl;
 --  l_col_style_tbl GEN_XL_XML.VARCHAR2_TBL;  --Added by Swamy for Ticket#7723(Nacha), In the Excel attachment generated, the Number format column should be able to use SUM function.
        x               number := 0;
        ii              number := 0;
        l_dir_name      varchar2(255);
        l_html_message  varchar2(32000);
    begin
-- dbms_output.put_line('In report email');
        gen_xl_xml.create_excel('MAILER_DIR', p_file_name);
        gen_xl_xml.set_header;
-- dbms_output.put_line('In report email'||p_sql);

  --  -- dbms_output.put_line(' writing the headers');
        l_sql := p_sql || ' AND 1 = 2';
        pc_log.log_error('report_emails', l_sql);
-- dbms_output.put_line('In report email'||l_sql);

        gen_xl_xml.print_table(l_sql, l_col_tbl, l_col_value_tbl);
	-- Commented above and Added below by Swamy for Ticket#7723(Nacha), In the Excel attachment generated, the Number format column should be able to use SUM function.
	--gen_xl_xml.print_table (l_sql,l_col_tbl,l_col_style_tbl);

        for i in 1..l_col_tbl.count loop
            x := x + 1;
	    -- gen_xl_xml.write_cell_char( i,i, 'sheet1', l_col_tbl(i) ,'sgs1' );
            gen_xl_xml.write_cell_char(1,
                                       i,
                                       'sheet1',
                                       l_col_tbl(i),
                                       'sgs1');
       ---- dbms_output.put_line(' writing the headers for '||i || 'of '||l_col_tbl.COUNT);

        end loop;

        gen_xl_xml.print_table(p_sql, l_col_tbl, l_col_value_tbl);
    -- dbms_output.put_line(' Value table count '||l_col_value_tbl.COUNT);

        for i in 1..l_col_value_tbl.count loop
        -- x := mod(l_col_tbl.COUNT,i)+2;

            if mod(i, l_col_tbl.count) > 0 then
                x := trunc(i / l_col_tbl.count) + 2;
            else
                x := trunc(i / l_col_tbl.count) + 1;
            end if;

            if mod(i, l_col_tbl.count) = 0 then
                ii := l_col_tbl.count;
            else
                ii := mod(i, l_col_tbl.count);
            end if;
       --  -- dbms_output.put_line('Processing '||i||' Row '||x||'column '||ii);
	    -- gen_xl_xml.write_cell_char( i,i, 'sheet1', l_col_tbl(i) ,'sgs1' );
            gen_xl_xml.write_cell_char(x,
                                       ii,
                                       'sheet1',
                                       l_col_value_tbl(i),
                                       'sgs2');
       /* -- Commented above and Added below by Swamy for Ticket#7723(Nacha), In the Excel attachment generated, the Number format column should be able to use SUM function.
	    IF L_Col_Style_Tbl(ii) = 2 THEN
           gen_xl_xml.write_cell_num( x,ii, 'sheet1' , l_col_value_tbl(i), 'sgs3'  );
        ELSE
           gen_xl_xml.write_cell_char( x,ii, 'sheet1' , l_col_value_tbl(i), 'sgs2'  );
        END IF;
		 */
        end loop;

    -- dbms_output.put_line(' closing the file');
        gen_xl_xml.close_file;
        l_html_message := '<html>
      <head>
          <title>'
                          || p_report_title
                          || '</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <tr align="LEFT" valign="BASELINE">
       <td width="100%" valign="middle">'
                          || p_report_title
                          || '</td>
       </table>
        </body>
        </html>';
-- dbms_output.put_line('Title done');
        if l_col_value_tbl.count > 0 then
-- dbms_output.put_line('In IF');
            if p_report_title like '%SAM USERS (Executive)%' then
                pc_notifications.insert_reports(p_report_title, '/u01/app/oracle/oradata/report/', p_file_name, null, p_html_message)
                ;
            else
                pc_notifications.insert_reports(p_report_title, '/home/oracle/mailer/', p_file_name, null, p_html_message);
            end if;

            mail_utility.email_files(
                from_name    => p_from_email,
                to_names     => p_to_email,
                subject      => p_report_title,
                html_message => p_html_message,
                attach       => samfiles('/u01/app/oracle/oradata/sam19qa/mailer/' || p_file_name)
            );
     -- dbms_output.put_line('Out IF');
        end if;
-- dbms_output.put_line('Out report email');
    end;

    procedure send_file_in_emails (
        p_from_email   in varchar2,
        p_to_email     in varchar2,
        p_file_name    in varchar2,
        p_sql          in varchar2,
        p_html_message in varchar2,
        p_report_title in varchar2
    ) is

        l_sql           varchar2(32000);
        l_col_tbl       gen_xl_xml.varchar2_tbl;
        l_col_value_tbl gen_xl_xml.varchar2_tbl;
        x               number := 0;
        ii              number := 0;
        l_dir_name      varchar2(255);
        l_html_message  varchar2(32000);
    begin
        l_html_message := '<html>
      <head>
          <title>'
                          || p_report_title
                          || '</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <tr align="LEFT" valign="BASELINE">
       <td width="100%" valign="middle">'
                          || p_report_title
                          || '</td>
       </table>
        </body>
        </html>';
        mail_utility.email_files(
            from_name    => p_from_email,
            to_names     => p_to_email,
            subject      => p_report_title,
            html_message => l_html_message,
            attach       => samfiles('/home/oracle/mailer/' || p_file_name)
        );

    end send_file_in_emails;

    procedure send_email (
        from_name varchar2,
        to_names  varchar2,
        subject   varchar2,
        mesg      varchar2
    ) is

        smtp_host      varchar2(256) := '216.109.157.30';
        smtp_port      number := 25;

   -- Change the boundary string, if needed, which demarcates boundaries of
   -- parts in a multi-part email, and should not appear inside the body of
   -- any part of the e-mail:

        boundary       constant varchar2(256) := 'CES.Boundary.DACA587499938898';
        recipients     varchar2(32767);
        directory_path varchar2(256);
        file_path      varchar2(256);
        mime_type      varchar2(256);
        file_name      varchar2(256);
        cr             varchar2(1) := chr(13);
        lf             varchar2(1) := chr(10);
        crlf           varchar2(2) := cr || lf;
        p_mesg         varchar2(32767);
        conn           utl_smtp.connection;
        i              binary_integer;
        my_code        number;
        my_errm        varchar2(32767);
    begin

-- dbms_output.put_line('Send email');
        conn := utl_smtp.open_connection(smtp_host, smtp_port);
        utl_smtp.helo(conn, smtp_host);
        utl_smtp.mail(conn, from_name);
        utl_smtp.rcpt(conn, to_names);
        utl_smtp.open_data(conn);
        utl_smtp.write_data(conn,
                            'Subject: '
                            || nvl(subject, '(no subject)')
                            || chr(13)
                            || chr(10));

        utl_smtp.write_data(conn,
                            '' || chr(13));
        utl_smtp.write_data(conn, mesg);
        utl_smtp.close_data(conn);
        utl_smtp.quit(conn);
    end;

    procedure do_email_files (
        from_name         varchar2,
        to_names          varchar2,
        subject           varchar2,
        message           varchar2,
        clob_message      clob,
        html_message      varchar2,
        clob_html_message clob,
        cc_names          varchar2,
        bcc_names         varchar2,
        file_attach       samfiles,
        clob_attach       samclobs,
        blob_attach       samblobs
    ) is

   -- Change the SMTP host name and port number below to your own values,
   -- if not localhost on port 25:

-- As suggested by Datapipeline changed the host name. Joshi on 01/07/2022
 ---  smtp_host          varchar2(256) := 'sterling3.sterlinghsa.com';
 --  smtp_host          varchar2(256) := '216.109.157.30' ;
        smtp_host      varchar2(256) := 'localhost';
        smtp_port      number := 25;

   -- Change the boundary string, if needed, which demarcates boundaries of
   -- parts in a multi-part email, and should not appear inside the body of
   -- any part of the e-mail:

        boundary       constant varchar2(256) := 'CES.Boundary.DACA587499938898';
        recipients     varchar2(32767);
        directory_path varchar2(256);
        file_path      varchar2(256);
        mime_type      varchar2(256);
        file_name      varchar2(256);
        cr             varchar2(1) := chr(13);
        lf             varchar2(1) := chr(10);
        crlf           varchar2(2) := cr || lf;
        mesg           varchar2(32767);
        conn           utl_smtp.connection;
        i              binary_integer;
        my_code        number;
        my_errm        varchar2(32767);

   -- Function to return the next email address in the list of email addresses,
   -- separated by either a "," or a ";".  From Oracle's demo_mail.  The format
   -- of mailbox may be in one of these:
   --    someone@some-domain
   --    "Someone at some domain" <someone@some-domain>
   --    Someone at some domain <someone@some-domain>

        function get_address (
            addr_list in out varchar2
        ) return varchar2 is

            addr varchar2(256);
            i    pls_integer;

            function lookup_unquoted_char (
                str  in varchar2,
                chrs in varchar2
            ) return pls_integer is
                c            varchar2(5);
                i            pls_integer;
                len          pls_integer;
                inside_quote boolean;
            begin
                inside_quote := false;
                i := 1;
                len := length(str);
                while ( i <= len ) loop
                    c := substr(str, i, 1);
                    if ( inside_quote ) then
                        if ( c = '"' ) then
                            inside_quote := false;
                        elsif ( c = '\' ) then
                            i := i + 1; -- Skip the quote character
                        end if;

                        goto next_char;
                    end if;

                    if ( c = '"' ) then
                        inside_quote := true;
                        goto next_char;
                    end if;
                    if ( instr(chrs, c) >= 1 ) then
                        return i;
                    end if;

                    << next_char >> i := i + 1;
                end loop;

                return 0;
            end;

        begin
            addr_list := ltrim(addr_list);
            i := lookup_unquoted_char(addr_list, ',;');
            if ( i >= 1 ) then
                addr := substr(addr_list, 1, i - 1);
                addr_list := substr(addr_list, i + 1);
            else
                addr := addr_list;
                addr_list := '';
            end if;

            i := lookup_unquoted_char(addr, '<');
            if ( i >= 1 ) then
                addr := substr(addr, i + 1);
                i := instr(addr, '>');
                if ( i >= 1 ) then
                    addr := substr(addr, 1, i - 1);
                end if;

            end if;

            i := lookup_unquoted_char(addr, '@');
            if (
                i = 0
                and smtp_host != 'localhost'
            ) then
                i := instr(smtp_host, '.', -1, 2);
                addr := addr
                        || '@'
                        || substr(smtp_host, i + 1);
            end if;

            addr := '<'
                    || addr
                    || '>';
            return addr;
        end;

   -- Procedure to split a file pathname into its directory path and file name
   -- components.

        procedure split_path_name (
            file_path      in varchar2,
            directory_path out varchar2,
            file_name      out varchar2
        ) is
            pos number;
        begin

      -- Separate the filename from the directory name

            pos := instr(file_path, '/', -1);
            if pos = 0 then
                pos := instr(file_path, '\', -1);
            end if;

            if pos = 0 then
                directory_path := null;
            else
                directory_path := substr(file_path, 1, pos - 1);
            end if;

            file_name := substr(file_path, pos + 1);
      -- dbms_output.put_line('file_name '||file_name);

        end;

   -- Procedure to append the contents of a file, character LOB, or binary LOB
   -- to the e-mail

        procedure append_file (
            directory_path in varchar2 default null,
            file_name      in varchar2 default null,
            mime_type      in varchar2,
            conn           in out utl_smtp.connection,
            clob_attach    in clob default null,
            blob_attach    in blob default null
        ) is

            generated_name varchar2(30) := 'CESDIR' || to_char(sysdate, 'HH24MISS');
            directory_name varchar2(256) := null;
            file_handle    utl_file.file_type;
            bfile_handle   bfile;
            lob_len        number(38) := 0;
            lob_pos        number(38) := 1;
            read_bytes     number(38);
            lf_at          number(38);
            line           varchar2(32767);
            data           raw(32767);
            my_code        number;
            my_errm        varchar2(32767);
        begin
            begin

         -- If this is a file to attach, grant access to the directory, unless
         -- already defined, and open the file (as a bfile for a binary file,
         -- otherwise as a text file)
               -- dbms_output.put_line('directory_path '||directory_path);
               -- dbms_output.put_line('mime_type '||mime_type);
               -- dbms_output.put_line('file_name '||file_name);

                if directory_path is not null then
                    begin
                        line := directory_path;
                        select
                            dd.directory_name
                        into directory_name
                        from
                            all_directories dd
                        where
                                dd.directory_path = line
                            and rownum = 1;
                              -- dbms_output.put_line('directory_name '||directory_name);

                    exception
                        when no_data_found then
                            directory_name := generated_name;
                    end;

                    if directory_name = generated_name then
                        execute immediate 'create or replace directory '
                                          || directory_name
                                          || ' as '''
                                          || directory_path
                                          || '''';
                        execute immediate 'grant read on directory '
                                          || directory_name
                                          || ' to public';
                    end if;

                    if substr(mime_type, 1, 4) = 'text' then
                        file_handle := utl_file.fopen(directory_name, file_name, 'r');
                    else
                        bfile_handle := bfilename(directory_name, file_name);
                        lob_len := dbms_lob.getlength(bfile_handle);
                        dbms_lob.open(bfile_handle, dbms_lob.lob_readonly);
                    end if;

         -- If this is a CLOB or BLOB to attach, just get the length of the LOB

                elsif clob_attach is not null then
                    lob_len := dbms_lob.getlength(clob_attach);
                elsif blob_attach is not null then
                    lob_len := dbms_lob.getlength(blob_attach);
                end if;

         -- Append the file's or LOB's contents to the end of the message

                loop

            -- If this is a text file, append the next line to the message,
            -- along with a carriage return / line feed

                    if
                        directory_path is not null
                        and substr(mime_type, 1, 4) = 'text'
                    then
                        utl_file.get_line(file_handle, line);
               -- dbms_output.put_line('line '||line);

                        utl_smtp.write_data(conn, line || crlf);
                    else

               -- If it is a character LOB, find the next line feed, get the
               -- the next line of text, and write it out, followed by a
               -- carriage return / line feed

                        if clob_attach is not null then
                            lf_at := dbms_lob.instr(clob_attach, lf, lob_pos);
                            if lf_at = 0 then
                                lf_at := lob_len + 1;
                            end if;
                            read_bytes := lf_at - lob_pos;
                            if
                                read_bytes > 0
                                and dbms_lob.substr(clob_attach, 1, lf_at - 1) = cr
                            then
                                read_bytes := read_bytes - 1;
                            end if;

                            if read_bytes > 0 then
                                dbms_lob.read(clob_attach, read_bytes, lob_pos, line);
                                utl_smtp.write_data(conn, line);
                            end if;

                            utl_smtp.write_data(conn, crlf);
                            lob_pos := lf_at + 1;

               -- If it is a binary file or binary LOB, process it 57 bytes
               -- at a time, reading them in with a LOB read, encoding them
               -- in BASE64, and writing out the encoded binary string as raw
               -- data

                        else
                            if lob_pos + 57 - 1 > lob_len then
                                read_bytes := lob_len - lob_pos + 1;
                            else
                                read_bytes := 57;
                            end if;

                            if blob_attach is not null then
                                dbms_lob.read(blob_attach, read_bytes, lob_pos, data);
                            else
                                dbms_lob.read(bfile_handle, read_bytes, lob_pos, data);
                            end if;

                            utl_smtp.write_raw_data(conn,
                                                    utl_encode.base64_encode(data));
                            lob_pos := lob_pos + read_bytes;
                        end if;

               -- Exit if we've processed all of the LOB or binary file
                     -- dbms_output.put_line('lob_len '||lob_len);
                     -- dbms_output.put_line('lob_pos '||lob_pos);

                        if lob_pos > lob_len then
                            exit;
                        end if;
                    end if;
                end loop;

      -- Output any errors, except at end when no more data is found

            exception
                when no_data_found then
                    null;
                           -- dbms_output.put_line('line '||line);

                when others then
                    my_code := sqlcode;
                    my_errm := sqlerrm;
                    raise_application_error(-20000, 'Failed to send mail: Error code '
                                                    || my_code
                                                    || ': '
                                                    || my_errm);
            end;

      -- Close the file (binary or text) and drop the generated directory,
      -- if any

            if directory_path is not null then
                if substr(mime_type, 1, 4) != 'text' then
                    dbms_lob.close(bfile_handle);
                else
                    utl_file.fclose(file_handle);
                end if;

            end if;

            if directory_name = generated_name then
                execute immediate 'drop directory ' || directory_name;
            end if;
        end;

    begin

   -- Open the SMTP connection and set the From and To e-mail addresses

        conn := utl_smtp.open_connection(smtp_host, smtp_port);
        utl_smtp.helo(conn, smtp_host);
        recipients := from_name;
        utl_smtp.mail(conn,
                      get_address(recipients));
        recipients := to_names;
        while recipients is not null loop
   --   -- dbms_output.put_line(' recipients '||recipients);
            utl_smtp.rcpt(conn,
                          get_address(recipients));
        end loop;

        if
            cc_names is not null
            and length(cc_names) > 0
        then
            recipients := cc_names;
            while recipients is not null loop
      --   -- dbms_output.put_line(' recipients '||recipients);

                utl_smtp.rcpt(conn,
                              get_address(recipients));
            end loop;

        end if;

        if
            bcc_names is not null
            and length(bcc_names) > 0
        then
            recipients := bcc_names;
            while recipients is not null loop
                utl_smtp.rcpt(conn,
                              get_address(recipients));
            end loop;

        end if;

        utl_smtp.open_data(conn);

   -- Build the start of the mail message

        mesg := 'Date: '
                || to_char(sysdate, 'dd Mon yy hh24:mi:ss')
                || crlf
                || 'From: '
                || from_name
                || crlf
                || 'Subject: '
                || subject
                || crlf
                || 'To: '
                || to_names
                || crlf;

        if
            cc_names is not null
            and length(cc_names) > 0
        then
            mesg := mesg
                    || 'Cc: '
                    || cc_names
                    || crlf;
        end if;

        if
            bcc_names is not null
            and length(bcc_names) > 0
        then
            mesg := mesg
                    || 'Bcc: '
                    || bcc_names
                    || crlf;
        end if;

        mesg := mesg
                || 'Mime-Version: 1.0'
                || crlf
                || 'Content-Type: multipart/mixed; boundary="'
                || boundary
                || '"'
                || crlf
                || crlf
                || 'This is a Mime message, which your current mail reader may not'
                || crlf
                || 'understand. Parts of the message will appear as text. If the remainder'
                || crlf
                || 'appears as random characters in the message body, instead of as'
                || crlf
                || 'attachments, then you''ll have to extract these parts and decode them'
                || crlf
                || 'manually.'
                || crlf
                || crlf;

        utl_smtp.write_data(conn, mesg);
    --        -- dbms_output.put_line(' recipients '||mesg);

   -- Write the text message or message file or message CLOB, if any

        if (
            message is not null
            and length(message) > 0
        )
        or clob_message is not null then
            mesg := '--'
                    || boundary
                    || crlf
                    || 'Content-Type: text/plain; name="message.txt"; charset=US-ASCII'
                    || crlf
                    ||
       --  'Content-Disposition: inline; filename="message.txt"' || crlf ||
                     'Content-Transfer-Encoding: 7bit'
                    || crlf
                    || crlf;

            utl_smtp.write_data(conn, mesg);
            if instr(message, '/') = 1
            or instr(message, ':\') = 2
            or instr(message, '\\') = 1 then
                split_path_name(message, directory_path, file_name);
         -- dbms_output.put_line('directory_path '||directory_path);

                append_file(directory_path, file_name, 'text', conn);
                utl_smtp.write_data(conn, crlf);
            elsif
                message is not null
                and length(message) > 0
            then
                utl_smtp.write_data(conn, message);
                if length(message) = 1
                or substr(message,
                          length(message) - 1) != crlf then
                    utl_smtp.write_data(conn, crlf);
                end if;

            elsif clob_message is not null then
                append_file(null, 'message.txt', 'text/plain', conn, clob_message);
            end if;

        end if;

   -- Write the HTML message or message file or message CLOB, if any

        if (
            html_message is not null
            and length(html_message) > 0
        )
        or clob_html_message is not null then
            mesg := '--'
                    || boundary
                    || crlf
                    || 'Content-Type: text/html; name="message.html"; charset=US-ASCII'
                    ||
       --  crlf ||
      --   'Content-Disposition: inline; filename="message.html"' || crlf ||
                     'Content-Transfer-Encoding: 7bit'
                    || crlf
                    || crlf;

            utl_smtp.write_data(conn, mesg);
            if instr(html_message, '/') = 1
            or instr(html_message, ':\') = 2
            or instr(html_message, '\\') = 1 then
                split_path_name(html_message, directory_path, file_name);
                append_file(directory_path, file_name, 'text', conn);
                utl_smtp.write_data(conn, crlf);
            elsif
                html_message is not null
                and length(html_message) > 0
            then
                utl_smtp.write_data(conn, html_message);
                if length(html_message) = 1
                or substr(html_message,
                          length(html_message) - 1) != crlf then
                    utl_smtp.write_data(conn, crlf);
                end if;

            elsif clob_html_message is not null then
                append_file(null, 'message.html', 'text/html', conn, clob_html_message);
            end if;

        end if;

   -- Attach the files, if any

        if file_attach is not null then
            for i in 1..file_attach.count loop
                file_path := null;
                mime_type := null;

         -- If this is a file path parameter, get the file path and check the
         -- next parameter to see if it is a file type parameter (else default
         -- to text/plain).

                if file_attach(i) is null
                   or length(file_attach(i)) = 0 then
                    exit;
                end if;

                if instr(
                    file_attach(i),
                    '/'
                ) = 1
                or instr(
                    file_attach(i),
                    ':\'
                ) = 2
                or instr(
                    file_attach(i),
                    '\\'
                ) = 1 then
                    file_path := file_attach(i);
                    if i = file_attach.count then
                        mime_type := 'text/plain';
                    else
                        if
                            instr(
                                file_attach(i + 1),
                                '/'
                            ) > 1
                            and instr(
                                file_attach(i + 1),
                                '/',
                                1,
                                2
                            ) = 0
                        then
                            mime_type := file_attach(i + 1);
                        else
                            mime_type := 'text/plain';
                        end if;
                    end if;

                end if;

         -- If this is a file path parameter ...

                if file_path is not null then
                    split_path_name(file_path, directory_path, file_name);

            -- Generate the MIME boundary line according to the file (mime) type
            -- specified.
            -- dbms_output.put_line('file_name'||file_name);
                    mesg := crlf
                            || '--'
                            || boundary
                            || crlf;
                    if substr(mime_type, 1, 4) != 'text' then
                        mesg := mesg
                                || 'Content-Type: '
                                || mime_type
                                || '; name="'
                                || file_name
                                || '"'
                                || crlf
                                || 'Content-Disposition: attachment; filename="'
                                || file_name
                                || '"'
                                || crlf
                                || 'Content-Transfer-Encoding: base64'
                                || crlf
                                || crlf;
                    else
                        mesg := mesg
                                || 'Content-Type: application/octet-stream; name="'
                                || file_name
                                || '"'
                                || crlf
                                || 'Content-Disposition: attachment; filename="'
                                || file_name
                                || '"'
                                || crlf
                                || 'Content-Transfer-Encoding: 7bit'
                                || crlf
                                || crlf;
                    end if;
                        -- dbms_output.put_line('mesg'||mesg);

                    utl_smtp.write_data(conn, mesg);

            -- Append the file contents to the end of the message
         -- dbms_output.put_line('directory_path '||directory_path);
         -- dbms_output.put_line('file_name '||file_name);
         -- dbms_output.put_line('mime_type '||mime_type);

                    append_file(directory_path, file_name, mime_type, conn);
                end if;

            end loop;
        end if;

   -- Attach the character LOB's, if any

        if clob_attach is not null then
            for i in 1..clob_attach.count loop

         -- Get the name and mime type, if given, else use default values

                if clob_attach(i).vclob is null then
                    exit;
                end if;
                file_name := clob_attach(i).filename;
                if file_name is null then
                    file_name := 'clob'
                                 || i
                                 || '.txt';
                end if;

                mime_type := clob_attach(i).mimetype;
                if mime_type is null then
                    mime_type := 'text/plain';
                end if;

         -- Generate the MIME boundary line for this character file attachment

                mesg := crlf
                        || '--'
                        || boundary
                        || crlf;
                mesg := mesg
                        || 'Content-Type: application/octet-stream; name="'
                        || file_name
                        || '"'
                        || crlf
                        || 'Content-Disposition: attachment; filename="'
                        || file_name
                        || '"'
                        || crlf
                        || 'Content-Transfer-Encoding: 7bit'
                        || crlf
                        || crlf;

                utl_smtp.write_data(conn, mesg);

         -- Append the CLOB contents to the end of the message

                append_file(null,
                            file_name,
                            mime_type,
                            conn,
                            clob_attach => clob_attach(i).vclob);

            end loop;
        end if;

   -- Attach the binary LOB's, if any

        if blob_attach is not null then
            for i in 1..blob_attach.count loop

         -- Get the name and mime type, if given, else use default values

                if blob_attach(i).vblob is null then
                    exit;
                end if;
                file_name := blob_attach(i).filename;
                if file_name is null
                   or length(file_name) = 0 then
                    file_name := 'blob' || i;
                end if;

                mime_type := blob_attach(i).mimetype;
                if mime_type is null then
                    mime_type := 'text/plain';  -- but, this is a strange default!
                end if;

         -- Generate the MIME boundary line for this BASE64 binary attachment

                mesg := crlf
                        || '--'
                        || boundary
                        || crlf;
                mesg := mesg
                        || 'Content-Type: '
                        || mime_type
                        || '; name="'
                        || file_name
                        || '"'
                        || crlf
                        || 'Content-Disposition: attachment; filename="'
                        || file_name
                        || '"'
                        || crlf
                        || 'Content-Transfer-Encoding: base64'
                        || crlf
                        || crlf;

                utl_smtp.write_data(conn, mesg);

         -- Append the BLOB contents to the end of the message
                dbms_output.put_line('before mesg ');
                append_file(null,
                            file_name,
                            mime_type,
                            conn,
                            blob_attach => blob_attach(i).vblob);

                dbms_output.put_line('after mesg ');
            end loop;
        end if;

   -- Append the final boundary line
 --  -- dbms_output.put_line(' mesg '||mesg);

        mesg := crlf
                || '--'
                || boundary
                || '--'
                || crlf;
        utl_smtp.write_data(conn, mesg);

   -- Close the SMTP connection

        utl_smtp.close_data(conn);
        utl_smtp.quit(conn);
    exception
        when utl_smtp.transient_error or utl_smtp.permanent_error then
            my_code := sqlcode;
            my_errm := sqlerrm;
            begin
                utl_smtp.quit(conn);
            exception
                when utl_smtp.transient_error or utl_smtp.permanent_error then
                    null;
            end;

            raise_application_error(-20000, 'Failed to send mail - SMTP server down or unavailable: Error code '
                                            || my_code
                                            || ': '
                                            || my_errm);
        when others then
            my_code := sqlcode;
            my_errm := sqlerrm;
            raise_application_error(-20000, 'Failed to send mail: Error code '
                                            || my_code
                                            || ': '
                                            || my_errm);
    end;

-- Define the various overloaded definitions (interfaces) to email_files

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      varchar2 default '',
        html_message varchar2 default '',
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samfiles,
        clob_attach  samclobs default null,
        blob_attach  samblobs default null
    ) is
    begin
-- dbms_output.put_line('email files');
        do_email_files(from_name, to_names, subject, message, null,
                       html_message, null, cc_names, bcc_names, attach,
                       clob_attach, blob_attach);
    end;

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      clob,
        html_message varchar2 default '',
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samfiles,
        clob_attach  samclobs default null,
        blob_attach  samblobs default null
    ) is
    begin
        do_email_files(from_name, to_names, subject, null, message,
                       html_message, null, cc_names, bcc_names, attach,
                       clob_attach, blob_attach);
    end;

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      varchar2 default '',
        html_message clob,
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samfiles,
        clob_attach  samclobs default null,
        blob_attach  samblobs default null
    ) is
    begin
        do_email_files(from_name, to_names, subject, message, null,
                       null, html_message, cc_names, bcc_names, attach,
                       clob_attach, blob_attach);
    end;

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      clob,
        html_message clob,
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samfiles,
        clob_attach  samclobs default null,
        blob_attach  samblobs default null
    ) is
    begin
        do_email_files(from_name, to_names, subject, null, message,
                       null, html_message, cc_names, bcc_names, attach,
                       clob_attach, blob_attach);
    end;

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      varchar2 default '',
        html_message varchar2 default '',
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samclobs
    ) is
    begin
        do_email_files(from_name,
                       to_names,
                       subject,
                       message,
                       null,
                       html_message,
                       null,
                       cc_names,
                       bcc_names,
                       samfiles(null),
                       attach,
                       null);
    end;

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      clob,
        html_message varchar2 default '',
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samclobs
    ) is
    begin
        do_email_files(from_name,
                       to_names,
                       subject,
                       null,
                       message,
                       html_message,
                       null,
                       cc_names,
                       bcc_names,
                       samfiles(null),
                       attach,
                       null);
    end;

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      varchar2 default '',
        html_message clob,
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samclobs
    ) is
    begin
        do_email_files(from_name,
                       to_names,
                       subject,
                       message,
                       null,
                       null,
                       html_message,
                       cc_names,
                       bcc_names,
                       samfiles(null),
                       attach,
                       null);
    end;

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      clob,
        html_message clob,
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samclobs
    ) is
    begin
        do_email_files(from_name,
                       to_names,
                       subject,
                       null,
                       message,
                       null,
                       html_message,
                       cc_names,
                       bcc_names,
                       samfiles(null),
                       attach,
                       null);
    end;

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      varchar2 default '',
        html_message varchar2 default '',
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samblobs
    ) is
    begin
        do_email_files(from_name,
                       to_names,
                       subject,
                       message,
                       null,
                       html_message,
                       null,
                       cc_names,
                       bcc_names,
                       samfiles(null),
                       null,
                       attach);
    end;

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      clob,
        html_message varchar2 default '',
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samblobs
    ) is
    begin
        do_email_files(from_name,
                       to_names,
                       subject,
                       null,
                       message,
                       html_message,
                       null,
                       cc_names,
                       bcc_names,
                       samfiles(null),
                       null,
                       attach);
    end;

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      varchar2 default '',
        html_message clob,
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samblobs
    ) is
    begin
        do_email_files(from_name,
                       to_names,
                       subject,
                       message,
                       null,
                       null,
                       html_message,
                       cc_names,
                       bcc_names,
                       samfiles(null),
                       null,
                       attach);
    end;

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      clob,
        html_message clob,
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samblobs
    ) is
    begin
        do_email_files(from_name,
                       to_names,
                       subject,
                       null,
                       message,
                       null,
                       html_message,
                       cc_names,
                       bcc_names,
                       samfiles(null),
                       null,
                       attach);
    end;

-- This overloaded version supports legacy code using the "filename/filetype"
-- parameter pairs instead of the current "attach" parameters.  It is also used
-- when no file attachments are specified (since there is not a default value
-- for the "attach" parameters in the interfaces above).

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      varchar2 default '',
        html_message varchar2 default '',
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        filename1    varchar2 default null,
        filetype1    varchar2 default 'text/plain',
        filename2    varchar2 default null,
        filetype2    varchar2 default 'text/plain',
        filename3    varchar2 default null,
        filetype3    varchar2 default 'text/plain'
    ) is
    begin
        do_email_files(from_name,
                       to_names,
                       subject,
                       message,
                       null,
                       html_message,
                       null,
                       cc_names,
                       bcc_names,
                       samfiles(filename1, filetype1, filename2, filetype2, filename3,
                                filetype3),
                       null,
                       null);
    end;

    procedure html_email (
        p_to      in varchar2,
        p_from    in varchar2,
        p_subject in varchar2,
        p_text    in varchar2 default null,
        p_html    in varchar2 default null
    ) is
   -- l_boundary      varchar2(255) default 'a1b2c3d4e3f2g1';
        l_connection utl_smtp.connection;
        l_body_html  clob := empty_clob;  --This LOB will be the email message
        l_offset     number;
        l_ammount    number;
        l_temp       varchar2(32767) default null;

   --smtp_host          varchar2(256) := '216.109.157.30'; --commented and added below by Joshi for 12707&12708
        smtp_host    varchar2(256) := 'localhost';
        l_boundary   constant varchar2(256) := 'CES.Boundary.DACA587499938898'; -- added below by Joshi for 12707&12708
        smtp_port    number := 25;
    begin
        l_connection := utl_smtp.open_connection(smtp_host, smtp_port);
        utl_smtp.helo(l_connection, smtp_host);
        utl_smtp.mail(l_connection, p_from);
        utl_smtp.rcpt(l_connection, p_to);
        l_temp := l_temp
                  || 'MIME-Version: 1.0'
                  || chr(13)
                  || chr(10);

        l_temp := l_temp
                  || 'To: '
                  || p_to
                  || chr(13)
                  || chr(10);

        l_temp := l_temp
                  || 'From: '
                  || p_from
                  || chr(13)
                  || chr(10);

        l_temp := l_temp
                  || 'Subject: '
                  || p_subject
                  || chr(13)
                  || chr(10);

        l_temp := l_temp
                  || 'Reply-To: '
                  || p_from
                  || chr(13)
                  || chr(10);

        l_temp := l_temp
                  || 'Content-Type: multipart/alternative; boundary='
                  || chr(34)
                  || l_boundary
                  || chr(34)
                  || chr(13)
                  || chr(10);

    ----------------------------------------------------
    -- Write the headers
        dbms_lob.createtemporary(l_body_html, false, 10);
        dbms_lob.write(l_body_html,
                       length(l_temp),
                       1,
                       l_temp);

    ----------------------------------------------------
    -- Write the text boundary
        l_offset := dbms_lob.getlength(l_body_html) + 1;
        l_temp := '--'
                  || l_boundary
                  || chr(13)
                  || chr(10);

        l_temp := l_temp
                  || 'content-type: text/plain; charset=us-ascii'
                  || chr(13)
                  || chr(10)
                  || chr(13)
                  || chr(10);

        dbms_lob.write(l_body_html,
                       length(l_temp),
                       l_offset,
                       l_temp);

    ----------------------------------------------------
    -- Write the plain text portion of the email
        l_offset := dbms_lob.getlength(l_body_html) + 1;
        dbms_lob.write(l_body_html,
                       length(p_text),
                       l_offset,
                       p_text);

    ----------------------------------------------------
    -- Write the HTML boundary
        l_temp := chr(13)
                  || chr(10)
                  || chr(13)
                  || chr(10)
                  || '--'
                  || l_boundary
                  || chr(13)
                  || chr(10);

        l_temp := l_temp
                  || 'content-type: text/html;'
                  || chr(13)
                  || chr(10)
                  || chr(13)
                  || chr(10);

        l_offset := dbms_lob.getlength(l_body_html) + 1;
        dbms_lob.write(l_body_html,
                       length(l_temp),
                       l_offset,
                       l_temp);

    ----------------------------------------------------
    -- Write the HTML portion of the message
        l_offset := dbms_lob.getlength(l_body_html) + 1;
        dbms_lob.write(l_body_html,
                       length(p_html),
                       l_offset,
                       p_html);

    ----------------------------------------------------
    -- Write the final html boundary
        l_temp := chr(13)
                  || chr(10)
                  || '--'
                  || l_boundary
                  || '--'
                  || chr(13);

        l_offset := dbms_lob.getlength(l_body_html) + 1;
        dbms_lob.write(l_body_html,
                       length(l_temp),
                       l_offset,
                       l_temp);

    ----------------------------------------------------
    -- Send the email in 1900 byte chunks to UTL_SMTP
        l_offset := 1;
        l_ammount := 1900;
        utl_smtp.open_data(l_connection);
        while l_offset < dbms_lob.getlength(l_body_html) loop
            utl_smtp.write_data(l_connection,
                                dbms_lob.substr(l_body_html, l_ammount, l_offset));
            l_offset := l_offset + l_ammount;
            l_ammount := least(1900,
                               dbms_lob.getlength(l_body_html) - l_ammount);
        end loop;

        utl_smtp.close_data(l_connection);
        utl_smtp.quit(l_connection);
        dbms_lob.freetemporary(l_body_html);
    end html_email;

    procedure send_file (
        p_from_email    in varchar2,
        p_to_email      in varchar2,
        p_file_name     in varchar2,
        p_directory     in varchar2,
        p_dir_path      in varchar2,
        p_html_message  in varchar2,
        p_report_title  in varchar2,
        p_col_tbl       in gen_xl_xml.varchar2_tbl,
        p_col_value_tbl in gen_xl_xml.varchar2_tbl
    ) is

        l_sql           varchar2(32000);
        l_col_tbl       gen_xl_xml.varchar2_tbl;
        l_col_value_tbl gen_xl_xml.varchar2_tbl;
        x               number := 0;
        ii              number := 0;
        l_dir_name      varchar2(255);
        l_html_message  varchar2(32000);
    begin
        gen_xl_xml.create_excel(p_directory, p_file_name);
        gen_xl_xml.set_header;
    -- dbms_output.put_line(p_col_tbl.COUNT);
        for i in 1..p_col_tbl.count loop
            x := x + 1;
            gen_xl_xml.write_cell_char(1,
                                       i,
                                       'sheet1',
                                       p_col_tbl(i),
                                       'sgs1');
        end loop;
    -- dbms_output.put_line(p_col_value_tbl.COUNT);

        for i in 1..p_col_value_tbl.count loop
        -- x := mod(l_col_tbl.COUNT,i)+2;

            if mod(i, p_col_tbl.count) > 0 then
                x := trunc(i / p_col_tbl.count) + 2;
            else
                x := trunc(i / p_col_tbl.count) + 1;
            end if;
             -- dbms_output.put_line(x);

            if mod(i, p_col_tbl.count) = 0 then
                ii := p_col_tbl.count;
            else
                ii := mod(i, p_col_tbl.count);
            end if;
                      -- dbms_output.put_line(ii);

            gen_xl_xml.write_cell_char(x,
                                       ii,
                                       'sheet1',
                                       p_col_value_tbl(i),
                                       'sgs2');
        end loop;

    -- dbms_output.put_line(' closing the file');
        gen_xl_xml.close_file;
        l_html_message := '<html>
      <head>
          <title>'
                          || p_report_title
                          || '</title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <tr align="LEFT" valign="BASELINE">
       <td width="100%" valign="middle">'
                          || p_report_title
                          || '</td>
       </table>
        </body>
        </html>';
        if p_col_value_tbl.count > 0 then
            mail_utility.email_files(
                from_name    => p_from_email,
                to_names     => p_to_email,
                subject      => p_report_title,
                html_message => p_html_message,
                attach       => samfiles(p_dir_path || p_file_name)
            );
        end if;

    end;

    procedure email_reports (
        p_file_name    in varchar2,
        p_report_title in varchar2,
        p_email        in varchar2,
        p_dir          in varchar2
    ) is
        l_html_message varchar2(3000);
    begin
        l_html_message := '<html>
	      <head>
		  <title>'
                          || p_report_title
                          || '</title>
	      </head>
	      <body bgcolor="#FFFFFF" link="#000080">
	       <table cellspacing="0" cellpadding="0" width="100%">
	       <tr align="LEFT" valign="BASELINE">
	       <td width="100%" valign="middle">'
                          || p_report_title
                          || '</td>
	       </table>
		</body>
		</html>';
        mail_utility.email_files(
            from_name    => 'oracle@sterlingadministration.com',
            to_names     => p_email,
            subject      => p_report_title,
            html_message => l_html_message,
            attach       => samfiles(p_dir || p_file_name)
        );

    end email_reports;

end mail_utility;
/

