-- liquibase formatted sql
-- changeset SAMQA:1754374146139 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\send_aop_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/send_aop_email.sql:null:e8c94b8e72b91e753c988553d31e8eb4210c5b5e:create

create or replace procedure samqa.send_aop_email (
    p_output_blob      in blob,
    p_output_filename  in varchar2,
    p_output_mime_type in varchar2
) is
    l_id number;
begin
    l_id := apex_mail.send(
        p_to        => 'shavee.kapoor@sterlingadministration.com',
        p_from      => 'techsupport@sterlingadministration.com',
        p_subj      => 'Sales Reports',
        p_body      => 'Please review the attachment.',
        p_body_html => 'Please review the attachment.'
    );

    apex_mail.add_attachment(
        p_mail_id    => l_id,
        p_attachment => p_output_blob,
        p_filename   => p_output_filename,
        p_mime_type  => p_output_mime_type
    );

    commit;
end send_aop_email;
/

