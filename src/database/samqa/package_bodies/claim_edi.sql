create or replace package body samqa.claim_edi as

-------------------------------------------------------------------
-- 1. MAIN METHOD WHICH PROCESS THE CLAIM FILE
-- This method execution populates claim header, claim detail and claim service tables - 837 file
-------------------------------------------------------------------
    procedure process_claim_file as
        l_claim_header_id claim_edi_header.claim_header_id%type;
    begin
   --1. Process header rows
        process_claim_header(l_claim_header_id);

   --2. Process detail rows
        process_claim_detail(l_claim_header_id);
    end;
-------------------------------------------------------------------
--1a. This method inserts records into the claim header table
-------------------------------------------------------------------
    procedure insert_header_row (
        claim_edi_header_table claim_edi_header_type
    ) is
    begin
        forall idx in claim_edi_header_table.first..claim_edi_header_table.last
            insert into claim_edi_header values claim_edi_header_table ( idx );

        commit;
    exception
        when others then
      --dbms_output.put_line(sqlerrm);
            pc_log.log_error('CLAIM_EDI', 'INSERT_HEADER_ROW' || sqlerrm);
    end insert_header_row;
-------------------------------------------------------------------
--1b. This method inserts records into the claim detail table
-------------------------------------------------------------------
    procedure insert_detail_row (
        claim_edi_detail_table in claim_edi_detail_type
    ) is
    begin
        forall idx in claim_edi_detail_table.first..claim_edi_detail_table.last
            insert into claim_edi_detail values claim_edi_detail_table ( idx );

        commit;
    exception
        when others then
      --dbms_output.put_line(sqlerrm);
            pc_log.log_error('CLAIM_EDI', 'INSERT_DETAIL_ROW' || sqlerrm);
    end insert_detail_row;

-------------------------------------------------------------------
--1c. This method inserts records into the claim service detail table
-------------------------------------------------------------------
    procedure insert_service_detail_row (
        claim_edi_service_detail_table in claim_edi_service_detail_type
    ) is
    begin
        forall idx in claim_edi_service_detail_table.first..claim_edi_service_detail_table.last
            insert into claim_edi_service_detail values claim_edi_service_detail_table ( idx );

        commit;
    exception
        when others then
      --dbms_output.put_line(sqlerrm);
            pc_log.log_error('CLAIM_EDI', 'INSERT_SERVICE_DETAIL_ROW' || sqlerrm);
    end insert_service_detail_row;

-------------------------------------------------------------------
-- 2a. This method processes claim header records only
-------------------------------------------------------------------
    procedure process_claim_header (
        p_claim_header_id_out out claim_edi_header.claim_header_id%type
    ) as

        l_begin_header_rec_num number := 1;
        l_end_header_rec_num   number;
        l_clm_hdr_rec_num      number := 1;
        l_clm_hdr_row          claim_edi_header_type;
        l_claim_header_id      claim_edi_header.claim_header_id%type;
    begin
        delete from claim_edi_header;

        commit;
   -- Fetch only the header records that lie between record number 1 and the 1st PROVIDER (HL03=20) record
        select
            count(next_row)
        into l_end_header_rec_num
        from
            (
                select
                    rownum,
                    cee_header.next_row,
                    cee_header.seg,
                    cee_header.s01,
                    cee_header.s02,
                    cee_header.s03,
                    lead(cee_header.next_row, 1, 0)
                    over(
                        order by
                            cee_header.next_row
                    ) - 1 as prev_row
                from
                    (
                        select
                            rownum next_row,
                            cee.seg,
                            cee.s01,
                            cee.s02,
                            cee.s03
                        from
                            claim_edi_external cee
                    ) cee_header
                where
                    rownum between 1 and (
                        select
                            a.next_row
                        from
                            (
                                select
                                    rownum,
                                    cee_provider.next_row,
                                    cee_provider.seg,
                                    cee_provider.s01,
                                    cee_provider.s02,
                                    cee_provider.s03,
                                    lead(cee_provider.next_row, 1, 0)
                                    over(
                                        order by
                                            cee_provider.next_row
                                    ) - 1 as prev_row
                                from
                                    (
                                        select
                                            rownum next_row,
                                            cee.seg,
                                            cee.s01,
                                            cee.s02,
                                            cee.s03
                                        from
                                            claim_edi_external cee
                                    ) cee_provider
                                where
                                        cee_provider.seg = 'HL'
                                    and cee_provider.s03 = '20'
                                    and rownum = 1
                            ) a
                    )
            );
   -- Get claim header segment details
        get_claim_header_seg(l_clm_hdr_rec_num, l_begin_header_rec_num, l_end_header_rec_num, l_clm_hdr_row, p_claim_header_id_out);
    exception
        when others then
    --dbms_output.put_line(sqlerrm(sqlcode));
            pc_log.log_error('CLAIM_EDI', 'PROCESS_CLAIM_HEADER' || sqlerrm);
    end process_claim_header;

