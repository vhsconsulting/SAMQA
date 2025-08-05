create or replace procedure samqa.update_orig_sys_ref_person as
begin
    for x in (
        select distinct
            det.policy_number,
            d.pers_id
        from
            enrollment_edi_detail det,
            enrollment_edi_header hdr,
            person                d
        where
                det.person_type = 'SUBSCRIBER'
            and hdr.header_id = det.header_id
            and format_ssn(det.subscriber_number) = d.ssn
            and d.orig_sys_vendor_ref is null
            and det.maintenance_cd in ( '030', '021' )
    ) loop
        update person
        set
            last_update_date = sysdate,
            last_updated_by = 0,
            orig_sys_vendor_ref = x.policy_number
        where
            pers_id = x.pers_id;

    end loop;
end;
/


-- sqlcl_snapshot {"hash":"aab221384a8cf9ccd2b694d4d22cc29a672f3527","type":"PROCEDURE","name":"UPDATE_ORIG_SYS_REF_PERSON","schemaName":"SAMQA","sxml":""}