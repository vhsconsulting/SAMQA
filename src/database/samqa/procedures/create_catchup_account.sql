create or replace procedure samqa.create_catchup_account (
    p_pers_id       in number,
    p_user_id       in number,
    x_error_message out varchar2
) is
    l_acc_id  number;
    l_pers_id number;
begin
    for x in (
        select
            a.first_name,
            a.last_name,
            a.middle_name,
            c.address,
            c.city,
            c.state,
            c.zip,
            c.phone_day,
            c.email,
            a.ssn,
            a.gender,
            a.relat_code,
            a.note,
            a.birth_date,
            a.title,
            b.broker_id,
            b.salesrep_id,
            b.fee_setup,
            b.plan_code,
            b.fee_maint,
            b.lang_perf,
            a.pers_main,
            b.acc_num
        from
            person  a,
            account b,
            person  c
        where
                a.pers_main = b.pers_id
            and a.pers_main = c.pers_id
            and a.pers_id = p_pers_id
            and b.pers_id = c.pers_id
    ) loop
        insert into person (
            pers_id,
            first_name,
            middle_name,
            last_name,
            birth_date,
            title,
            gender,
            ssn,
            address,
            city,
            state,
            zip,
            phone_day,
            email,
            relat_code,
            note,
            person_type,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            pers_main
        ) values ( pers_seq.nextval,
                   x.first_name,
                   x.middle_name,
                   x.last_name,
                   x.birth_date,
                   x.title,
                   x.gender,
                   x.ssn,
                   x.address,
                   x.city,
                   x.state,
                   x.zip,
                   x.phone_day,
                   x.email,
                   1,
                   'Online Enrollment',
                   'SUBSCRIBER',
                   sysdate,
                   421,
                   sysdate,
                   421,
                   x.pers_main ) returning pers_id into l_pers_id;

        insert into account (
            acc_id,
            pers_id,
            acc_num,
            plan_code,
            start_date,
            broker_id,
            note,
            fee_setup,
            fee_maint,
            reg_date,
            account_status,
            complete_flag,
            signature_on_file,
            hsa_effective_date,
            account_type,
            enrollment_source,
            salesrep_id,
            lang_perf,
            catchup_flag
        ) values ( acc_seq.nextval,
                   l_pers_id,
                   substr(x.acc_num,
                          4,
                          length(x.acc_num)),
                   x.plan_code,
                   sysdate,
                   x.broker_id,
                   'Catchup Contribution Account',
                   x.fee_setup,
                   x.fee_maint,
                   sysdate,
                   1,
                   1,
                   'Y',
                   sysdate,
                   'HSA',
                   'CATCHUP',
                   x.salesrep_id,
                   x.lang_perf,
                   'Y' ) returning acc_id into l_acc_id;

    end loop;
exception
    when others then
        x_error_message := sqlerrm;
end;
/


-- sqlcl_snapshot {"hash":"d7f325ae40c77defaf0b5aee84091565d153db8d","type":"PROCEDURE","name":"CREATE_CATCHUP_ACCOUNT","schemaName":"SAMQA","sxml":""}