-------------------------------------------------------------------
-- 2b. This method processes claim detail records only
-------------------------------------------------------------------
    procedure process_claim_detail (
        p_claim_header_id_in in claim_edi_header.claim_header_id%type
    ) as

        type edi_prov_data_type is
            table of claim_provider_edi_vw%rowtype index by binary_integer;
        l_provider_all_rec      edi_prov_data_type;
        l_subscriber_rec        claim_detail_table_t;
        l_service_detail_rec    claim_service_detail_table_t;
        l_det_row               claim_edi_detail_type;
        l_rec_cntr              number := 0;

   -- for claim service table - GN created on 04/01/11
        l_srvc_rec_cntr         number := 0;
        l_claim_service_det_row claim_edi_service_detail_type;
    begin
   --1. Get all  the provider records
   --Vanitha: Created new view claim_provider_edi_vw which will just have
   --provider information
        select
            cee_seg_data.*
        bulk collect
        into l_provider_all_rec
        from
            (
                select
                    cv.*
                from
                    claim_provider_edi_vw cv
                order by
                    rn asc
            ) cee_seg_data;

        if l_provider_all_rec.count > 0 then
       --1. Fetch Billing provider details
            for i in l_provider_all_rec.first..l_provider_all_rec.last loop

          --3. Now fetch all subscribers/claim records between prior provider and next provider records
          --Vanitha: Added new view claim_edi_external_rn_v, that will get
          --row numbers of all subscribers between two providers
          --
                for x in (
                    select
                        rn,
                        next_row
                    from
                        claim_edi_external_rn_v
                    where
                            rn >= l_provider_all_rec(i).rn
                        and rn <= l_provider_all_rec(i).next_rn
                ) loop
               -- All the logic of getting the information
               -- about subscriber is in claim_edi.get_claim_det
               -- which is PIPELINED function
                    select
                        cee_seg_data.*
                    bulk collect
                    into l_subscriber_rec
                    from
                        (
                            select
                                *
                            from
                                table ( claim_edi.get_claim_det(x.rn, x.next_row) )
                        ) cee_seg_data;

                    if l_subscriber_rec.count > 0 then
                        for j in l_subscriber_rec.first..l_subscriber_rec.last loop
                     -- if claim record does not have subscriber name and other details then pull it from HL23 record so that
                     -- we can insert in next if statement when claim number exists.

                     -- Every claim needs to have an entry within a provider, so check and create entry
                     -- only if claim number exists
                            if trim(l_subscriber_rec(j).claim_number) is not null then
                                l_rec_cntr := l_rec_cntr + 1;
                                l_det_row(l_rec_cntr).claim_detail_id := claim_edi_det_seq.nextval;
                                l_det_row(l_rec_cntr).claim_header_id := p_claim_header_id_in;
                                l_det_row(l_rec_cntr).batch_number := 'EDI' || to_char(sysdate, 'yyyymmddhhmiss');

                        -- 1. BILLING PROVIDER
			                  -- Vanitha: We get this information from claim_provider_edi_vw
                                l_det_row(l_rec_cntr).bllng_prvdr_nm := l_provider_all_rec(i).billing_provider_name;
                                l_det_row(l_rec_cntr).bllng_prvdr_addrss1 := l_provider_all_rec(i).billing_provider_address1;
                                l_det_row(l_rec_cntr).bllng_prvdr_addrss2 := l_provider_all_rec(i).billing_provider_address2;
                                l_det_row(l_rec_cntr).bllng_prvdr_city := l_provider_all_rec(i).billing_provider_city;
                                l_det_row(l_rec_cntr).bllng_prvdr_stt_cd := l_provider_all_rec(i).billing_provider_state;
                                l_det_row(l_rec_cntr).bllng_prvdr_zip := l_provider_all_rec(i).billing_provider_zip;
                                l_det_row(l_rec_cntr).bllng_prvdr_cntry_cd := l_provider_all_rec(i).billing_provider_country;
                                l_det_row(l_rec_cntr).bllng_prvdr_accnt_nmbr := l_provider_all_rec(i).billing_provider_acct_number;
                                l_det_row(l_rec_cntr).bllng_prvdr_cntct_nm := l_provider_all_rec(i).billing_provider_contact_name;
                                l_det_row(l_rec_cntr).bllng_prvdr_email := l_provider_all_rec(i).billing_provider_email;
                                l_det_row(l_rec_cntr).bllng_prvdr_phn := l_provider_all_rec(i).billing_provider_phone;

                        /* Vanitha: Ignore this pay to provider for now I will think about it later
                        -- 2. PAY TO PROVIDER
                        -- Per Vanitha on 02/27/11, Pay to provider is same as subscriber details. If it changes, then it will be taken care in future
                        l_det_row(l_rec_cntr).pay_to_prvdr_nm := nvl(trim(l_subscriber_rec(j).subscriber_name), l_hl23_subscriber_rec(1).subscriber_name);
                        l_det_row(l_rec_cntr).pay_to_prvdr_addrss1 := nvl(trim(l_subscriber_rec(j).subscriber_address1), l_hl23_subscriber_rec(1).subscriber_address1);
                        L_Det_Row(L_Rec_Cntr).pay_to_prvdr_addrss2 := Nvl(Trim(L_Subscriber_Rec(J).Subscriber_Address2), L_Hl23_Subscriber_Rec(1).Subscriber_Address2);
                        L_Det_Row(L_Rec_Cntr).pay_to_prvdr_city := Nvl(Trim(L_Subscriber_Rec(J).Subscriber_City), L_Hl23_Subscriber_Rec(1).Subscriber_City);
                        L_Det_Row(L_Rec_Cntr).pay_to_prvdr_Stt_cd := Nvl(Trim(L_Subscriber_Rec(J).Subscriber_State), L_Hl23_Subscriber_Rec(1).Subscriber_State);
                        L_Det_Row(L_Rec_Cntr).pay_to_prvdr_zip := nvl(trim(L_Subscriber_Rec(J).Subscriber_Zip), L_Hl23_Subscriber_Rec(1).Subscriber_zip);
                        l_det_row(l_rec_cntr).pay_to_prvdr_accnt_nmbr := nvl(trim(l_subscriber_rec(j).subscriber_number), l_hl23_subscriber_rec(1).subscriber_number);

                        -- 3. RENDERING PROVIDER
                        l_det_row(l_rec_cntr).rndrng_prvdr_nm := l_subscriber_rec(j).rendering_provider_name;
                        l_det_row(l_rec_cntr).rndrng_prvdr_frst_nm := l_subscriber_rec(j).rendering_provider_first_name;
                        l_det_row(l_rec_cntr).rndrng_prvdr_mddl_nm := L_Subscriber_Rec(J).rendering_provider_middle_Name;
                        */

                        -- 4. SUBSCRIBER
                        -- if claim record does not have subscriber name and other details then pull it from prior HL23 record.
                        -- nvl is used for this purpose mainly.
                        -- trim is used to eliminate blanks, otherwise does not give expected results
			                  -- Vanitha: We get this information from pipelined function

                                l_det_row(l_rec_cntr).sbscrbr_nm := trim(l_subscriber_rec(j).subscriber_name);
                                l_det_row(l_rec_cntr).sbscrbr_addrss1 := trim(l_subscriber_rec(j).subscriber_address1);
                                l_det_row(l_rec_cntr).sbscrbr_addrss2 := trim(l_subscriber_rec(j).subscriber_address2);
                                l_det_row(l_rec_cntr).sbscrbr_city := trim(l_subscriber_rec(j).subscriber_city);
                                l_det_row(l_rec_cntr).sbscrbr_stt_cd := trim(l_subscriber_rec(j).subscriber_state);
                                l_det_row(l_rec_cntr).sbscrbr_zip := trim(l_subscriber_rec(j).subscriber_zip);
                        --l_det_row(l_rec_cntr).sbscrbr_cntry_cd := l_subscriber_rec(j).subscriber_country;
                                l_det_row(l_rec_cntr).sbscrbr_nmbr := trim(l_subscriber_rec(j).subscriber_number);
                                l_det_row(l_rec_cntr).pers_id := get_pers_id(trim(l_subscriber_rec(j).subscriber_number)); -- Geetha added on 04/08/2011
                        -- populate account details for the given pers_id now
                                get_acc_details(l_det_row(l_rec_cntr).pers_id, -- in parameter
                                                l_det_row(l_rec_cntr).acc_id,  -- out parameter1
                                                l_det_row(l_rec_cntr).acc_num);  -- out parameter2

                        -- 3. PATIENT AND CLAIM DETAILS
                                l_det_row(l_rec_cntr).patient_last_nm := l_subscriber_rec(j).patient_last_name;
                                l_det_row(l_rec_cntr).patient_frst_nm := l_subscriber_rec(j).patient_first_name;
                                l_det_row(l_rec_cntr).patient_mddl_nm := l_subscriber_rec(j).patient_middle_name;
                                l_det_row(l_rec_cntr).claim_nmbr := l_subscriber_rec(j).claim_number;
                                l_det_row(l_rec_cntr).service_amnt := l_subscriber_rec(j).claim_amount;
                                l_det_row(l_rec_cntr).patient_amnt_paid := l_subscriber_rec(j).amount_to_be_paid;

		                    -- Vanitha: Add patient number as well here
                        -- All of the below information we need to add
			                  -- but to test out I didnt add these. Once we are successful we can go back and add this
                        --   l_det_row(l_rec_cntr).claim_note := l_subscriber_rec(j).claim_note;
                                l_det_row(l_rec_cntr).bllng_note := null;
                                l_det_row(l_rec_cntr).patient_note := null;
                                l_det_row(l_rec_cntr).eob_rqrd := l_subscriber_rec(j).eoq_reqd;
                                l_det_row(l_rec_cntr).rmbrsmnt_mthd := 'SUBSCRIBER';
                                l_det_row(l_rec_cntr).status_cd := 'NEW';

                        -- 4. CLAIM SERVICE DETAILS - INSERT INTO SEPERATE CLAIM SERVICE DETAIL TABLE
                        -- Service details will be in HL = '23' only, that is why this check before capturing service details

			-- Vanitha: Between two subscribers get the service details
			-- This is also from pipelined function claim_edi.get_claim_service_det
                                select
                                    cee_seg_data.*
                                bulk collect
                                into l_service_detail_rec
                                from
                                    (
                                        select
                                            *
                                        from
                                            table ( claim_edi.get_claim_service_det(x.rn, x.next_row) )
                                    ) cee_seg_data;

                                if l_service_detail_rec.count > 0 then
                                    for k in l_service_detail_rec.first..l_service_detail_rec.last loop
                                        l_srvc_rec_cntr := l_srvc_rec_cntr + 1;
                                        l_claim_service_det_row(l_srvc_rec_cntr).claim_service_detail_id := claim_edi_service_det_seq.nextval
                                        ;
                                        l_claim_service_det_row(l_srvc_rec_cntr).claim_detail_id := l_det_row(l_rec_cntr).claim_detail_id
                                        ;

                                   -- 1. CLAIM SERVICE PROVIDER
                                        l_claim_service_det_row(l_srvc_rec_cntr).service_provider_name := l_service_detail_rec(k).service_provider
                                        ; -- Combination of first name||LastName
                                        l_claim_service_det_row(l_srvc_rec_cntr).service_provider_id := l_service_detail_rec(k).provider_acc_num
                                        ;
                                   -- Get this from subscriber information
                                        l_claim_service_det_row(l_srvc_rec_cntr).patient_name := l_subscriber_rec(j).patient_first_name
                                                                                                 || ' '
                                                                                                 || l_subscriber_rec(j).patient_middle_name
                                                                                                 || ' '
                                                                                                 || l_subscriber_rec(j).patient_last_name
                                                                                                 ;  -- Combination of first name||middleName||LastName

                                        l_claim_service_det_row(l_srvc_rec_cntr).service_procedure_code := l_service_detail_rec(k).service_code
                                        ;
                                        l_claim_service_det_row(l_srvc_rec_cntr).service_monetary_amount := l_service_detail_rec(k).service_cost
                                        ;
                                        l_claim_service_det_row(l_srvc_rec_cntr).service_start_date := substr(l_service_detail_rec(k).service_date
                                        ,
                                                                                                              1,
                                                                                                              8);

                                        l_claim_service_det_row(l_srvc_rec_cntr).service_end_date := substr(l_service_detail_rec(k).service_date
                                        ,
                                                                                                            10);

                                    end loop;
                                end if; -- l_service_detail_rec
                            end if;   -- trim(l_subscriber_rec(j).claim_number)
                        end loop; -- l_subscriber_rec
                    end if;

                end loop;

             -- assign provider_all_rec to provider_prior_rec now to continue with next provider in loop
            -- L_Provider_Prior_Rec(1) := L_Provider_All_Rec(I);
            end loop;

        end if;
    -- Now insert all captured records in claim detail table
        insert_detail_row(l_det_row);

    -- Now insert all captured records in claim service detail table
        insert_service_detail_row(l_claim_service_det_row);
    exception
        when others then
       --dbms_output.put_line(sqlerrm(sqlcode));
            raise;
            pc_log.log_error('CLAIM_EDI', 'PROCESS_CLAIM_DETAIL' || sqlerrm);
    end process_claim_detail;

