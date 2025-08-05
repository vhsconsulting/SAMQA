-- liquibase formatted sql
-- changeset SAMQA:1754374146267 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\send_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/send_email.sql:null:438d766097eec85ce244235969b00d205fcbdbd3:create

create or replace procedure samqa.send_email (
    from_name varchar2,
    to_names  varchar2,
    subject   varchar2,
    mesg      varchar2
) is

    smtp_host      varchar2(256) := 'smtp.mandrillapp.com';
    smtp_port      number := 587;
    p_user_name    varchar2(100) := 'techsupport@sterlingadministration.com';
    p_password     varchar2(100) := 'KOwFx0sGtM96UwjNLyXr_A';
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
  --   utl_smtp.starttls(conn);
    utl_smtp.helo(conn, smtp_host);
    utl_smtp.command(conn, 'AUTH LOGIN');
    utl_smtp.command(conn,
                     utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(p_user_name))));

    utl_smtp.command(conn,
                     utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(p_password))));

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
/

