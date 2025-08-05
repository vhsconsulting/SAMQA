-- liquibase formatted sql
-- changeset SAMQA:1754374143241 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\create_cheyenne_dep_missed.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/create_cheyenne_dep_missed.sql:null:6cafb52b3fadd342d06b2dff57e421a62f09858a:create

create or replace procedure samqa.create_cheyenne_dep_missed as

    l_account_type   varchar2(30);
    l_entrp_acc_id   number;
    l_entrp_acc_num  varchar2(30);
    l_entrp_id       number;
    l_duplicate_flag varchar2(30);
    l_pers_id        number;
    l_acc_id         number;
    l_acc_num        varchar2(30);
    l_benefit_plan   varchar2(30);
    l_ben_plan_id    number;
    l_ee_ben_plan    varchar2(30);
    l_sponsor_id     varchar2(30);
    l_status         varchar2(255) := 'SUCCESS';
    l_sqlerrm        varchar2(3200);
begin
    for a in (
        select
            det.birth_date,
            det.ssn,
            max(det.benefit_begin_dt)   benefit_begin_dt,
            det.coverage_level,
            det.email,
            det.phone_work,
            det.phone_home,
            det.orig_system_ref,
            det.subscriber_number,
            case
                when det.gender not in ( 'M', 'F' ) then
                    'M'
                else
                    det.gender
            end                         gender,
            det.first_name,
            det.middle_name,
            det.last_name,
            det.address,
            det.city,
            det.state,
            det.zip,
            max(hdr.header_id)          header_id,
            max(detail_id)              detail_id,
            hdr.sponsor_id,
            max(det.mass_enrollment_id) mass_enrollment_id,
            decode(relationship_cd, '19', 3, '01', 2,
                   4)                   relat_code,
            c.pers_id
  --  , c.mass_enrollment_id
        from
            enrollment_edi_detail det,
            enrollment_edi_header hdr,
            person                c
        where
                det.person_type = 'DEPENDANT'
            and hdr.header_id = det.header_id
     -- AND   det.SSN is not null
            and c.orig_sys_vendor_ref like substr(det.subscriber_number,
                                                  1,
                                                  length(det.subscriber_number) - 2)
                                           || '01'
            and det.maintenance_cd in ( '030', '021' )
            and det.pers_id is null
            and det.error_code is null
        group by
            det.birth_date,
            det.ssn,
            det.coverage_level,
            det.email,
            det.phone_work,
            det.phone_home,
            det.orig_system_ref,
            det.subscriber_number,
            case
                when det.gender not in ( 'M', 'F' ) then
                        'M'
                else
                    det.gender
            end,
            det.first_name,
            det.middle_name,
            det.last_name,
            det.address,
            det.city,
            det.state,
            det.zip,
            hdr.sponsor_id,
            decode(relationship_cd, '19', 3, '01', 2,
                   4),
            c.pers_id
    ) loop
        begin
            select
                pers_seq.nextval
            into l_pers_id
            from
                dual;

            insert into person (
                pers_id,
                first_name,
                middle_name,
                last_name,
                birth_date,
                gender,
                ssn,
                relat_code,
                note,
                pers_main,
                person_type,
                mass_enrollment_id
            )
                select
                    l_pers_id,
                    initcap(a.first_name),
                    initcap(substr(a.middle_name, 1, 1)),
                    initcap(a.last_name),
                    to_date(a.birth_date, 'RRRRMMDD'),
                    a.gender,
                    format_ssn(a.ssn),
                    a.relat_code,
                    '837 EDI Enrollment',
                    a.pers_id,
                    'DEPENDANT',
                    a.mass_enrollment_id
                from
                    dual
                where
                    not exists (
                        select
                            *
                        from
                            person c
                        where
                            replace(c.ssn, '-') = a.ssn
                    );

            update enrollment_edi_detail
            set
                status_cd = 'INTERFACED',
                last_update_date = sysdate,
                pers_id = l_pers_id
            where
                detail_id = a.detail_id;

        exception
            when others then
                l_sqlerrm := sqlerrm;
                update enrollment_edi_detail
                set
                    error_code = l_sqlerrm,
                    status_cd = 'INTERFACE_ERROR',
                    last_update_date = sysdate
                where
                        status_cd = 'PROCESSED'
                    and detail_id = a.detail_id;

        end;
    end loop;
end;
/

