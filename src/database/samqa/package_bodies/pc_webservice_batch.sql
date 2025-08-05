create or replace package body samqa.pc_webservice_batch as

   -- Procedure to generate
   -- files for veratad id checks
   --
    procedure generate_ofac_batch (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id     utl_file.file_type;
        l_file_name  varchar2(3200);
        l_line       varchar2(32000);
        l_person_tbl person_tab;
        l_sqlerrm    varchar2(32000);
        l_file_id    number;
        l_message    varchar2(32000);
        mass_card_create exception;
        no_card_create exception;
        l_conn       utl_tcp.connection;
    begin

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

      /*  SELECT  '"'||b.first_name||'"'  first_name
         ,  '"'||b.middle_name||'"'  middle_name
         ,  '"'||b.last_name||'"'  last_name
         ,  '"'||b.address||'"'  address
         ,  '"'||b.city||'"'  city
         ,  '"'||b.state||'"'  state
         ,  '"'||b.zip||'"' zip
         ,  c.acc_num
        -- ,  to_char(b.birth_date,'MM/DD/YYYY') birth_date
        -- ,  'MM/DD/YYYY' date_type
       --  ,  SSN
       BULK COLLECT INTO   l_person_tbl
       FROM  person b , account c
       WHERE c.PERS_ID = B.PERS_ID
       AND   c.account_status <> 4;*/

--   just send negative results only

        select
            '"'
            || first_name
            || '"' first_name,
            '"'
            || middle_name
            || '"' middle_name,
            '"'
            || last_name
            || '"' last_name,
            '"'
            || address
            || '"' address,
            '"'
            || city
            || '"' city,
            '"'
            || state
            || '"' state,
            '"'
            || zip
            || '"' zip,
            '"'
            || b.acc_num
            || '"'
        -- ,  to_char(b.birth_date,'MM/DD/YYYY') birth_date
        -- ,  'MM/DD/YYYY' date_type
       --  ,  SSN
        bulk collect
        into l_person_tbl
        from
            person  a,
            account b
        where
                a.pers_id = b.pers_id
            and b.account_status <> 4
            and b.account_type = 'HSA'
            and b.complete_flag = 1
      /* and   rownum < 20
       AND   NOT EXISTS ( SELECT * FROM fraud_verifications C
                          WHERE OFAC_TEXT = 'negative'
			                    AND   C.ACC_ID = B.ACC_ID)*/;

        if l_person_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := pc_file_upload.insert_file_seq('OFAC_BATCH');
                l_file_name := 'VT_'
                               || l_file_id
                               || '_person.txt';
            else
                l_file_name := p_file_name;
            end if;

            update external_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('EOB_OUT_DIR', l_file_name, 'w');
            --  l_utl_id := utl_file.fopen( 'VERATAD_OUTBOUND', l_file_name, 'w' );

        end if;

        l_line := null;
        for i in 1..l_person_tbl.count loop
            l_line := l_person_tbl(i).first_name      -- First Name
                      || ','
                      || l_person_tbl(i).middle_name     -- Middle Name
                      || ','
                      || l_person_tbl(i).last_name       -- Last Name
                      || ','
                      || l_person_tbl(i).address         -- Address
                      || ','
                      || l_person_tbl(i).city            -- City
                      || ','
                      || l_person_tbl(i).state           -- State
                      || ','
                      || l_person_tbl(i).zip             -- Zip
                      || ','
                      || l_person_tbl(i).acc_num         -- Account Number
           -- ||','||l_person_tbl(i).birth_date      -- Birth Date
          --  ||','||l_person_tbl(i).date_type        -- DOB type
           -- ||','||l_person_tbl(i).ssn
                      ;             -- SSN

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            l_conn := ftp.login('172.24.16.119', '22', 'ftp_admin', 'SterlinGFtP2@!2admIn');
            ftp.binary(p_conn => l_conn);
            ftp.put(
                p_conn      => l_conn,
                p_from_dir  => 'EOB_OUT_DIR',
                p_from_file => l_file_name,
                p_to_file   => '/FILES/OUT/VERATAD/' || l_file_name
            );

            ftp.logout(l_conn);
            p_file_name := l_file_name;
        end if;

    exception
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating OFAC batch File'
            , l_sqlerrm);
    end generate_ofac_batch;

    procedure generate_ssn_batch (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(32000);
        l_ssn_tbl   ssn_tab;
        l_sqlerrm   varchar2(32000);
        l_file_id   number;
        l_message   varchar2(32000);
        mass_card_create exception;
        no_card_create exception;
        l_conn      utl_tcp.connection;
    begin


--   just send negative results only
        select
            rownum                              rn,
            '"'
            || b.acc_num
            || '"',
            '"'
            || b.enrollment_source
            || '"',
            '"'
            || first_name
            || '"'                              first_name,
            '"'
            || middle_name
            || '"'                              middle_name,
            '"'
            || last_name
            || '"'                              last_name,
            '"'
            || address
            || '"'                              address,
            '"'
            || city
            || '"'                              city,
            '"'
            || state
            || '"'                              state,
            '"'
            || zip
            || '"'                              zip,
            to_char(a.birth_date, 'MM/DD/YYYY') birth_date,
            'MM/DD/YYYY'                        date_type,
            replace(ssn, '-')
        bulk collect
        into l_ssn_tbl
        from
            person  a,
            account b
        where
                a.pers_id = b.pers_id
            and b.account_type = 'HSA'
            and b.account_status = 3
            and b.complete_flag = 1
  --     AND   nvl(b.blocked_flag,'N') = 'N'
   --    AND   trunc(b.creation_date) = trunc(sysdate)
            and nvl(b.id_verified, 'N') = 'N';
    /*   AND   NOT EXISTS ( SELECT * FROM fraud_verifications C
                          WHERE OFAC_TEXT = 'negative'
			                    AND   C.ACC_ID = B.ACC_ID)*/

        if l_ssn_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := pc_file_upload.insert_file_seq('SSN_BATCH');
                l_file_name := 'VT_'
                               || l_file_id
                               || '_ssn.txt';
            else
                l_file_name := p_file_name;
            end if;

            update external_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('WEBSERVICE_DIR', l_file_name, 'w');
            --  l_utl_id := utl_file.fopen( 'VERATAD_OUTBOUND', l_file_name, 'w' );

        end if;

        l_line := null;
        for i in 1..l_ssn_tbl.count loop
            l_line := l_ssn_tbl(i).rn
                      || ','
                      || l_ssn_tbl(i).acc_num
                      || ','
                      || l_ssn_tbl(i).source_system
                      || ','
                      || l_ssn_tbl(i).first_name      -- First Name
                      || ','
                      || l_ssn_tbl(i).middle_name     -- Middle Name
                      || ','
                      || l_ssn_tbl(i).last_name       -- Last Name
                      || ','
                      || l_ssn_tbl(i).address         -- Address
                      || ','
                      || l_ssn_tbl(i).city            -- City
                      || ','
                      || l_ssn_tbl(i).state           -- State
                      || ','
                      || l_ssn_tbl(i).zip             -- Zip
                      || ','
                      || l_ssn_tbl(i).birth_date      -- Birth Date
                      || ','
                      || l_ssn_tbl(i).date_type        -- DOB type
                      || ','
                      || l_ssn_tbl(i).ssn;             -- SSN

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            l_conn := ftp.login('172.24.16.119', '22', 'ftp_admin', 'SterlinGFtP2@!2admIn');
            ftp.binary(p_conn => l_conn);
            ftp.put(
                p_conn      => l_conn,
                p_from_dir  => 'WEBSERVICE_DIR',
                p_from_file => l_file_name,
                p_to_file   => '/FILES/OUT/VERATAD/' || l_file_name
            );

            ftp.logout(l_conn);
            p_file_name := l_file_name;
        end if;

    exception
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating SSN batch File'
            , l_sqlerrm);
    end generate_ssn_batch;

    procedure generate_ssn_batch is

        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(32000);
        l_ssn_tbl   ssn_tab;
        l_sqlerrm   varchar2(32000);
        l_file_id   number;
        l_message   varchar2(32000);
        mass_card_create exception;
        no_card_create exception;
        l_conn      utl_tcp.connection;
    begin


