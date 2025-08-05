-- liquibase formatted sql
-- changeset SAMQA:1754373950529 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\ftp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/ftp.sql:null:fecbe5632d4e7e53862ab6a94cc134c2c2857e7b:create

create or replace package body samqa.ftp as
-- --------------------------------------------------------------------------
-- Name         : http://www.oracle-base.com/dba/miscellaneous/ftp.pkb
-- Author       : DR Timothy S Hall
-- Description  : Basic FTP API. For usage notes see:
--                  http://www.oracle-base.com/articles/misc/FTPFromPLSQL.php
-- Requirements : http://www.oracle-base.com/dba/miscellaneous/ftp.pks
-- Ammedments   :
--   When         Who       What
--   ===========  ========  =================================================
--   14-AUG-2003  Tim Hall  Initial Creation
--   10-MAR-2004  Tim Hall  Add convert_crlf procedure.
--                          Incorporate CRLF conversion functionality into
--                          put_local_ascii_data and put_remote_ascii_data
--                          functions.
--                          Make get_passive function visible.
--                          Added get_direct and put_direct procedures.
--   23-DEC-2004  Tim Hall  The get_reply procedure was altered to deal with
--                          banners starting with 4 white spaces. This fix is
--                          a small variation on the resolution provided by
--                          Gary Mason who spotted the bug.
--   10-NOV-2005  Tim Hall  Addition of get_reply after doing a transfer to
--                          pickup the 226 Transfer complete message. This
--                          allows gets and puts with a single connection.
--                          Issue spotted by Trevor Woolnough.
--   03-OCT-2006  Tim Hall  Add list, rename, delete, mkdir, rmdir procedures.
--   12-JAN-2007  Tim Hall  A final call to get_reply was added to the get_remote%
--                          procedures to allow multiple transfers per connection.
--   15-Jan-2008  Tim Hall  login: Include timeout parameter (suggested by Dmitry Bogomolov).
--   21-Jan-2008  Tim Hall  put_%: "l_pos < l_clob_len" to "l_pos <= l_clob_len" to prevent
--                          potential loss of one character for single-byte files or files
--                          sized 1 byte bigger than a number divisible by the buffer size
--                          (spotted by Michael Surikov).
--   23-Jan-2008  Tim Hall  send_command: Possible solution for ORA-29260 errors included,
--                          but commented out (suggested by Kevin Phillips).
--   12-Feb-2008  Tim Hall  put_local_binary_data and put_direct: Open file with "wb" for
--                          binary writes (spotted by Dwayne Hoban).
--   03-Mar-2008  Tim Hall  list: get_reply call and close of passive connection added
--                          (suggested by Julian, Bavaria).
--   12-Jun-2008  Tim Hall  A final call to get_reply was added to the put_remote%
--                          procedures, but commented out. If uncommented, it may cause the
--                          operation to hang, but it has been reported (morgul) to allow
--                          multiple transfers per connection.
--                          get_reply: Moved to pakage specification.
--   24-Jun-2008  Tim Hall  get_remote% and put_remote%: Exception handler added to close the passive
--                          connection and reraise the error (suggested by Mark Reichman).
--   22-Apr-2009  Tim Hall  get_remote_ascii_data: Remove unnecessary logout (suggested by John Duncan).
--                          get_reply and list: Handle 400 messages as well as 500 messages (suggested by John Duncan).
--                          logout: Added a call to UTL_TCP.close_connection, so not necessary to close
--                          any connections manually (suggested by Victor Munoz).
--                          get_local_*_data: Check for zero length files to prevent exception (suggested by Daniel)
--                          nlst: Added to return list of file names only (suggested by Julian and John Duncan)
-- --------------------------------------------------------------------------

    g_reply        t_string_table := t_string_table();
    g_binary       boolean := true;
    g_debug        boolean := true;
    g_convert_crlf boolean := true;
    procedure debug (
        p_text in varchar2
    );

-- --------------------------------------------------------------------------
    function login (
        p_host    in varchar2,
        p_port    in varchar2,
        p_user    in varchar2,
        p_pass    in varchar2,
        p_timeout in number := null
    ) return utl_tcp.connection is
