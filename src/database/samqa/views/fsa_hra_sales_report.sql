create or replace force editionable view samqa.fsa_hra_sales_report (
    entrp_id,
    employer_name,
    plan_year,
    plan_type,
    no_of_employees,
    acc_num,
    salesrep_id,
    salesrep_name
) as
    select
        a.entrp_id,
        pc_entrp.get_entrp_name(a.entrp_id)         employer_name,
        plan_year,
        plan_type,
        count(a.acc_id)                             no_of_employees,
        acc_num,
        salesrep_id,
        pc_account.get_salesrep_name(b.salesrep_id) salesrep_name
    from
        (
            select
                listagg(plan_type, ',') within group(
                order by
                    plan_type
                ) plan_type,
                acc_id,
                plan_year,
                entrp_id
            from
                (
                    select unique
                        det.plan_type,
                        det.acc_id,
                        to_char(det.plan_end_date, 'YYYY') plan_year,
                        main.entrp_id
                    from
                        ben_plan_enrollment_setup det,
                        ben_plan_enrollment_setup main
                    where
                            det.ben_plan_id_main = main.ben_plan_id
                        and det.plan_type in ( 'FSA', 'DCA', 'LPF' )
                        and det.status in ( 'A', 'I' )
                )
            group by
                acc_id,
                plan_year,
                entrp_id
            union
            select
                'HRA',
                det.acc_id,
                to_char(det.plan_end_date, 'YYYY') plan_year,
                main.entrp_id
            from
                ben_plan_enrollment_setup det,
                ben_plan_enrollment_setup main
            where
                    det.ben_plan_id_main = main.ben_plan_id
                and det.status in ( 'A', 'I' )
                and det.plan_type in ( 'HRA', 'HR5', 'ACO', 'HRP', 'HR4' )
            group by
                det.acc_id,
                to_char(det.plan_end_date, 'YYYY'),
                main.entrp_id
            union
            select
                listagg(plan_type, ',') within group(
                order by
                    plan_type
                ) plan_type,
                acc_id,
                plan_year,
                entrp_id
            from
                (
                    select unique
                        det.plan_type,
                        det.acc_id,
                        to_char(det.plan_end_date, 'YYYY') plan_year,
                        main.entrp_id
                    from
                        ben_plan_enrollment_setup det,
                        ben_plan_enrollment_setup main
                    where
                            det.ben_plan_id_main = main.ben_plan_id
                        and det.plan_type in ( 'TRN', 'PKG', 'UA1' )
                        and det.status in ( 'A', 'I' )
                )
            group by
                acc_id,
                plan_year,
                entrp_id
            union
            select
                listagg(plan_type, ',') within group(
                order by
                    plan_type
                ) plan_type,
                acc_id,
                plan_year,
                entrp_id
            from
                (
                    select unique
                        det.plan_type,
                        det.acc_id,
                        to_char(det.plan_end_date, 'YYYY') plan_year,
                        main.entrp_id
                    from
                        ben_plan_enrollment_setup det,
                        ben_plan_enrollment_setup main
                    where
                            det.ben_plan_id_main = main.ben_plan_id
                        and det.plan_type = 'IIR'
                        and det.status in ( 'A', 'I' )
                )
            group by
                acc_id,
                plan_year,
                entrp_id
            order by
                2
        )       a,
        account b
    where
            a.entrp_id = b.entrp_id
        and plan_year > 2010
    group by
        a.entrp_id,
        plan_year,
        plan_type,
        acc_num,
        salesrep_id
    order by
        a.entrp_id,
        plan_type,
        plan_year;


-- sqlcl_snapshot {"hash":"69af6696be1e8c55ac49d5e3af34c76d5345f9d7","type":"VIEW","name":"FSA_HRA_SALES_REPORT","schemaName":"SAMQA","sxml":""}