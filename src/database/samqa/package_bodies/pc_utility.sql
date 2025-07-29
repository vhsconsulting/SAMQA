create or replace package body samqa.pc_utility as

    procedure save_1099 as

        f_lob       bfile := bfilename('BANK_SERV_DIR',
                                 '1099-'
                                 || to_char((trunc(sysdate, 'YYYY') - 1),
                                            'YYYY')
                                 || '.txt');
        b_lob       blob;
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(32000);
        l_line_tbl  varchar2_4000_tbl;
        pragma autonomous_transaction;
    begin
        delete from files
        where
            name = '1099-'
                   || to_char((trunc(sysdate, 'YYYY') - 1),
                              'YYYY')
                   || '.txt';

        insert into files (
            file_id,
            name,
            content_type,
            blob_content,
            last_updated,
            description
        ) values ( file_seq.nextval,
                   '1099-'
                   || to_char((trunc(sysdate, 'YYYY') - 1),
                              'YYYY')
                   || '.txt',
                   '1099',
                   empty_blob(),
                   sysdate,
                   '1099 Generated in ' || to_char(sysdate, 'YYYY') ) return blob_content into b_lob;

        dbms_lob.fileopen(f_lob, dbms_lob.file_readonly);
        dbms_lob.loadfromfile(b_lob,
                              f_lob,
                              dbms_lob.getlength(f_lob));
        dbms_lob.fileclose(f_lob);
        commit;
    end save_1099;

    procedure generate_1099 (
        p_year in varchar2
    ) as

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
            external_1099_v
        where
                begin_date = to_date('01-JAN-' || p_year, 'DD-MON-YYYY')
            and end_date = to_date('31-DEC-' || p_year, 'DD-MON-YYYY');

        l_utl_id := utl_file.fopen('BANK_SERV_DIR',
                                   '5498-'
                                   || to_char((trunc(sysdate, 'YYYY') - 1),
                                              'YYYY')
                                   || '.csv',
                                   'w');

        for i in 1..l_line_tbl.count loop
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line_tbl(i)
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
        htp.p('Content-Disposition: attachment; filename="downloaded_file.txt"');
        owa_util.http_header_close;
        wpg_docload.download_file(l_dest_blob);
    exception
        when others then
            htp.p(sqlerrm
                  || '...'
                  || dbms_utility.format_error_backtrace);
    end generate_1099;

    procedure download_file (
        p_file_name in varchar2,
        p_directory in varchar2
    ) as

        b_lob          blob;
        l_utl_id       utl_file.file_type;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_line_tbl     varchar2_4000_tbl;
        l_dest_blob    blob;
        l_source_bfile bfile;
        l_src_offset   number := 1;
        l_dest_offset  number := 1;
        l_src_osin     number;
        l_dst_osin     number;
    begin
  --get_dir_list( '/u01/benetrac' );

        dbms_lob.createtemporary(l_dest_blob, true);
        dbms_lob.open(l_dest_blob, dbms_lob.lob_readwrite);
        l_source_bfile := bfilename(p_directory, p_file_name);
        l_file_name := p_file_name;
        dbms_lob.fileopen(l_source_bfile, dbms_lob.file_readonly);
  /* Use LOBMAXSIZE to indicate loading the entire BFILE */
        dbms_lob.loadfromfile(l_dest_blob,
                              l_source_bfile,
                              dbms_lob.getlength(l_source_bfile));
        owa_util.mime_header('application/octet', false);
        htp.p('Content-length: ' || dbms_lob.getlength(l_source_bfile));
        htp.p('Content-Disposition: attachment; filename="'
              || l_file_name
              || '"');
        owa_util.http_header_close;
        dbms_lob.fileclose(l_source_bfile);
        wpg_docload.download_file(l_dest_blob);
    exception
        when others then
            htp.p(sqlerrm
                  || '...'
                  || dbms_utility.format_error_backtrace);
    end download_file;

    procedure purge_tables is
    begin
   -- commiting, as this is not a transaction and not to extend rollback segment too much !!
        delete from website_logs wl
        where
            wl.creation_date < sysdate - 7;

        commit;
        delete from metavante_errors
        where
            last_update_date < add_months(sysdate, -6);

        commit;
        delete from email_notifications
        where
            last_update_date < add_months(sysdate, -3);

        commit;
        delete from user_login_history
        where
            creation_date < add_months(sysdate, -3);

        commit;
        delete from external_files
        where
            last_update_date < add_months(sysdate, -6);

        commit;
        delete from event_notifications
        where
            creation_date < add_months(sysdate, -6);

        commit;
        delete from activity_statement
        where
            creation_date < add_months(sysdate, -1);

        commit;
        delete from activity_statement_detail
        where
            creation_date < add_months(sysdate, -1);

        commit;
    end purge_tables;

    procedure insert_notes (
        p_entity_id     in varchar2,
        p_entity_type   in varchar2,
        p_description   in varchar2,
        p_user_id       in varchar2,
        p_creation_date in date default sysdate,
        p_pers_id       in number default null,
        p_acc_id        in number default null,
        p_entrp_id      in number default null,
        p_action        in varchar2 default null
    ) is
        l_acc_id number;
    begin
        if p_description is not null then
            if
                p_pers_id is not null
                and p_acc_id is null
            then
                begin
                    select
                        acc_id
                    into l_acc_id
                    from
                        account
                    where
                        pers_id = p_pers_id;

                exception
                    when others then
                        null;
                end;
            end if;

            if
                p_entrp_id is not null
                and p_pers_id is null
                and p_acc_id is null
            then
                begin
                    select
                        acc_id
                    into l_acc_id
                    from
                        account
                    where
                        entrp_id = p_entrp_id;

                exception
                    when others then
                        null;
                end;

            end if;

            insert into notes (
                note_id,
                entity_id,
                entity_type,
                description,
                created_by,
                entered_date,
                pers_id,
                acc_id,
                entrp_id,
                creation_date,
                note_action
            ) values ( notes_seq.nextval,
                       p_entity_id,
                       p_entity_type,
                       p_description,
                       p_user_id,
                       p_creation_date,
                       p_pers_id,
                       nvl(p_acc_id, l_acc_id),
                       p_entrp_id,
                       sysdate,
                       p_action );

        end if;
    end insert_notes;

    procedure break_notes (
        p_note_id in number
    ) is

        l_note_tbl varchar2_4000_tbl := varchar2_4000_tbl();
        l_date     varchar2(30);
        l_c_date   date;
        l_user_id  number := null;
        l_text     varchar2(3200);
    begin
        for x in (
            select
                *
            from
                notes
            where
                note_id = p_note_id
        ) loop
            l_note_tbl := notes_list(x.note_id);
            pc_log.log_error('BREAK_NOTES,l_note_tbl.count ', l_note_tbl.count);
            if l_note_tbl.count > 1 then
                for i in 1..l_note_tbl.count loop
                    l_c_date := null;
                    l_date := null;
                    l_user_id := null;
                    if
                        l_note_tbl(i) is not null
                        and strip_bad(l_note_tbl(i)) <> ' '
                    then
                        begin
                            if regexp_instr(
                                l_note_tbl(i),
                                '([[:digit:]]{1,2})+(\.|\-|\/)+([[:digit:]]{1,2})+(\.|\-|\/)([[:digit:]]{1,2})+\'
                            ) > 0 then
                                l_date := substr(
                                    l_note_tbl(i),
                                    regexp_instr(
                                                                     l_note_tbl(i),
                                                                     '([[:digit:]]{1,2})+(\.|\-|\/)+([[:digit:]]{1,2})+(\.|\-|\/)([[:digit:]]{1,2})+\'
                                                                     ,
                                                                     1,
                                                                     1,
                                                                     0
                                                                 ),
                                    regexp_instr(
                                                                     l_note_tbl(i),
                                                                     '([[:digit:]]{1,2})+(\.|\-|\/)+([[:digit:]]{1,2})+(\.|\-|\/)([[:digit:]]{1,2})+\'
                                                                     ,
                                                                     1,
                                                                     1,
                                                                     1
                                                                 ) - 1
                                );
                            end if;

                            l_text := substr(
                                substr(
                                    l_note_tbl(i),
                                    regexp_instr(
                                        l_note_tbl(i),
                                        '(\()$+|(\))$+'
                                    ) - 5
                                ),
                                2,
                                2
                            );

                            l_user_id := get_prefix_user_id(l_text);
                            if l_date is not null then
                                l_c_date := format_to_date(l_date);
                            end if;
                        exception
                            when others then
                                null;
                        end;

                        insert_notes(x.entity_id,
                                     x.entity_type,
                                     l_note_tbl(i),
                                     nvl(l_user_id, x.created_by),
                                     nvl(l_c_date, sysdate));

                    end if;

                end loop;
            end if;

        end loop;
    end break_notes;

    procedure generate_5498 (
        p_year in varchar2
    ) as

        f_lob          bfile := bfilename('BANK_SERV_DIR', '5498-'
                                                  || p_year
                                                  || '.csv');
        b_lob          blob;
        l_utl_id       utl_file.file_type;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_line_tbl     varchar2_4000_tbl;
        l_dest_blob    blob;
        l_source_bfile bfile := bfilename('BANK_SERV_DIR', '5498-'
                                                           || p_year
                                                           || '.csv');
        l_src_offset   number := 1;
        l_dest_offset  number := 1;
        l_src_osin     number;
        l_dst_osin     number;
    begin
        select
            '"'
            || acc_num
            || '","'
            || replace(
                nvl(b.first_name, ''),
                ','
            )
            || ' '
            || replace(
                nvl(b.middle_name, ''),
                ','
            )
            || ' '
            || replace(
                nvl(b.last_name, ''),
                ','
            )
            || '","'
            || replace(b.address, ',')
            || '","'
            || replace(b.city, ',')
            || '","'
            || b.state
            || '","'
            || b.zip
            || '","'
            || b.ssn
            || '",0,"'
            || nvl(a.curr_yr_deposit, 0)
            || '","'
            || nvl(a.prev_yr_deposit, 0)
            || '","'
            || nvl(a.rollover, 0)
            || '","'
            || nvl(a.current_bal, 0)
            || '",'
            || 'Y'
            || ','
            || pc_users.check_user_registered(
                replace(b.ssn, '-'),
                'S'
            )
        bulk collect
        into l_line_tbl
        from
            tax_forms a,
            person    b
        where
                a.pers_id = b.pers_id
            and a.tax_doc_type = '5498'
            and a.begin_date = to_date('01-JAN-' || p_year, 'DD-MON-YYYY')
            and a.end_date = to_date('31-DEC-' || p_year, 'DD-MON-YYYY')
            and a.tax_form_id in (
                select
                    max(c.tax_form_id)
                from
                    tax_forms c
                where
                        begin_date = c.begin_date
                    and end_date = c.end_date
                    and a.acc_id = c.acc_id
                    and a.tax_doc_type = c.tax_doc_type
            );

        l_utl_id := utl_file.fopen('BANK_SERV_DIR', '5498-'
                                                    || p_year
                                                    || '.csv', 'w');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => 'Account Number,Name,Address,City,State,Zip,SSN,BOX1,BOX2,BOX3,BOX4,BOX5,HSA,Online User'
        );
        for i in 1..l_line_tbl.count loop
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line_tbl(i)
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
        htp.p('Content-Disposition: attachment; filename="5498.csv"');
        owa_util.http_header_close;
        wpg_docload.download_file(l_dest_blob);
    exception
        when others then
            htp.p(sqlerrm
                  || '...'
                  || dbms_utility.format_error_backtrace);
    end generate_5498;

    procedure export_1099 (
        p_year in varchar2
    ) as

        f_lob          bfile := bfilename('BANK_SERV_DIR', '1099-'
                                                  || p_year
                                                  || '.csv');
        b_lob          blob;
        l_utl_id       utl_file.file_type;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_line_tbl     varchar2_4000_tbl;
        l_dest_blob    blob;
        l_source_bfile bfile := bfilename('BANK_SERV_DIR', '1099-'
                                                           || p_year
                                                           || '.csv');
        l_src_offset   number := 1;
        l_dest_offset  number := 1;
        l_src_osin     number;
        l_dst_osin     number;
    begin
        select
            '"'
            || acc_num
            || '","'
            || replace(
                nvl(b.first_name, ''),
                ','
            )
            || ' '
            || replace(
                nvl(b.middle_name, ''),
                ','
            )
            || ' '
            || replace(
                nvl(b.last_name, ''),
                ','
            )
            || '","'
            || replace(b.address, ',')
            || '","'
            || replace(b.city, ',')
            || '","'
            || b.state
            || '","'
            || b.zip
            || '","'
            || b.ssn
            || '","'
            || nvl(a.gross_dist, 0)
            || '","'
            || '0'
            || '","'
            || '0'
            || '",'
            || pc_users.check_user_registered(
                replace(b.ssn, '-'),
                'S'
            )
        bulk collect
        into l_line_tbl
        from
            tax_forms a,
            person    b
        where
                a.pers_id = b.pers_id
            and a.tax_doc_type = '1099'
            and a.begin_date = to_date('01-JAN-' || p_year, 'DD-MON-YYYY')
            and a.end_date = to_date('31-DEC-' || p_year, 'DD-MON-YYYY')
            and a.tax_form_id in (
                select
                    max(c.tax_form_id)
                from
                    tax_forms c
                where
                        begin_date = c.begin_date
                    and end_date = c.end_date
                    and a.acc_id = c.acc_id
                    and a.tax_doc_type = c.tax_doc_type
            );

        l_utl_id := utl_file.fopen('BANK_SERV_DIR', '1099-'
                                                    || p_year
                                                    || '.csv', 'w');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => 'Account Number,Name,Address,City,State,Zip,SSN,Gross Dist,Earn on Excess,FMV,Online User'
        );
        for i in 1..l_line_tbl.count loop
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line_tbl(i)
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
        htp.p('Content-Disposition: attachment; filename="1099.csv"');
        owa_util.http_header_close;
        wpg_docload.download_file(l_dest_blob);
    exception
        when others then
            htp.p(sqlerrm
                  || '...'
                  || dbms_utility.format_error_backtrace);
    end export_1099;

    procedure assign_pers_entrp_id (
        p_entity_id   in varchar2,
        p_entity_type in varchar2
    ) is
    begin
        update notes
        set
            acc_id = (
                select
                    acc_id
                from
                    account
                where
                    pers_id = notes.pers_id
            )
        where
            pers_id is not null
            and acc_id is null;

        update notes
        set
            entrp_id = nvl(entrp_id,
                           pc_person.get_entrp_from_pers_id(pers_id))
        where
            entrp_id is null
            and pers_id is not null
            and entity_type = 'PERSON';

        update notes
        set
            acc_id = entity_id,
            pers_id = nvl(pers_id,
                          pc_person.pers_id_from_acc_id(entity_id)),
            entrp_id = nvl(entrp_id,
                           pc_person.get_entrp_id(entity_id))
        where
                entity_type = 'ACCOUNT'
            and ( acc_id is null
                  or pers_id is null
                  or entrp_id is null )
            and entity_id = p_entity_id
            and entity_type = p_entity_type;

        update notes
        set
            entrp_id = entity_id,
            acc_id = pc_entrp.get_acc_id(notes.entity_id)
        where
                entity_type = 'ENTERPRISE'
            and entity_id = p_entity_id
            and entity_type = p_entity_type;

        update notes
        set
            entrp_id = (
                select
                    entrp_id
                from
                    employer_deposits
                where
                    employer_deposit_id = notes.entity_id
            )
        where
                entity_type = 'EMPLOYER_DEPOSITS'
            and entrp_id is null
            and entity_id = p_entity_id
            and entity_type = p_entity_type;

        update notes
        set
            acc_id = pc_entrp.get_acc_id(entrp_id)
        where
                entity_type = 'EMPLOYER_DEPOSITS'
            and acc_id is null
            and entrp_id is not null
            and entity_id = p_entity_id
            and entity_type = p_entity_type;

        update notes
        set
            acc_id = pc_entrp.get_acc_id(entrp_id)
        where
                entity_type = 'ACCOUNT'
            and ( acc_id is null
                  and entrp_id is not null
                  and pers_id is null )
            and entity_id = p_entity_id
            and entity_type in ( 'EMPLOYER_DEPOSITS', 'EMPLOYER_PAYMENTS', 'ENTERPRISE', 'ACCOUNT' );

    end assign_pers_entrp_id;

    procedure export_cms_query_file as

        b_lob          blob;
        l_utl_id       utl_file.file_type;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_line_tbl     varchar2_4000_tbl;
        l_line_count   number := 0;
        l_dest_blob    blob;
        l_src_offset   number := 1;
        l_dest_offset  number := 1;
        l_src_osin     number;
        l_dst_osin     number;
        l_rreid        varchar2(255) := '000038675';
        l_source_bfile bfile := bfilename('DEBIT_CARD_DIR',
                                          'CMS_Query_'
                                          || to_char(sysdate, 'mmddyyyyhhmiss')
                                          || '.txt');
    begin