-------------------------------------------------------------------
-- 3a. This method fetches header records only for processing
-------------------------------------------------------------------
    procedure get_claim_header_seg (
        p_rec_cntr_in         in number,
        p_begin_header_rec_in in number,
        p_end_header_rec_in   in number,
        p_header_row_out      out claim_edi_header_type,
        p_claim_header_id_out out claim_edi_header.claim_header_id%type
    ) is

-- 1. Fetch data from claim edi external table for given segment and within the appropriate beginning and end record numbers
        cursor c_edi_seg_data is
        select
            cee_seg_data.*
        from
            (
                select
                    rownum rec_num,
                    cee.*
                from
                    claim_edi_external cee
            ) cee_seg_data
        where
            cee_seg_data.rec_num between p_begin_header_rec_in and p_end_header_rec_in;

        type edi_seg_data_type is
            table of c_edi_seg_data%rowtype index by binary_integer;
        l_claim_header_tbl edi_seg_data_type;
    begin
        select
            cee_seg_data.*
        bulk collect
        into l_claim_header_tbl
        from
            (
                select
                    rownum rec_num,
                    cee.*
                from
                    claim_edi_external cee
            ) cee_seg_data
        where
            cee_seg_data.rec_num between p_begin_header_rec_in and p_end_header_rec_in;

        if l_claim_header_tbl.count > 0 then
            for i in l_claim_header_tbl.first..l_claim_header_tbl.last loop
            --1. ST segment details
                if ( l_claim_header_tbl(i).seg = 'ST' ) then
                    p_header_row_out(p_rec_cntr_in).claim_header_id := claim_edi_hdr_seq.nextval;
                    p_claim_header_id_out := p_header_row_out(p_rec_cntr_in).claim_header_id;
                    p_header_row_out(p_rec_cntr_in).creation_date := systimestamp;
                    p_header_row_out(p_rec_cntr_in).last_updated_date := systimestamp;
                    p_header_row_out(p_rec_cntr_in).trans_set_cntrl_num := l_claim_header_tbl(i).s02;
                    p_header_row_out(p_rec_cntr_in).batch_number := 'EDI' || to_char(sysdate, 'yyyymmddhhmiss');
                end if;

            --2. BHT segment details
                if ( l_claim_header_tbl(i).seg = 'BHT' ) then
                    p_header_row_out(p_rec_cntr_in).hrrchcl_struct_code := l_claim_header_tbl(i).s01;
                    p_header_row_out(p_rec_cntr_in).trans_set_prps_code := l_claim_header_tbl(i).s02;
                    p_header_row_out(p_rec_cntr_in).trans_ref_id := l_claim_header_tbl(i).s03;
                    p_header_row_out(p_rec_cntr_in).trans_create_dt := l_claim_header_tbl(i).s04;
                    p_header_row_out(p_rec_cntr_in).trans_create_time := l_claim_header_tbl(i).s05;
                    p_header_row_out(p_rec_cntr_in).trans_type_code := l_claim_header_tbl(i).s06;
                end if;

            --3. REF segment details
                if ( l_claim_header_tbl(i).seg = 'REF' ) then
                    p_header_row_out(p_rec_cntr_in).ref_id_qlfr := l_claim_header_tbl(i).s01;
                    p_header_row_out(p_rec_cntr_in).ref_id := l_claim_header_tbl(i).s02;
                end if;

            --4. NM1 segment details
                if ( l_claim_header_tbl(i).seg = 'NM1' ) then
                    if ( l_claim_header_tbl(i).s01 = '41' ) then
                        p_header_row_out(p_rec_cntr_in).submitter_idntfr_code := l_claim_header_tbl(i).s01;
                        p_header_row_out(p_rec_cntr_in).submitter_type_qlfr := l_claim_header_tbl(i).s02;
                        p_header_row_out(p_rec_cntr_in).submitter_last_name := l_claim_header_tbl(i).s03;
                        p_header_row_out(p_rec_cntr_in).submitter_first_name := l_claim_header_tbl(i).s04;
                        p_header_row_out(p_rec_cntr_in).submitter_middl_name := l_claim_header_tbl(i).s05;
                        p_header_row_out(p_rec_cntr_in).sumbitter_code_qlfr := l_claim_header_tbl(i).s08;
                        p_header_row_out(p_rec_cntr_in).submitter_prim_id_num := l_claim_header_tbl(i).s09;
                    elsif ( l_claim_header_tbl(i).s01 = '40' ) then
                        p_header_row_out(p_rec_cntr_in).rcvr_entty_id_cd := l_claim_header_tbl(i).s01;
                        p_header_row_out(p_rec_cntr_in).rcvr_entty_type_qlfr := l_claim_header_tbl(i).s02;
                        p_header_row_out(p_rec_cntr_in).rcvr_nm := l_claim_header_tbl(i).s03;
                        p_header_row_out(p_rec_cntr_in).rcvr_cd_qlfr := l_claim_header_tbl(i).s08;
                        p_header_row_out(p_rec_cntr_in).rcvr_id_cd := l_claim_header_tbl(i).s09;
                    end if;
                end if;

            --5. PER segment details
                if ( l_claim_header_tbl(i).seg = 'PER' ) then
                    p_header_row_out(p_rec_cntr_in).submitter_cont_func_code := l_claim_header_tbl(i).s01;
                    p_header_row_out(p_rec_cntr_in).submitter_cont_name := l_claim_header_tbl(i).s02;
                    p_header_row_out(p_rec_cntr_in).comm_num_qlfr := l_claim_header_tbl(i).s03;
                    p_header_row_out(p_rec_cntr_in).comm_num := l_claim_header_tbl(i).s04;
                    p_header_row_out(p_rec_cntr_in).comm_num_qlfr_situational := l_claim_header_tbl(i).s05;
                    p_header_row_out(p_rec_cntr_in).comm_num_situational := l_claim_header_tbl(i).s06;
                end if;

            end loop; -- l_claim_header_tbl(i)
            insert_header_row(p_header_row_out);
        end if; --- end of if l_claim_header_tbl.count > 0
    exception
        when others then
   --dbms_output.put_line(sqlerrm(sqlcode));
            pc_log.log_error('CLAIM_EDI', 'GET_CLAIM_HEADER_SEG' || sqlerrm);
            raise;
    end get_claim_header_seg;

