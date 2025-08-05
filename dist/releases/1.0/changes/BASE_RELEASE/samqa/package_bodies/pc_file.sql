-- liquibase formatted sql
-- changeset SAMQA:1754374028782 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_file.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_file.sql:null:256d2012fa44a969ef73c12256377e32d77235c5:create

create or replace package body samqa.pc_file is

    procedure download_attachment (
        attachment_id_in in number
    ) is

        blob_v      blob;
        mime_type_v varchar2(128);
        l_file_name varchar2(255);
        l_amt       number default 30;
        l_off       number default 1;
        l_raw       raw(4096);
    begin
        htp.flush;
        htp.init;
        select
            attachment,
            document_type,
            document_name
        into
            blob_v,
            mime_type_v,
            l_file_name
        from
            file_attachments
        where
            attachment_id = attachment_id_in;

        owa_util.mime_header(mime_type_v, false);
        htp.p('Content-Length: ' || dbms_lob.getlength(blob_v));
        htp.p('Content-Disposition: attachment; filename="'
              || l_file_name
              || '"');
        owa_util.http_header_close;

 --  owa_util.http_header_close;
        wpg_docload.download_file(blob_v);
    exception
        when others then
            htp.p('pc_file.download:'
                  || to_char(attachment_id_in)
                  || ':'
                  || sqlerrm);
    end download_attachment;

    procedure download_claim_doc (
        claim_id_in in number
    ) is

        blob_v      blob;
        mime_type_v varchar2(128);
        l_file_name varchar2(255);
        l_amt       number default 30;
        l_off       number default 1;
        l_raw       raw(4096);
    begin
        dbms_lob.createtemporary(blob_v, true);
        for x in (
            select
                attachment,
                document_type,
                document_name
            from
                file_attachments
            where
                    entity_name = 'CLAIMN'
                and entity_id = claim_id_in
        ) loop
          --dbms_lob.append(blob_v,x.ATTACHMENT);
            mime_type_v := x.document_type;
         -- blob_v := x.ATTACHMENT;
            dbms_lob.append(blob_v, x.attachment);
            owa_util.mime_header(x.document_type);
            htp.p('Content-Length: '
                  || dbms_lob.getlength(x.attachment));
            htp.p('Content-Disposition: attachment; filename="'
                  || x.document_name
                  || '"');
   --  owa_util.http_header_close;
        end loop;

        wpg_docload.download_file(blob_v);
        commit;
    exception
        when others then
            htp.p('pc_file.download:'
                  || to_char(claim_id_in)
                  || ':'
                  || sqlerrm);
    end download_claim_doc;

-- ?????? ?? ???????? ?????
    procedure upload_request (
        table_name_in in varchar2,
        table_id_in   in varchar2,
        p_key         in varchar2
    ) is
    begin
        htp.htmlopen;
        htp.headopen;
        htp.linkrel('STYLESHEET',
                    pc_param.get_value('WEB_STYLESHEET'));
        htp.meta('Content-Type',
                 null,
                 pc_param.get_value('WEB_CONTENT-TYPE'));
        htp.title(pc_param.get_value('APP_NAME')
                  || ' : File upload');
        htp.headclose;
        htp.bodyopen;
        htp.formopen(
            curl     => pc_param.get_value('WEB_URL_MODPLSQL')
                    || '/pc_file.upload',
            cmethod  => 'POST',
            cenctype => 'multipart/form-data'
        );

        htp.formhidden('table_name_in', table_name_in);
        htp.formhidden('table_id_in', table_id_in);
        htp.formhidden('p_key', p_key);
        htp.p('Description:');
        htp.formtext('description_in', 60, 128);
        htp.p('Select file: <INPUT type="file" name="file">');
        htp.formsubmit(null, 'Load');
        htp.formclose;
        htp.bodyclose;
        htp.htmlclose;
    end upload_request;
-- ???????? ?????
    procedure upload (
        file           in varchar2,
        table_name_in  in varchar2,
        table_id_in    in varchar2,
        description_in in varchar2,
        p_key          in varchar2
    ) is
    begin
        htp.htmlopen;
        htp.headopen;
        htp.linkrel('STYLESHEET',
                    pc_param.get_value('WEB_STYLESHEET'));
        htp.meta('Content-Type',
                 null,
                 pc_param.get_value('WEB_CONTENT-TYPE'));
        htp.title(pc_param.get_value('APP_NAME')
                  || ' : File upload');
        htp.headclose;
        htp.bodyopen;
        update files
        set
            table_name = table_name_in,
            table_id = table_id_in,
            description = description_in,
            name = substr(name,
                          instr(name, '/', -1) + 1)
        where
            name = file;

        htp.p('File '
              || file
              || ' loaded.');
        htp.bodyclose;
        htp.htmlclose;
    end upload;