-- followed guidelines from the link
  -- http://www.cms.gov/Medicare/Coordination-of-Benefits-and-Recovery/Mandatory-Insurer-Reporting-For-Group-Health-Plans/Downloads/New-Downloads/MMSEA-Revised-July-14-2014-GHP-User-Guide-Version-4-4.pdf

        l_utl_id := utl_file.fopen('DEBIT_CARD_DIR',
                                   'CMS_Query_'
                                   || to_char(sysdate, 'mmddyyyyhhmiss')
                                   || '.txt',
                                   'w');

        l_line := 'H0'
                  || l_rreid
                  || 'NGHQ'
                  || to_char(sysdate, 'YYYYMMDD')
                  || lpad(' ', 177, ' ');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select
                a.last_name,
                a.first_name,
                a.birth_date,
                decode(gender, 'M', '1', 'F', '2',
                       '1') gender,
                a.ssn,
                b.acc_num,
                a.pers_id
            from
                person                    a,
                account                   b,
                ben_plan_enrollment_setup c
            where
                    a.pers_id = b.pers_id
                and c.acc_id = b.acc_id
                and c.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )
                and c.annual_election >= 5000
                and c.status = 'A'
                and c.effective_date > (
                    select
                        max(creation_date)
                    from
                        medicare_pers_record
                )
                and b.account_type in ( 'FSA', 'HRA' )
                and a.ssn is not null
                and not exists (
                    select
                        *
                    from
                        medicare_pers_record c
                    where
                        c.pers_id = a.pers_id
                )
            union
            select
                a.last_name,
                a.first_name,
                a.birth_date,
                decode(gender, 'M', '1', 'F', '2',
                       '1') gender,
                a.ssn,
                b.acc_num,
                a.pers_id
            from
                person                    a,
                account                   b,
                ben_plan_enrollment_setup c
            where
                    a.pers_main = b.pers_id
                and c.acc_id = b.acc_id
                and c.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )
                and c.annual_election >= 5000
                and c.status = 'A'
                and c.effective_date > (
                    select
                        max(creation_date)
                    from
                        medicare_pers_record
                )
                and b.account_type in ( 'FSA', 'HRA' )
                and a.ssn is not null
                and not exists (
                    select
                        *
                    from
                        medicare_pers_record c
                    where
                        c.pers_id = a.pers_id
                )
        ) loop
            l_line := lpad(' ', 12, ' ')
                      || rpad(
                substr(
                    upper(x.last_name),
                    1,
                    6
                ),
                6,
                ' '
            )
                      || substr(
                upper(x.first_name),
                1,
                1
            )
                      || nvl(
                to_char(x.birth_date, 'YYYYMMDD'),
                lpad(' ', 8, ' ')
            )
                      || nvl(x.gender, '0')
                      || nvl(
                replace(x.ssn, '-'),
                lpad(' ', 9, ' ')
            )
                      || rpad(x.acc_num, 30, '+')
                      || rpad(x.pers_id, 30, '+')
                      || lpad(' ', 103, ' ');

            l_line_count := l_line_count + 1;
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := 'T0'
                  || l_rreid
                  || 'NGHQ'
                  || to_char(sysdate, 'YYYYMMDD')
                  || lpad(l_line_count, 9, '0')
                  || lpad(' ', 168, ' ');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
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
              || 'CMS_Query_'
              || to_char(sysdate, 'mmddyyyyhhmiss')
              || '.txt'
              || '"');

        owa_util.http_header_close;
        wpg_docload.download_file(l_dest_blob);
    exception
        when others then
            htp.p(sqlerrm
                  || '...'
                  || dbms_utility.format_error_backtrace);
    end export_cms_query_file;

    procedure export_cms_tin_file as

        b_lob          blob;
        l_utl_id       utl_file.file_type;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_line_tbl     varchar2_4000_tbl;
        l_line_count   number := 0;
        l_dest_blob    blob;
        l_src_offset   number := 1;
        l_dest_offset  number := 1;
        l_src_osin     number;
        l_dst_osin     number;
        l_rreid        varchar2(255) := '000038675';
        l_source_bfile bfile := bfilename('DEBIT_CARD_DIR',
                                          'CMS_TIN_'
                                          || to_char(sysdate, 'mmddyyyyhhmiss')
                                          || '.txt');
    begin
