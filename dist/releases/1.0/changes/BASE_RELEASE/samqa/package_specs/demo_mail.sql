-- liquibase formatted sql
-- changeset SAMQA:1754374133404 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\demo_mail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/demo_mail.sql:null:1e0fa20c933eb8c135de63ed62f713e180bfbc8e:create

create or replace package samqa.demo_mail is

  ----------------------- Customizable Section -----------------------

  -- Customize the SMTP host, port and your domain name below.
    smtp_host varchar2(256) := 'sterling2.sterlinghsa.com';
    smtp_port pls_integer := 25;
    smtp_domain varchar2(256) := 'sterlinghsa.com';

  -- Customize the signature that will appear in the email's MIME header.
  -- Useful for versioning.
    mailer_id constant varchar2(256) := 'Mailer by Oracle UTL_SMTP';

  --------------------- End Customizable Section ---------------------

  -- A unique string that demarcates boundaries of parts in a multi-part email
  -- The string should not appear inside the body of any part of the email.
  -- Customize this if needed or generate this randomly dynamically.
    boundary constant varchar2(256) := '-----7D81B75CCC90D2974F7A1CBD';
    first_boundary constant varchar2(256) := '--'
                                             || boundary
                                             || utl_tcp.crlf;
    last_boundary constant varchar2(256) := '--'
                                            || boundary
                                            || '--'
                                            || utl_tcp.crlf;

  -- A MIME type that denotes multi-part email (MIME) messages.
    multipart_mime_type constant varchar2(256) := 'multipart/mixed; boundary="'
                                                  || boundary
                                                  || '"';
    max_base64_line_width constant pls_integer := 76 / 4 * 3;

  -- A simple email API for sending email in plain text in a single call.
  -- The format of an email address is one of these:
  --   someone@some-domain
  --   "Someone at some domain" <someone@some-domain>
  --   Someone at some domain <someone@some-domain>
  -- The recipients is a list of email addresses  separated by
  -- either a "," or a ";"
    procedure mail (
        sender     in varchar2,
        recipients in varchar2,
        subject    in varchar2,
        message    in varchar2
    );

  -- Extended email API to send email in HTML or plain text with no size limit.
  -- First, begin the email by begin_mail(). Then, call write_text() repeatedly
  -- to send email in ASCII piece-by-piece. Or, call write_mb_text() to send
  -- email in non-ASCII or multi-byte character set. End the email with
  -- end_mail().
    function begin_mail (
        sender     in varchar2,
        recipients in varchar2,
        subject    in varchar2,
        mime_type  in varchar2 default 'text/plain',
        priority   in pls_integer default null
    ) return utl_smtp.connection;

  -- Write email body in ASCII
    procedure write_text (
        conn    in out nocopy utl_smtp.connection,
        message in varchar2
    );

  -- Write email body in non-ASCII (including multi-byte). The email body
  -- will be sent in the database character set.
    procedure write_mb_text (
        conn    in out nocopy utl_smtp.connection,
        message in varchar2
    );

  -- Write email body in binary
    procedure write_raw (
        conn    in out nocopy utl_smtp.connection,
        message in raw
    );

  -- APIs to send email with attachments. Attachments are sent by sending
  -- emails in "multipart/mixed" MIME format. Specify that MIME format when
  -- beginning an email with begin_mail().

  -- Send a single text attachment.
    procedure attach_text (
        conn      in out nocopy utl_smtp.connection,
        data      in varchar2,
        mime_type in varchar2 default 'text/plain',
        inline    in boolean default true,
        filename  in varchar2 default null,
        last      in boolean default false
    );

  -- Send a binary attachment. The attachment will be encoded in Base-64
  -- encoding format.
    procedure attach_base64 (
        conn      in out nocopy utl_smtp.connection,
        data      in raw,
        mime_type in varchar2 default 'application/octet',
        inline    in boolean default true,
        filename  in varchar2 default null,
        last      in boolean default false
    );

  -- Send an attachment with no size limit. First, begin the attachment
  -- with begin_attachment(). Then, call write_text repeatedly to send
  -- the attachment piece-by-piece. If the attachment is text-based but
  -- in non-ASCII or multi-byte character set, use write_mb_text() instead.
  -- To send binary attachment, the binary content should first be
  -- encoded in Base-64 encoding format using the demo package for 8i,
  -- or the native one in 9i. End the attachment with end_attachment.
    procedure begin_attachment (
        conn         in out nocopy utl_smtp.connection,
        mime_type    in varchar2 default 'text/plain',
        inline       in boolean default true,
        filename     in varchar2 default null,
        transfer_enc in varchar2 default null
    );

  -- End the attachment.
    procedure end_attachment (
        conn in out nocopy utl_smtp.connection,
        last in boolean default false
    );

  -- End the email.
    procedure end_mail (
        conn in out nocopy utl_smtp.connection
    );

  -- Extended email API to send multiple emails in a session for better
  -- performance. First, begin an email session with begin_session.
  -- Then, begin each email with a session by calling begin_mail_in_session
  -- instead of begin_mail. End the email with end_mail_in_session instead
  -- of end_mail. End the email session by end_session.
    function begin_session return utl_smtp.connection;

  -- Begin an email in a session.
    procedure begin_mail_in_session (
        conn       in out nocopy utl_smtp.connection,
        sender     in varchar2,
        recipients in varchar2,
        subject    in varchar2,
        mime_type  in varchar2 default 'text/plain',
        priority   in pls_integer default null
    );

  -- End an email in a session.
    procedure end_mail_in_session (
        conn in out nocopy utl_smtp.connection
    );

  -- End an email session.
    procedure end_session (
        conn in out nocopy utl_smtp.connection
    );

end;
/