-- --------------------------------------------------------------------------
        l_conn utl_tcp.connection;
    begin
        g_reply.delete;
        l_conn := utl_tcp.open_connection(p_host, p_port,
                                          tx_timeout => p_timeout);
        get_reply(l_conn);
        send_command(l_conn, 'USER ' || p_user);
        send_command(l_conn, 'PASS ' || p_pass);
        return l_conn;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    function get_passive (
        p_conn in out nocopy utl_tcp.connection
    ) return utl_tcp.connection is
-- --------------------------------------------------------------------------
        l_conn  utl_tcp.connection;
        l_reply varchar2(32767);
        l_host  varchar(100);
        l_port1 number(10);
        l_port2 number(10);
    begin
        send_command(p_conn, 'PASV');
        l_reply := g_reply(g_reply.last);
        l_reply := replace(
            substr(l_reply,
                   instr(l_reply, '(') + 1,
                   (instr(l_reply, ')')) -(instr(l_reply, '(')) - 1),
            ',',
            '.'
        );

        l_host := substr(l_reply,
                         1,
                         instr(l_reply, '.', 1, 4) - 1);

        l_port1 := to_number ( substr(l_reply,
                                      instr(l_reply, '.', 1, 4) + 1,
                                      (instr(l_reply, '.', 1, 5) - 1) -(instr(l_reply, '.', 1, 4))) );

        l_port2 := to_number ( substr(l_reply,
                                      instr(l_reply, '.', 1, 5) + 1) );

        l_conn := utl_tcp.open_connection(l_host, 256 * l_port1 + l_port2);
        return l_conn;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure logout (
        p_conn  in out nocopy utl_tcp.connection,
        p_reply in boolean := true
    ) as
-- --------------------------------------------------------------------------
    begin
        send_command(p_conn, 'QUIT', p_reply);
        utl_tcp.close_connection(p_conn);
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure send_command (
        p_conn    in out nocopy utl_tcp.connection,
        p_command in varchar2,
        p_reply   in boolean := true
    ) is
-- --------------------------------------------------------------------------
        l_result pls_integer;
    begin
        l_result := utl_tcp.write_line(p_conn, p_command);
  -- If you get ORA-29260 after the PASV call, replace the above line with the following line.
  -- l_result := UTL_TCP.write_text(p_conn, p_command || utl_tcp.crlf, length(p_command || utl_tcp.crlf));

        if p_reply then
            get_reply(p_conn);
        end if;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure get_reply (
        p_conn in out nocopy utl_tcp.connection
    ) is
-- --------------------------------------------------------------------------
        l_reply_code varchar2(3) := null;
    begin
        loop
            g_reply.extend;
            g_reply(g_reply.last) := utl_tcp.get_line(p_conn, true);
            debug(g_reply(g_reply.last));
            if l_reply_code is null then
                l_reply_code := substr(
                    g_reply(g_reply.last),
                    1,
                    3
                );
            end if;

            if substr(l_reply_code, 1, 1) in ( '4', '5' ) then
                raise_application_error(-20000,
                                        g_reply(g_reply.last));
            elsif (
                substr(
                    g_reply(g_reply.last),
                    1,
                    3
                ) = l_reply_code
                and substr(
                    g_reply(g_reply.last),
                    4,
                    1
                ) = ' '
            ) then
                exit;
            end if;

        end loop;
    exception
        when utl_tcp.end_of_input then
            null;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    function get_local_ascii_data (
        p_dir  in varchar2,
        p_file in varchar2
    ) return clob is
-- --------------------------------------------------------------------------
        l_bfile bfile;
        l_data  clob;
    begin
        dbms_lob.createtemporary(
            lob_loc => l_data,
            cache   => true,
            dur     => dbms_lob.call
        );

        l_bfile := bfilename(p_dir, p_file);
        dbms_lob.fileopen(l_bfile, dbms_lob.file_readonly);
        if dbms_lob.getlength(l_bfile) > 0 then
            dbms_lob.loadfromfile(l_data,
                                  l_bfile,
                                  dbms_lob.getlength(l_bfile));
        end if;

        dbms_lob.fileclose(l_bfile);
        return l_data;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    function get_local_binary_data (
        p_dir  in varchar2,
        p_file in varchar2
    ) return blob is