-- ???????? ?? ??????? ??????????? ??? ????????? ??????? ? ??????????????
-- (1-????,0-???)
    function is_there_are_attach (
        table_name_in in varchar2,
        table_id_in   in varchar2
    ) return number is

        cursor c1 (
            p_table_name varchar2,
            p_table_id   varchar2
        ) is
        select
            'x'
        from
            files
        where
                table_name = p_table_name
            and table_id = p_table_id;

        r1 c1%rowtype;
        f1 boolean;
    begin
        open c1(table_name_in, table_id_in);
        fetch c1 into r1;
        f1 := c1%found;
        close c1;
        if f1 then
            return 1;
        else
            return 0;
        end if;
    end is_there_are_attach;
-- ???????? ????????
    procedure download (
        file_id_in in number,
        p_key      in varchar2
    ) is
        blob_v      blob;
        mime_type_v varchar2(128);
    begin
        select
            blob_content,
            mime_type
        into
            blob_v,
            mime_type_v
        from
            files
        where
            file_id = file_id_in;

        owa_util.mime_header(mime_type_v, false);
        htp.p('Content-Length: ' || dbms_lob.getlength(blob_v));
        owa_util.http_header_close;
        wpg_docload.download_file(blob_v);
    exception
        when others then
            htp.p('pc_file.download:'
                  || to_char(file_id_in)
                  || ':'
                  || sqlerrm);
    end download;

    procedure download (
        name_in in varchar2
    ) is
        blob_v      blob;
        mime_type_v varchar2(128);
    begin
        select
            blob_content,
            mime_type
        into
            blob_v,
            mime_type_v
        from
            files
        where
            name = name_in;

        owa_util.mime_header(mime_type_v, false);
        htp.p('Content-Length: ' || dbms_lob.getlength(blob_v));
        owa_util.http_header_close;
        wpg_docload.download_file(blob_v);
    exception
        when others then
            htp.p('pc_file.download:'
                  || name_in
                  || ':'
                  || sqlerrm);
    end download;

    procedure get_query_result_as_csv_file (
        in_query    in varchar2,
        in_filename in varchar2
    ) is

        l_blob          blob;
        l_raw           raw(32767);
        l_cursor        integer;
        l_cursor_status integer;
        l_col_count     number;
        l_col_val       varchar2(32767);
        l_desc_tbl      sys.dbms_sql.desc_tab2;
    begin
	-- create temporary BLOB
        dbms_lob.createtemporary(l_blob, false);
	-- open BLOB
        dbms_lob.open(l_blob, dbms_lob.lob_readwrite);
	-- open cursor (and get cursor id)
        l_cursor := dbms_sql.open_cursor;
	-- parse query
        dbms_sql.parse(l_cursor, in_query, dbms_sql.native);
	-- get number of columns and description
        dbms_sql.describe_columns2(l_cursor, l_col_count, l_desc_tbl);
	-- define report columns
        for i in 1..l_col_count loop
            dbms_sql.define_column(l_cursor, i, l_col_val, 32767);
        end loop;
	-- write column headings to CSV file
        for i in 1..l_col_count loop
            l_col_val := l_desc_tbl(i).col_name;
            if i = l_col_count then
                l_col_val := '"'
                             || l_col_val
                             || '"'
                             || chr(10);
            else
                l_col_val := '"'
                             || l_col_val
                             || '",';
            end if;

            l_raw := utl_raw.cast_to_raw(l_col_val);
            dbms_lob.writeappend(l_blob,
                                 utl_raw.length(l_raw),
                                 l_raw);
        end loop;

        pc_log.log_error('get_query_result_as_csv_file ', 'l_col_count' || l_col_count);
        pc_log.log_error('get_query_result_as_csv_file ', 'l_col_val' || l_col_val);

	-- execute the query
        l_cursor_status := dbms_sql.execute(l_cursor);
	-- write result set to CSV file
        loop
            exit when dbms_sql.fetch_rows(l_cursor) <= 0
            or dbms_sql.last_row_count > 1000;
            for i in 1..l_col_count loop
                dbms_sql.column_value(l_cursor, i, l_col_val);
                if i = l_col_count then
                    l_col_val := '"'
                                 || l_col_val
                                 || '"'
                                 || chr(10);
                else
                    l_col_val := '"'
                                 || l_col_val
                                 || '",';
                end if;

                l_raw := utl_raw.cast_to_raw(l_col_val);
                dbms_lob.writeappend(l_blob,
                                     utl_raw.length(l_raw),
                                     l_raw);
            end loop;

        end loop;
	-- close cursor and BLOB
        dbms_sql.close_cursor(l_cursor);
        dbms_lob.close(l_blob);
	-- set http headers
        owa_util.mime_header('application/octet', false);
        htp.p('content-length: ' || dbms_lob.getlength(l_blob));
        htp.p('content-disposition: attachment;filename="'
              || in_filename
              || '.csv"');
	--owa_util.http_header_close;
	-- download the file
        wpg_docload.download_file(l_blob);
    exception
        when others then
            pc_log.log_error('get_query_result_as_csv_file ', 'SQLERRM ' || sqlerrm);
    end get_query_result_as_csv_file;

    procedure get_scheduler_details (
        p_scheduler_id in number,
        p_plan_type    in varchar2,
        p_entrp_id     in number
    ) as
        l_query varchar2(32000);
    begin
 /* SELECT region_source
  INTO   l_query
  FROM apex_application_page_regions
  WHERE application_id = 103 -- replace with your application id
  AND static_id = 'SCHEDULER_DETAILS';
*/
        pc_log.log_error('get_scheduler_details ', 'start' || p_scheduler_id);
        l_query := 'SELECT    ACC_NUM "Account Number"
        , FIRST_NAME||'' ''||LAST_NAME "Subscriber"
        , BEN_PLAN_ENROLLMENT_SETUP.ANNUAL_ELECTION "Annual Election"
        , NVL(ER_AMOUNT,0)  "Employer Contribution"
        , NVL(EE_AMOUNT,0) "Employee Contribution"
        , SCHEDULER_DETAIL_ID
        , CASE WHEN SCHEDULER_DETAIL_ID IS NULL THEN
	         ''No Schedule Defined''
	       WHEN SCHEDULER_DETAILS.STATUS = ''I'' THEN
	         ''Terminated''
	       ELSE ''Scheduled'' END "Status"
        , SCHEDULER_DETAILS.NOTE  "Note"