-- followed guidelines from the link
  -- http://www.cms.gov/Medicare/Coordination-of-Benefits-and-Recovery/Mandatory-Insurer-Reporting-For-Group-Health-Plans/Downloads/New-Downloads/MMSEA-Revised-July-14-2014-GHP-User-Guide-Version-4-4.pdf

        l_utl_id := utl_file.fopen('DEBIT_CARD_DIR',
                                   'CMS_TIN_'
                                   || to_char(sysdate, 'mmddyyyyhhmiss')
                                   || '.txt',
                                   'w');

        l_line := 'H0'
                  || l_rreid
                  || 'REFR'
                  || to_char(sysdate, 'YYYYMMDD')
                  || lpad(' ', 402, ' ');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select
                rpad(
                    replace(x.entrp_code, '-'),
                    9,
                    ' '
                )  -- TIN
                || rpad(x.name, 32, ' ')                    -- NAME OF ENTITY
                || rpad(x.address, 32, ' ')                 -- Address Line 1.
                || lpad(
                    nvl(x.address2, ' '),
                    32,
                    ' '
                )       -- Address Line 2.
                || rpad(x.city, 15, ' ')                    -- City
                || rpad(x.state, 2, ' ')                    -- State
                || rpad(x.zip, 9, ' ')                      -- Zip
                || 'E' line                               -- TIN indicator
            from
                (
                    select
                        c.*
                    from
                        medicare_pers_record a,
                        person               b,
                        enterprise           c
                    where
                            a.pers_id = b.pers_id
                        and b.entrp_id = c.entrp_id
                ) x
            union
            select
                rpad(
                    replace(x.entrp_code, '-'),
                    9,
                    ' '
                )
                || rpad(x.name, 32, ' ')
                || rpad(x.address, 32, ' ')
                || lpad(
                    nvl(x.address2, ' '),
                    32,
                    ' '
                )
                || rpad(x.city, 15, ' ')
                || rpad(x.state, 2, ' ')
                || rpad(x.zip, 9, ' ')
                || 'I'
            from
                enterprise x
            where
                x.entrp_id = 7647
        ) loop
            l_line := x.line;
            l_line_count := l_line_count + 1;
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := 'T0'
                  || l_rreid
                  || 'REFR'
                  || to_char(sysdate, 'YYYYMMDD')
                  || lpad(l_line_count, 9, '0')
                  || lpad(' ', 393, ' ');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
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
              || 'CMS_TIN_'
              || to_char(sysdate, 'mmddyyyyhhmiss')
              || '.txt'
              || '"');

        owa_util.http_header_close;
        wpg_docload.download_file(l_dest_blob);
    exception
        when others then
            htp.p(sqlerrm
                  || '...'
                  || dbms_utility.format_error_backtrace);
    end export_cms_tin_file;

    procedure export_cms_msp_file as

        b_lob          blob;
        l_utl_id       utl_file.file_type;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        l_line_tbl     varchar2_4000_tbl;
        l_line_count   number := 0;
        l_dest_blob    blob;
        l_src_offset   number := 1;
        l_dest_offset  number := 1;
        l_src_osin     number;
        l_dst_osin     number;
        l_rreid        varchar2(255) := '000038675';
        l_source_bfile bfile := bfilename('DEBIT_CARD_DIR',
                                          'CMS_MSP_'
                                          || to_char(sysdate, 'mmddyyyyhhmiss')
                                          || '.txt');
    begin
  -- followed guidelines from the link
  -- http://www.cms.gov/Medicare/Coordination-of-Benefits-and-Recovery/Mandatory-Insurer-Reporting-For-Group-Health-Plans/Downloads/New-Downloads/MMSEA-Revised-July-14-2014-GHP-User-Guide-Version-4-4.pdf

        l_utl_id := utl_file.fopen('DEBIT_CARD_DIR',
                                   'CMS_MSP_'
                                   || to_char(sysdate, 'mmddyyyyhhmiss')
                                   || '.txt',
                                   'w');

        l_line := 'H0'
                  || l_rreid
                  || 'MSPI'
                  || to_char(sysdate, 'YYYYMMDD')
                  || lpad(' ', 777, ' ');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select
                rpad(
                    nvl(a.hic_number, ' '),
                    12,
                    ' '
                )              -- HIC Number (12)
                || rpad(
                    substr(b.last_name, 1, 6),
                    6,
                    ' '
                )           -- Sur name (6)
                || substr(b.first_name, 1, 1)                      -- First name (1)
                || rpad(
                    nvl(
                        to_char(b.birth_date, 'YYYYMMDD'),
                        ' '
                    ),
                    8,
                    ' '
                )              -- Birth Date (8)
                || decode(b.gender, 'M', '1', 'F', '2',
                          '0')          -- Sex (1)
                || rpad(
                    nvl(a.cms_doc_crl_number, ' '),
                    15,
                    ' '
                )             -- DCN (15)
                || '0'                                           -- Transaction Type (1)
                || 'R'                                           -- Coverage Type (1)
                || rpad(
                    replace(b.ssn, '-'),
                    9,
                    ' '
                )                -- SSN (9)
                || to_char(a.effective_date, 'YYYYMMDD')          -- Effective Date (8)
                || nvl(
                    to_char(a.effective_date, 'YYYYMMDD'),
                    '00000000'
                ) -- Termination Date (8)
                || '01'                                           -- Relationship Code (2)
                || rpad(
                    substr(b.first_name, 1, 9),
                    9,
                    ' '
                )           -- Policy Holder's First Name  (9)
                || rpad(
                    substr(b.last_name, 1, 16),
                    16,
                    ' '
                )         -- Policy Holder's Last Name  (16)
                || rpad(
                    replace(b.ssn, '-'),
                    9,
                    ' '
                )                -- Policy Holder's SSN  (9)
                ||
                case
                        when pc_entrp.count_person(b.entrp_id) < 20              then
                            '0'
                        when pc_entrp.count_person(b.entrp_id) between 20 and 99 then
                            '1'
                        else
                            '2'
                end        -- Employer Size(1)
                || rpad(
                    nvl(
                        to_char(b.entrp_id),
                        ' '
                    ),
                    20,
                    ' '
                )      -- Group Policy Number(20)
                || rpad(b.pers_id, 17, ' ')                         -- Individual Policy Number(17)
                || '1'                                            -- Subscriber Only (1)
                || '1'                                            -- Employee Status (1)
                || rpad(
                    replace(
                        pc_entrp.get_tax_id(b.entrp_id),
                        '-'
                    ),
                    9,
                    ' '
                ) -- TIN (9)
                || '841637046' line                               -- TPA TIN (9)
            from
                medicare_pers_record a,
                person               b
            where
                    a.pers_id = b.pers_id
                and b.pers_main is null
            union
            select
                rpad(
                    nvl(a.hic_number, ' '),
                    12,
                    ' '
                )                       -- HIC Number (12)
                || rpad(
                    substr(b.last_name, 1, 6),
                    6,
                    ' '
                )             -- Sur name (6)
                || substr(b.first_name, 1, 1)                        -- First name (1)
                || rpad(
                    nvl(
                        to_char(b.birth_date, 'YYYYMMDD'),
                        ' '
                    ),
                    8,
                    ' '
                )                -- Birth Date (8)
                || decode(b.gender, 'M', '1', 'F', '2',
                          '0')           -- Sex (1)
                || rpad(
                    nvl(a.cms_doc_crl_number, ' '),
                    15,
                    ' '
                )               -- DCN (15)
                || '0'                                           --- Transaction Type (1)
                || 'R'                                           --- Coverage Type (1)
                || rpad(
                    nvl(
                        replace(b.ssn, '-'),
                        ' '
                    ),
                    9,
                    ' '
                )                  -- SSN (9)
                || to_char(a.effective_date, 'YYYYMMDD')           -- Effective Date (8)
                || nvl(
                    to_char(a.effective_date, 'YYYYMMDD'),
                    '00000000'
                ) -- Termination Date (8)
                || lpad(
                    nvl(b.relat_code, '04'),
                    2,
                    '0'
                )              -- Relationship Code (2)
                || rpad(
                    substr(c.first_name, 1, 9),
                    9,
                    ' '
                )            -- Policy Holder's First Name  (9)
                || rpad(
                    substr(c.last_name, 1, 16),
                    16,
                    ' '
                )          -- Policy Holder's Last Name  (16)
                || rpad(
                    nvl(
                        replace(c.ssn, '-'),
                        ' '
                    ),
                    9,
                    ' '
                )                 -- Policy Holder's SSN  (9)
                ||
                case
                        when pc_entrp.count_person(c.entrp_id) < 20              then
                            '0'
                        when pc_entrp.count_person(c.entrp_id) between 20 and 99 then
                            '1'
                        else
                            '2'
                end                      -- Employer Size(1)
                || rpad(
                    nvl(
                        to_char(c.entrp_id),
                        ' '
                    ),
                    20,
                    ' '
                )      -- Group Policy Number(20)
                || rpad(b.pers_id, 17, ' ')                          -- Individual Policy Number(17)
                || '1'                                             -- Subscriber Only (1)
                || '1'                                             -- Employee Status (1)
                || rpad(
                    replace(
                        pc_entrp.get_tax_id(c.entrp_id),
                        '-'
                    ),
                    9,
                    ' '
                ) -- TIN (9)
                || '841637046'                                      -- TPA TIN (9)
            from
                medicare_pers_record a,
                person               b,
                person               c
            where
                    a.pers_id = b.pers_id
                and b.pers_main is not null
                and b.pers_main = c.pers_id
        ) loop
            l_line := lpad(x.line, 425, ' ');
            l_line_count := l_line_count + 1;
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := 'T0'
                  || l_rreid
                  || 'REFR'
                  || to_char(sysdate, 'YYYYMMDD')
                  || lpad(l_line_count, 9, '0')
                  || lpad(' ', 393, ' ');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
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
              || 'CMS_TIN_'
              || to_char(sysdate, 'mmddyyyyhhmiss')
              || '.txt'
              || '"');

        owa_util.http_header_close;
        wpg_docload.download_file(l_dest_blob);
    exception
        when others then
            htp.p(sqlerrm
                  || '...'
                  || dbms_utility.format_error_backtrace);
    end export_cms_msp_file;

    procedure import_cms_file (
        pv_file_name in varchar2,
        p_user_id    in number
    ) as

        l_file          utl_file.file_type;
        l_buffer        raw(32767);
        l_amount        binary_integer := 32767;
        l_pos           integer := 1;
        l_blob          blob;
        l_blob_len      integer;
        exc_no_file exception;
        l_create_ddl    varchar2(32000);
        lv_dest_file    varchar2(300);
        l_sqlerrm       varchar2(32000);
        l_create_error exception;
        l_batch_number  number;
        l_valid_plan    number(10);
        l_acc_id        number(10);
        x_return_status varchar2(10);
        x_error_message varchar2(2000);
    begin
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

  /* Get the contents of BLOB from wwv_flow_files */
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            l_file := utl_file.fopen('DEBIT_CARD_DIR', pv_file_name, 'w', 32767);
            l_blob_len := dbms_lob.getlength(l_blob); -- gets file length

    -- Open / Creates the destination file.
    -- Read chunks of the BLOB and write them to the file
    -- until complete.
            while l_pos < l_blob_len loop
                dbms_lob.read(l_blob, l_amount, l_pos, l_buffer);
                utl_file.put_raw(l_file, l_buffer, true);
                l_pos := l_pos + l_amount;
            end loop;
    -- Close the file.
            utl_file.fclose(l_file);
    -- Delete file from wwv_flow_files
            delete from wwv_flow_files
            where
                name = pv_file_name;

        exception
            when others then
                null;
        end;

        begin
            execute immediate ' ALTER TABLE CMS_EXTERNAL
		location (DEBIT_CARD_DIR:'''
                              || lv_dest_file
                              || ''')';
        exception
            when others then
                l_sqlerrm := 'Error in Changing location of compliance file' || sqlerrm;
                raise l_create_error;
        end;

    end import_cms_file;

    procedure update_medicare_information is
        l_pers_id number;
    begin
        for x in (
            select
                substr(cms_record, 1, 12)   hic_number,
                substr(cms_record, 102, 14) medicare_ctrl_number,
                replace(
                    substr(cms_record, 117, 30),
                    '+'
                )                           acc_num,
                replace(
                    substr(cms_record, 147, 30),
                    '+'
                )                           pers_id,
                substr(cms_record, 100, 2)  medicare_flag,
                substr(cms_record, 29, 9)   ssn
            from
                cms_external
            where
                trim(substr(cms_record, 1, 12)) is not null
                and substr(cms_record, 100, 2) = '01'
        ) loop
            l_pers_id := null;
            update medicare_pers_record
            set
                hic_number = x.hic_number,
                effective_date = sysdate,
                cms_doc_crl_number = x.medicare_ctrl_number,
                last_update_date = sysdate
            where
                pers_id = x.pers_id
            returning pers_id into l_pers_id;

            if l_pers_id is null then
                insert into medicare_pers_record (
                    pers_id,
                    hic_number,
                    cms_doc_crl_number,
                    effective_date,
                    creation_date,
                    last_update_date,
                    acc_num,
                    ssn
                ) values ( x.pers_id,
                           x.hic_number,
                           x.medicare_ctrl_number,
                           sysdate,
                           sysdate,
                           sysdate,
                           x.acc_num,
                           format_ssn(x.ssn) );

            end if;

        end loop;

        for x in (
            select
                substr(cms_record, 1, 12)   hic_number,
                substr(cms_record, 102, 14) medicare_ctrl_number,
                replace(
                    substr(cms_record, 117, 30),
                    '+'
                )                           acc_num,
                replace(
                    substr(cms_record, 147, 30),
                    '+'
                )                           pers_id,
                substr(cms_record, 100, 2)  medicare_flag
            from
                cms_external
            where
                trim(substr(cms_record, 1, 12)) is not null
                and substr(cms_record, 100, 2) = '51'
        ) loop
            update medicare_pers_record
            set
                effective_end_date = sysdate,
                cms_doc_crl_number = x.medicare_ctrl_number,
                last_update_date = sysdate
            where
                pers_id = x.pers_id;

        end loop;

        update_plan_dates_cms;
    end update_medicare_information;

    procedure update_plan_dates_cms is
    begin
        for x in (
            select
                a.acc_num,
                max(c.effective_date)     effective_date,
                max(c.effective_end_date) effective_end_date
            from
                medicare_pers_record      a,
                account                   b,
                ben_plan_enrollment_setup c
            where
                    a.acc_num = b.acc_num
                and b.acc_id = c.acc_id
                and c.product_type = 'HRA'
            group by
                a.acc_num
        ) loop
            update medicare_pers_record
            set
                effective_date = x.effective_date,
                effective_end_date = x.effective_end_date
            where
                acc_num = x.acc_num;

        end loop;

        update medicare_pers_record a
        set
            entrp_id = (
                select
                    b.entrp_id
                from
                    account c,
                    person  b
                where
                        a.acc_num = c.acc_num
                    and b.pers_id = c.pers_id
            )
        where
            entrp_id is null;

        update medicare_pers_record a
        set
            ein = (
                select
                    replace(entrp_code, '-')
                from
                    enterprise b
                where
                    a.entrp_id = b.entrp_id
            )
        where
            ein is null;

    end;

    procedure update_tin_result is
        l_pers_id    number;
        l_line_count number := 0;
    begin
        for x in (
            select
                substr(cms_record, 559, 2)     tin_result_code,
                trim(substr(cms_record, 1, 9)) ein,
                cms_record                     line
            from
                cms_external
            where
                trim(substr(cms_record, 1, 9)) is not null
        ) loop
            l_pers_id := null;
            l_line_count := l_line_count + 1;
            if
                l_line_count = 1
                and x.line not like 'H0000038675TGRP%'
            then
                raise_application_error('-20001', 'Not a valid TIN response file');
            end if;

            update medicare_pers_record
            set
                tin_result_code = x.tin_result_code
            where
                ein = x.ein;

        end loop;
    exception
        when others then
            raise;
    end update_tin_result;

    procedure update_msp_result is
        l_pers_id    number;
        l_line_count number := 0;
    begin
        for x in (
            select
                trim(substr(cms_record, 5, 9))    hic_number,
                trim(substr(cms_record, 51, 1))   medicare_reason,
                trim(substr(cms_record, 184, 8))  msp_effective_date,
                trim(substr(cms_record, 192, 8))  msp_termination_date,
                trim(substr(cms_record, 381, 17)) pers_id,
                trim(substr(cms_record, 454, 8))  medicare_eff_date,
                trim(substr(cms_record, 462, 8))  medicare_term_date,
                trim(substr(cms_record, 485, 8))  medicare_a_eff_date,
                trim(substr(cms_record, 493, 8))  medicare_a_term_date,
                trim(substr(cms_record, 501, 8))  medicare_b_eff_date,
                trim(substr(cms_record, 509, 8))  medicare_b_term_date,
                trim(substr(cms_record, 517, 8))  date_of_death,
                trim(substr(cms_record, 530, 8))  medicare_c_eff_date,
                trim(substr(cms_record, 538, 8))  medicare_c_term_date,
                trim(substr(cms_record, 551, 8))  medicare_d_eff_date,
                trim(substr(cms_record, 559, 8))  medicare_d_term_date,
                trim(substr(cms_record, 567, 8))  medicare_d_elig_s_date,
                trim(substr(cms_record, 575, 8))  medicare_d_elig_t_date,
                cms_record                        line
            from
                cms_external
        ) loop
            l_line_count := l_line_count + 1;
            if
                l_line_count = 1
                and x.line not like 'H0000038675MSPR%'
            then
                raise_application_error('-20001', 'Not a valid MSP response file');
            end if;

            l_pers_id := null;
            update medicare_pers_record
            set
                msp_effective_date = x.msp_effective_date,
                msp_termination_date = x.msp_termination_date,
                medicare_reason = x.medicare_reason,
                medicare_eff_date = x.medicare_eff_date,
                medicare_term_date = x.medicare_term_date,
                medicare_a_eff_date = x.medicare_a_eff_date,
                medicare_a_term_date = x.medicare_a_term_date,
                medicare_b_eff_date = x.medicare_b_eff_date,
                medicare_b_term_date = x.medicare_b_term_date,
                date_of_death = x.date_of_death,
                medicare_c_eff_date = x.medicare_c_eff_date,
                medicare_c_term_date = x.medicare_c_term_date,
                medicare_d_eff_date = x.medicare_d_eff_date,
                medicare_d_term_date = x.medicare_d_term_date,
                medicare_d_elig_s_date = x.medicare_d_elig_s_date,
                medicare_d_elig_t_date = x.medicare_d_elig_t_date
            where
                pers_id = x.pers_id;

        end loop;
    exception
        when others then
            raise;
    end update_msp_result;

    procedure generate_file (
        p_file_name    in varchar2,
        p_sql          in varchar2,
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
        gen_xl_xml.create_excel('MAILER_DIR', p_file_name);
        gen_xl_xml.set_header;

  --  dbms_output.put_line(' writing the headers');
        l_sql := p_sql || ' AND 1 = 2';
        gen_xl_xml.print_table(l_sql, l_col_tbl, l_col_value_tbl);
        for i in 1..l_col_tbl.count loop
            x := x + 1;
	    -- gen_xl_xml.write_cell_char( i,i, 'sheet1', l_col_tbl(i) ,'sgs1' );
            gen_xl_xml.write_cell_char(1,
                                       i,
                                       'sheet1',
                                       l_col_tbl(i),
                                       'sgs1');
       --dbms_output.put_line(' writing the headers for '||i || 'of '||l_col_tbl.COUNT);

        end loop;

        gen_xl_xml.print_table(p_sql, l_col_tbl, l_col_value_tbl);
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
       --  dbms_output.put_line('Processing '||i||' Row '||x||'column '||ii);
	    -- gen_xl_xml.write_cell_char( i,i, 'sheet1', l_col_tbl(i) ,'sgs1' );
            gen_xl_xml.write_cell_char(x,
                                       ii,
                                       'sheet1',
                                       l_col_value_tbl(i),
                                       'sgs2');
        end loop;

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
   --  IF l_col_value_tbl.COUNT > 0 THEN

        pc_notifications.insert_reports(p_report_title, '/home/oracle/mailer/', p_file_name, null, l_html_message);
   --- END IF;
    end generate_file;

 -- code added by Joshi for sam upgrade

    function get_ticket_info (
        p_entity_type varchar2,
        p_acct_type   varchar2,
        p_where_val1  number
    ) return ticker_tbl
        pipelined
        deterministic
    as

        v_ticker       ticker_rec;
        v_sql_cur      l_cursor;
        v_where_value1 number;
        v_where_value2 number;
        v_row_count    number;
        v_pers_main    number;
        v_acc_id       number;
        v_acct_type    varchar2(15);
    begin
        v_where_value1 := p_where_val1;
  /* ticker for Employer */

        if p_entity_type = 'E' then
            select
                acc_id
            into v_acc_id
            from
                account
            where
                entrp_id = p_where_val1;

            begin
                for x in (
                    select
                        seq_no,
                        label_name,
                        target_page,
                        setup_query
                    from
                        ticker_setup
                    where
                            account_type = p_acct_type
                        and entity_type = 'E'
                    order by
                        seq_no
                ) loop
                    if upper(x.label_name) = 'BANK ACCOUNT'
                    or upper(x.label_name) = 'DISCOUNTS' then -- Discounts Added by jaggi #10845
                        v_where_value1 := v_acc_id;
                    elsif upper(x.label_name) = 'COVERAGE TIER' then
                        v_where_value1 := v_acc_id;
                        v_where_value2 := p_where_val1;
                    else
                        v_where_value1 := p_where_val1;
                    end if;

                    pc_log.log_error('GET_TICKET_INFO - ' || x.label_name, 'V_WHERE_VALUE1: ' || v_where_value1);
                    pc_log.log_error('GET_TICKET_INFO- ' || x.label_name, 'V_WHERE_VALUE2: ' || v_where_value2);
                    if upper(x.label_name) = 'COVERAGE TIER' then
                        open v_sql_cur for x.setup_query
                            using v_where_value1, v_where_value2;

                    else
                        open v_sql_cur for x.setup_query
                            using v_where_value1;

                    end if;

                    fetch v_sql_cur into v_row_count;
                    close v_sql_cur;
                    pc_log.log_error('GET_TICKET_INFO', x.setup_query
                                                        || '-'
                                                        || v_row_count);
                    v_ticker.lvl := null;
                    v_ticker.label_name := x.label_name;
                    v_ticker.target_page_link := 'f?p='
                                                 || v('APP_ID')
                                                 || ':'
                                                 || x.target_page
                                                 || ':'
                                                 || v('APP_SESSION');

                    v_ticker.is_current_list_entry := 'NO';
                    if v_row_count > 0 then
                        v_ticker.icon := 'fa-check icon-green';
                    else
                        v_ticker.icon := 'fa-times icon-red';
                    end if;

                    pipe row ( v_ticker );
                end loop;

            exception
                when invalid_cursor then
                    pipe row ( v_ticker );
            end;

        else
       /* ticker for subscriber */

            begin
                select
                    acc_id,
                    pers_main,
                    account_type
                into
                    v_acc_id,
                    v_pers_main,
                    v_acct_type
                from
                    account,
                    person
                where
                        account.pers_id (+) = person.pers_id
                    and person.pers_id = p_where_val1;

            exception
                when no_data_found then
                    v_where_value1 := null;
                    v_pers_main := null;
            end;

            for x in (
                select
                    label_name,
                    target_page,
                    setup_query
                from
                    ticker_setup
                where
                    entity_type = 'S'
                order by
                    seq_no
            ) loop

        -- Below If Cond. Added by Swamy for Ticket#9912(10231) on 23/08/2021
                if
                    v_acct_type = 'LSA'
                    and ( upper(x.label_name) = upper('Outside Investment')
                    or upper(x.label_name) = upper('Benefit Plans')
                    or upper(x.label_name) = upper('Beneficiary')
                    or upper(x.label_name) = upper('Dependent') )
                then
                    continue;
                end if;
        --
        --5408:joshi: added disbursement and receipts
                if upper(x.label_name) = 'PAYMENT'
                or upper(x.label_name) = 'BENEFIT PLANS'
                or upper(x.label_name) = 'RECEIPTS' then
                    v_where_value1 := v_acc_id;
                else
                    v_where_value1 := p_where_val1;
                end if;

                open v_sql_cur for x.setup_query
                    using v_where_value1;

                fetch v_sql_cur into v_row_count;
                close v_sql_cur;

        --pc_log.log_error('GET_TICKET_INFO',SQLERRM );
       -- pc_log.log_error('GET_TICKET_INFO',x.SETUP_QUERY|| '-'|| V_ROW_COUNT);

                v_ticker.lvl := null;
                if (
                    v_pers_main is not null
                    and upper(x.label_name) = 'BENEFIT PLANS'
                )
                or (
                    upper(x.label_name) = 'BENEFIT PLANS'
                    and v_acct_type = 'HSA'
                )
                or (
                    upper(x.label_name) = upper('Outside Investment')
                    and v_acct_type <> 'HSA'
                ) then
                    v_ticker.label_name := null;
                    v_ticker.target_page_link := null;
                    v_ticker.is_current_list_entry := null;
                    v_ticker.icon := null;
                else
                    v_ticker.label_name := x.label_name;
                    v_ticker.target_page_link := 'f?p='
                                                 || v('APP_ID')
                                                 || ':'
                                                 || x.target_page
                                                 || ':'
                                                 || v('APP_SESSION');

                    v_ticker.is_current_list_entry := 'NO';
                    if v_row_count > 0 then
                        v_ticker.icon := 'fa-check icon-green';
                    else
                        v_ticker.icon := 'fa-times icon-red';
                    end if;

                end if;

                pipe row ( v_ticker );
            end loop;

        end if;

    end get_ticket_info;

    function get_notes (
        p_page_no number
    ) return notes_tbl
        pipelined
        deterministic
    as

        v_notes         notes_rec;
        v_entity_type   varchar2(255);
        v_argument_name varchar2(100);
        v_where_clause  varchar2(1000);
        v_sql           varchar2(4000);
        note_cur        sys_refcursor;
        v_arg_value     number;
    begin
        select
            entity_type,
            argument_name
        into
            v_entity_type,
            v_argument_name
        from
            note_setup
        where
            page_no = p_page_no;

        if v_argument_name = 'APP_ENTRP_ID' then
            v_arg_value := v('APP_ENTRP_ID');
            v_where_clause := ' AND ENTRP_ID = '
                              || v_arg_value
                              || ' AND ENTITY_TYPE = '''
                              || v_entity_type
                              || '''';
        else
            v_arg_value := v('APP_PERS_ID');
        -- V_WHERE_CLAUSE  :=  ' AND PERS_ID = ' ||' V('''|| V_ARGUMENT_NAME ||''')' || ' AND ENTITY_TYPE = '''||V_ENTITY_TYPE ||'''' ;
            v_where_clause := ' AND PERS_ID = '
                              || v_arg_value
                              || ' AND ENTITY_TYPE = '''
                              || v_entity_type
                              || '''';
        end if;
 --ENTITY_TYPE = '|| V_ENTITY_TYPE ||'

        if p_page_no = 273 then
            v_sql := 'SELECT  A.NOTE_ID, A.ENTITY_TYPE,nulL AS DESCRIPTION, A.ENTERED_DATE, A.CREATED_BY,A.ENTITY_ID '
                     || ' FROM    NOTES A, BEN_PLAN_ENROLLMENT_SETUP B WHERE   A.ENTITY_TYPE = ''BEN_PLAN_ENROLLMENT_SETUP'''
                     || ' AND     A.ENTITY_ID = TO_CHAR(B.BEN_PLAN_ID) AND A.PERS_ID = '
                     || v_arg_value;
        else
            v_sql := 'SELECT NOTE_ID,ENTITY_TYPE,SUBSTR(DESCRIPTION,1,250)AS DESCRIPTION, ENTERED_DATE, CREATED_BY,ENTITY_ID' || ' FROM  NOTES WHERE ENTITY_TYPE NOT IN (''BEN_PLAN_ENROLLMENT_SETUP'',''ER_BEN_PLAN_ENROLLMENT_SETUP'') '
            ;
    --V_WHERE_CLAUSE  :=  ' AND pers_id = 379072 and ENTITY_TYPE = ''PERSON''';
            v_sql := v_sql
                     || v_where_clause
                     || ' ORDER BY  ENTERED_DATE DESC';
    --|| ' ORDER BY ENTERED_DATE DESC ' ;
        end if;

        pc_log.log_error('GET_NOTES', v_sql);
        note_cur := get_cursor(v_sql);
        loop
            fetch note_cur into v_notes;
            exit when note_cur%notfound;
            pipe row ( v_notes );
        end loop;

        close note_cur;
    end get_notes;

    function get_crm_cases (
        p_acc_num varchar2
    ) return case_tbl
        pipelined
        deterministic
    as
        v_case_rec case_rec;
        v_sql      varchar2(4000);
        case_cur   sys_refcursor;
    begin
        v_sql := 'select cs."case_number", cs."name",null as "description", cs."date_entered", cs."date_modified"'
                 || ' , cs."status", cs."resolution",cs."assigned_user_id" from  "cases"@SUGARPROD cs '
                 || ' , "accounts"@SUGARPROD acct  , "accounts_cstm"@SUGARPROD accs where  acct."id" = cs."account_id" '
                 || ' and    accs."id_c" = acct."id" and    accs."acc_num_c" = '
                 || ''''
                 || p_acc_num
                 || '''';

        pc_log.log_error('GET_CRM_CASES', v_sql);
        case_cur := get_cursor(v_sql);
        loop
            fetch case_cur into v_case_rec;
            v_case_rec.assigned_user := get_assigned_uname(v_case_rec.assigned_user);
            exit when case_cur%notfound;
            pipe row ( v_case_rec );
        end loop;

    end get_crm_cases;
-- code ends here Joshi for sam upgrade

--   Added for the Ticket #6326 ( Sprint Cycle 8: DEMO- Can we have piyush run this nightly script)
---  'PARADMIN', 'DEMOADMIN' , 'ERFSADEMO ' ,  'ERHRADEMO', 'EMPLOYEEDEMO', 'DEMOEE' users renewal records are to be  deleted.
--  Changed as only renewals records are getting deleted this procedure,Instead of all records where enrollment records also got  deleted.

    procedure delete_demo_renewals is
    begin
        for i in (
            select
                user_id
            from
                online_users
            where
                upper(user_name) in ( 'PARADMIN', 'DEMOADMIN', 'ERFSADEMO', 'ERHRADEMO', 'EMPLOYEEDEMO',
                                      'DEMOEE' )
        ) loop
            for j in (
                select
                    renewed_plan_id
                from
                    ben_plan_renewals
                where
                        created_by = i.user_id
                    and ( trunc(creation_date) >= trunc(sysdate - 1)
                          or trunc(last_updated_date) >= trunc(sysdate - 1) )
            )  ---Last_updated_date added by rprabu on 18/12/2018
             loop
                delete ben_plan_enrollment_setup
                where
                        ben_plan_id = j.renewed_plan_id
                    and created_by = i.user_id
                    and ( trunc(creation_date) >= trunc(sysdate - 1)
                          or trunc(last_update_date) >= trunc(sysdate - 1) );     ---Last_updated_date added by rprabu on 18/12/2018
            end loop;

            delete ben_plan_renewals
            where
                    created_by = i.user_id
                and ( trunc(creation_date) >= trunc(sysdate - 1)
                      or trunc(last_updated_date) >= trunc(sysdate - 1) );   --Last_updated_date added by rprabu on 18/12/2018
        end loop;
    end;

end pc_utility;
/


-- sqlcl_snapshot {"hash":"4739dab6a74bd5b8fc2c152e2c1606ff5cccc4d4","type":"PACKAGE_BODY","name":"PC_UTILITY","schemaName":"SAMQA","sxml":""}