-------------------------------------------------------------------
-- 4a. This method fetches claim detail's begin and end rows
-------------------------------------------------------------------
    function get_claim_det (
        p_from_row in number,
        p_to_row   in number
    ) return claim_detail_table_t
        pipelined
        deterministic
    is

        l_cursor       sys_refcursor;
        l_record       claim_detail_row_t;
        l_cur_rec      claim_edi_external_v%rowtype;
        l_record_index number := 0;
        l_claim_number varchar2(255);
    begin

    /** query each subscriber and work your way up ***/
    /** only thing that I dont have here is the provider info ***/

        open l_cursor for select
                                                *
                                            from
                                                claim_edi_external_v x
                          where
                                  rn >= p_from_row
                              and rn <= p_to_row;

        loop
       --  l_record_index := 0;
       -- Fetch the next row from the result set
            fetch l_cursor into l_cur_rec;
          -- Exit if there are no more rows
            exit when l_cursor%notfound;

         -- claim information
            if
                l_claim_number is not null
                and l_cur_rec.seg = 'CLM'
                and l_claim_number <> l_cur_rec.s01
            then
                pipe row ( l_record );
            end if;

            if l_cur_rec.seg = 'CLM' then
                l_record.claim_number := l_cur_rec.s01;
                l_claim_number := l_record.claim_number;
                l_record.claim_amount := l_cur_rec.s02;
                l_record.eoq_reqd :=
                    case
                        when l_cur_rec.s09 = 'N' then
                            'Y'
                        else 'N'
                    end;
            end if;
         -- patient information
            if
                l_cur_rec.seg = 'AMT'
                and l_cur_rec.s01 = 'F5'
            then
                l_record.amount_to_be_paid := l_cur_rec.s02;
            end if;

         -- claim note -- GN added on 04/07/2011
            if l_cur_rec.seg = 'NTE' then
                l_record.claim_note := l_cur_rec.s02;
            end if;

            if
                l_cur_rec.seg = 'NM1'
                and l_cur_rec.s01 = 'IL'
            then
                l_record.subscriber_name := l_cur_rec.s03
                                            || ' '
                                            || l_cur_rec.s04
                                            || ' '
                                            || l_cur_rec.s05;

                l_record.subscriber_number := l_cur_rec.s09;
                l_record_index := l_cur_rec.rn;
            end if;

            if
                l_cur_rec.seg = 'N3'
                and l_record_index + 1 = l_cur_rec.rn
            then
                l_record.subscriber_address1 := l_cur_rec.s01;
                l_record.subscriber_address2 := l_cur_rec.s02;
            end if;

            if
                l_cur_rec.seg = 'N4'
                and l_record_index + 2 = l_cur_rec.rn
            then
                l_record.subscriber_city := l_cur_rec.s01;
                l_record.subscriber_state := l_cur_rec.s02;
                l_record.subscriber_zip := l_cur_rec.s03;
                l_record.subscriber_country := l_cur_rec.s04;
            end if;

            if
                l_cur_rec.seg = 'NM1'
                and l_cur_rec.s01 = 'QC'
            then
                l_record.patient_last_name := l_cur_rec.s03;
                l_record.patient_first_name := l_cur_rec.s04;
                l_record.patient_middle_name := l_cur_rec.s05;
                l_record.patient_number := l_cur_rec.s09;
            end if;

        end loop;

        pipe row ( l_record );

    -- Close the cursor and exit
        close l_cursor;
        return;
    end get_claim_det;