-- --------------------------------------------------------------------------
        l_bfile bfile;
        l_data  blob;
    begin
        dbms_lob.createtemporary(
            lob_loc => l_data,
            cache   => true,
            dur     => dbms_lob.call
        );

        l_bfile := bfilename(p_dir, p_file);
        dbms_lob.fileopen(l_bfile, dbms_lob.file_readonly);
        if dbms_lob.getlength(l_bfile) > 0 then
            dbms_lob.loadfromfile(l_data,
                                  l_bfile,
                                  dbms_lob.getlength(l_bfile));
        end if;

        dbms_lob.fileclose(l_bfile);
        return l_data;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    function get_remote_ascii_data (
        p_conn in out nocopy utl_tcp.connection,
        p_file in varchar2
    ) return clob is
-- --------------------------------------------------------------------------
        l_conn   utl_tcp.connection;
        l_amount pls_integer;
        l_buffer varchar2(32767);
        l_data   clob;
    begin
        dbms_lob.createtemporary(
            lob_loc => l_data,
            cache   => true,
            dur     => dbms_lob.call
        );

        l_conn := get_passive(p_conn);
        send_command(p_conn, 'RETR ' || p_file, true);
  --logout(l_conn, FALSE);

        begin
            loop
                l_amount := utl_tcp.read_text(l_conn, l_buffer, 32767);
                dbms_lob.writeappend(l_data, l_amount, l_buffer);
            end loop;
        exception
            when utl_tcp.end_of_input then
                null;
            when others then
                null;
        end;

        utl_tcp.close_connection(l_conn);
        get_reply(p_conn);
        return l_data;
    exception
        when others then
            utl_tcp.close_connection(l_conn);
            raise;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    function get_remote_binary_data (
        p_conn in out nocopy utl_tcp.connection,
        p_file in varchar2
    ) return blob is
-- --------------------------------------------------------------------------
        l_conn   utl_tcp.connection;
        l_amount pls_integer;
        l_buffer raw(32767);
        l_data   blob;
    begin
        dbms_lob.createtemporary(
            lob_loc => l_data,
            cache   => true,
            dur     => dbms_lob.call
        );

        l_conn := get_passive(p_conn);
        send_command(p_conn, 'RETR ' || p_file, true);
        begin
            loop
                l_amount := utl_tcp.read_raw(l_conn, l_buffer, 32767);
                dbms_lob.writeappend(l_data, l_amount, l_buffer);
            end loop;
        exception
            when utl_tcp.end_of_input then
                null;
            when others then
                null;
        end;

        utl_tcp.close_connection(l_conn);
        get_reply(p_conn);
        return l_data;
    exception
        when others then
            utl_tcp.close_connection(l_conn);
            raise;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure put_local_ascii_data (
        p_data in clob,
        p_dir  in varchar2,
        p_file in varchar2
    ) is
-- --------------------------------------------------------------------------
        l_out_file utl_file.file_type;
        l_buffer   varchar2(32767);
        l_amount   binary_integer := 32767;
        l_pos      integer := 1;
        l_clob_len integer;
    begin
        l_clob_len := dbms_lob.getlength(p_data);
        l_out_file := utl_file.fopen(p_dir, p_file, 'w', 32767);
        while l_pos <= l_clob_len loop
            dbms_lob.read(p_data, l_amount, l_pos, l_buffer);
            if g_convert_crlf then
                l_buffer := replace(l_buffer,
                                    chr(13),
                                    null);
            end if;

            utl_file.put(l_out_file, l_buffer);
            utl_file.fflush(l_out_file);
            l_pos := l_pos + l_amount;
        end loop;

        utl_file.fclose(l_out_file);
    exception
        when others then
            if utl_file.is_open(l_out_file) then
                utl_file.fclose(l_out_file);
            end if;
            raise;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure put_local_binary_data (
        p_data in blob,
        p_dir  in varchar2,
        p_file in varchar2
    ) is