FROM "PERSON"
    ,"ACCOUNT"
    ,"SCHEDULER_DETAILS"
    ,BEN_PLAN_ENROLLMENT_SETUP
 WHERE SCHEDULER_DETAILS.SCHEDULER_ID(+) = '
                   || p_scheduler_id
                   || '
  AND   SCHEDULER_DETAILS.ACC_ID(+) = ACCOUNT.ACC_ID
  AND   BEN_PLAN_ENROLLMENT_SETUP.ACC_ID = ACCOUNT.ACC_ID
  AND   BEN_PLAN_ENROLLMENT_SETUP.PLAN_TYPE =  '''
                   || p_plan_type
                   || '''
  AND   TRUNC(BEN_PLAN_ENROLLMENT_SETUP.PLAN_END_DATE) >= TRUNC(SYSDATE)
 AND   TRUNC(BEN_PLAN_ENROLLMENT_SETUP.PLAN_END_DATE)  >=  NVL((
       SELECT PAYMENT_END_DATE
        FROM SCHEDULER_MASTER
      WHERE  SCHEDULER_ID =  '
                   || p_scheduler_id
                   || '),
                 TRUNC(BEN_PLAN_ENROLLMENT_SETUP.PLAN_END_DATE))
  AND   PERSON.ENTRP_ID = '
                   || p_entrp_id
                   || '
  AND   PERSON.PERS_ID = ACCOUNT.PERS_ID ';

        pc_log.log_error('get_scheduler_details ',
                         length(l_query));
        pc_log.log_error('get_scheduler_details ', l_query);
        get_query_result_as_csv_file(l_query,
                                     'Scheduler Details Export for scheduler #'
                                     || p_scheduler_id
                                     || ' '
                                     || to_char(sysdate, 'MM/DD/YYYY'));

    exception
        when others then
            null;
    end get_scheduler_details;

    procedure get_hsa_scheduler_details (
        p_scheduler_id in number,
        p_entrp_id     in number
    ) is
        l_query varchar2(32000);
    begin
 /* SELECT region_source
  INTO   l_query
  FROM apex_application_page_regions
  WHERE application_id = 103 -- replace with your application id
  AND static_id = 'SCHEDULER_DETAILS';
*/
        pc_log.log_error('get_hsa_scheduler_details ', 'start' || p_scheduler_id);
        l_query := 'SELECT    ACC_NUM "Account Number"
        , FIRST_NAME||'' ''||LAST_NAME "Subscriber"
        , NVL(ER_AMOUNT,0)  "Employer Contribution"
        , NVL(EE_AMOUNT,0) "Employee Contribution"
        , NVL(ER_FEE_AMOUNT,0)  "Employer Fee Contribution"
        , NVL(EE_FEE_AMOUNT,0) "Employee Fee Contribution"
        , SCHEDULER_DETAIL_ID
        , CASE WHEN SCHEDULER_DETAIL_ID IS NULL THEN
	         ''No Schedule Defined''
	       WHEN SCHEDULER_DETAILS.STATUS = ''I'' THEN
	         ''Terminated''
	       ELSE ''Scheduled'' END "Status"
        , SCHEDULER_DETAILS.NOTE  "Note"
FROM "PERSON"
    ,"ACCOUNT"
    ,"SCHEDULER_DETAILS"
  WHERE SCHEDULER_DETAILS.SCHEDULER_ID(+) = '
                   || p_scheduler_id
                   || '
  AND   SCHEDULER_DETAILS.ACC_ID(+) = ACCOUNT.ACC_ID
  AND   PERSON.ENTRP_ID = '
                   || p_entrp_id
                   || '
  AND   PERSON.PERS_ID = ACCOUNT.PERS_ID ';
        pc_log.log_error('get_scheduler_details ',
                         length(l_query));
        pc_log.log_error('get_scheduler_details ', l_query);
        get_query_result_as_csv_file(l_query,
                                     'Scheduler Details Export for scheduler #'
                                     || p_scheduler_id
                                     || ' '
                                     || to_char(sysdate, 'MM/DD/YYYY'));

    exception
        when others then
            null;
    end get_hsa_scheduler_details;

    procedure extract_error_from_log (
        p_in_file_name in varchar2,
        p_dir          in varchar2,
        x_file_name    out varchar2
    ) is

        l_utl_id     utl_file.file_type;
        l_new_utl_id utl_file.file_type;
        l_file_name  varchar2(3200);
        l_line       varchar2(32000);
        l_line_count number := 0;
    begin
        x_file_name := replace(p_in_file_name, '.')
                       || '_error.log';
        l_utl_id := utl_file.fopen(p_dir, p_in_file_name, 'r');
        l_new_utl_id := utl_file.fopen(p_dir, x_file_name, 'w');
        loop
            begin
                utl_file.get_line(l_utl_id, l_line);
                if l_line like '%KUP-%' then
                    utl_file.put_line(
                        file   => l_new_utl_id,
                        buffer => l_line
                    );
                end if;

            exception
                when no_data_found then
                    exit;
            end;
        end loop;

        utl_file.fclose(file => l_utl_id);
        utl_file.fclose(file => l_new_utl_id);
    end extract_error_from_log;

    procedure import_crm_employer is

        l_utl_id       utl_file.file_type;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_line_count   number := 0;
        l_dest_blob    blob;
        l_src_offset   number := 1;
        l_dest_offset  number := 1;
        l_src_osin     number;
        l_dst_osin     number;
        l_source_bfile bfile := bfilename('REPORT_DIR',
                                          'CRM_IMPORT_ER_'
                                          || to_char(sysdate, 'mmddyyyy')
                                          || '.csv');
    begin
        l_file_name := 'CRM_IMPORT_ER_'
                       || to_char(sysdate, 'mmddyyyy')
                       || '.csv';
        l_utl_id := utl_file.fopen('REPORT_DIR', l_file_name, 'w');
        l_line := 'Name,Account Number,Website,Email Address,Office Phone,Alternate Phone,Fax,Billing Street,Billing City,Billing State,Billing Postal Code,Billing Country,Shipping Street,Shipping City,Shipping State,Shipping Postal Code,Shipping Country,Description,Type,Industry,Annual Revenue,Employees,SIC Code,Ticker Symbol,Parent Account ID,Ownership,Campaign ID,Rating,Assigned User Name,Assigned To,Date Created,Date Modified,Modified By,Created By,Deleted'
        ;
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select
                '"'
                || replace(
                    replace(name,
                            chr(10)),
                    chr(13)
                )
                || '",'
                || replace(
                    replace(acc_num,
                            chr(10)),
                    chr(13)
                )
                || ',,"'
                || replace(
                    replace(entrp_email,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(entrp_phones,
                            chr(10)),
                    chr(13)
                )
                || '",,'
                || replace(
                    replace(entrp_fax,
                            chr(10)),
                    chr(13)
                )
                || ',"'
                || replace(
                    replace(address,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(city,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(state,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(zip,
                            chr(10)),
                    chr(13)
                )
                || '",'
                || country
                || ',"'
                || replace(
                    replace(address,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(city,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(state,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(zip,
                            chr(10)),
                    chr(13)
                )
                || '",'
                || country
                || ',,'
                || a_type
                || ','
                || industry
                || ','
                || annual_revenue
                || ','
                || employees
                || ','
                || sic_code
                || ','
                || ticker
                || ','
                || parent_account_id
                || ','
                || ownership
                || ','
                || campaign_id
                || ','
                || rating
                || ','
                || assigned_user_name
                || ','
                || assigned_to
                || ','
                || date_created
                || ','
                || date_modified
                || ','
                || modified_by
                || ','
                || created_by
                || ','
                || deleted line
            from
                crm_import_v
            where
                to_date(date_created, 'MM/DD/YYYY') >= trunc(sysdate)
            union
            select
                '"'
                || replace(
                    replace(name,
                            chr(10)),
                    chr(13)
                )
                || '",'
                || replace(
                    replace(acc_num,
                            chr(10)),
                    chr(13)
                )
                || ',,"'
                || replace(
                    replace(entrp_email,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(entrp_phones,
                            chr(10)),
                    chr(13)
                )
                || '",,'
                || replace(
                    replace(entrp_fax,
                            chr(10)),
                    chr(13)
                )
                || ',"'
                || replace(
                    replace(address,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(city,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(state,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(zip,
                            chr(10)),
                    chr(13)
                )
                || '",'
                || country
                || ',"'
                || replace(
                    replace(address,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(city,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(state,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(zip,
                            chr(10)),
                    chr(13)
                )
                || '",'
                || country
                || ',,'
                || a_type
                || ','
                || industry
                || ','
                || annual_revenue
                || ','
                || employees
                || ','
                || sic_code
                || ','
                || ticker
                || ','
                || parent_account_id
                || ','
                || ownership
                || ','
                || campaign_id
                || ','
                || rating
                || ','
                || assigned_user_name
                || ','
                || assigned_to
                || ','
                || date_created
                || ','
                || date_modified
                || ','
                || modified_by
                || ','
                || created_by
                || ','
                || deleted line
            from
                crm_import_v
            where
                not exists (
                    select
                        *
                    from
                        a
                    where
                        acc_num = crm_import_v.acc_num
                )
        ) loop
            utl_file.put_line(
                file   => l_utl_id,
                buffer => x.line
            );
        end loop;

        utl_file.fclose(file => l_utl_id);
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
        htp.p('Content-Disposition: attachment; filename="'
              || 'CRM_IMPORT_ER_'
              || to_char(sysdate, 'mmddyyyy')
              || '.csv'
              || '"');

        owa_util.http_header_close;
        wpg_docload.download_file(l_dest_blob);
    exception
        when others then
            htp.p(sqlerrm
                  || '...'
                  || dbms_utility.format_error_backtrace);
    end import_crm_employer;

    procedure import_crm_employer_acc (
        p_acc_num in varchar2
    ) is

        l_utl_id       utl_file.file_type;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_line_count   number := 0;
        l_dest_blob    blob;
        l_src_offset   number := 1;
        l_dest_offset  number := 1;
        l_src_osin     number;
        l_dst_osin     number;
        l_source_bfile bfile := bfilename('REPORT_DIR',
                                          'CRM_IMPORT_ER_'
                                          || to_char(sysdate, 'mmddyyyy')
                                          || '.csv');
    begin
        l_file_name := 'CRM_IMPORT_ER_'
                       || to_char(sysdate, 'mmddyyyy')
                       || '.csv';
        l_utl_id := utl_file.fopen('REPORT_DIR', l_file_name, 'w');
        l_line := 'Name,Account Number,Website,Email Address,Office Phone,Alternate Phone,Fax,Billing Street,Billing City,Billing State,Billing Postal Code,Billing Country,Shipping Street,Shipping City,Shipping State,Shipping Postal Code,Shipping Country,Description,Type,Industry,Annual Revenue,Employees,SIC Code,Ticker Symbol,Parent Account ID,Ownership,Campaign ID,Rating,Assigned User Name,Assigned To,Date Created,Date Modified,Modified By,Created By,Deleted'
        ;
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select
                '"'
                || replace(
                    replace(name,
                            chr(10)),
                    chr(13)
                )
                || '",'
                || replace(
                    replace(acc_num,
                            chr(10)),
                    chr(13)
                )
                || ',,"'
                || replace(
                    replace(entrp_email,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(entrp_phones,
                            chr(10)),
                    chr(13)
                )
                || '",,'
                || replace(
                    replace(entrp_fax,
                            chr(10)),
                    chr(13)
                )
                || ',"'
                || replace(
                    replace(address,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(city,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(state,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(zip,
                            chr(10)),
                    chr(13)
                )
                || '",'
                || country
                || ',"'
                || replace(
                    replace(address,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(city,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(state,
                            chr(10)),
                    chr(13)
                )
                || '","'
                || replace(
                    replace(zip,
                            chr(10)),
                    chr(13)
                )
                || '",'
                || country
                || ',,'
                || a_type
                || ','
                || industry
                || ','
                || annual_revenue
                || ','
                || employees
                || ','
                || sic_code
                || ','
                || ticker
                || ','
                || parent_account_id
                || ','
                || ownership
                || ','
                || campaign_id
                || ','
                || rating
                || ','
                || assigned_user_name
                || ','
                || assigned_to
                || ','
                || date_created
                || ','
                || date_modified
                || ','
                || modified_by
                || ','
                || created_by
                || ','
                || deleted line
            from
                crm_import_v
            where
                acc_num = p_acc_num
        ) loop
            utl_file.put_line(
                file   => l_utl_id,
                buffer => x.line
            );
        end loop;

        utl_file.fclose(file => l_utl_id);
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
        htp.p('Content-Disposition: attachment; filename="'
              || 'CRM_IMPORT_ER_'
              || to_char(sysdate, 'mmddyyyy')
              || '.csv'
              || '"');

        owa_util.http_header_close;
        wpg_docload.download_file(l_dest_blob);
    exception
        when others then
            htp.p(sqlerrm
                  || '...'
                  || dbms_utility.format_error_backtrace);
    end import_crm_employer_acc;

    function remove_line_feed (
        p_in_file_name in varchar2,
        p_dir          in varchar2,
        p_date         in varchar2
    ) return varchar2 is

        l_utl_id     utl_file.file_type;
        l_new_utl_id utl_file.file_type;
        l_file_name  varchar2(3200);
        l_line       varchar2(32000);
        l_line_count number := 0;
    begin
        l_file_name := p_in_file_name || 'txt';
        l_utl_id := utl_file.fopen(p_dir, p_in_file_name, 'r');
        l_new_utl_id := utl_file.fopen(p_dir, l_file_name, 'w');
        loop
            begin
                utl_file.get_line(l_utl_id, l_line);
                l_line_count := l_line_count + 1;
                if l_line_count = 1 then
                    utl_file.put_line(l_new_utl_id, l_line);
                end if;
                if
                    instr(p_in_file_name, 'inv' || p_date) > 0
                    and substr(l_line, 1, 1) = '3'
                then
                    utl_file.put_line(l_new_utl_id, l_line);
                elsif instr(l_line, p_date) > 0 then
                    utl_file.put_line(l_new_utl_id, l_line);
                end if;

            exception
                when no_data_found then
                    exit;
            end;
        end loop;

        utl_file.fclose(file => l_utl_id);
        utl_file.fclose(file => l_new_utl_id);
        return l_file_name;
    end remove_line_feed;

end pc_file;
/