--   just send negative results only
        select
            rownum                              rn,
            '"'
            || b.acc_num
            || '"',
            '"'
            || b.enrollment_source
            || '"',
            '"'
            || first_name
            || '"'                              first_name,
            '"'
            || middle_name
            || '"'                              middle_name,
            '"'
            || last_name
            || '"'                              last_name,
            '"'
            || address
            || '"'                              address,
            '"'
            || city
            || '"'                              city,
            '"'
            || state
            || '"'                              state,
            '"'
            || zip
            || '"'                              zip,
            to_char(a.birth_date, 'MM/DD/YYYY') birth_date,
            'MM/DD/YYYY'                        date_type,
            replace(ssn, '-')
        bulk collect
        into l_ssn_tbl
        from
            person  a,
            account b
        where
                a.pers_id = b.pers_id
            and b.account_type = 'HSA'
            and b.account_status = 3
            and b.complete_flag = 1
  --     AND   nvl(b.blocked_flag,'N') = 'N'
   --    AND   trunc(b.creation_date) = trunc(sysdate)
            and nvl(b.id_verified, 'N') = 'N';
    /*   AND   NOT EXISTS ( SELECT * FROM fraud_verifications C
                          WHERE OFAC_TEXT = 'negative'
			                    AND   C.ACC_ID = B.ACC_ID)*/

        if l_ssn_tbl.count > 0 then
            l_file_id := pc_file_upload.insert_file_seq('SSN_BATCH');
            l_file_name := 'VT_'
                           || l_file_id
                           || '_ssn.txt';
            update external_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('WEBSERVICE_DIR', l_file_name, 'w');
            --  l_utl_id := utl_file.fopen( 'VERATAD_OUTBOUND', l_file_name, 'w' );

        end if;

        l_line := null;
        for i in 1..l_ssn_tbl.count loop
            l_line := l_ssn_tbl(i).rn
                      || ','
                      || l_ssn_tbl(i).acc_num
                      || ','
                      || l_ssn_tbl(i).source_system
                      || ','
                      || l_ssn_tbl(i).first_name      -- First Name
                      || ','
                      || l_ssn_tbl(i).middle_name     -- Middle Name
                      || ','
                      || l_ssn_tbl(i).last_name       -- Last Name
                      || ','
                      || l_ssn_tbl(i).address         -- Address
                      || ','
                      || l_ssn_tbl(i).city            -- City
                      || ','
                      || l_ssn_tbl(i).state           -- State
                      || ','
                      || l_ssn_tbl(i).zip             -- Zip
                      || ','
                      || l_ssn_tbl(i).birth_date      -- Birth Date
                      || ','
                      || l_ssn_tbl(i).date_type        -- DOB type
                      || ','
                      || l_ssn_tbl(i).ssn;             -- SSN

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            l_conn := ftp.login('172.24.16.119', '22', 'ftp_admin', 'SterlinGFtP2@!2admIn');
            ftp.binary(p_conn => l_conn);
            ftp.put(
                p_conn      => l_conn,
                p_from_dir  => 'WEBSERVICE_DIR',
                p_from_file => l_file_name,
                p_to_file   => '/edi/veratad/out/' || l_file_name
            );

            ftp.logout(l_conn);
        end if;

    exception
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating SSN batch File'
            , l_sqlerrm);
    end generate_ssn_batch;

    procedure generate_review_batch is

        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(32000);
        l_ssn_tbl   ssn_tab;
        l_sqlerrm   varchar2(32000);
        l_file_id   number;
        l_message   varchar2(32000);
        mass_card_create exception;
        no_card_create exception;
        l_conn      utl_tcp.connection;
    begin


