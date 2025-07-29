create or replace procedure samqa.download_file (
    p_file in number
) as

    v_mime      varchar2(48);
    v_length    number;
    v_file_name varchar2(2000);
    v_subject   varchar2(2000);
    lob_loc     blob;
begin
    select
        mime_type,
        blob_content,
        name,
        dbms_lob.getlength(blob_content),
        description
    into
        v_mime,
        lob_loc,
        v_file_name,
        v_length,
        v_subject
    from
        files
    where
        file_id = p_file;

-- -- set up HTTP header
-- -- use an NVL around the mime type and
-- if it is a null set it to application/octect
-- application/octect may launch a download window from windows
    owa_util.mime_header(
        nvl(v_mime, 'application/octet'),
        false
    );
-- set the size so the browser knows how much to download
    htp.p('Content-length: ' || v_length);
-- the filename will be used by the browser if the users does a save as
    htp.p('Content-Disposition: attachment; filename="'
          || replace(
        replace(
            substr(v_file_name,
                   instr(v_file_name, '/') + 1),
            chr(10),
            null
        ),
        chr(13),
        null
    )
          || '"');
-- close the headers
    owa_util.http_header_close;
-- download the BLOB
    wpg_docload.download_file(lob_loc);
exception
    when others then
        null;
end download_file;
/


-- sqlcl_snapshot {"hash":"9ee28d00bc21988dfe2f22a7b727889d2e34deae","type":"PROCEDURE","name":"DOWNLOAD_FILE","schemaName":"SAMQA","sxml":""}