-- --------------------------------------------------------------------------
        l_out_file utl_file.file_type;
        l_buffer   raw(32767);
        l_amount   binary_integer := 32767;
        l_pos      integer := 1;
        l_blob_len integer;
    begin
        l_blob_len := dbms_lob.getlength(p_data);
        l_out_file := utl_file.fopen(p_dir, p_file, 'wb', 32767);
        while l_pos <= l_blob_len loop
            dbms_lob.read(p_data, l_amount, l_pos, l_buffer);
            utl_file.put_raw(l_out_file, l_buffer, true);
            utl_file.fflush(l_out_file);
            l_pos := l_pos + l_amount;
        end loop;

        utl_file.fclose(l_out_file);
    exception
        when others then
            if utl_file.is_open(l_out_file) then
                utl_file.fclose(l_out_file);
            end if;
            raise;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure put_remote_ascii_data (
        p_conn in out nocopy utl_tcp.connection,
        p_file in varchar2,
        p_data in clob
    ) is
-- --------------------------------------------------------------------------
        l_conn     utl_tcp.connection;
        l_result   pls_integer;
        l_buffer   varchar2(32767);
        l_amount   binary_integer := 32767;
        l_pos      integer := 1;
        l_clob_len integer;
    begin
        l_conn := get_passive(p_conn);
        send_command(p_conn, 'STOR ' || p_file, true);
        l_clob_len := dbms_lob.getlength(p_data);
        while l_pos <= l_clob_len loop
            dbms_lob.read(p_data, l_amount, l_pos, l_buffer);
            if g_convert_crlf then
                l_buffer := replace(l_buffer,
                                    chr(13),
                                    null);
            end if;

            l_result := utl_tcp.write_text(l_conn,
                                           l_buffer,
                                           length(l_buffer));
            utl_tcp.flush(l_conn);
            l_pos := l_pos + l_amount;
        end loop;

        utl_tcp.close_connection(l_conn);
  -- The following line allows some people to make multiple calls from one connection.
  -- It causes the operation to hang for me, hence it is commented out by default.
  -- get_reply(p_conn);

    exception
        when others then
            utl_tcp.close_connection(l_conn);
            raise;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure put_remote_binary_data (
        p_conn in out nocopy utl_tcp.connection,
        p_file in varchar2,
        p_data in blob
    ) is
-- --------------------------------------------------------------------------
        l_conn     utl_tcp.connection;
        l_result   pls_integer;
        l_buffer   raw(32767);
        l_amount   binary_integer := 32767;
        l_pos      integer := 1;
        l_blob_len integer;
    begin
        l_conn := get_passive(p_conn);
        send_command(p_conn, 'STOR ' || p_file, true);
        l_blob_len := dbms_lob.getlength(p_data);
        while l_pos <= l_blob_len loop
            dbms_lob.read(p_data, l_amount, l_pos, l_buffer);
            l_result := utl_tcp.write_raw(l_conn, l_buffer, l_amount);
            utl_tcp.flush(l_conn);
            l_pos := l_pos + l_amount;
        end loop;

        utl_tcp.close_connection(l_conn);
  -- The following line allows some people to make multiple calls from one connection.
  -- It causes the operation to hang for me, hence it is commented out by default.
  -- get_reply(p_conn);

    exception
        when others then
            utl_tcp.close_connection(l_conn);
            raise;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure get (
        p_conn      in out nocopy utl_tcp.connection,
        p_from_file in varchar2,
        p_to_dir    in varchar2,
        p_to_file   in varchar2
    ) as
-- --------------------------------------------------------------------------
    begin
        if g_binary then
            put_local_binary_data(
                p_data => get_remote_binary_data(p_conn, p_from_file),
                p_dir  => p_to_dir,
                p_file => p_to_file
            );

        else
            put_local_ascii_data(
                p_data => get_remote_ascii_data(p_conn, p_from_file),
                p_dir  => p_to_dir,
                p_file => p_to_file
            );
        end if;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure put (
        p_conn      in out nocopy utl_tcp.connection,
        p_from_dir  in varchar2,
        p_from_file in varchar2,
        p_to_file   in varchar2
    ) as
-- --------------------------------------------------------------------------
    begin
        if g_binary then
            put_remote_binary_data(
                p_conn => p_conn,
                p_file => p_to_file,
                p_data => get_local_binary_data(p_from_dir, p_from_file)
            );
        else
            put_remote_ascii_data(
                p_conn => p_conn,
                p_file => p_to_file,
                p_data => get_local_ascii_data(p_from_dir, p_from_file)
            );
        end if;

        get_reply(p_conn);
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure get_direct (
        p_conn      in out nocopy utl_tcp.connection,
        p_from_file in varchar2,
        p_to_dir    in varchar2,
        p_to_file   in varchar2
    ) is