-------------------------------------------------------------------
-- 4b. This method claim service detail's begin and end rows
-------------------------------------------------------------------
    function get_claim_service_det (
        p_from_row in number,
        p_to_row   in number
    ) return claim_service_detail_table_t
        pipelined
        deterministic
    is
        l_cursor            sys_refcursor;
        l_record            claim_service_detail_row_t;
        l_cur_rec           claim_edi_external_v%rowtype;
        l_claim_line_number varchar2(255);
    begin
        open l_cursor for select
                                                *
                                            from
                                                claim_edi_external_v x
                          where
                                  rn >= p_from_row
                              and rn <= p_to_row;

        loop
      -- Fetch the next row from the result set
            fetch l_cursor into l_cur_rec;

          -- Exit if there are no more rows
            exit when l_cursor%notfound;
            if
                l_claim_line_number is not null
                and l_cur_rec.seg = 'LX'
                and l_claim_line_number <> l_cur_rec.s01
            then
                pipe row ( l_record );
            end if;

            if
                l_cur_rec.seg = 'NM1'
                and l_cur_rec.s01 = '82'
            then
                l_record.service_provider := l_cur_rec.s03
                                             || ' '
                                             || l_cur_rec.s04
                                             || ' '
                                             || l_cur_rec.s05; -- Firstname||Lastname|Middlename
                l_record.provider_acc_num := l_cur_rec.s09;
            end if;

            if
                l_cur_rec.seg = 'DTP'
                and l_cur_rec.s01 = '472'
            then
                l_record.service_date := l_cur_rec.s03;
            end if;

            if l_cur_rec.seg = 'LX' then
                l_record.claim_line_number := l_cur_rec.s01;
                l_claim_line_number := l_record.claim_line_number;
            end if;

            if l_cur_rec.seg = 'SV1' then
                l_record.service_code := l_cur_rec.s01;
                l_record.service_cost := l_cur_rec.s02;
            end if;

      -- Check if the row should be sent based on the filter criteria
       -- Pipe the row of data to the caller
        end loop;

        pipe row ( l_record );

    -- Close the cursor and exit
        close l_cursor;
        return;
    end get_claim_service_det;

