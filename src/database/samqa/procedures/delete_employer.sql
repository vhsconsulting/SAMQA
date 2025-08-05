create or replace procedure samqa.delete_employer is
begin
    for x in (
        select
            e.entrp_id,
            e.entrp_code,
            a.acc_id
        from
            enterprise     e,
            account        a,
            g_acc_num_list g
        where
                e.entrp_id = a.entrp_id
            and g.acc_num = a.acc_num
    ) loop
        if x.entrp_id is not null then
            delete from income
            where
                contributor = x.entrp_id;

            delete from insure
            where
                pers_id in (
                    select
                        pers_id
                    from
                        person
                    where
                        entrp_id = x.entrp_id
                );

            delete from account
            where
                pers_id in (
                    select
                        pers_id
                    from
                        person
                    where
                        entrp_id = x.entrp_id
                );

            delete from card_debit
            where
                card_id in (
                    select
                        pers_id
                    from
                        person
                    where
                        entrp_id = x.entrp_id
                );

            delete from person
            where
                entrp_id = x.entrp_id;

            delete from account
            where
                entrp_id = x.entrp_id;

            delete from ben_plan_enrollment_setup
            where
                entrp_id = x.entrp_id;

            delete from online_users
            where
                tax_id = x.entrp_code;

            delete from ar_invoice_lines
            where
                invoice_id in (
                    select
                        invoice_id
                    from
                        ar_invoice
                    where
                            entity_type = 'EMPLOYER'
                        and entity_id = x.entrp_id
                );

            delete from ar_invoice
            where
                    entity_type = 'EMPLOYER'
                and entity_id = x.entrp_id;

            delete from ar_invoice_dist_plans
            where
                entrp_id = x.entrp_id;

            delete from invoice_distribution_summary
            where
                entrp_id = x.entrp_id;

            delete from invoice_parameters
            where
                entity_id = x.entrp_id;

            delete from rate_plan_detail
            where
                rate_plan_id in (
                    select
                        rate_plan_id
                    from
                        rate_plans
                    where
                        entity_id = x.entrp_id
                );

            delete from rate_plans
            where
                entity_id = x.entrp_id;

            delete from scheduler_details
            where
                scheduler_id in (
                    select
                        scheduler_id
                    from
                        scheduler_master
                    where
                        acc_id = x.acc_id
                );

            delete from scheduler_details_stg
            where
                scheduler_id in (
                    select
                        scheduler_id
                    from
                        scheduler_master
                    where
                        acc_id = x.acc_id
                );

            delete from scheduler_stage
            where
                scheduler_id in (
                    select
                        scheduler_id
                    from
                        scheduler_master
                    where
                        acc_id = x.acc_id
                );

            delete from scheduler_master
            where
                acc_id = x.acc_id;

            delete from enterprise
            where
                entrp_id = x.entrp_id;

        end if;
    end loop;
end;
/


-- sqlcl_snapshot {"hash":"abfcd0653d835ec98bde4bce55ba71dcad3f44cc","type":"PROCEDURE","name":"DELETE_EMPLOYER","schemaName":"SAMQA","sxml":""}