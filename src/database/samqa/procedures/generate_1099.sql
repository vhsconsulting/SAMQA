create or replace procedure samqa.generate_1099 as

    f_lob          bfile := bfilename('BANK_SERV_DIR',
                             '1099-'
                             || to_char((trunc(sysdate, 'YYYY') - 1),
                                        'YYYY')
                             || '.txt');
    b_lob          blob;
    l_utl_id       utl_file.file_type;
    l_file_name    varchar2(3200);
    l_line         varchar2(32000);
    l_line_tbl     varchar2_4000_tbl;
    l_dest_blob    blob;
    l_source_bfile bfile := bfilename('BANK_SERV_DIR',
                                      '1099-'
                                      || to_char((trunc(sysdate, 'YYYY') - 1),
                                                 'YYYY')
                                      || '.txt');
    l_src_offset   number := 1;
    l_dest_offset  number := 1;
    l_src_osin     number;
    l_dst_osin     number;
begin
    select
        output
    bulk collect
    into l_line_tbl
    from
        external_1099_v;

    l_utl_id := utl_file.fopen('BANK_SERV_DIR',
                               '1099-'
                               || to_char((trunc(sysdate, 'YYYY') - 1),
                                          'YYYY')
                               || '.txt',
                               'w');

    for i in 1..l_line_tbl.count loop
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line_tbl(i)
        );
    end loop;

    utl_file.fclose(file => l_utl_id);
/*  delete from files where name  = '1099-'||TO_CHAR((trunc(sysdate,'YYYY')-1),'YYYY')||'.txt';

  insert into files(file_id,name,content_type,blob_content,last_updated,description)
  values ( file_seq.nextval, '1099-'||TO_CHAR((trunc(sysdate,'YYYY')-1),'YYYY')||'.txt','1099',empty_blob(),SYSDATE,'1099 Generated in '||to_char(sysdate,'YYYY'))
  return blob_content into b_lob;
  commit;

   dbms_lob.fileopen(f_lob, dbms_lob.file_readonly);
    dbms_lob.loadfromfile
   ( b_lob, f_lob, dbms_lob.getlength(f_lob) );

   dbms_lob.fileclose(f_lob);
  */
    dbms_lob.createtemporary(l_dest_blob, true);

   /* Opening the source BFILE is mandatory */
    dbms_lob.fileopen(l_source_bfile, dbms_lob.file_readonly);

/* Save the input source/destination offsets */
    l_src_osin := l_src_offset;
    l_dst_osin := l_dest_offset;

/* Use LOBMAXSIZE to indicate loading the entire BFILE */
    dbms_lob.loadblobfromfile(l_dest_blob, l_source_bfile, dbms_lob.lobmaxsize, l_src_offset, l_dest_offset);
    owa_util.mime_header('application/octet', false);
    htp.p('Content-length: ' || dbms_lob.getlength(l_dest_blob));
    htp.p('Content-Disposition: attachment; filename="downloaded_file.txt"');
    owa_util.http_header_close;
    wpg_docload.download_file(l_dest_blob);
exception
    when others then
        htp.p(sqlerrm
              || '...'
              || dbms_utility.format_error_backtrace);
end;
/


-- sqlcl_snapshot {"hash":"6ffc1b6ade813aa1ee0479d1706f9296fd1e6cb1","type":"PROCEDURE","name":"GENERATE_1099","schemaName":"SAMQA","sxml":""}