-------------------------------------------------------------------
-- 5a. This method gets person id for the given subscriber number -- Geetha added on 04/08/2011
-------------------------------------------------------------------
    function get_pers_id (
        p_sbscrbr_nmbr_in in claim_edi_detail.sbscrbr_nmbr%type
    ) return number is
        l_pers_id person.pers_id%type;
    begin
        select
            pers_id
        into l_pers_id
        from
            person
        where
            orig_sys_vendor_ref = p_sbscrbr_nmbr_in;

        return l_pers_id;
    exception
        when no_data_found then
            return l_pers_id;
        when others then
            pc_log.log_error('CLAIM_EDI', 'GET_PERS_ID' || sqlerrm);
            raise;
    end get_pers_id;

-------------------------------------------------------------------
-- 6. This method gets account id and account number for a given person id -- Geetha added on 04/08/2011
-------------------------------------------------------------------
    procedure get_acc_details (
        p_pers_id_in  in person.pers_id%type,
        p_acc_id_out  out account.acc_id%type,
        p_acc_num_out out account.acc_num%type
    ) is
    begin
        select
            acc_id,
            acc_num
        into
            p_acc_id_out,
            p_acc_num_out
        from
            account
        where
            pers_id = p_pers_id_in;

    exception
        when no_data_found then
            p_acc_id_out := null;
            p_acc_num_out := null;
        when others then
            pc_log.log_error('CLAIM_EDI', 'GET_ACC_DETAILS' || sqlerrm);
            raise;
    end get_acc_details;

