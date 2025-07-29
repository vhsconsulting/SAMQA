create or replace procedure samqa.download_pdf_from_blob as

    l_file     utl_file.file_type;
    l_buffer   raw(32767);
    l_amount   binary_integer := 32767;
    l_pos      number := 1;
    l_blob     blob;
    l_blob_len number;
begin
    for x in ( 
	/* select b.acc_num, a.document_name, b.ENROLLMENT_SOURCE,A.ATTACHMENT,a.attachment_id
	from file_attachments a, account b
	where a.entity_id (+)= b.acc_id
	and a.document_purpose(+) = 'APP'
	and  a.entity_name(+)= 'ACCOUNT'
	AND b.acc_num in ('ICA007115','ICA010387','ICA011990','ICA014908','ICA015357','ICA018270',
	             'ICA019219','ICA020505','ICA022626','DHS023524','ICA025158','ICA026313','ICA027664',
		     'ICA028330','ICA028668','ICA029381','ICA029893','ICA032028','ICA033333','ICA251089',
		     'ICA034861','ICA036054','ICA251772','ICA251855','ICA042717','ICA043845','ICA044489',
		     'ICA253476','ICA253704','ICA253861','ICA254031','ICA046989','ICA254402','ICA254540',
		     'ICA257008','ICA257986','ICA050916','ICA259245','ICA260100','ICA264691','ICA265360',
		     'ICA265806','ICA267485','ICA270603','IMN271551','ICA064413','ICA064643','ICA065048',
		     'ICA065869','ICA066405','ICA276810','ITX279394','ICA279528','ICA068950','ICA280121',
		     'ICA280272','ICA280941','ITX281602','ICA284181','ICA285401','ICA287040','42438',
		     'ICA072020','ICA291425','ICA072465','ICA291792','ICA292005','ICA292187','ICA292348',
		     'ICA292487','ICA292639','ICA292872','ICA076111','ITX293476','ICA077375','ICA294258',
		     'ICA294797','ICA296002','ICA079972','ICA296865','ICA297145','ITX297498','ICA298197',
		     'INV299017','ICA082320','ITX300118','ICA300341','ICO300684','ICA083875','ICA301246',
		     'ICA085070','ICA301666','ICA301776','ICA086621','ICA302565','ICA087213','ICA303042',
		     'ICA303257','ICA303415','ICA303608','ICA303902','ICA304057','ICT088964','ICA304504',
		     'ICA111962','ITX305180','ICA305377','ICA112876','ICA113209','ICA113350','ICA113478',
		     'ITX306073','ICA114145','ICA114469','ITX306957','ICA115398','ICA115771','ICA308518',
		     'ICA309157','ICA309364','ICA309499','ICA309659','ITX309845','ICA117831','ICA118152',
		     'IIL310302','ICA310533','ICA119096','ICA119444','INC119817','ICA311410','ICA311691',
		     'ICA312190','ITX120802','ICA312601','ICA121282','IMD313190','ICA313345','ICA313484',
		     'ICA313610','ICA313896','ICA123257','ITX316295','ITX317616','IAK319075','ICA124343',
		     'ICA321536','ICA322235','ICA322856','ICA323712','ICA324358','ICA324914','ICA325458',
		     'ICA325997','ICA327695','INC328072','ICA328201','ICA328334','ICA328497','ICA329875')*/
        select
            a.attachment_id,
            a.attachment,
            a.document_name,
            c.acc_num,
            b.claim_id
        from
            file_attachments a,
            claimn           b,
            account          c
        where
                a.created_by = 1141
            and a.entity_name = 'CLAIMN'
            and replace(a.entity_id, '-') = b.claim_id
            and b.pers_id = c.pers_id
    ) loop
        if x.attachment_id is not null then
            l_blob_len := dbms_lob.getlength(x.attachment);
            l_pos := 1;
            dbms_output.put_line('l_blob_len ' || l_blob_len);
    -- Open the destination file.
            l_file := utl_file.fopen('WEBSITE_FORMS_DIR', x.acc_num
                                                          || ':'
                                                          || x.claim_id
                                                          || ':'
                                                          || x.document_name, 'wb', 32767);

            if l_blob_len > 0 then
                while l_pos < l_blob_len loop
                    dbms_lob.read(x.attachment, l_amount, l_pos, l_buffer);
                    utl_file.put_raw(l_file, l_buffer, true);
                    l_pos := l_pos + l_amount;
                end loop;
            end if;
  -- Close the file.
            utl_file.fclose(l_file);
        end if;
    end loop;
end download_pdf_from_blob;
/


-- sqlcl_snapshot {"hash":"3c1488c4c208aaa728d4fde9c4c5a33dec6e8fda","type":"PROCEDURE","name":"DOWNLOAD_PDF_FROM_BLOB","schemaName":"SAMQA","sxml":""}