-- --------------------------------------------------------------------------
        l_conn       utl_tcp.connection;
        l_out_file   utl_file.file_type;
        l_amount     pls_integer;
        l_buffer     varchar2(32767);
        l_raw_buffer raw(32767);
    begin
        l_conn := get_passive(p_conn);
        send_command(p_conn, 'RETR ' || p_from_file, true);
        if g_binary then
            l_out_file := utl_file.fopen(p_to_dir, p_to_file, 'wb', 32767);
        else
            l_out_file := utl_file.fopen(p_to_dir, p_to_file, 'w', 32767);
        end if;

        begin
            loop
                if g_binary then
                    l_amount := utl_tcp.read_raw(l_conn, l_raw_buffer, 32767);
                    utl_file.put_raw(l_out_file, l_raw_buffer, true);
                else
                    l_amount := utl_tcp.read_text(l_conn, l_buffer, 32767);
                    if g_convert_crlf then
                        l_buffer := replace(l_buffer,
                                            chr(13),
                                            null);
                    end if;

                    utl_file.put(l_out_file, l_buffer);
                end if;

                utl_file.fflush(l_out_file);
            end loop;
        exception
            when utl_tcp.end_of_input then
                null;
            when others then
                null;
        end;

        utl_file.fclose(l_out_file);
        utl_tcp.close_connection(l_conn);
    exception
        when others then
            if utl_file.is_open(l_out_file) then
                utl_file.fclose(l_out_file);
            end if;
            raise;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure put_direct (
        p_conn      in out nocopy utl_tcp.connection,
        p_from_dir  in varchar2,
        p_from_file in varchar2,
        p_to_file   in varchar2
    ) is
-- --------------------------------------------------------------------------
        l_conn       utl_tcp.connection;
        l_bfile      bfile;
        l_result     pls_integer;
        l_amount     pls_integer := 32767;
        l_raw_buffer raw(32767);
        l_len        number;
        l_pos        number := 1;
        ex_ascii exception;
    begin
        if not g_binary then
            raise ex_ascii;
        end if;
        l_conn := get_passive(p_conn);
        send_command(p_conn, 'STOR ' || p_to_file, true);
        l_bfile := bfilename(p_from_dir, p_from_file);
        dbms_lob.fileopen(l_bfile, dbms_lob.file_readonly);
        l_len := dbms_lob.getlength(l_bfile);
        while l_pos <= l_len loop
            dbms_lob.read(l_bfile, l_amount, l_pos, l_raw_buffer);
            debug(l_amount);
            l_result := utl_tcp.write_raw(l_conn, l_raw_buffer, l_amount);
            l_pos := l_pos + l_amount;
        end loop;

        dbms_lob.fileclose(l_bfile);
        utl_tcp.close_connection(l_conn);
    exception
        when ex_ascii then
            raise_application_error(-20000, 'PUT_DIRECT not available in ASCII mode.');
        when others then
            if dbms_lob.fileisopen(l_bfile) = 1 then
                dbms_lob.fileclose(l_bfile);
            end if;

            raise;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure help (
        p_conn in out nocopy utl_tcp.connection
    ) as
-- --------------------------------------------------------------------------
    begin
        send_command(p_conn, 'HELP', true);
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure ascii (
        p_conn in out nocopy utl_tcp.connection
    ) as
-- --------------------------------------------------------------------------
    begin
        send_command(p_conn, 'TYPE A', true);
        g_binary := false;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure binary (
        p_conn in out nocopy utl_tcp.connection
    ) as
-- --------------------------------------------------------------------------
    begin
        send_command(p_conn, 'TYPE I', true);
        g_binary := true;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure list (
        p_conn in out nocopy utl_tcp.connection,
        p_dir  in varchar2,
        p_list out t_string_table
    ) as