-------------------------------------------------------------------
-- 7. This method imports the EDI claims -- Geetha added on 04/09/2011
-------------------------------------------------------------------
    procedure import_edi_claims (
        p_user_id_in      in number,
        p_batch_number_in in varchar2
    ) as

        app_exception exception;
        l_error_msg        varchar2(150);
        l_first_detail_row boolean;
        l_acc_id           number;
        l_acc_num          varchar2(20);
        l_claim_id         number;
        l_return_status    varchar2(1);
        l_error_message    varchar2(150);
        l_idx              number;
        l_claim_method     varchar2(5);
        l_pay_reason       varchar2(3);
        l_bank_acct_id     number;
        l_service_start_dt date;
        l_service_end_dt   date;
        l_vendor_id        number;
        l_claim_amount     number;
        l_claim_type       varchar2(30);
        l_service_provider pc_online_enrollment.varchar2_tbl;
        l_service_date     pc_online_enrollment.varchar2_tbl;
        l_service_end_date pc_online_enrollment.varchar2_tbl;
        l_service_name     pc_online_enrollment.varchar2_tbl;
        l_service_price    pc_online_enrollment.varchar2_tbl;
        l_patient_dep_name pc_online_enrollment.varchar2_tbl;
        l_note             pc_online_enrollment.varchar2_tbl;
        l_medical_code     pc_online_enrollment.varchar2_tbl;
        l_service_type     varchar2(30);
    begin
  -- for cheyenne, one check per member and provider combination. for others one check per one claim number
  -- so outer loop will not include claim number for chyenne but will for others
  -- and, inner loop where condition will not be restricted by claim number for cheyenne, but will be for others
  -- amt calculation will not include claim_number in where clause but will for others
  -- I am thinking that in order to process claim effectively will combine similar provider
  -- and payout , if some one complains then will decide
        for x in (
            select
                acc_id,
                pers_id,
                bllng_prvdr_nm,
                rmbrsmnt_mthd,
                decode(rmbrsmnt_mthd,
                       'SUBSCRIBER',
                       sbscrbr_stt_cd,
                       nvl(bllng_prvdr_stt_cd, pay_to_prvdr_stt_cd))   state,
                decode(rmbrsmnt_mthd,
                       'SUBSCRIBER',
                       sbscrbr_city,
                       nvl(bllng_prvdr_city, pay_to_prvdr_city))       city,
                decode(rmbrsmnt_mthd,
                       'SUBSCRIBER',
                       sbscrbr_addrss1,
                       nvl(bllng_prvdr_addrss1, pay_to_prvdr_addrss1)) address,
                decode(rmbrsmnt_mthd,
                       'SUBSCRIBER',
                       sbscrbr_zip,
                       nvl(bllng_prvdr_zip, pay_to_prvdr_zip))         zip,
                'HRA'                                                  service_plan_type,
                bllng_prvdr_accnt_nmbr,
                acc_num,
                sum(patient_amnt_paid)                                 claim_amount --depending on the agreement, either service amount or patient amnt paid for now let us do patient amnt paid
            from
                claim_edi_detail
            where
                    status_cd = 'NEW'
                and batch_number = p_batch_number_in
            group by
                acc_id,
                pers_id,
                bllng_prvdr_nm,
                rmbrsmnt_mthd,
                decode(rmbrsmnt_mthd,
                       'SUBSCRIBER',
                       sbscrbr_stt_cd,
                       nvl(bllng_prvdr_stt_cd, pay_to_prvdr_stt_cd)),
                decode(rmbrsmnt_mthd,
                       'SUBSCRIBER',
                       sbscrbr_city,
                       nvl(bllng_prvdr_city, pay_to_prvdr_city)),
                decode(rmbrsmnt_mthd,
                       'SUBSCRIBER',
                       sbscrbr_addrss1,
                       nvl(bllng_prvdr_addrss1, pay_to_prvdr_addrss1)),
                decode(rmbrsmnt_mthd,
                       'SUBSCRIBER',
                       sbscrbr_zip,
                       nvl(bllng_prvdr_zip, pay_to_prvdr_zip)),
                bllng_prvdr_accnt_nmbr,
                acc_num
        ) loop
            begin
                pc_log.log_error('IMPORT_UPLOADED_CLAIMS', x.acc_id);
                if x.claim_amount = 0 then
                    update claim_edi_detail
                    set
                        status_cd = 'PROCESSED',
                        error_message = 'Claim Amount is Zero, nothing to pay out'
                    where
                            acc_id = x.acc_id
                        and bllng_prvdr_nm = x.bllng_prvdr_nm
                        and status_cd = 'NEW';

                else
                    l_service_type := x.service_plan_type;
                    if x.service_plan_type = 'HRA' then
                        l_service_type := pc_benefit_plans.get_hra_ben_plan_type(x.acc_id, 'HRA');
                    end if;

                    l_return_status := 'S';
                    l_vendor_id := pc_payee.get_payee(x.acc_id, l_service_type, x.address, x.city, x.state,
                                                      x.zip);

                    if l_vendor_id is null then
                        l_return_status := 'S';
                    else
                        pc_payee.add_payee(
                            p_payee_name          => x.bllng_prvdr_nm,
                            p_payee_acc_num       => x.bllng_prvdr_accnt_nmbr,
                            p_address             => x.address,
                            p_city                => x.city,
                            p_state               => x.state,
                            p_zipcode             => x.zip,
                            p_acc_num             => x.acc_num,
                            p_user_id             => p_user_id_in,
                            p_orig_sys_vendor_ref => x.bllng_prvdr_accnt_nmbr,
                            p_acc_id              => x.acc_id,
                            p_payee_type          => l_service_type,
                            p_payee_tax_id        => null,
                            x_vendor_id           => l_vendor_id,
                            x_return_status       => l_return_status,
                            x_error_message       => l_error_message
                        );

                        if l_return_status <> 'S' then
                            update claim_edi_detail
                            set
                                status_cd = 'ERROR',
                                error_message = 'Error in creating vendor ' || l_error_message
                            where
                                    acc_id = x.acc_id
                                and bllng_prvdr_nm = x.bllng_prvdr_nm
                                and bllng_prvdr_accnt_nmbr = x.bllng_prvdr_accnt_nmbr
                                and ( sbscrbr_addrss1 = x.address
                                      or bllng_prvdr_addrss1 = x.address
                                      or pay_to_prvdr_addrss1 = x.address )
                                and ( sbscrbr_stt_cd = x.state
                                      or bllng_prvdr_stt_cd = x.state
                                      or pay_to_prvdr_stt_cd = x.state )
                                and ( sbscrbr_zip = x.zip
                                      or bllng_prvdr_zip = x.zip
                                      or pay_to_prvdr_zip = x.zip )
                                and ( sbscrbr_city = x.city
                                      or bllng_prvdr_city = x.city
                                      or pay_to_prvdr_city = x.city )
                                and status_cd = 'NEW';

                            raise app_exception;
                        end if;

                    end if;

                end if;

                if x.rmbrsmnt_mthd = 'SUBSCRIBER' then
                    l_pay_reason := 12;
                    l_claim_type := 'SUBSCRIBER_EDI';
                end if;

             -- if we didnt find bank account id and vendor id then we will just pay the account holder
             -- by check
                l_return_status := 'S';
                pc_log.log_error('IMPORT CLAIMS, claim amount', x.claim_amount);
                if x.service_plan_type in ( 'HRA', 'HR5', 'HRP' ) then
                    pc_claim.create_hra_disbursement(
                        p_acc_num            => x.acc_num,
                        p_acc_id             => x.acc_id,
                        p_vendor_id          => l_vendor_id,
                        p_vendor_acc_num     => x.bllng_prvdr_accnt_nmbr,
                        p_amount             => x.claim_amount,
                        p_patient_name       => null,
                        p_note               => 'Claim from EDI',
                        p_user_id            => p_user_id_in,
                        p_service_start_date => null,
                        p_service_end_date   => null,
                        p_date_received      => sysdate,
                        p_service_type       => l_service_type,
                        p_claim_source       => 'EDI',
                        p_claim_method       => l_claim_type,
                        p_bank_acct_id       => l_bank_acct_id,
                        p_pay_reason         => l_pay_reason,
                        p_doc_flag           => 'N',
                        p_insurance_category => null,
                        p_claim_category     => null,
                        p_memo               => null,
                        x_claim_id           => l_claim_id,
                        x_return_status      => l_return_status,
                        x_error_message      => l_error_message
                    );

                    if l_return_status <> 'S' then
                        update claim_edi_detail
                        set
                            status_cd = 'ERROR',
                            error_message = 'Error in creating claim ' || l_error_message
                        where
                                acc_id = x.acc_id
                            and bllng_prvdr_nm = x.bllng_prvdr_nm
                            and status_cd = 'NOT_INTERFACED';

                        raise app_exception;
                    end if;

                end if;

                if l_claim_id is not null then
                    for xx in (
                        select distinct
                            *
                        from
                            claim_edi_service_detail
                        where  --acc_id = x.acc_id -- Geetha: do you want to add acc_id in service detail table too?
                         --and
                                service_provider_name = x.bllng_prvdr_nm
                            and status_cd = 'NEW'
                            and batch_number = p_batch_number_in
                    ) loop
                        l_service_provider(1) := xx.service_provider_name;
                        l_service_date(1) := to_char(to_date(xx.service_start_date, 'YYYY-MM-DD'), 'MM/DD/YYYY');

                        l_service_end_date(1) := to_char(to_date(xx.service_end_date, 'YYYY-MM-DD'), 'MM/DD/YYYY');

                        l_service_name(1) := xx.service_provider_name;
                        l_service_price(1) := xx.service_monetary_amount;
                        l_patient_dep_name(1) := xx.patient_name;
                   -- l_note (1)            := xx.note;
                        l_medical_code(1) := null;
                        l_return_status := 'S';
                   /* PC_CLAIM_DETAIL.INSERT_CLAIM_DETAIL
                       (  p_claim_id          => l_claim_id,
                          P_SERICE_PROVIDER   => l_service_provider,
                          P_SERVICE_DATE      => l_service_date,
                          P_SERVICE_END_DATE  => l_service_end_date,
                          P_SERVICE_NAME      => l_service_name,
                          P_SERVICE_PRICE     => l_service_price,
                          P_PATIENT_DEP_NAME  => l_patient_dep_name,
                          p_medical_code      => l_medical_code,
                          P_SERVICE_CODE      => 0, -- xx.claim_number,  -- Geetha: for now just put 0 to be compilable. but we'll need to add claim number in service table too then, right?
                          p_note              => l_note,
                          P_CREATED_BY        => p_user_id_in,
                          p_creation_date     => sysdate,
                          P_LAST_UPDATED_BY   => p_user_id_in,
                          P_LAST_UPDATE_DATE  => sysdate,
                          X_RETURN_STATUS     => l_RETURN_STATUS,
                          X_ERROR_MESSAGE     => l_ERROR_MESSAGE ); */

                        if l_return_status <> 'S' then
                            update claim_edi_detail
                            set
                                status_cd = 'ERROR',
                                error_message = 'Error in creating claim detail ' || l_error_message
                            where
                                    batch_number = p_batch_number_in
                                and acc_id = x.acc_id
                                and bllng_prvdr_nm = x.bllng_prvdr_nm
                                and status_cd = 'NEW';

                            raise app_exception;
                        else
                            update claim_edi_detail
                            set
                                status_cd = 'INTERFACED'
                          -- ,   claim_id = l_claim_id -- Geetha claim_id column not in this table, which column did you intend toput here?
                            where
                                    batch_number = p_batch_number_in
                                and acc_id = x.acc_id
                                and bllng_prvdr_nm = x.bllng_prvdr_nm
                                and status_cd = 'NEW';

                        end if;

                    end loop;
            /*  Geetha: commented because these columns are not in claim table,
            UPDATE claim
              set    prov_name = x.provider_name
                   , claim_amount = x.claim_amount
              where  claim_id = l_claim_id;
              */
                end if; --l_CLAIM_ID
    -- END IF;
            exception
                when app_exception then
                    pc_log.log_error('IMPORT_UPLOADED_CLAIMS', 'Error Message ' || l_error_message);
                    null;
                when others then
                    l_error_message := sqlerrm;
                    update claim_edi_detail
                    set
                        status_cd = 'ERROR',
                        error_message = 'Error in creating claim ' || l_error_message
                    where
                            acc_id = x.acc_id
                        and bllng_prvdr_nm = x.bllng_prvdr_nm
                        and status_cd = 'NOT_INTERFACED';

            end;
        end loop;
    end import_edi_claims;

end claim_edi;
/


-- sqlcl_snapshot {"hash":"5f5d8e67df65cbf54a5e751a4efdb66b33d0baa6","type":"PACKAGE_BODY","name":"CLAIM_EDI","schemaName":"SAMQA","sxml":""}