--   just send negative results only
        select
            rownum                              rn,
            '"'
            || b.acc_num
            || '"',
            '"'
            || b.enrollment_source
            || '"',
            '"'
            || first_name
            || '"'                              first_name,
            '"'
            || middle_name
            || '"'                              middle_name,
            '"'
            || last_name
            || '"'                              last_name,
            '"'
            || address
            || '"'                              address,
            '"'
            || city
            || '"'                              city,
            '"'
            || state
            || '"'                              state,
            '"'
            || zip
            || '"'                              zip,
            to_char(a.birth_date, 'MM/DD/YYYY') birth_date,
            'MM/DD/YYYY'                        date_type,
            replace(ssn, '-')
        bulk collect
        into l_ssn_tbl
        from
            person  a,
            account b
        where
                a.pers_id = b.pers_id
            and b.account_type = 'HSA'
            and b.account_status = 3
            and b.complete_flag = 1
  --     AND   nvl(b.blocked_flag,'N') = 'N'
            and trunc(b.creation_date) < trunc(sysdate)
            and nvl(b.id_verified, 'N') = 'N';
    /*   AND   NOT EXISTS ( SELECT * FROM fraud_verifications C
                          WHERE OFAC_TEXT = 'negative'
			                    AND   C.ACC_ID = B.ACC_ID)*/

        if l_ssn_tbl.count > 0 then
            l_file_id := pc_file_upload.insert_file_seq('SSN_BATCH');
            l_file_name := 'VT_'
                           || l_file_id
                           || '_ssn.review';
            update external_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('WEBSERVICE_DIR', l_file_name, 'w');
            --  l_utl_id := utl_file.fopen( 'VERATAD_OUTBOUND', l_file_name, 'w' );

        end if;

        l_line := null;
        for i in 1..l_ssn_tbl.count loop
            l_line := l_ssn_tbl(i).rn
                      || ','
                      || l_ssn_tbl(i).acc_num
                      || ','
                      || l_ssn_tbl(i).source_system
                      || ','
                      || l_ssn_tbl(i).first_name      -- First Name
                      || ','
                      || l_ssn_tbl(i).middle_name     -- Middle Name
                      || ','
                      || l_ssn_tbl(i).last_name       -- Last Name
                      || ','
                      || l_ssn_tbl(i).address         -- Address
                      || ','
                      || l_ssn_tbl(i).city            -- City
                      || ','
                      || l_ssn_tbl(i).state           -- State
                      || ','
                      || l_ssn_tbl(i).zip             -- Zip
                      || ','
                      || l_ssn_tbl(i).birth_date      -- Birth Date
                      || ','
                      || l_ssn_tbl(i).date_type        -- DOB type
                      || ','
                      || l_ssn_tbl(i).ssn;             -- SSN

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            l_conn := ftp.login('216.109.157.41', '21', 'ftpadmin', 'SterlinGFtP2@!2admIn');
            ftp.binary(p_conn => l_conn);
            ftp.put(
                p_conn      => l_conn,
                p_from_dir  => 'WEBSERVICE_DIR',
                p_from_file => l_file_name,
                p_to_file   => '/FILES/OUT/VERATAD/' || l_file_name
            );

            ftp.logout(l_conn);
        end if;

    exception
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating SSN batch File'
            , l_sqlerrm);
    end generate_review_batch;

    procedure process_ofac_batch (
        p_file_name     in out varchar2,
        x_error_message out varchar2
    ) is
        l_sql     varchar2(32000);
        l_sqlerrm varchar2(32000);
        l_create_error exception;
    begin
        if p_file_name is null then
            p_file_name := pc_file_upload.get_file_seq('OFAC_BATCH');
        end if;
        l_sql := 'ALTER TABLE VERATAD_OFAC_EXTERNAL LOCATION (VERATAD_INBOUND:'''
                 || p_file_name
                 || ''')';
        dbms_output.put_line('l_sql ' || l_sql);
        begin
            execute immediate l_sql;
        exception
            when others then
                dbms_output.put_line('Error message ' || sqlerrm);
                rollback;
                x_error_message := 'Error when altering VERATAD_EXTERNAL table ' || sqlerrm;
                dbms_output.put_line('Error message ' || sqlerrm);
       /** send email alert as soon as it fails **/
              /*  mail_utility.send_email('metavante@sterlingadministration.com'
                   ,'vanitha.subramanyam@sterlingadministration.com'
                   ,'Error in creating VERATAD_EXTERNAL file'
                   ,l_sqlerrm);*/
                raise l_create_error;
        end;

              -- All the negative results are sent back
        for x in (
            select
                transaction_id,
                ofac_text,
                verification_date,
                ofac_code,
                ofacreference,
                acc_num
            from
                veratad_ofac_external b
            where
                exists (
                    select
                        *
                    from
                        fraud_verifications c
                    where
                        c.acc_num = b.acc_num
                )
        ) loop
            update fraud_verifications
            set
                ofac_text = x.ofac_text,
                verification_date = x.verification_date,
                ofac_code = x.ofac_code,
                ofacreference = x.ofacreference,
                transaction_id = x.transaction_id,
                last_update_date = sysdate,
                last_updated_by = 0
            where
                acc_num = x.acc_num;

        end loop;

        dbms_output.put_line('Sending notifications');
         -- pc_notifications.send_email_on_ofac_results;
        dbms_output.put_line('Sending out notifications');
        insert into fraud_verifications (
            acc_num,
            acc_id,
            transaction_id,
            ofac_text,
            verification_date,
            ofac_code,
            ofacreference,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                b.acc_num,
                b.acc_id,
                a.transaction_id,
                a.ofac_text,
                a.verification_date,
                a.ofac_code,
                a.ofacreference,
                sysdate,
                4,
                sysdate,
                4
            from
                veratad_ofac_external a,
                account               b
            where
                    a.acc_num = b.acc_num
                and a.ofac_text in ( 'positive', 'negative' )
                and not exists (
                    select
                        *
                    from
                        fraud_verifications c
                    where
                        c.acc_num = b.acc_num
                );

    exception
        when l_create_error then
            null;
        when others then
            x_error_message := 'When OTHERS ' || sqlerrm;
            dbms_output.put_line('Error message ' || sqlerrm);

    /*   mail_utility.send_email('metavante@sterlingadministration.com'
                     ,'vanitha.subramanyam@sterlingadministration.com'
                   ,'Error in creating VERATAD_EXTERNAL file'
                   ,l_sqlerrm);
    */
    end process_ofac_batch;

    procedure process_ssn_batch (
        p_file_name     in out varchar2,
        x_error_message out varchar2
    ) is
        l_sql      varchar2(32000);
        l_sqlerrm  varchar2(32000);
        l_create_error exception;
        l_entrp_id number;
    begin
        if p_file_name is null then
            p_file_name := pc_file_upload.get_file_seq('SSN_BATCH');
        end if;
        l_sql := 'ALTER TABLE VERATAD_EXTERNAL LOCATION (VERATAD_INBOUND:'''
                 || p_file_name
                 || ''')';
        begin
            execute immediate l_sql;
        exception
            when others then
                rollback;
                x_error_message := 'Error when altering VERATAD_EXTERNAL table ' || sqlerrm;

       /** send email alert as soon as it fails **/
              /*  mail_utility.send_email('metavante@sterlingadministration.com'
                   ,'vanitha.subramanyam@sterlingadministration.com'
                   ,'Error in creating VERATAD_EXTERNAL file'
                   ,l_sqlerrm);*/
                raise l_create_error;
        end;
                     --   pc_notifications.send_email_on_id_results;
        insert into fraud_verifications (
            sequence_no,
            acc_num,
            acc_id,
            first_name,
            last_name,
            address,
            city,
            state,
            zip,
            birth_date,
            ssn,
            status,
            message,
            transaction_id,
            verification_date,
            age_code,
            age_text,
            deceased_code,
            deceased_text,
            age_delta,
            ssn_code,
            ssn_text,
            closest_first_name,
            closest_middle_name,
            closest_last_name,
            closest_street_num,
            closest_predirection,
            closest_street_name,
            closest_postdirection,
            closest_suffix,
            closest_box_des,
            closest_box_num,
            closest_route_des,
            closest_route_num,
            closest_unit_des,
            closest_unit_num,
            closest_city,
            closest_state,
            closest_zip,
            newest_first_name,
            newest_middle,
            newest_last_name,
            newest_street_num,
            newest_predirection,
            newest_street_name,
            newest_postdirection,
            newest_suffix,
            newest_box_des,
            newest_box_num,
            newest_route_des,
            newest_route_num,
            newest_unitdes,
            newest_unitnum,
            newest_city,
            newest_state,
            newest_zip,
            newest_date,
            ambiguous_code,
            ambiguous_text,
            ofac_code,
            ofac_text,
            ofacreference,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                a.sequence_no,
                a.acc_num,
                b.acc_id,
                a.first_name,
                a.last_name,
                a.address,
                a.city,
                a.state,
                a.zip,
                a.birth_date,
                a.ssn,
                a.status,
                a.message,
                a.transaction_id,
                a.verification_date,
                a.age_code,
                a.age_text,
                a.deceased_code,
                a.deceased_text,
                a.age_delta,
                a.ssn_code,
                a.ssn_text,
                a.closest_first_name,
                a.closest_middle_name,
                a.closest_last_name,
                a.closest_street_num,
                a.closest_predirection,
                a.closest_street_name,
                a.closest_postdirection,
                a.closest_suffix,
                a.closest_box_des,
                a.closest_box_num,
                a.closest_route_des,
                a.closest_route_num,
                a.closest_unit_des,
                a.closest_unit_num,
                a.closest_city,
                a.closest_state,
                a.closest_zip,
                a.newest_first_name,
                a.newest_middle,
                a.newest_last_name,
                a.newest_street_num,
                a.newest_predirection,
                a.newest_street_name,
                a.newest_postdirection,
                a.newest_suffix,
                a.newest_box_des,
                a.newest_box_num,
                a.newest_route_des,
                a.newest_route_num,
                a.newest_unitdes,
                a.newest_unitnum,
                a.newest_city,
                a.newest_state,
                a.newest_zip,
                a.newest_date,
                a.ambiguous_code,
                a.ambiguous_text,
                a.ofac_code,
                a.ofac_text,
                a.ofacreference,
                sysdate,
                4,
                sysdate,
                4
            from
                veratad_external a,
                account          b
            where
                    a.acc_num = b.acc_num
      --    AND    A.OFAC_TEXT IN ('positive','negative')
                and not exists (
                    select
                        *
                    from
                        fraud_verifications c
                    where
                        c.acc_num = b.acc_num
                );

              -- All the negative results are sent back
        for x in (
            select
                sequence_no,
                acc_num,
                first_name,
                last_name,
                address,
                city,
                state,
                zip,
                birth_date,
                dob_type,
                ssn,
                status,
                message,
                transaction_id,
                verification_date,
                age_code,
                age_text,
                deceased_code,
                deceased_text,
                age_delta,
                ssn_code,
                ssn_text,
                closest_first_name,
                closest_middle_name,
                closest_last_name,
                closest_street_num,
                closest_predirection,
                closest_street_name,
                closest_postdirection,
                closest_suffix,
                closest_box_des,
                closest_box_num,
                closest_route_des,
                closest_route_num,
                closest_unit_des,
                closest_unit_num,
                closest_city,
                closest_state,
                closest_zip,
                newest_first_name,
                newest_middle,
                newest_last_name,
                newest_street_num,
                newest_predirection,
                newest_street_name,
                newest_postdirection,
                newest_suffix,
                newest_box_des,
                newest_box_num,
                newest_route_des,
                newest_route_num,
                newest_unitdes,
                newest_unitnum,
                newest_city,
                newest_state,
                newest_zip,
                newest_date,
                ambiguous_code,
                ambiguous_text,
                ofac_code,
                ofac_text,
                ofacreference
            from
                veratad_external b
            where
                exists (
                    select
                        *
                    from
                        fraud_verifications c
                    where
                        c.acc_num = b.acc_num
                )
        ) loop
            update fraud_verifications
            set
                first_name = x.first_name,
                last_name = x.last_name,
                address = x.address,
                city = x.city,
                state = x.state,
                zip = x.zip,
                birth_date = x.birth_date,
                status = x.status,
                ssn = x.ssn,
                message = x.message,
                transaction_id = x.transaction_id,
                verification_date = x.verification_date,
                age_code = x.age_code,
                age_text = x.age_text,
                deceased_code = x.deceased_code,
                deceased_text = x.deceased_text,
                age_delta = x.age_delta,
                ssn_code = x.ssn_code,
                ssn_text = x.ssn_text,
                closest_first_name = x.closest_first_name,
                closest_middle_name = x.closest_middle_name,
                closest_last_name = x.closest_last_name,
                closest_street_num = x.closest_street_num,
                closest_predirection = x.closest_predirection,
                closest_street_name = x.closest_street_name,
                closest_postdirection = x.closest_postdirection,
                closest_suffix = x.closest_suffix,
                closest_box_des = x.closest_box_des,
                closest_box_num = x.closest_box_num,
                closest_route_des = x.closest_route_des,
                closest_route_num = x.closest_route_num,
                closest_unit_des = x.closest_unit_des,
                closest_unit_num = x.closest_unit_num,
                closest_city = x.closest_city,
                closest_state = x.closest_state,
                closest_zip = x.closest_zip,
                newest_first_name = x.newest_first_name,
                newest_middle = x.newest_middle,
                newest_last_name = x.newest_last_name,
                newest_street_num = x.newest_street_num,
                newest_predirection = x.newest_predirection,
                newest_street_name = x.newest_street_name,
                newest_postdirection = x.newest_postdirection,
                newest_suffix = x.newest_suffix,
                newest_box_des = x.newest_box_des,
                newest_box_num = x.newest_box_num,
                newest_route_des = x.newest_route_des,
                newest_route_num = x.newest_route_num,
                newest_unitdes = x.newest_unitdes,
                newest_unitnum = x.newest_unitnum,
                newest_city = x.newest_city,
                newest_state = x.newest_state,
                newest_zip = x.newest_zip,
                newest_date = x.newest_date,
                ofac_code = x.ofac_code,
                ofac_text = x.ofac_text,
                ofacreference = x.ofacreference,
                ambiguous_code = x.ambiguous_code,
                ambiguous_text = x.ambiguous_text,
                last_update_date = sysdate
            where
                acc_num = x.acc_num;

            for xx in (
                select
                    a.entrp_id
                from
                    person  a,
                    account b
                where
                        a.pers_id = b.pers_id
                    and b.acc_num = x.acc_num
            ) loop
                l_entrp_id := xx.entrp_id;
            end loop;

            if l_entrp_id is not null then
                if (
                    x.age_code in ( '1', '4' )
                    and x.deceased_text in ( '{}', 'negative' )
                    and x.ssn_text = 'positive'
                    and x.ofac_text = 'negative'
                ) then
                    update account
                    set
                        id_verified = 'Y',
                        note = substr(note
                                      || 'ID Verification is cleared on '
                                      || x.verification_date, 1, 4000),
                        last_updated_by = 0,
                        last_update_date = sysdate,
                        verified_by = 0,
                        blocked_flag = 'N'
                    where
                            acc_num = x.acc_num
                        and nvl(id_verified, 'N') in ( 'N', 'R' );

                    update online_users
                    set
                        blocked = 'N'
                    where
                            tax_id = x.ssn
                        and blocked = 'Y';

                else
                    update account
                    set
                        id_verified = 'R',
                        last_updated_by = 0,
                        last_update_date = sysdate,
                        verified_by = 0
                    where
                            acc_num = x.acc_num
                        and nvl(id_verified, 'N') = 'N';

                end if;
            else
                update account
                set
                    id_verified = 'R',
                    last_updated_by = 0,
                    last_update_date = sysdate,
                    verified_by = 0
                where
                        acc_num = x.acc_num
                    and nvl(id_verified, 'N') = 'N';

            end if;

        end loop;

        for x in (
            select
                x.verification_date,
                x.acc_num
            from
                fraud_verifications x,
                account             b,
                veratad_external    c
            where
                    x.acc_num = b.acc_num
                and c.acc_num = x.acc_num
                and nvl(b.id_verified, 'N') = 'N'
                and ( ( x.age_text is not null
                        and x.age_code not in ( '1', '4' ) )
                      or ( x.deceased_text is not null
                           and x.deceased_text <> 'negative' )
                      or ( x.ssn_text is not null
                           and x.ssn_text <> 'positive' ) )
        ) loop
            update account
            set
                id_verified = 'R',
                last_updated_by = 0,
                last_update_date = sysdate,
                verified_by = 0
            where
                    acc_num = x.acc_num
                and nvl(id_verified, 'N') = 'N';

        end loop;

        for x in (
            select
                x.verification_date,
                x.acc_num,
                replace(x.ssn, '-')              ssn,
                pc_person.get_entrp_id(b.acc_id) entrp_id
            from
                fraud_verifications x,
                account             b,
                veratad_external    c
            where
                    x.acc_num = b.acc_num
                and nvl(b.id_verified, 'N') in ( 'N', 'R' )
                and c.acc_num = x.acc_num
                and x.age_code in ( '1', '4' )
                and x.deceased_text = 'negative'
                and x.ssn_text = 'positive'
                and x.ofac_text = 'negative'
        ) loop
            if x.entrp_id is not null then
                update account
                set
                    id_verified = 'Y',
                    blocked_flag = 'N',
                    note = substr(note
                                  || 'ID Verification is cleared on '
                                  || x.verification_date, 1, 4000),
                    last_updated_by = 0,
                    last_update_date = sysdate,
                    verified_by = 0
                where
                        acc_num = x.acc_num
                    and nvl(id_verified, 'N') in ( 'N', 'R' );

                update online_users
                set
                    blocked = 'N',
                    last_update_date = sysdate,
                    last_updated_by = 0
                where
                        tax_id = x.ssn
                    and blocked = 'Y';

            end if;
        end loop;
            -- Release the accounts that might have been stuck
        begin
            for x in (
                select
                    x.verification_date,
                    x.acc_num,
                    x.ssn
                from
                    fraud_verifications x,
                    account             b,
                    person              c
                where
                        x.acc_num = b.acc_num
                    and nvl(b.id_verified, 'N') in ( 'N', 'R' )
                    and x.age_code in ( '1', '4' )
                    and c.pers_id = b.pers_id
                    and c.entrp_id is not null
                    and x.deceased_text = 'negative'
                    and x.ssn_text = 'positive'
                    and x.ofac_text = 'negative'
            ) loop
                update account
                set
                    id_verified = 'Y',
                    blocked_flag = 'N',
                    note = substr(note
                                  || 'ID Verification is cleared on '
                                  || x.verification_date, 1, 4000),
                    last_updated_by = 0,
                    last_update_date = sysdate,
                    verified_by = 0
                where
                        acc_num = x.acc_num
                    and nvl(id_verified, 'N') in ( 'N', 'R' );

                update online_users
                set
                    blocked = 'N',
                    last_update_date = sysdate,
                    last_updated_by = 0
                where
                        tax_id = x.ssn
                    and blocked = 'Y';

            end loop;
        end;
                     -- Release the accounts that might have been stuck
        begin
            for x in (
                select
                    x.verification_date,
                    x.acc_num,
                    replace(x.ssn, '-') ssn
                from
                    fraud_verifications x,
                    account             b,
                    person              c,
                    online_users        o
                where
                        x.acc_num = b.acc_num
                    and nvl(b.id_verified, 'N') = 'Y'
                    and b.blocked_flag = 'N'
                    and b.account_status = 2
                    and c.ssn = format_ssn(o.tax_id)
                    and o.blocked = 'Y'
                    and x.age_code in ( '1', '4' )
                    and c.pers_id = b.pers_id
                    and c.entrp_id is not null
                    and x.deceased_text = 'negative'
                    and x.ssn_text = 'positive'
                    and x.ofac_text = 'negative'
            ) loop
                update online_users
                set
                    blocked = 'N',
                    last_update_date = sysdate,
                    last_updated_by = 0
                where
                        tax_id = x.ssn
                    and blocked = 'Y';

            end loop;
        end;

    exception
        when l_create_error then
            null;
        when others then
            x_error_message := 'When OTHERS ' || sqlerrm;
            mail_utility.send_email('metavante@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in creating VERATAD_EXTERNAL file'
            , x_error_message);
    end process_ssn_batch;

    procedure process_online_verification (
        p_acc_num           in varchar2,
        p_transaction_id    in varchar2,
        p_verification_date in varchar2,
        x_return_status     out varchar2,
        x_error_message     out varchar2
    ) is
    begin
        x_return_status := 'S';
        insert into fraud_verifications (
            sequence_no,
            acc_num,
            acc_id,
            first_name,
            last_name,
            address,
            city,
            state,
            zip,
            birth_date,
            ssn,
            status,
            message,
            transaction_id,
            verification_date,
            age_code,
            age_text,
            deceased_code,
            deceased_text,
            ssn_code,
            ssn_text,
            ofac_code,
            ofac_text,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                rownum,
                b.acc_num,
                b.acc_id,
                a.first_name,
                a.last_name,
                a.address,
                a.city,
                a.state,
                a.zip,
                a.birth_date,
                a.ssn,
                0,
                'ID Verification from Online',
                p_transaction_id,
                p_verification_date,
                1,
                'positive',
                2,
                'negative',
                1,
                'positive',
                2,
                'negative',
                sysdate,
                4,
                sysdate,
                4
            from
                person  a,
                account b
            where
                    a.pers_id = b.pers_id
                and b.acc_num = p_acc_num;
               -- Vanitha:12/10/2018: Unlock the online user if locked

        for x in (
            select
                x.verification_date,
                x.acc_num,
                replace(x.ssn, '-') ssn
            from
                fraud_verifications x,
                account             b,
                person              c,
                online_users        o
            where
                    x.acc_num = b.acc_num
                and b.acc_num = p_acc_num
                and nvl(b.id_verified, 'N') = 'Y'
                and b.blocked_flag = 'N'
                and c.ssn = format_ssn(o.tax_id)
                and o.blocked = 'Y'
                and x.age_code in ( '1', '4' )
                and c.pers_id = b.pers_id
                and c.entrp_id is not null
                and x.deceased_text = 'negative'
                and x.ssn_text = 'positive'
                and x.ofac_text = 'negative'
        ) loop
            update online_users
            set
                blocked = 'N',
                last_update_date = sysdate,
                last_updated_by = 0
            where
                    tax_id = x.ssn
                and blocked = 'Y';

        end loop;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := 'Exception from  process online verification ' || sqlerrm;
    end process_online_verification;

    function get_notification return pc_online_enroll_dml.notify_t
        pipelined
        deterministic
    is

        l_record        pc_online_enroll_dml.notify_row_t;
        l_name          varchar2(2000);
        l_user_name     varchar2(2000);
        l_template_body varchar2(4000);
    begin
    /*Ticket#6588. We will extract the template from PHP side */
    -- FOR X IN ( SELECT  template_subject,template_body
    --                 FROM   notification_template
   --                 WHERE   template_name = 'HSA_WELCOME_EMAIL'
    --                 AND     status = 'A')
    -- LOOP
   --           l_record.subject :=  x.template_subject;
    --          l_template_body := x.template_body;

   --  END LOOP;
    /*
     FOR XX IN (select x.VERIFICATION_DATE, x.acc_num ,x.ssn,B.ACC_ID,d.email
                    ,  e.FIRST_NAME||' '||e.LAST_NAME NAME, NVL(b.start_amount,0)amount
                        from fraud_verifications x, account b,
                        veratad_external c,
                         online_users d
                          , person e
                       where  x.acc_num = b.acc_num
                        and  NVL(b.id_verified,'N') = 'Y'
                        AND  c.acc_num = x.acc_num
                        AND  d.confirmed_flag = 'N'
                        AND  format_ssn(d.tax_id) = format_ssn(x.ssn)
                        and  e.pers_id = b.pers_id
                        and  e.ssn = format_ssn(x.ssn)
                        and  x.age_text = 'positive'
                        AND  x.deceased_text in ('{}', 'negative')
                        AND  x.ssn_text = 'positive'
                        AND  x.ofac_text = 'negative'
                        and b.confirmation_date is null
                        UNION
                        select x.VERIFICATION_DATE, x.acc_num ,x.ssn,B.ACC_ID,e.email
                    ,  e.FIRST_NAME||' '||e.LAST_NAME NAME, NVL(b.start_amount,0)amount
                        from fraud_verifications x, account b,
                             person e
                       where  x.acc_num = b.acc_num
                        and  NVL(b.id_verified,'N') = 'Y'
                        AND  TO_DATE(SUBSTR(VERIFICATION_DATE, 1,10),'YYYY-MM-DD') >= TRUNC(SYSDATE-1)
                         and  e.pers_id = b.pers_id
                        and b.confirmation_date is null
                        and  e.ssn = format_ssn(x.ssn)
                        and  x.age_text = 'positive'
                        and  e.email IS NOT NULL
                        AND  x.deceased_text in ('{}', 'negative')
                        AND  x.ssn_text = 'positive'
                        AND  x.ofac_text = 'negative')
     LOOP*/
        for xx in (
            select
                e.ssn,
                b.acc_id,
                e.email,
                e.first_name
                || ' '
                || e.last_name         name,
                nvl(b.start_amount, 0) amount,
                b.acc_num
            from
                account b,
                person  e
            where
                    b.pers_id = e.pers_id
                and trunc(b.creation_date) > trunc(sysdate - 1)
                and b.confirmation_date is null
                and b.account_type = 'HSA'
                and e.email is not null
        ) loop
            l_record.acc_num := xx.acc_num;
            l_record.email := xx.email;
            l_record.user_name := null;
            l_record.person_name := xx.name;
            l_record.acc_id := xx.acc_id;
            l_record.contrib_amt := xx.amount; /*Ticket#6588 */
        --    l_record.email_body :=    REPLACE(REPLACE(l_template_body,'<<NAME>>',Xx.NAME)
	          --               ,'<<USER_NAME>>',xX.USER_NAME);
            pipe row ( l_record );
        end loop;
    end get_notification;

   /*Ticket#6588 */
    function get_er_notification return pc_online_enroll_dml.notify_t
        pipelined
        deterministic
    is

        l_record        pc_online_enroll_dml.notify_row_t;
        l_name          varchar2(2000);
        l_user_name     varchar2(2000);
        l_template_body varchar2(4000);
    begin
        for xx in (
            select
                account_number,
                er_name,
                email,
                user_name
            from
                employer_hsa_welcome_email
            where
                    trunc(start_date) >= trunc(sysdate - 1)
                and confirmation_date is null
        ) loop
            l_record.acc_num := xx.account_number;
            l_record.email := xx.email;
            l_record.user_name := xx.er_name;
	          --l_record.person_name  := Xx.NAME;
            --l_record.acc_id       := xx.acc_id;
       --     l_record.email_body :=    REPLACE(REPLACE(l_template_body,'<<NAME>>',Xx.er_NAME)
	      --                   ,'<<USER_NAME>>',xX.USER_NAME);
            pipe row ( l_record );
        end loop;
    end get_er_notification;

  /*Ticket#6588 */
    procedure process_manual_verification (
        p_acc_id        in number,
        p_note          in varchar2,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        x_return_status := 'S';
        insert into fraud_verifications (
            sequence_no,
            acc_num,
            acc_id,
            first_name,
            last_name,
            address,
            city,
            state,
            zip,
            birth_date,
            ssn,
            status,
            message,
            transaction_id,
            verification_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                rownum,
                b.acc_num,
                b.acc_id,
                a.first_name,
                a.last_name,
                a.address,
                a.city,
                a.state,
                a.zip,
                a.birth_date,
                a.ssn,
                - 10001 -- Manual ID verification cleared
                ,
                p_note,
                - 1,
                to_char(sysdate, 'YYYY-MM-DD HH:MI:SS'),
                sysdate,
                p_user_id,
                sysdate,
                p_user_id
            from
                person  a,
                account b
            where
                    a.pers_id = b.pers_id
                and b.acc_num = p_acc_id;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := 'Exception from  process online verification ' || sqlerrm;
    end process_manual_verification;

-- Added by Swamy for Ticket#9669
    function get_template_notification (
        p_acc_num      in varchar2,
        p_flg_employer in varchar2
    ) return template_person_tab
        pipelined
        deterministic
    is
        l_record       template_person_rec;
        l_account_type varchar2(100);
        l_entrp_id     account.entrp_id%type;
    begin
        for j in (
            select
                account_type,
                entrp_id
            from
                account
            where
                acc_num = p_acc_num
        ) loop
            l_account_type := j.account_type;
            l_entrp_id := j.entrp_id;
        end loop;
    -- For Employer email
        if p_flg_employer = 'E' then
            if l_account_type = 'HSA' then
                for xx in (
                    select
                        account_number,
                        er_name,
                        email,
                        user_name
                    from
                        template_emplyr_hsa_wel_email
                    where
                        account_number = p_acc_num
                ) loop
                    l_record.acc_num := xx.account_number;
                    l_record.email := xx.email;
                    l_record.user_name := xx.er_name;
                    pipe row ( l_record );
                end loop;

            end if;
      -- For Employee and Individual email
        elsif p_flg_employer = 'I' then
            if l_account_type = 'HSA' then
                for xx in (
                    select
                        e.ssn,
                        b.acc_id,
                        e.email,
                        e.first_name
                        || ' '
                        || e.last_name         name,
                        nvl(b.start_amount, 0) amount,
                        b.acc_num
                    from
                        account b,
                        person  e
                    where
                            b.pers_id = e.pers_id
                        and b.account_type = 'HSA'
                        and acc_num = p_acc_num
                ) loop
                    l_record.acc_num := xx.acc_num;
                    l_record.email := xx.email;
                    l_record.person_name := xx.name;
                    l_record.acc_id := xx.acc_id;
                    l_record.contrib_amt := xx.amount; /*Ticket#6588 */
                    if nvl(l_record.email, '*') = '*' then
                        for j in (
                            select
                                email
                            from
                                online_users
                            where
                                find_key = p_acc_num
                        ) loop
                            l_record.email := j.email;
                        end loop;
                    end if;

                    pipe row ( l_record );
                end loop;

            elsif l_account_type in ( 'HRA', 'FSA' ) then
              -- For Employees
                for xx in (
                    select
                        person_name,
                        email,
                        account_number,
                        employer,
                        template_name,
                        subject,
                        entrp_email,
                        acc_id
                    from
                        template_subscrib_hra_wel_mail
                    where
                        account_number = p_acc_num
                ) loop
                    l_record.acc_num := xx.account_number;
                    l_record.email := xx.email;
                    l_record.person_name := xx.person_name;
                    l_record.employer := xx.employer;
                    l_record.template_name := xx.template_name;
                    l_record.subject := xx.subject;
                    l_record.entrp_email := xx.entrp_email;
                    l_record.acc_id := xx.acc_id;
                    if nvl(l_record.email, '*') = '*' then
                        for j in (
                            select
                                email
                            from
                                online_users
                            where
                                find_key = p_acc_num
                        ) loop
                            l_record.email := j.email;
                        end loop;
                    end if;

                    pipe row ( l_record );
                end loop;
            end if;
        end if;

    exception
        when others then
            pc_log.log_error('get_template_notification OTHERS ', sqlerrm);
    end get_template_notification;

    procedure generate_ssn_batch_aop is

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        aop_api_pkg.g_cloud_provider := 'sftp';
        aop_api_pkg.g_cloud_location := '/edi/veratad/out/';
        aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.119",
                                                  "port": 22,
                                                  "user": "ftp_admin",
                                                  "password": "SterlinGFtP2@!2admIn"}';
        l_file_id := pc_file_upload.insert_file_seq('SSN_BATCH');
        l_file_name := 'VT_'
                       || l_file_id
                       || '_ssn.txt';
        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;

        select
            json_object(
                'PERSON' value json_arrayagg(
                    json_object(
                        'RN' value rownum,
                                'ACC_NUM' value b.acc_num,
                                'ENROLLMENT_SOURCE' value b.enrollment_source,
                                'FIRST_NAME' value '"'
                                                   || first_name
                                                   || '"',
                                'MIDDLE_NAME' value '"'
                                                    || middle_name
                                                    || '"',
                                'LAST_NAME' value '"'
                                                  || last_name
                                                  || '"',
                                'ADDRESS' value '"'
                                                || address
                                                || '"',
                                'CITY' value '"'
                                             || city
                                             || '"',
                                'STATE' value '"'
                                              || state
                                              || '"',
                                'ZIP' value '"'
                                            || zip
                                            || '"',
                                'BIRTH_DATE' value to_char(a.birth_date, 'MM/DD/YYYY'),
                                'DATE_TYPE' value 'MM/DD/YYYY',
                                'SSN' value replace(ssn, '-')
                    )
                returning clob)
            returning clob)
        into l_clob
        from
            person  a,
            account b
        where
                a.pers_id = b.pers_id
            and b.account_type = 'HSA'
            and b.account_status = 3
            and b.complete_flag = 1
            and nvl(b.id_verified, 'N') = 'N';

        l_return := aop_api_pkg.plsql_call_to_aop(
            p_data_type       => 'JSON',
            p_data_source     => l_clob,
            p_template_type   => 'APEX',
            p_template_source => q'[veratad_csv_template.csv]',
            p_output_type     => 'csv',
            p_output_filename => l_file_name,
            p_output_encoding => aop_api_pkg.c_output_encoding_raw,
            p_output_to       => 'CLOUD',
            p_aop_url         => 'http://172.24.16.116:8010/',   --  'http://216.109.157.48:8010/', changed by joshi on 09/11/2023
            p_app_id          => 204
        );

    exception
        when others then
            l_sqlerrm := sqlerrm;
            mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating SSN batch File'
            , l_sqlerrm);
            dbms_output.put_line('l_sqlerrm: ' || l_sqlerrm);
    end generate_ssn_batch_aop;

    procedure generate_ofac_batch_aop is

        l_clob      clob;
        l_return    blob;
        l_file_name varchar2(255);
        l_file_id   number;
        l_sqlerrm   varchar2(32000);
    begin
        aop_api_pkg.g_cloud_provider := 'sftp';
        aop_api_pkg.g_cloud_location := '/edi/veratad/out/';
        aop_api_pkg.g_cloud_access_token := '{"host": "172.24.16.119",
                                                  "port": 22,
                                                  "user": "ftp_admin",
                                                  "password": "SterlinGFtP2@!2admIn"}';
        l_file_id := pc_file_upload.insert_file_seq('OFAC_BATCH');
        l_file_name := 'VT_'
                       || l_file_id
                       || '_person.txt';
        update external_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;

        select
            json_object(
                'PERSON' value json_arrayagg(
                    json_object(
                        'FIRST_NAME' value '"'
                                           || first_name
                                           || '"',
                        'MIDDLE_NAME' value '"'
                                            || middle_name
                                            || '"',
                        'LAST_NAME' value '"'
                                          || last_name
                                          || '"',
                        'ADDRESS' value '"'
                                        || address
                                        || '"',
                        'CITY' value '"'
                                     || city
                                     || '"',
                                'STATE' value '"'
                                              || state
                                              || '"',
                        'ZIP' value '"'
                                    || zip
                                    || '"',
                        'ACC_NUM' value '"'
                                        || acc_num
                                        || '"'
                    )
                returning clob)
            returning clob)
        into l_clob
        from
            person  a,
            account b
        where
                a.pers_id = b.pers_id
            and b.account_type = 'HSA'
            and b.account_status <> 4
            and b.complete_flag = 1;

        l_return := aop_api_pkg.plsql_call_to_aop(
            p_data_type       => 'JSON',
            p_data_source     => l_clob,
            p_template_type   => 'APEX',
            p_template_source => q'[veratad_ofac_template.csv]',
            p_output_type     => 'csv',
            p_output_filename => l_file_name,
            p_output_encoding => aop_api_pkg.c_output_encoding_raw,
            p_output_to       => 'CLOUD',
            p_aop_url         => 'http://172.24.16.116:8010/',  --  'http://216.109.157.48:8010/', changed by joshi on 09/11/2023
            p_app_id          => 204
        );

    exception
        when others then
            l_sqlerrm := sqlerrm;
            mail_utility.send_email('webservice@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in Creating OFAC batch File'
            , l_sqlerrm);
    end generate_ofac_batch_aop;

    procedure upd_edi_repo_file_process_flag (
        p_file_name   in varchar2,
        p_vendor_name in varchar2,
        p_feed_type   in varchar2
    ) is
        l_upd_clob clob;
        l_req_body clob;
    begin
        pc_log.log_error('pc_webservice_batch.Upd_edi_repo_file_process_flag', 'p_file_name  ' || p_file_name);
        apex_web_service.oauth_authenticate(
            p_token_url     => 'https://sam.sterlinghsa.com:8082/ords/sam21pdb/sterlingftp/oauth/token',
            p_client_id     => 'AAWC6jbJW1xX9YSW7yVNLQ..',
            p_client_secret => 'MbGzcMQguBhm0qyGedFwVA..'
        );

        apex_web_service.g_request_headers(1).name := 'Authorization';
        apex_web_service.g_request_headers(1).value := 'Bearer ' || apex_web_service.oauth_get_last_token;
        apex_web_service.g_request_headers(2).name := 'Content-Type';
        apex_web_service.g_request_headers(2).value := 'application/json';
        apex_json.initialize_clob_output();
        apex_json.open_object();
        apex_json.write('file_name', p_file_name);
        apex_json.write('vendor_name', p_vendor_name);
        apex_json.write('feed_type', p_feed_type);
        apex_json.close_all();
        l_req_body := apex_json.get_clob_output();
        pc_log.log_error('Upd_edi_repo_file_process_flag l_req_body ', l_req_body);
        apex_json.free_output();
        dbms_output.put_line('l_req_body=' || l_req_body);
        l_upd_clob := apex_web_service.make_rest_request(
            p_url         => 'https://sam.sterlinghsa.com:8082/ords/sam21pdb/sterlingftp/EDI/metavantefiles/',
            p_http_method => 'POST',
            p_body        => l_req_body
        );

        pc_log.log_error('Upd_edi_repo_file_process_flag l_upd_clob ', l_upd_clob);
    exception
        when others then
            pc_log.log_error('Upd_edi_repo_file_process_flag others ', sqlerrm);
    end upd_edi_repo_file_process_flag;

end pc_webservice_batch;
/


-- sqlcl_snapshot {"hash":"48bdf22620b5110c998e9d51f8bf1a4a879786db","type":"PACKAGE_BODY","name":"PC_WEBSERVICE_BATCH","schemaName":"SAMQA","sxml":""}