-- --------------------------------------------------------------------------
        l_conn       utl_tcp.connection;
        l_list       t_string_table := t_string_table();
        l_reply_code varchar2(3) := null;
    begin
        l_conn := get_passive(p_conn);
        send_command(p_conn, 'LIST ' || p_dir, true);
        begin
            loop
                l_list.extend;
                l_list(l_list.last) := utl_tcp.get_line(l_conn, true);
                debug(l_list(l_list.last));
                if l_reply_code is null then
                    l_reply_code := substr(
                        l_list(l_list.last),
                        1,
                        3
                    );
                end if;

                if substr(l_reply_code, 1, 1) in ( '4', '5' ) then
                    raise_application_error(-20000,
                                            l_list(l_list.last));
                elsif (
                    substr(
                        g_reply(g_reply.last),
                        1,
                        3
                    ) = l_reply_code
                    and substr(
                        g_reply(g_reply.last),
                        4,
                        1
                    ) = ' '
                ) then
                    exit;
                end if;

            end loop;
        exception
            when utl_tcp.end_of_input then
                null;
        end;

        l_list.delete(l_list.last);
        p_list := l_list;
        utl_tcp.close_connection(l_conn);
        get_reply(p_conn);
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure nlst (
        p_conn in out nocopy utl_tcp.connection,
        p_dir  in varchar2,
        p_list out t_string_table
    ) as
-- --------------------------------------------------------------------------
        l_conn       utl_tcp.connection;
        l_list       t_string_table := t_string_table();
        l_reply_code varchar2(3) := null;
    begin
        l_conn := get_passive(p_conn);
        send_command(p_conn, 'NLST ' || p_dir, true);
        begin
            loop
                l_list.extend;
                l_list(l_list.last) := utl_tcp.get_line(l_conn, true);
                debug(l_list(l_list.last));
                if l_reply_code is null then
                    l_reply_code := substr(
                        l_list(l_list.last),
                        1,
                        3
                    );
                end if;

                if substr(l_reply_code, 1, 1) in ( '4', '5' ) then
                    raise_application_error(-20000,
                                            l_list(l_list.last));
                elsif (
                    substr(
                        g_reply(g_reply.last),
                        1,
                        3
                    ) = l_reply_code
                    and substr(
                        g_reply(g_reply.last),
                        4,
                        1
                    ) = ' '
                ) then
                    exit;
                end if;

            end loop;
        exception
            when utl_tcp.end_of_input then
                null;
        end;

        l_list.delete(l_list.last);
        p_list := l_list;
        utl_tcp.close_connection(l_conn);
        get_reply(p_conn);
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure rename (
        p_conn in out nocopy utl_tcp.connection,
        p_from in varchar2,
        p_to   in varchar2
    ) as
-- --------------------------------------------------------------------------
        l_conn utl_tcp.connection;
    begin
        l_conn := get_passive(p_conn);
        send_command(p_conn, 'RNFR ' || p_from, true);
        send_command(p_conn, 'RNTO ' || p_to, true);
        logout(l_conn, false);
    end rename;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure delete (
        p_conn in out nocopy utl_tcp.connection,
        p_file in varchar2
    ) as
-- --------------------------------------------------------------------------
        l_conn utl_tcp.connection;
    begin
        l_conn := get_passive(p_conn);
        send_command(p_conn, 'DELE ' || p_file, true);
        logout(l_conn, false);
    end delete;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure mkdir (
        p_conn in out nocopy utl_tcp.connection,
        p_dir  in varchar2
    ) as
-- --------------------------------------------------------------------------
        l_conn utl_tcp.connection;
    begin
        l_conn := get_passive(p_conn);
        send_command(p_conn, 'MKD ' || p_dir, true);
        logout(l_conn, false);
    end mkdir;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure rmdir (
        p_conn in out nocopy utl_tcp.connection,
        p_dir  in varchar2
    ) as
-- --------------------------------------------------------------------------
        l_conn utl_tcp.connection;
    begin
        l_conn := get_passive(p_conn);
        send_command(p_conn, 'RMD ' || p_dir, true);
        logout(l_conn, false);
    end rmdir;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure convert_crlf (
        p_status in boolean
    ) as
-- --------------------------------------------------------------------------
    begin
        g_convert_crlf := p_status;
    end;
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
    procedure debug (
        p_text in varchar2
    ) is
-- --------------------------------------------------------------------------
    begin
        if g_debug then
            dbms_output.put_line(substr(p_text, 1, 255));
        end if;
    end;
-- --------------------------------------------------------------------------

end ftp;
/

